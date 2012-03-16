# This program is distributed under the terms of the MIT license.
# Copyright 2012 (c) Markus Kohlhase <mail@markus-kohlhase.de>

exports.Router  = require("./Router").Router
exports.Manager = require("./Manager").Manager

exports.object = require "./JOAPObjects"
exports.stanza = require "./stanza"

Parser = require("./Parser").Parser

exports.Parser = Parser
exports.parse = Parser.parse
exports.isJOAPStanza = Parser.isJOAPStanza
exports.isRPCStanza  = Parser.isRPCStanza

Serializer = require("./Serializer").Serializer
exports.Serializer = Serializer
exports.serialize = Serializer.serialize

exports.uniqueId = (length=8) ->
 id = ""
 id += Math.random().toString(36).substr(2) while id.length < length
 id.substr 0, length

class JOAPError extends Error

  constructor: (@message, @code)->
    @name = "JOAPError"

exports.Error = JOAPError
