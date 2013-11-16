chai        = require 'chai'
expect      = chai.expect

describe "Serializer", ->

  Serializer = require "../src/Serializer"
  ltx  = require "ltx"

  describe "serialize", ->

    it "serializes basic data types", ->

      (expect Serializer.serialize null ).to.equal ""
      (expect Serializer.serialize undefined ).to.equal ""
      (expect Serializer.serialize("foo").toString()).to.eql "<string>foo</string>"
      (expect Serializer.serialize(2).toString()).to.eql ltx.parse("<int>2</int>").toString()
      (expect Serializer.serialize(-0.3).toString()).to.deep.eql ltx.parse("<double>-0.3</double>").toString()
      (expect Serializer.serialize(true).toString()).to.deep.eql ltx.parse("<boolean>1</boolean>").toString()
      (expect Serializer.serialize([]).toString()).to.eql ltx.parse("<array><data></data></array>").toString()
      (expect Serializer.serialize(["x", -0.35, false]).toString()).to.eql ltx.parse("<array><data>" +
        "<value><string>x</string></value><value><double>-0.35</double></value><value>" +
        "<boolean>0</boolean></value></data></array>").toString()
      (expect Serializer.serialize({a:"foo", b:["bar"]}).toString()).to.eql ltx.parse("<struct>"+
        "<member><name>a</name><value><string>foo</string></value></member>" +
        "<member><name>b</name>" +
          "<value><array><data><value><string>bar</string></value></data></array>" +
          "</value></member></struct>").toString()

    it "serializes result attributes", ->

      descAct   = { type: "describe" }
      readAct   = { type: "read"     }
      addAct    = { type: "add"      }
      editAct   = { type: "edit"     }
      delAct    = { type: "delete"   }
      searchAct = { type: "search"   }
      addr = "Class@component.example.com/instance"

      readObj = {a:"foo", b:2}
      (expect Serializer.serialize(readObj, readAct).toString()).to.deep.equal ltx.parse("<read xmlns='jabber:iq:joap'>"+
        "<attribute><name>a</name><value><string>foo</string></value></attribute>" +
        "<attribute><name>b</name><value><int>2</int></value></attribute>" +
        "</read>").toString()

      (expect Serializer.serialize addr, addAct).to.deep.equal ltx.parse "<add xmlns='jabber:iq:joap'>"+
        "<newAddress>#{addr}</newAddress></add>"

      (expect Serializer.serialize null, editAct).to.deep.equal ltx.parse "<edit xmlns='jabber:iq:joap' />"
      (expect Serializer.serialize addr, editAct).to.deep.equal ltx.parse "<edit xmlns='jabber:iq:joap' >" +
        "<newAddress>#{addr}</newAddress></edit>"

      (expect Serializer.serialize null, delAct).to.deep.equal ltx.parse "<delete xmlns='jabber:iq:joap' />"

      serverDesc =
        desc:
          "en-US":"A server"
          "de-DE":"Ein Server"
        attributes:
          foo:
            writable:true
            type: "bar"
            desc:
              "en-US":"Hello world"
              "de-DE":"Hallo Welt"
          bar:
            writable:false
            type: "int"

      (expect Serializer.serialize(serverDesc, descAct).toString()).to.eql ltx.parse("<describe xmlns='jabber:iq:joap' >" +
        "<desc xml:lang='en-US' >A server</desc>"+
        "<desc xml:lang='de-DE' >Ein Server</desc>"+
        "<attributeDescription writable='true'><name>foo</name><type>bar</type>" +
        "<desc xml:lang='en-US' >Hello world</desc>"+
        "<desc xml:lang='de-DE' >Hallo Welt</desc>"+
        "</attributeDescription>"+
        "<attributeDescription writable='false'><name>bar</name><type>int</type>" +
        "</attributeDescription>"+
        "</describe>").toString()

      searchResults = ["a", "b", "c"]
      (expect Serializer.serialize searchResults, searchAct).to.deep.equal ltx.parse "<search xmlns='jabber:iq:joap' >" +
        "<item>a</item>" +
        "<item>b</item>" +
        "<item>c</item>" +
        "</search>"

    it "serializes custom joap data", ->
      customAct  = { type: "foo" }
      customData = { x: "y" }
      xmlData    = ltx.parse "<cutom><data><foo bar='baz' /></data></cutom>"
      (expect Serializer.serialize null, customAct).to.deep.equal ltx.parse "<foo xmlns='jabber:iq:joap' />"
      (expect Serializer.serialize(customData, customAct).toString()).to.deep.equal ltx.parse("<foo xmlns='jabber:iq:joap' >" +
        "<struct><member><name>x</name><value><string>y</string></value></member></struct></foo>").toString()
        (expect Serializer.serialize xmlData, customAct).to.deep.equal ltx.parse "<foo xmlns='jabber:iq:joap' >" +
        "<cutom><data><foo bar='baz' /></data></cutom>" + "</foo>"
