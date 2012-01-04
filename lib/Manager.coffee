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

  addClass: (name, creator, required=[], protected=[]) ->
    if typeof creator is "function" and not @classes[name]?
      @classes[name] = { creator:creator, required:required, protected:protected }
      @objects[name] = {}
      true
    else false

  createClass: (a) ->
    clazz = @classes[a.class]
    x = new clazz.creator a.attributes
    if not x.id or @objects[a.class][x.id]?
      x.id = joap.uniqueId()
    @objects[a.class][x.id] = x
    "#{a.class}@#{@router.xmpp.jid}/#{x.id}"

  onRead: (a) =>
    if @grant(a) and @classExists(a) and @instanceExists(a)
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
      @router.sendError a, 404, "Object '#{a.instance}' does not exits."
      false
    else true

  classExists: (a) ->
    if not @classes[a.class]?
      @router.sendError a, 404, "Class '#{a.class}' does not exits."
      false
    else true

  isClassAddress: (a) ->
    if not a.class? or a.instance?
      @router.sendError a, 405, "'#{a.iq.attrs.to}' is not a class"
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

  areWritableAttributes: (a) ->
    p = @classes[a.class].protected
    for k,v of a.attributes
      if k in p
        @router.sendError a, 406, "'#{k}' of '#{a.class}' is not a writeable attribute"
        return false
    true

exports.Manager = Manager
