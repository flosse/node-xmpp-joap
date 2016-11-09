###
This program is distributed under the terms of the MIT license.
Copyright 2012 - 2016 (c) Markus Kohlhase <mail@markus-kohlhase.de>
###

Router = require "./Router"
async  = require "async"

TYPES  = [
  'add'
  'read'
  'edit'
  'delete'
  'describe'
  'search'
  'rpc'
]

class Response

  constructor: (@req, @app) ->

  end:   (data=@data) -> @app.router.sendResponse @req, data
  error: (err) -> @app.router.sendError err, @req

class Application

  constructor: (@xmpp, opt={}) ->
    unless @xmpp?.connection?.jid?
      throw new Error "invalid XMPP Component"
    { errorOnTooBusy } = opt
    @router = new Router @xmpp, { errorOnTooBusy }
    @plugins = { use:[] }
    @router.on "action", (req) =>
      res = new Response req, @
      async.applyEachSeries @plugins.use, req, res, (err) =>
        return console.error err if err
        if (fns = @plugins[req.type])?
          async.applyEachSeries fns, req, res, (err) ->
            return console.error err if err

  use: (fn, type) ->
    return unless typeof fn is 'function'
    if type then return unless type in TYPES
    else type = 'use'
    @plugins[type] ?= []
    @plugins[type].push fn

  add: (fn) -> @use fn, 'add'

module.exports = Application
