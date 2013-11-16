###
This program is distributed under the terms of the MIT license.
Copyright 2012 - 2013 (c) Markus Kohlhase <mail@markus-kohlhase.de>
###

ltx     = require "ltx"
joap    = require "./node-xmpp-joap"

JOAP_NS       = "jabber:iq:joap"
RPC_NS        = "jabber:iq:rpc"
JOAP_STANZAS  = ["describe", "read","add", "edit", "delete", "search"]

class Parser

  @hasJOAPNS: (xml) -> xml.attrs?.xmlns is JOAP_NS

  @hasRPCNS: (xml) -> xml.attrs?.xmlns is RPC_NS

  @getType: (xml) ->
    if @hasJOAPNS xml then xml.getName().toLowerCase()
    else if Parser.isRPCStanza xml then "rpc"

  @isCustomJOAPAction: (name) -> not (name in JOAP_STANZAS)

  @isJOAPStanza: (xml) -> not @isCustomJOAPAction(xml.name) and @hasJOAPNS xml

  @isRPCStanza: (xml) ->
    (xml.name is "query" and @hasRPCNS xml)

  @parse: (xml) ->

    if typeof xml in ["string", "number", "boolean"] then xml

    else if xml instanceof Array
      (Parser.parse c for c in xml)

    else if typeof xml is "object"

      if Parser.hasJOAPNS xml
        action = type: Parser.getType xml
        attrs = {}

        a = xml.getChildren "attribute"
        if a.length > 0
          attrs[c.name] = c.value for c in Parser.parse a
          action.attributes = attrs
        n = xml.getChildren "name"
        action.limits = Parser.parse(n) if n.length > 0
        action
      else if Parser.isRPCStanza xml
        call = xml.getChild "methodCall"
        o =
          type: Parser.getType xml
          method: call.getChildText "methodName"
        v = Parser.parse call.getChild "params"
        o.params = v if v?
        o

      else

        child = xml.children?[0]

        switch xml.getName()
          when "string", "name"
            child
          when "i4", "int", "double"
            child * 1
          when "boolean"
            (child is "true" or child is "1")
          when "value"
            Parser.parse child
          when "struct"
            struct = {}
            members = (Parser.parse m for m in xml.getChildren "member")
            struct[m.name] = m.value for m in members
            struct
          when "array"
            Parser.parse xml.getChild "data"
          when "params"
            (Parser.parse c.getChild "value" for c in xml.getChildren "param")
          when "data"
            data = []
            for d in xml.getChildren "value"
              data.push Parser.parse d
            data
          when "member", "attribute"
            {
              name: xml.getChildText "name"
              value: Parser.parse xml.getChild "value"
            }

module.exports = Parser
