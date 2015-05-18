###
This program is distributed under the terms of the MIT license.
Copyright 2012 - 2015 (c) Markus Kohlhase <mail@markus-kohlhase.de>
###

JID = require("node-xmpp-core").JID

getDefaultOpts = ->
  attributes:           {}
  methods:              {}
  required:             []
  protected:            []
  creator:              ->
  timestamp:            new Date()
  description:          new Description
  definitions:
    attributes: {}
    methods: {}

class Class

  constructor: (jid, opts={}) ->
    @jid = new JID jid
    { @attributes, @methods, @timestamp, @description,
      @definitions, @superclass, @creator, @required, @protected } = opts

    @[k] ?= v for k,v of getDefaultOpts()

    if not @creator?
      @creator = ->

    else if typeof(@creator) is "function"

      #TODO: specify types
      for c in [@creator, @creator.prototype]
        for k,v of c
          if typeof(v) isnt "function"
            @attributes[k] ?= v
            @definitions.attributes[k] ?= new AttributeDefinition
              classAttribute: (c is @creator)
              required: (k in @required)
              writable: not (k in @protected)
          else
            @methods[k] ?= v
            @definitions.methods[k] ?= new MethodDefinition
              classMethod: (c is @creator)

    for a in [@protected, @required]
      for k in a
        @definitions.attributes[k] ?= new AttributeDefinition
          classAttribute: false
          required: (k in @required)
          writable: not (k in @protected)

    if typeof(@superclass) is "string"
      @superclass = new JID @superclass

class Description

  constructor: (desc={}) ->
    @[k]=v for k,v of desc when typeof(v) is "string"

class Definition

  constructor: (opts={}) ->
    { @type, @description } = opts
    @type        ?= ""
    @description ?= new Description

class AttributeDefinition extends Definition

  constructor: (opts={}) ->
    super opts
    { @writable, @required, @classAttribute } = opts
    @writable       ?= true
    @required       ?= false
    @classAttribute ?= false

class MethodDefinition extends Definition

  constructor: (opts={}) ->
    super opts
    { @classMethod, @parameters } = opts
    @classMethod  ?= false
    @parameters   ?= {}

exports.Class               = Class
exports.Description         = Description
exports.AttributeDefinition = AttributeDefinition
exports.MethodDefinition    = MethodDefinition
exports.ParameterDefinition = Definition
