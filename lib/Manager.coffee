# This program is distributed under the terms of the MIT license.
# Copyright 2012 (c) Markus Kohlhase <mail@markus-kohlhase.de>

events  = require "events"
joap    = require "node-xmpp-joap"
ltx     = require "ltx"

class Manager extends events.EventEmitter

  constructor: (@xmpp) ->

    @classes = {}
    @serverDescription={'en-US':"JOAP Server"}
    @serverAttributes = {}
    @router = new joap.Router @xmpp
    @router.on "describe", @onDescribe
    @router.on "add", @onAdd
    @router.on "read", @onRead
    @router.on "edit", @onEdit
    @router.on "delete", @onDelete
    @objects = {}

  @getArgNames: (fn) ->
    args = fn.toString().match(/function\b[^(]*\(([^)]*)\)/)[1]
    args.split /\s*,\s*/

  # override if you want to manipule the request
  before:

    add: (a, callback) -> callback null, a
    # override if you want to manipule the reading of instances
    read: (a, callback) -> callback null, a

    # override if you want to manipule the editing of instances
    edit: (a, callback) -> callback null, a

    # override if you want to manipule the deletion of instances
    delete: (a, callback) -> callback null, a

    # override if you want to manipule the description of instances
    describe: (a, callback) -> callback null, a

  # override if you want to use a database
  saveInstance: (clazz, id, obj, next) ->
    @objects[clazz][id] = obj
    next null

  # override if you want to use a database
  loadInstance: (clazz, id, next) -> next null, @objects[clazz][id]

  # override if you want to use a database
  deleteInstance: (clazz, id, next) ->
    delete @objects[clazz][id]
    next null

  # Public method to override by the main application
  hasPermission: (action) -> true

  addClass: (name, creator, required=[], protected=[], objects={}) ->
    if typeof creator is "function" and not @classes[name]?
      @classes[name] = { creator:creator, required:required, protected:protected }
      @objects[name] = objects
      true
    else false

  createInstance: (a, next) ->
    clazz = @classes[a.class]
    argNames = Manager.getArgNames clazz.creator
    x = new clazz.creator (a.attributes[n] for n in argNames when n isnt "")...
    x.id = joap.uniqueId() if not x.id
    @saveInstance a.class, x.id, x, (err) =>
      next err, "#{a.class}@#{@router.xmpp.jid}/#{x.id}"

  onRead: (a) =>
    if @grant(a) and @classExists(a)
      @instanceExists a, (err, exists) =>
        if exists and not err? and @areExistingAttributes(a)
          @before.read a, (err, a) =>
            if err?
              @sendInternalServerError a
            else
              res = {}
              @loadInstance a.class, a.instance, (err, inst) =>
                if a.limits
                  res[k] = v for k,v of inst when k in a.limits and typeof v isnt "function"
                else
                  res[k] = v for k,v of inst when typeof v isnt "function"
                @router.sendResponse a, res

  onAdd: (a) =>
    if @grant(a) and @isClassAddress(a) and @classExists(a) and @areRequiredAttributes(a)
      @before.add a, (err, a) =>
        if err?
          @sendInternalServerError a
        else
          @createInstance a, (err, address) =>
            if err?
              @sendInternalServerError a
            else
              @router.sendResponse a, address

  onEdit: (a) =>
    if @grant(a)
      @instanceExists a, (err, exists) =>
        if exists and not err? and @areWritableAttributes(a)
            @before.edit a, (err, a) =>
              if err?
                @sendInternalServerError a
              else
                @loadInstance a.class, a.instance, (err, inst) =>
                  if err?
                    @sendInternalServerError a
                  else
                    inst[k] = v for k,v of a.attributes
                    @saveInstance a.class, a.instance, inst, (err) =>
                      if err?
                        @sendInternalServerError a
                      else
                        @router.sendResponse a

  onDelete: (a) =>
    if @grant(a) and @isInstanceAddress(a)
      @instanceExists a, (err, exists) =>
        if exists and not err?
          @before.delete a, (err, a) =>
            if err?
              @sendInternalServerError a
            else
              @deleteInstance a.class, a.instance, (err) =>
                if err?
                  @sendInternalServerError a
                else
                  @router.sendResponse a

  onDescribe: (a) =>
    @before.describe a, (err, a) =>
      if err?
        @sendInternalServerError a
      else
        data = null
        if not a.class?
          data = desc: @serverDescription
          classes = (k for k,v of @classes)
          if classes.length > 0
            data.classes = classes
          data.attributes = @serverAttributes

        @router.sendResponse a, data


  grant: (a) ->
    if not @hasPermission a
      @router.sendError a, 403, "You are not authorized"
      false
    else true

  instanceExists: (a, next) ->
    @loadInstance a.class, a.instance, (err, inst) =>
      if not inst? or err?
        @router.sendError a, 404, "Object '#{a.instance}' does not exists"
        next err, false
      else next err, true

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

  sendInternalServerError: (a) ->

    err = new ltx.Element "iq",
      to:   a.iq.attrs.from
      from: a.iq.attrs.to
      id:   a.iq.attrs.id
      type: 'error'
    err.c("error", type:'cancel')
      .c("internal-server-error", xmlns:'urn:ietf:params:xml:ns:xmpp-stanzas')

    @router.send err

exports.Manager = Manager
