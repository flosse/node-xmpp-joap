ltx     = require "ltx"
joap    = require "./node-xmpp-joap"

JOAP_NS       = "jabber:iq:joap"
RPC_NS        = "jabber:iq:rpc"
JOAP_STANZAS  = ["describe", "read","add", "edit", "delete", "search"]

Element   = ltx.Element

class Serializer

  @serialize: (val, action) ->

    if action?
      if action.type isnt "rpc"
        el = (new Element action.type, {xmlns:JOAP_NS})
        switch action.type
          when "read"
            for k,v of val
              el.cnode(new joap.Attribute k,v)
            el
          when "add"
            el.c("newAddress").t(val).up()
          when "edit"
            el.c("newAddress").t(val) if val?
            el
          when "delete"
            el
          when "search"
            for v in val
              el.c("item").t(v.toString()).up()
            el

      else if action.type is "rpc"
        el = (new Element "query", {xmlns:RPC_NS})

    else if val?

      switch typeof val

        when "string"
          (new Element "string").t(val)

        when "number"
          if val % 1 is 0
            (new Element "int").t(val.toString())
          else
            (new Element "double").t(val.toString())

        when "boolean"
          (new Element "boolean").t(if val is true then "1" else "0")

        when "object"
          if val instanceof Array
            new joap.Array val
          else
            new joap.Struct val
    else ""

exports.Serializer = Serializer
