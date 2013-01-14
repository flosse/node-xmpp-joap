###
This program is distributed under the terms of the MIT license.
Copyright 2012 - 2013 (c) Markus Kohlhase <mail@markus-kohlhase.de>
###

ltx  = require "ltx"
joap = require "./node-xmpp-joap"
uuid = require 'node-uuid'

createIq = (type, to, customAttrs) ->
  iqType = if (type in ["read", "search", "describe"]) then "get" else "set"
  xmlns  = if type is "query" then joap.RPC_NS else joap.JOAP_NS
  attrs  = xmlns: xmlns
  attrs[k]=v for k,v of attrs when v? if customAttrs?
  id = uuid.v4()
  (new ltx.Element "iq", to: to, type:iqType, id: id).c(type, attrs)

sendRequest = (type, to, cb, opt={}) ->
 iq = createIq type, to, opt.attrs
 opt.beforeSend? iq
 id = iq.tree().attrs.id
 @xmpp.on "stanza", (res) ->
   if res.name is "iq" and res.attrs.id is id
     err = if res.attrs.type is 'error'
       new Error iq.getChildText "error"
     else null
     cb? err, res, opt.onResult? res
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
  describe = iq.getChild("describe")
  if describe?
    for c in describe.children
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

class JOAPClient

  constructor: (@xmpp) ->
    throw new Error unless typeof @xmpp is "object"

  describe: (id, cb) ->
    sendRequest.call @, "describe", id, cb,
      onResult: parseDescription

  read: (instance, limits, cb) ->

  add: (clazz, attrs, cb) ->

  edit: (instance, attrs, cb) ->

  search: (clazz, attrs, cb) ->

module.exports = JOAPClient
