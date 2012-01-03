stanza = require("./stanza")

exports.Router  = require("./Router").Router
exports.Manager = require("./Manager").Manager

exports.Attribute = stanza.Attribute
exports.Member    = stanza.Member
exports.Struct    = stanza.Struct
exports.Array     = stanza.Array
exports.Value     = stanza.Value

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
