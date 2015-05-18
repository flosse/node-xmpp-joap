###
This program is distributed under the terms of the MIT license.
Copyright 2012 - 2015 (c) Markus Kohlhase <mail@markus-kohlhase.de>
###

events  = require "events"
joap    = require "./node-xmpp-joap"
ltx     = require "ltx"
async   = require "async"

isMethod = (clz, inst, key) ->
  (typeof clz[key]   is "function") or
  (typeof clz::[key] is "function") or
  (typeof inst[key]  is "function")

class Manager extends events.EventEmitter

  constructor: (@xmpp, opt={}) ->

    { errorOnTooBusy }  = opt
    @serverDescription  = {'en-US':"JOAP Server"}
    @serverAttributes   = {}
    @serverMethods      = {}
    @classes            = {}
    @_objects           = {}
    @_handlers          = { enter: {}, leave:{} }

    @router = new joap.Router @xmpp, { errorOnTooBusy }

    @router.on "describe", @onDescribe
    @router.on "add",      @onAdd
    @router.on "read",     @onRead
    @router.on "edit",     @onEdit
    @router.on "delete",   @onDelete
    @router.on "search",   @onSearch
    @router.on "rpc",      @onRPC

  @getArgNames: (fn) ->
    args = fn.toString().match(/function\b[^(]*\(([^)]*)\)/)[1]
    args.split /\s*,\s*/

  onEnter: (action, fn) =>
    @_handlers.enter[action] ?= []
    @_handlers.enter[action].push fn

  onLeave: (action, fn) ->
    @_handlers.leave[action] ?= []
    @_handlers.leave[action].push fn

  before: (a) => @_handlers.enter[a.type] or []
  after:  (a) => @_handlers.leave[a.type] or []

  # override if you want to use a database
  saveInstance: (a, obj, next) =>
    @_objects[a.class][obj.id] = obj
    next null, a

  # override if you want to use a database
  loadInstance: (a, next) =>
    inst = @_objects[a.class]?[a.instance]
    if not inst?
      err = new joap.Error "Object '#{a.instance}' does not exists", 404
    next err, a, inst

  # override if you want to use a database
  queryInstances: (a, next) =>
    if a.attributes?
      items = []
      for id, o of @_objects[a.class]
        items.push id for k,v of a.attributes when o[k] is v
      next null, a, items
    else
      next null, a, (k for k,v of @_objects[a.class])

  # override if you want to use a database
  deleteInstance: (a, next) =>
    @loadInstance a, (err, a, inst) =>
      if err?
        next err, a
      else
        delete @_objects[a.class][a.instance]
        next null, a

  # Public method to override by the main application
  hasPermission: (a, next) -> next null, a

  addClass: (name, creator, opts={}) ->
    { required, objects, constructorAttributes } = opts
    prot = opts.protected # protected is protected in coffee-script ;-)
    objects ?= {}

    if required? and not (required instanceof Array)
      throw new Error "required attributes option has to be an array"

    if prot? and not (prot instanceof Array)
      throw new Error "protected attributes option has to be an array"

    if constructorAttributes? and not (constructorAttributes instanceof Array)
      throw new Error "constructorAttributes option has to be an array"

    clazz = new joap.object.Class "#{name}@#{@xmpp.connection.jid.toString()}",
      creator: creator
      required: required
      protected: prot
      constructorAttributes: constructorAttributes

    for k,v of clazz.prototype when typeof v is "function" and not (k in prot)
      prot.push k

    if typeof creator is "function" and not @classes[name]?
      @classes[name] = clazz
      @_objects[name] = objects
      true
    else false

  addServerMethod: (name, fn) -> @serverMethods[name] ?= fn

  createInstance: (a, next) =>
    clazz = @classes[a.class]
    a.attributes ?= {}
    args = []
    if clazz.constructorAttributes?
      args = (a.attributes[n] for n in constructorAttributes)
    else
      cArgs = Manager.getArgNames clazz.creator
      if clazz.required?
        for n,i in cArgs when (n in clazz.required) and a.attributes[n]?
          args[i] = a.attributes[n]
    x = new clazz.creator args...
    prot = clazz.protected or []
    x[k] = v for k,v of a.attributes when not (k in prot)
    # TODO: we should not assign the id to the instance
    x.id ?= joap.uniqueId()
    a.instance = x.id
    next null, a, x

  getAddress: (clazz, instance) =>
    addr = ""
    addr += "#{clazz}@" if (typeof clazz in ["string", "number"])
    addr += @router.xmpp.connection.jid
    addr += "/#{instance}" if (typeof(instance) in ["string", "number"])
    addr

  onRead: (a) =>
    async.waterfall [
      (next) -> next null, a
      @grant
      @isInstanceAddress
      @classExists
      @before(a)...
      @loadInstance
      @areExistingAttributes
      (a, inst, next) ->
        res = {}
        if a.limits?
          res[k] = v for k,v of inst when k in a.limits and typeof v isnt "function"
        else
          # Add static properties
          if inst.__proto__?.constructor?
            for k,v of inst.__proto__.constructor
              res.__static__ ?= {}
              res.__static__[k] if k.slice(0,2) isnt "__"
          res[k] = v for k,v of inst when typeof v isnt "function"
        next null, a, res
      @after(a)...
      @sendResponse
    ], (err) => @sendError err, a

  onAdd: (a) =>
    async.waterfall [
      (next) -> next null, a
      @grant
      @isClassAddress
      @classExists
      @areRequiredAttributes
      @before(a)...
      @createInstance
      @saveInstance
      (a, next) => next null, a, @getAddress(a.class, a.instance)
      @after(a)...
      @sendResponse
    ], (err) => @sendError err, a


  onEdit: (a) =>
    #TODO: Is it possible to edit the server attributes?
    async.waterfall [
      (next) -> next null, a
      @grant
      @isInstanceAddress
      @classExists
      @before(a)...
      @loadInstance
      @areWritableAttributes
      (a, inst, next) =>
        inst[k] = v for k,v of a.attributes
        if a.attributes.id?
          a.newAddress = @getAddress(a.class, inst.id)
        next null, a, inst
      @saveInstance
      (a, next) => next null, a, a.newAddress
      @after(a)...
      @sendResponse
    ], (err) => @sendError err, a

  onDelete: (a) =>
    async.waterfall [
      (next) -> next null, a
      @grant
      @isInstanceAddress
      @classExists
      @before(a)...
      @deleteInstance
      @after(a)...
      @sendResponse
    ], (err) => @sendError err, a

  onDescribe: (a) =>
    async.waterfall [
      (next) -> next null, a
      @grant
      @before(a)...
      @checkTarget
      @createDescription
      @after(a)...
      @sendResponse
    ], (err) => @sendError err, a

  onSearch: (a) =>
    async.waterfall [
      (next) -> next null, a
      @grant
      @isClassAddress
      @classExists
      @isValidSearch
      @before(a)...
      @queryInstances
      (a, items, next) =>
        addresses = (@getAddress a.class, id for id in items) if items?
        next null, a, addresses
      @after(a)...
      @sendResponse
    ], (err) => @sendError err, a

  onRPC: (a) =>
    async.waterfall [
      (next) -> next null, a
      @grant
      @before(a)...
      @checkTarget
      @execRPC
      @after(a)...
      @sendResponse
    ], (err) => @sendError err, a

  checkTarget: (a, next) =>
    err = null
    if a.instance
      a.target = "instance"
      err ?= @isInstanceAddress a
    else if a.class and not a.instance
      a.target = "class"
      err ?= @isClassAddress a
    else
      a.target = "server"
    if a.class or a.instance
      err ?= @classExists a
    next err, a

  execRPC: (a, next) =>
    switch a.target
      when "server"
        method = @serverMethods[a.method]
        if typeof method isnt "function"
          err = new joap.Error "Server method '#{a.method}' does not exist"
        else
          data = method.apply null, a.params
        next err, a, data
      when "class"
        clazz = @classes[a.class].creator
        if typeof clazz?[a.method] isnt "function"
          err = new joap.Error "Class method '#{a.method}' does not exist"
        else
          data = clazz[a.method].apply clazz, a.params
        next err, a, data
      when "instance"
        @loadInstance a, (err, a, inst) =>
          if err? or typeof inst?[a.method] isnt "function"
            err ?= new joap.Error "Instance method '#{a.method}' does not exist"
          else
            data = inst[a.method].apply inst, a.params
          next err, a, data
      else
        next (new Error), a

  createDescription: (a, next) =>
    data = null
    if not a.class?
      data = desc: @serverDescription
      data.attributes = @serverAttributes
      #TODO: Implement class descriptions
      # data.methods = @getMethodDescriptions @serverMethods
      classes = (k for k,v of @classes)
      data.classes = classes if classes.length > 0
    else err = true
    next null, a, data

    #TODO: Implement class descriptions
    # else if a.class? and not a.instance?

    #TODO: Implement object descriptions
    # else if a.class? and a.instance?

  grant: (a, next) =>
    @hasPermission a, (err, a) ->
      if err?
        msg = if err.message then ": #{err.message}" else ''
        err = new joap.Error "You are not authorized#{msg}", 403
      next err, a

  classExists: (a, next) =>
    if not @classes[a.class]?
      err = new joap.Error "Class '#{a.class}' does not exists", 404
    next? err, a
    err

  isValidSearch: (a, next) =>
    if a.attributes? and typeof a.attributes isnt "object" or a.attributes instanceof Array
      err = next new joap.Error "search filter is invalid", 405
    next err, a

  isClassAddress: (a, next) ->
    if not a.class? or a.instance?
      err = new joap.Error "'#{a.iq.attrs.to}' isn't a class", 405
    next? err, a
    err

  isInstanceAddress: (a, next) ->
    if not a.class? or not a.instance?
      err = new joap.Error "'#{a.iq.attrs.to}' is not an instance", 405
    next? err, a
    err

  areRequiredAttributes: (a, next) =>
    req = @classes[a.class].required
    if req?
      for r in req
        if not a.attributes?[r]?
          err = new joap.Error "Invalid constructor parameters", 406
          break
    next err, a

  areExistingAttributes: (a, inst, next) =>
    if a.limits?
      for l in a.limits
        if inst[l] is undefined
          err = new joap.Error "Requested attribute '#{l}' doesn't exists", 406
          break
    next err, a, inst

  areWritableAttributes: (a, inst, next) =>
    clz = @classes[a.class]
    p = clz.protected or []
    for k,v of a.attributes
      if (k in p) or isMethod clz.creator, inst, k
        err = new joap.Error "Attribute '#{k}' of class '#{a.class}' is not writeable", 406
        break
    next err, a, inst

  sendError: (err, a) =>
    if err.code or a.type is "rpc" then @router.sendError err, a
    else @sendInternalServerError err, a

  sendResponse: (a, data) => @router.sendResponse a, data

  sendInternalServerError: (err, a) ->

    iq = new ltx.Element "iq",
      to:   a.iq.attrs.from
      from: a.iq.attrs.to
      id:   a.iq.attrs.id
      type: 'error'
    iq.c("error", type:'cancel')
      .c("internal-server-error", xmlns:'urn:ietf:params:xml:ns:xmpp-stanzas')
      .t(err.message or '')

    @router.send iq

module.exports = Manager
