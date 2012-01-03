ltx     = require "ltx"
events  = require "events"
joap    = require "./node-xmpp-joap"

JOAP_NS       = "jabber:iq:joap"
RPC_NS        = "jabber:iq:rpc"
JOAP_STANZAS  = ["describe", "read","add", "edit", "delete", "search"]

class Router extends events.EventEmitter

  constructor: (@xmpp) ->
    @xmpp.on "stanza", (iq) =>

      if iq.name is "iq" and (joap.isJOAPStanza xml or joap.isRPCStanza xml)

        child    = iq.children?[0]
        to       = iq.attrs.to
        clazz    = to.split('@')[0]
        instance = to.split('/')[1]

        action = joap.parse child
        @emit action.type, action, clazz, instance, iq
        @emit "action", action, clazz, instance, iq

  sendError: (action, code, msg, iq) ->

    err = new ltx.Element "iq",
      id: iq.attrs.id
      type:'error'
      to: iq.attrs.from
      from: iq.attrs.to

    if action.type isnt "rpc"
      if action.type in JOAP_STANZAS
        err.c(action.type, xmlns: JOAP_NS).up()
      err
        .c("error", code: code)
        .t(msg)
    else if action.type is "rpc"
      err
        .c("query", xmlns: RPC_NS)
        .c("methodResponse")
        .c("fault")
        .cnode(new joap.Value { faultCode: code, faultString: msg })

    @xmpp.send err

  sendResponse: (data, iq) ->

    res = new ltx.Element "iq",
      id: iq.attrs.id
      type:'result'
      to: iq.attrs.from
      from: iq.attrs.to

    res.cnode data
    @xmpp.send res

exports.Router = Router
