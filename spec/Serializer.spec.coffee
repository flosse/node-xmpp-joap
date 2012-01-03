describe "Serializer", ->

  joap = require "../lib/node-xmpp-joap"
  ltx  = require "ltx"
  Serializer = joap.Serializer

  describe "serialize", ->

    it "serializes basic data types", ->

      (expect Serializer.serialize null ).toEqual ""
      (expect Serializer.serialize undefined ).toEqual ""
      (expect Serializer.serialize "foo" ).toEqual ltx.parse "<string>foo</string>"
      (expect Serializer.serialize 2 ).toEqual ltx.parse "<int>2</int>"
      (expect Serializer.serialize -0.3 ).toEqual ltx.parse "<double>-0.3</double>"
      (expect Serializer.serialize true ).toEqual ltx.parse "<boolean>1</boolean>"
      (expect Serializer.serialize [] ).toEqual ltx.parse "<array><data></data></array>"
      (expect Serializer.serialize ["x", -0.35, false] ).toEqual ltx.parse "<array><data>" +
        "<value><string>x</string></value><value><double>-0.35</double></value><value>" +
        "<boolean>0</boolean></value></data></array>"
      (expect Serializer.serialize {a:"foo", b:["bar"]} ).toEqual ltx.parse "<struct>"+
        "<member><name>a</name><value><string>foo</string></value></member>" +
        "<member><name>b</name>" +
          "<value><array><data><value><string>bar</string></value></data></array>" +
          "</value></member></struct>"

    it "serializes result attributes", ->

      readAct   = { type: "read"   }
      addAct    = { type: "add"    }
      editAct   = { type: "edit"   }
      delAct    = { type: "delete" }
      searchAct = { type: "search" }
      addr = "Class@component.example.com/instance"

      readObj = {a:"foo", b:2}
      (expect Serializer.serialize readObj, readAct).toEqual ltx.parse "<read xmlns='jabber:iq:joap'>"+
        "<attribute><name>a</name><value><string>foo</string></value></attribute>" +
        "<attribute><name>b</name><value><int>2</int></value></attribute>" +
        "</read>"

      (expect Serializer.serialize addr, addAct).toEqual ltx.parse "<add xmlns='jabber:iq:joap'>"+
        "<newAddress>#{addr}</newAddress></add>"

      (expect Serializer.serialize null, editAct).toEqual ltx.parse "<edit xmlns='jabber:iq:joap' />"
      (expect Serializer.serialize addr, editAct).toEqual ltx.parse "<edit xmlns='jabber:iq:joap' >" +
        "<newAddress>#{addr}</newAddress></edit>"

      (expect Serializer.serialize null, delAct).toEqual ltx.parse "<delete xmlns='jabber:iq:joap' />"

      searchResults = ["a", "b", "c"]
      (expect Serializer.serialize searchResults, searchAct).toEqual ltx.parse "<search xmlns='jabber:iq:joap' >" +
        "<item>a</item>" +
        "<item>b</item>" +
        "<item>c</item>" +
        "</search>"

