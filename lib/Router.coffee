ltx     = require "ltx"
events  = require "events"
joap    = require "./node-xmpp-joap"

JOAP_NS       = "jabber:iq:joap"
RPC_NS        = "jabber:iq:rpc"
JOAP_STANZAS  = ["describe", "read","add", "edit", "delete", "search"]

class Router extends events.EventEmitter

  constructor: (@xmpp) ->
    @xmpp.on "stanza", (iq) =>

      if iq.name is "iq"

        action = joap.parse iq.children?[0]

        if action.type?

          to              = iq.attrs.to
          action.from     = iq.attrs.from
          action.class    = to.split('@')[0]
          action.instance = to.split('/')[1]
          action.iq       = iq

          @emit action.type, action
          @emit "action", action

  sendError: (a, code, msg) ->

    err = new ltx.Element "iq",
      id: a.iq.attrs.id
      type:'error'
      to: a.iq.attrs.from
      from: a.iq.attrs.to

    if a.type isnt "rpc"
      if a.type in JOAP_STANZAS
        err.c(a.type, xmlns: JOAP_NS).up()
      err
        .c("error", code: code)
        .t(msg)
    else if a.type is "rpc"
      err
        .c("query", xmlns: RPC_NS)
        .c("methodResponse")
        .c("fault")
        .cnode(new joap.Value { faultCode: code, faultString: msg })

    @xmpp.send err

  sendResponse: (a, data) ->
    res = new ltx.Element "iq",
      id: a.iq.attrs.id
      type:'result'
      to: a.iq.attrs.from
      from: a.iq.attrs.to
    res.cnode joap.serialize(data, a)
    @xmpp.send res

exports.Router = Router
