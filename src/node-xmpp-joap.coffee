###
This program is distributed under the terms of the MIT license.
Copyright 2012 - 2016 (c) Markus Kohlhase <mail@markus-kohlhase.de>
###

uuid = require 'node-uuid'

exports.Router  = require "./Router"
exports.Manager = require "./Manager"
exports.Client  = require "./Client"

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

exports.uniqueId = -> uuid.v4()

class JOAPError extends Error

  constructor: (@message, @code)->
    @name = "JOAPError"

exports.Error = JOAPError

JOAP_NS = "jabber:iq:joap"
RPC_NS  = "jabber:iq:rpc"

exports.JOAP_NS = JOAP_NS
exports.RPC_NS  = RPC_NS
exports.XML_NS  = JOAP_NS
