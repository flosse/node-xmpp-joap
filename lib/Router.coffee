###
This program is distributed under the terms of the MIT license.
Copyright 2012 - 2013 (c) Markus Kohlhase <mail@markus-kohlhase.de>
###

ltx     = require "ltx"
events  = require "events"
JID     = require("node-xmpp").JID
joap    = require "./node-xmpp-joap"

class Router extends events.EventEmitter

  constructor: (@xmpp) ->

    @xmpp.on "stanza", (iq) =>

      if iq.name is "iq"

        action = joap.parse iq.children?[0]

        try
          from = new JID iq.attrs.from
          to   = new JID iq.attrs.to
        catch e
          console.error "invalid JIDs in IQ stanza"
          if iq.attrs.from?
            action.from = iq.attrs.from
            action.iq   = iq
            @sendError (new Error "invalid 'to' attribute in IQ stanza"), action

        if action?.type? and to? and from?

          action.to       = to
          action.iq       = iq
          action.from     = from
          action.class    = to.user
          action.instance = to.resource

          if typeof action.type is "string" and action.type.trim() isnt ""
            @emit action.type, action
            @emit "action", action

  sendError: (err, a) ->
    @send new joap.stanza.ErrorIq a.type, err.code, err.message,
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

module.exports = Router
