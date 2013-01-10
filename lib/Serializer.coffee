###
This program is distributed under the terms of the MIT license.
Copyright 2012 - 2013 (c) Markus Kohlhase <mail@markus-kohlhase.de>
###

ltx     = require "ltx"
joap    = require "./node-xmpp-joap"
stanza  = joap.stanza

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
              el.cnode(new stanza.Attribute k,v)
            el
          when "add"
            if val?
              el.c("newAddress").t(val).up()
            el
          when "edit"
            el.c("newAddress").t(val) if val?
            el
          when "delete"
            el
          when "search"
            for v in val
              el.c("item").t(v.toString()).up()
            el
          when "describe"
            if val?
              if val.desc?
                for k,v of val.desc
                  el.cnode(new stanza.Description v,k).up()
              if val.attributes?
                for k,v of val.attributes
                  el.cnode(new stanza.AttributeDescription k, v.type, v.writable, v.desc).up()
              if val.classes?
                for c in val.classes
                  el.c("class").t(c).up()
              if val.timestamp?
                el.c("timestamp").t(val.timestamp).up()
            el
          else
            if val?
              el.cnode(@serialize val)
            el

      else if action.type is "rpc"
        new stanza.MethodResponse val

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
            new stanza.Array val
          else if val instanceof Element
            val
          else
            new stanza.Struct val
    else ""

module.exports = Serializer
