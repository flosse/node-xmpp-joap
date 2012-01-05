# This program is distributed under the terms of the MIT license.
# Copyright 2012 (c) Markus Kohlhase <mail@markus-kohlhase.de>

ltx     = require "ltx"
events  = require "events"
joap    = require "./node-xmpp-joap"

class Router extends events.EventEmitter

  constructor: (@xmpp) ->
    @xmpp.on "stanza", (iq) =>

      if iq.name is "iq"

        action = joap.parse iq.children?[0]

        if action?.type?

          to              = iq.attrs.to
          action.iq       = iq
          action.from     = iq.attrs.from

          if to.indexOf('@') >= 0
            action.class  = to.substr(0, to.indexOf '@')

          if to.indexOf('/') >= 0
            action.instance = to.substr(to.indexOf('/') + 1)

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
