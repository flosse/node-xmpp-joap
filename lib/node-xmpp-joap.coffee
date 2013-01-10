# This program is distributed under the terms of the MIT license.
# Copyright 2012 - 2013 (c) Markus Kohlhase <mail@markus-kohlhase.de>

exports.Router  = require "./Router"
exports.Manager = require "./Manager"

exports.object = require "./JOAPObjects"
exports.stanza = require "./stanza"

Parser = require "./Parser"

exports.Parser = Parser
exports.parse = Parser.parse
exports.isJOAPStanza = Parser.isJOAPStanza
exports.isRPCStanza  = Parser.isRPCStanza

Serializer = require "./Serializer"
exports.Serializer = Serializer
exports.serialize = Serializer.serialize

exports.uniqueId = require 'node-uuid'

class JOAPError extends Error

  constructor: (@message, @code)->
    @name = "JOAPError"

exports.Error = JOAPError

exports.XML_NS = "jabber:iq:joap"
