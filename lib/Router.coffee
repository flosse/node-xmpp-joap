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
          action.to       = to
          action.iq       = iq
          action.from     = iq.attrs.from

          if to.indexOf('@') >= 0
            action.class  = to.substr(0, to.indexOf '@')

          if to.indexOf('/') >= 0
            action.instance = to.substr(to.indexOf('/') + 1)

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
