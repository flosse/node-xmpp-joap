###
This program is distributed under the terms of the MIT license.
Copyright 2012 - 2016 (c) Markus Kohlhase <mail@markus-kohlhase.de>
###

ltx  = require "ltx"
joap = require "./node-xmpp-joap"
uuid = require 'node-uuid'
JID  = require('node-xmpp-core').JID

createIq = (type, to, customAttrs) ->
  iqType = if (type in ["read", "search", "describe"]) then "get" else "set"
  xmlns  = if type is "query" then joap.RPC_NS else joap.JOAP_NS
  attrs  = xmlns: xmlns
  attrs[k]=v for k,v of attrs when v? if customAttrs?
  id = uuid.v4()
  (new ltx.Element "iq",
    to: to.toString()
    from: @xmpp.connection.jid.toString()
    type:iqType
    id: id
  ).c(type, attrs)

getError = (res) ->
  if res.attrs.type isnt 'error' then null
  else
    tag = res.getChild "error"
    errMsg =
      if tag? then "#{tag.text()}, Error Code: #{tag.attrs.code} "
      else "unknown error"
    new Error errMsg

sendRequest = (type, to, cb, opt={}) ->
  iq = createIq.call @, type, to, opt.attrs
  opt.beforeSend? iq
  id = iq.tree().attrs.id
  resultListener = (res) =>
    if  res.name        is "iq"                and
        res.attrs?.type in ['result', 'error'] and
        res.attrs.id    is id

      cb? getError(res), res, (if not err? then opt.onResult? res.getChild type)
      @xmpp.removeListener "stanza", resultListener

  @xmpp.on "stanza", resultListener
  @xmpp.send iq

parseAttributeDescription = (d) ->
  name: d.getChild("name")?.text()
  type: d.getChild("type")?.text()
  desc: parseDesc d.getChildren("desc")

parseMethodDescription = (d) ->
  name: d.getChild("name")?.text()
  returnType: d.getChild("returnType")?.text()
  desc: parseDesc d.getChildren("desc")

parseDesc = (desc) ->
  res = {}
  for c in desc
    res[c.attrs["xml:lang"]] = c.text()
  res

parseDescription = (iq) ->
  result = desc: {}, attributes: {}, methods: {}, classes: []
  if iq?
    for c in iq.children
      switch c.name.toLowerCase()
        when "desc"
          result.desc[c.attrs["xml:lang"]] = c.text()
        when "attributedescription"
          ad = parseAttributeDescription c
          result.attributes[ad.name] = ad
        when "methoddescription"
          md = parseMethodDescription c
          result.methods[md.name] = md
        when "superclass"
          result.superclass = new JID(c.text).toString()
        when "timestamp"
          result.timestamp = c.text()
        when "class"
          classes.push = c.text()
  result

addXMLAttributes = (iq, attrs) ->
  return if not attrs?
  if attrs instanceof Array
    return console.warn "Attribute parameter is not an object"
  else if typeof attrs is "object"
    for k,v of attrs
      iq.c("attribute")
        .c("name").t(k).up()
        .c("value").cnode(joap.Serializer.serialize v).up().up()

parseNewAddress = (iq) ->
  a = iq.getChild("newAddress")
  if a? then  new JID(a.text()).toString()
  else undefined

parseAttributes = (iq) ->
  attrs = iq.getChildren("attribute")
  data = {}
  for a in attrs
    key = a.getChild("name").text()
    data[key] = joap.Parser.parse a.getChild("value")
  data

parseSearch = (iq) ->
  items = iq.getChildren("item")
  (new JID(i.text()).toString() for i in items)

addRPCElements = (iq, method, params=[]) ->
  throw new TypeError unless typeof method is "string"
  ref = iq.c("methodCall").c("methodName").t(method).up()
  if not (params instanceof Array)
    console?.warn? "No parameters added: parameter is not an array"
    return
  if params.length > 0
    ref = ref.c("params")
    for p in params
      ref.c("param").c("value")
        .cnode(joap.Serializer.serialize p).up().up()

parseRPCParams = (iq) ->
  if iq.tree().attrs.type is "result"
    v = iq.getChild("methodResponse")?.
      getChild("params")?.
      getChild("param")?.
      getChild("value")

    if v?
      joap.Parser.parse v

  else if iq.tree().attrs.type is "error"
    v = iq.getChild("methodResponse")?.
      getChild("fault")?.
      getChild("value")

    if v?
      joap.Parser.parse v

class JOAPClient

  constructor: (@xmpp) ->
    throw new Error unless typeof @xmpp is "object"

  describe: (id, cb) ->
    sendRequest.call @, "describe", id, cb,
      onResult: parseDescription

  read: (instance, limits, cb) ->
    if typeof limits is "function"
      cb = limits; limits = null
    sendRequest.call @, "read", instance, cb,
      beforeSend: (iq) -> if limits instanceof Array
        iq.c("name").t(l).up() for l in limits
      onResult: parseAttributes

  add: (clazz, attrs, cb) ->
    if typeof attrs is "function"
      cb = attrs; attrs=null
    sendRequest.call @, "add", clazz, cb,
      beforeSend: (iq) -> addXMLAttributes iq, attrs
      onResult: parseNewAddress

  edit: (instance, attrs, cb) ->
    sendRequest.call @, "edit", instance, cb,
      beforeSend: (iq) -> addXMLAttributes iq, attrs
      onResult: parseNewAddress

  delete: (instance, cb) ->
    sendRequest.call @, "delete", instance, cb

  search: (clazz, attrs, cb) ->
    if typeof attrs is "function"
      cb = attrs; attrs=null
    sendRequest.call @, "search", clazz, cb,
      beforeSend: (iq) -> addXMLAttributes iq, attrs
      onResult: parseSearch

  methodCall: (method, address, params, cb) ->
    sendRequest.call @, "query", address, cb,
      beforeSend: (iq) -> addRPCElements iq, method, params
      onResult: parseRPCParams

module.exports = JOAPClient
