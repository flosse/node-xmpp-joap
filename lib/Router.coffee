ltx     = require "ltx"
events  = require "events"

JOAP_NS = "jabber:iq:joap"
RPC_NS  = "jabber:iq:rpc"

class Router extends events.EventEmitter

  constructor: (@xmpp) ->
    @xmpp.on "stanza", (iq) =>

      if iq.name is "iq"

        child    = iq.children[0]
        to       = iq.attrs.to
        clazz    = to.split('@')[0]
        instance = to.split('/')[1]

        if child.attrs?.xmlns is JOAP_NS
          @emit child.name.toLowerCase(), iq, clazz, instance
        else if child.attrs?.xmlns is RPC_NS
          @emit "rpc", iq, clazz, instance

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

exports.Router = Router
