ltx     = require "ltx"
joap    = require "./node-xmpp-joap"

class KeyVal extends ltx.Element
  constructor: (name, key, value) ->
    super name
    @c("name")
      .t(key.toString()).up()
    .cnode(new Value value).up().up()

class Attribute extends KeyVal

  constructor: (key, value) ->
    super "attribute", key, value

class Member extends KeyVal

  constructor: (key, value) ->
    super "member", key, value

class Struct extends ltx.Element
  constructor: (obj) ->
    super "struct"
    for own k,v of obj
      @cnode(new Member k,v).up()

class Array extends ltx.Element
  constructor: (arr) ->
    super "array"
    data = @c "data"
    for v in arr
      data.cnode(new Value v)

class Value extends ltx.Element
  constructor: (val) ->
    super "value"
    @cnode(joap.serialize val)

exports.Attribute = Attribute
exports.Member = Member
exports.Struct = Struct
exports.Array = Array
exports.Value = Value
