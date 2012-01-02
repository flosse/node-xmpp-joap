ltx     = require "ltx"
events  = require "events"

JOAP_NS       = "jabber:iq:joap"
RPC_NS        = "jabber:iq:rpc"
JOAP_STANZAS  = ["describe", "read","add", "edit", "delete", "search"]

class Router extends events.EventEmitter

  constructor: (@xmpp) ->
    @xmpp.on "stanza", (iq) =>

      if iq.name is "iq" and (Router.isJOAPStanza xml or Router.isRPCStanza xml)

        child    = iq.children?[0]
        to       = iq.attrs.to
        clazz    = to.split('@')[0]
        instance = to.split('/')[1]

        action = Router.parse child
        @emit action.type, action, clazz, instance, iq
        @emit "action", action, clazz, instance, iq

  sendError: (action, code, msg, iq) ->

    err = new ltx.Element "iq",
      id: iq.attrs.id
      type:'error'
      to: iq.attrs.from
      from: iq.attrs.to

    err
      .c(action, xmlns: JOAP_NS).up()
      .c("error", code: code)
      .t(msg)

    @xmpp.send err

  @getType: (xml) ->
    if Router.isJOAPStanza xml then xml.getName().toLowerCase()
    else if Router.isRPCStanza  xml then "rpc"

  @isJOAPStanza: (xml) ->
    (xml.name in JOAP_STANZAS and xml.attrs?.xmlns is JOAP_NS)

  @isRPCStanza: (xml) ->
    (xml.name is "query" and xml.attrs?.xmlns is RPC_NS)

  @parse: (xml) ->

    if typeof xml in ["string", "number", "boolean"] then xml

    else if xml instanceof Array
      (Router.parse c for c in xml)

    else if xml instanceof ltx.Element

      if Router.isJOAPStanza xml
        action = {
          type: Router.getType xml
        }
        attrs = {}

        a = xml.getChildren "attribute"
        if a.length > 0
          attrs[c.name] = c.value for c in Router.parse a
          action.attributes = attrs
        n = xml.getChildren "name"
        action.limits = Router.parse(n) if n.length > 0
        action
      else if Router.isRPCStanza xml
        call = xml.getChild "methodCall"
        {
          type: Router.getType xml
          method: call.getChildText "methodName"
          params: Router.parse call.getChild "params"
        }
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
            Router.parse child
          when "struct"
            struct = {}
            members = (Router.parse m for m in xml.getChildren "member")
            struct[m.name] = m.value for m in members
            struct
          when "array"
            Router.parse xml.getChild "data"
          when "params"
            (Router.parse c.getChild "value" for c in xml.getChildren "param")
          when "data"
            data = []
            for d in xml.getChildren "value"
              data.push Router.parse d
            data
          when "member", "attribute"
            {
              name: xml.getChildText "name"
              value: Router.parse xml.getChild "value"
            }

  @serialize: (val) ->

    switch typeof val

      when "string"
        (new ltx.Element "string").t(val)

      when "number"
        if val % 1 is 0
          (new ltx.Element "i4").t(val.toString())
        else
          (new ltx.Element "double").t(val.toString())

      when "boolean"
        (new ltx.Element "boolean").t(if val is true then "1" else "0")

      when "object"
        if val instanceof Array
          vals = (Router.serialize v for v in val)
          el = (new ltx.Element "array").c("data")
          for v in vals
            el.c("value").cnode(v).up()#+.up()
          el.tree()
        else
          struct = new ltx.Element "struct"
          for own k,v of val
            struct.c("member").c("name").t(k.toString())
              .up().c("value").cnode(Router.serialize v)
          struct.tree()

exports.Router = Router
