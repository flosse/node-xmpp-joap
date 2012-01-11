# This program is distributed under the terms of the MIT license.
# Copyright 2012 (c) Markus Kohlhase <mail@markus-kohlhase.de>

ltx     = require "ltx"
events  = require "events"
JID     = require("node-xmpp").JID
joap    = require "./node-xmpp-joap"

class Router extends events.EventEmitter

  constructor: (@xmpp) ->

    @xmpp.on "stanza", (iq) =>

      if iq.name is "iq"

        action = joap.parse iq.children?[0]

        to = new JID iq.attrs.to

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
            @sendError (new joap.Error "stanza #{action.type} is not supported", 406), action

  sendError: (err, a) ->
    @send new joap.ErrorIq a.type, err.code, err.message,
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

  send: (stanza) -> @xmpp.send stanza

exports.Router = Router
