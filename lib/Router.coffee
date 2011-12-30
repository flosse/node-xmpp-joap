ltx     = require "ltx"
events  = require "events"

JOAP_NS = "jabber:iq:joap"
RPC_NS  = "jabber:iq:rpc"

class Router extends events.EventEmitter

  constructor: (@xmpp)->
    xmpp.on "stanza", (iq)=>

      if iq.name is "iq"

        child = iq.children[0]

        if child.attrs?.xmlns is JOAP_NS
          @emit child.name.toLowerCase(), iq
        else if child.attrs?.xmlns is RPC_NS
          @emit "rpc", iq

exports.Router = Router
