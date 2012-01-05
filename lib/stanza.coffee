# This program is distributed under the terms of the MIT license.
# Copyright 2012 (c) Markus Kohlhase <mail@markus-kohlhase.de>

ltx     = require "ltx"
joap    = require "./node-xmpp-joap"
JOAP_NS = "jabber:iq:joap"
RPC_NS  = "jabber:iq:rpc"

class KeyVal extends ltx.Element
  constructor: (name, key, value) ->
    super name
    @c("name")
      .t(key.toString()).up()
    .cnode(new Value value).up().up()

class Attribute extends KeyVal

  constructor: (key, value) ->
    super "attribute", key, value

class AttributeDescription extends ltx.Element

  constructor: (name, type, writable=true, desc) ->
    super "attributeDescription", {writable: writable.toString()}
    @c("name")
      .t(name.toString()).up()
    .c("type").t(type).up()
    if desc?
      @cnode(new Description v, k) for k,v of desc

class Description extends ltx.Element

  constructor: (text="", lang="en-US") ->
    super "desc", "xml:lang": lang
    @t(text)

class Member extends KeyVal

  constructor: (key, value) ->
    super "member", key, value

class Struct extends ltx.Element
  constructor: (obj) ->
    super "struct"
    for own k,v of obj
      @cnode(new Member k,v).up()

class Array extends ltx.Element
  constructor: (arr) ->
    super "array"
    data = @c "data"
    for v in arr
      data.cnode(new Value v)

class Value extends ltx.Element
  constructor: (val) ->
    super "value"
    @cnode(joap.serialize val)

class ErrorIq extends ltx.Element
  constructor: (type, code, msg, attrs) ->
    super "iq", attrs
    @attrs.type = 'error'

    if type isnt "rpc"
      @c(type, xmlns: JOAP_NS).up()
      @cnode new Error code, msg

    else if type is "rpc"
      @c("query", xmlns: RPC_NS)
      @c("methodResponse")
      @c("fault")
      @cnode(new Value { faultCode: code, faultString: msg })

class Error extends ltx.Element
  constructor: (code, msg) ->
    super "error", {code:code}
    @t msg

exports.Attribute = Attribute
exports.AttributeDescription = AttributeDescription
exports.Description = Description
exports.Member = Member
exports.Struct = Struct
exports.Array = Array
exports.Value = Value
exports.ErrorIq = ErrorIq
