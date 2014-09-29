###
This program is distributed under the terms of the MIT license.
Copyright 2012 - 2014 (c) Markus Kohlhase <mail@markus-kohlhase.de>
###

ltx     = require "ltx"
events  = require "events"
JID     = require("node-xmpp").JID
joap    = require "./node-xmpp-joap"
toobusy = require "toobusy"

class Router extends events.EventEmitter

  constructor: (@xmpp,opt={}) ->

    @xmpp.on "stanza", (iq) =>

      if iq?.name is "iq" and iq.attrs?.type in ["set","get"]

        action    = joap.parse iq.children?[0]

        return unless action?

        action.iq = iq

        try
          from = new JID iq.attrs.from
          to   = new JID iq.attrs.to
        catch e
          console.error "invalid JIDs in IQ stanza"
          @sendError (new Error "invalid 'to' attribute in IQ stanza"), action

        if opt.errorOnTooBusy and toobusy()
          msg = "server is too busy"
          @sendError (new Error msg), action
          console.warn msg
          return

        if action.type? and to? and from?

          action.to       = to
          action.from     = from
          action.class    = to.user
          action.instance = to.resource

          if typeof action.type is "string" and action.type.trim() isnt ""
            @emit action.type, action
            @emit "action", action

  sendError: (err, a) ->
    return console.error "no 'from' attribute found" unless a.iq.attrs.from?
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
