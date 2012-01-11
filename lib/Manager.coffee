# This program is distributed under the terms of the MIT license.
# Copyright 2012 (c) Markus Kohlhase <mail@markus-kohlhase.de>

events  = require "events"
joap    = require "node-xmpp-joap"
ltx     = require "ltx"
async   = require "async"

class Manager extends events.EventEmitter

  constructor: (@xmpp, opts) ->

    @classes = {}
    @serverDescription={'en-US':"JOAP Server"}
    @serverAttributes = {}
    @serverMethods = {}
    @router = new joap.Router @xmpp, opts
    @router.on "describe", @onDescribe
    @router.on "add",      @onAdd
    @router.on "read",     @onRead
    @router.on "edit",     @onEdit
    @router.on "delete",   @onDelete
    @router.on "search",   @onSearch
    @objects = {}

  @getArgNames: (fn) ->
    args = fn.toString().match(/function\b[^(]*\(([^)]*)\)/)[1]
    args.split /\s*,\s*/

  # override if you want to manipule the request
  before:

    add: (a, next) -> next null, a
    # override if you want to manipule the reading of instances
    read: (a, next) -> next null, a

    # override if you want to manipule the editing of instances
    edit: (a, next) -> next null, a

    # override if you want to manipule the deletion of instances
    delete: (a, next) -> next null, a

    # override if you want to manipule the description of instances
    describe: (a, next) -> next null, a

    # override if you want to manipule the search of instances
    search: (a, next) -> next null, a

  # override if you want to use a database
  saveInstance: (a, obj, next) =>
    @objects[a.class][obj.id] = obj
    next null, a

  # override if you want to use a database
  loadInstance: (a, next) =>
    inst = @objects[a.class][a.instance]
    if not inst?
      err = new joap.Error "Object '#{a.instance}' does not exists", 404
    next err, a, inst

  # override if you want to use a database
  queryInstances: (a, next) ->
    if a.attributes?
      items = []
      for id, o of @objects[a.class]
        items.push id for k,v of a.attributes when o[k] is v
      next null, a, items
    else
      next null, a, (k for k,v of @objects[a.class])

  # override if you want to use a database
  deleteInstance: (a, inst, next) =>
    delete @objects[a.class][a.instance]
    next null, a

  # Public method to override by the main application
  hasPermission: (a, next) -> next null, a

  addClass: (name, creator, required=[], protected=[], objects={}) ->
    if typeof creator is "function" and not @classes[name]?
      @classes[name] = { creator:creator, required:required, protected:protected }
      @objects[name] = objects
      true
    else false

  createInstance: (a, next) =>
    clazz = @classes[a.class]
    argNames = Manager.getArgNames clazz.creator
    x = new clazz.creator (a.attributes[n] for n in argNames when n isnt "")...
    x.id = joap.uniqueId() if not x.id
    a.instance = x.id
    next null, a, x

  getAddress: (a, next) =>
    addr = ""
    addr += "#{a.class}@" if (typeof a.class in ["string", "number"])
    addr += @router.xmpp.jid
    addr += "/#{a.instance}" if (typeof(a.instance) in ["string", "number"])
    next null, a, addr

  onRead: (a) =>
    async.waterfall [
      (next) -> next null, a
      @grant
      @isInstanceAddress
      @classExists
      @before.read
      @loadInstance
      @areExistingAttributes
      (a, inst, next) ->
        res = {}
        if a.limits?
          res[k] = v for k,v of inst when k in a.limits and typeof v isnt "function"
        else
          res[k] = v for k,v of inst when typeof v isnt "function"
        next null, a, res
      @sendResponse
    ], (err) => @sendError err, a

  onAdd: (a) =>
    async.waterfall [
      (next) -> next null, a
      @grant
      @isClassAddress
      @classExists
      @areRequiredAttributes
      @before.add
      @createInstance
      @saveInstance
      @getAddress
      @sendResponse
    ], (err) => @sendError err, a


  onEdit: (a) =>
    #TODO: Is it possible to edit the server attributes?
    async.waterfall [
      (next) -> next null, a
      @grant
      @isInstanceAddress
      @classExists
      @before.edit
      @areWritableAttributes
      @loadInstance
      (a, inst, next) ->
        inst[k] = v for k,v of a.attributes
        next null, a, inst
      @saveInstance
      @sendResponse
    ], (err) => @sendError err, a

  onDelete: (a) =>
    async.waterfall [
      (next) -> next null, a
      @grant
      @isInstanceAddress
      @classExists
      @before.delete
      @loadInstance
      @deleteInstance
      @sendResponse
    ], (err) => @sendError err, a

  onDescribe: (a) =>
    async.waterfall [
      (next) -> next null, a
      @grant
      @before.describe
      @createDescription
      @sendResponse
    ], (err) => @sendError err, a

  onSearch: (a) =>
    async.waterfall [
      (next) -> next null, a
      @grant
      @isClassAddress
      @classExists
      @before.search
      @queryInstances
      (a, items, next) -> next null, a, ((@getAddress a.class, id for id in items) if items?)
      @sendResponse
    ], (err) => @sendError err, a

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
    next err, a

  isClassAddress: (a, next) ->
    if not a.class? or a.instance?
      err = new joap.Error "'#{a.iq.attrs.to}' isn't a class", 405
    next err, a

  isInstanceAddress: (a, next) ->
    if not a.class? or not a.instance?
      err = new joap.Error "'#{a.iq.attrs.to}' is not an instance", 405
    next err, a

  areRequiredAttributes: (a, next) =>
    for r in @classes[a.class].required
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

  areWritableAttributes: (a, next) =>
    p = @classes[a.class].protected
    for k,v of a.attributes
      if k in p
        err = new joap.Error "Attribute '#{k}' of class '#{a.class}' is not writeable", 406
        break
    next err, a

  sendError: (err, a) =>
    if err.code then @router.sendError err, a
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

exports.Manager = Manager
