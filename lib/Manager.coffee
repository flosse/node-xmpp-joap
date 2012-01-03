events  = require "events"
joap    = require "node-xmpp-joap"

YOUR_NOT_AUTH = "You are not authorized"

class Manager extends events.EventEmitter

  constructor: (@xmpp) ->
    @classes = {}
    @objects = {}
    @router = new joap.Router @xmpp
    @router.on "add", @onAdd
    @router.on "read", @onRead

  hasPermission: (jid, action, clazz) -> true

  addClass: (name, creator, required=[], notWritable=[]) ->
    if typeof creator is "function" and not @classes[name]?
      @classes[name] = {creator:creator, required:required, notWritable:notWritable}
      @objects[name] = {}
      true
    else false

  create: (clazzName, params) ->
    clazz = @classes[clazzName]
    if clazz?
      for r in clazz.required
        return false if not params[r]?
      x = new clazz.creator params
      if not x.id or @objects[clazzName][x.id]?
        x.id = joap.uniqueId()
      @objects[clazzName][x.id] = x
      "#{clazzName}@#{@router.xmpp.jid}/#{x.id}"
    else false

  onRead: (action, clazz, instance, iq) =>

    if not @hasPermission iq.attrs.from, action.type, clazz
      @router.sendError action, 403, "#{YOUR_NOT_AUTH} to read", iq

    else if not clazz? or not instance? or not @objects[clazz][instance]?
      @router.sendError action, 404, "The object adressed does not exist", iq

    else if @objects[clazz][instance]?

      res = {}
      inst = @objects[clazz][instance]

      if action.limits
        res[k] = v for k,v of inst when k in action.limits and typeof v isnt "function"
      else
        res[k] = v for k,v of inst when typeof v isnt "function"
      @router.sendResponse joap.serialize(res, action), iq

  onAdd: (action, clazz, instance, iq) =>

    if not @hasPermission iq.attrs.from, action.type, clazz
      @router.sendError action, 403, "#{YOUR_NOT_AUTH} to create an instance of the class #{clazz}", iq

    else if not clazz? or instance?
      @router.sendError action, 405, "#{iq.attrs.to} is not a class", iq

    else if not @classes[clazz]?
      @router.sendError action, 404, "The class '#{clazz}' does not exist.", iq

    else
      address = @create clazz, action.attributes
      if address is false
        @router.sendError action, 406, "Invalid constructor parameters", iq
      else
        @router.sendResponse joap.serialize(address, action), iq

exports.Manager = Manager
