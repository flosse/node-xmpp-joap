# This program is distributed under the terms of the MIT license.
# Copyright 2012 (c) Markus Kohlhase <mail@markus-kohlhase.de>

ltx     = require "ltx"
events  = require "events"
JID     = require("node-xmpp").JID
joap    = require "./node-xmpp-joap"

class Router extends events.EventEmitter

  constructor: (@xmpp, opts={}) ->

    @xmpp.on "stanza", (iq) =>

      to = new JID iq.attrs.to
      go = not (opts.checkAddress and to.domain isnt @xmpp.jid.domain)

      if iq.name is "iq" and go

        action = joap.parse iq.children?[0]

        if action?.type?

          action.to       = to
          action.iq       = iq
          action.from     = new JID iq.attrs.from
          action.class    = to.user
          action.instance = to.resource

          if typeof action.type is "string" and action.type.trim() isnt ""
            @emit action.type, action
            @emit "action", action
          else
            @sendError action, 406, "stanza #{action.type} is not supported"

  sendError: (a, code, msg) ->
    @send new joap.ErrorIq a.type, code, msg,
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
    @send res

  send: (stanza) => @xmpp.send stanza

exports.Router = Router
