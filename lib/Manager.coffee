events  = require "events"
joap    = require "node-xmpp-joap"

class Manager extends events.EventEmitter

  constructor: (@xmpp) ->
    @classes = {}
    @objects = {}
    @router = new joap.Router @xmpp
    @router.on "add", @onAdd
    @router.on "read", @onRead
    @router.on "edit", @onEdit
    @router.on "delete", @onDelete

  @getArgNames: (fn) ->
    args = fn.toString().match(/function\b[^(]*\(([^)]*)\)/)[1]
    args.split /\s*,\s*/

  addClass: (name, creator, required=[], protected=[]) ->
    if typeof creator is "function" and not @classes[name]?
      @classes[name] = { creator:creator, required:required, protected:protected }
      @objects[name] = {}
      true
    else false

  createClass: (a) ->
    clazz = @classes[a.class]
    argNames = Manager.getArgNames clazz.creator
    x = new clazz.creator (a.attributes[n] for n in argNames when n isnt "")...
    if not x.id or @objects[a.class][x.id]?
      x.id = joap.uniqueId()
    @objects[a.class][x.id] = x
    "#{a.class}@#{@router.xmpp.jid}/#{x.id}"

  onRead: (a) =>
    if @grant(a) and @classExists(a) and @instanceExists(a) and @areExistingAttributes(a)
      res = {}
      inst = @objects[a.class][a.instance]
      if a.limits
        res[k] = v for k,v of inst when k in a.limits and typeof v isnt "function"
      else
        res[k] = v for k,v of inst when typeof v isnt "function"
      @router.sendResponse a, res

  onAdd: (a) =>
    if @grant(a) and @isClassAddress(a) and @classExists(a) and @areRequiredAttributes(a)
      @router.sendResponse a, @createClass(a)

  onEdit: (a) =>
    if @grant(a) and @instanceExists(a) and @areWritableAttributes(a)
      inst = @objects[a.class][a.instance]
      inst[k] = v for k,v of a.attributes
      @router.sendResponse a

  onDelete: (a) =>
    if @grant(a) and @isInstanceAddress(a) and @instanceExists(a)
      delete @objects[a.class][a.instance]
      @router.sendResponse a

  # Public method to override by the main application
  hasPermission: (action) -> true

  grant: (a) ->
    if not @hasPermission a
      @router.sendError a, 403, "You are not authorized"
      false
    else true

  instanceExists: (a) ->
    if not @objects[a.class]?[a.instance]?
      @router.sendError a, 404, "Object '#{a.instance}' does not exists"
      false
    else true

  classExists: (a) ->
    if not @classes[a.class]?
      @router.sendError a, 404, "Class '#{a.class}' does not exists"
      false
    else true

  isClassAddress: (a) ->
    if not a.class? or a.instance?
      @router.sendError a, 405, "'#{a.iq.attrs.to}' isn't a class"
      false
    else true

  isInstanceAddress: (a) ->
    if not a.class? or not a.instance?
      @router.sendError a, 405, "'#{a.iq.attrs.to}' is not an instance"
      false
    else true

  areRequiredAttributes: (a) ->
    for r in @classes[a.class].required
      if not a.attributes?[r]?
        @router.sendError a, 406, "Invalid constructor parameters"
        return false
    true

  areExistingAttributes: (a) ->
    if a.limits?
      inst = @objects[a.class][a.instance]
      for l in a.limits
        if inst[l] is undefined
          @router.sendError a, 406, "Requested attribute '#{l}' doesn't exists"
          return false
    true
  areWritableAttributes: (a) ->
    p = @classes[a.class].protected
    for k,v of a.attributes
      if k in p
        @router.sendError a, 406, "Attribute '#{k}' of class '#{a.class}' is not writeable"
        return false
    true

exports.Manager = Manager
