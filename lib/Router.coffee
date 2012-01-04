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
    @xmpp.send new joap.ErrorIq a.type, code, msg,
      to:   a.iq.attrs.from
      from: a.iq.attrs.to
      id:   a.iq.attrs.id

  sendResponse: (a, data) ->
    res = new ltx.Element "iq",
      to: a.iq.attrs.from
      from: a.iq.attrs.to
      id: a.iq.attrs.id
      type:'result'
    res.cnode joap.serialize(data, a)
    @xmpp.send res

exports.Router = Router
