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

      descAct   = { type: "describe" }
      readAct   = { type: "read"     }
      addAct    = { type: "add"      }
      editAct   = { type: "edit"     }
      delAct    = { type: "delete"   }
      searchAct = { type: "search"   }
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

      (expect Serializer.serialize serverDesc, descAct).toEqual ltx.parse "<describe xmlns='jabber:iq:joap' >" +
        "<desc xml:lang='en-US' >A server</desc>"+
        "<desc xml:lang='de-DE' >Ein Server</desc>"+
        "<attributeDescription writable='true'><name>foo</name><type>bar</type>" +
        "<desc xml:lang='en-US' >Hello world</desc>"+
        "<desc xml:lang='de-DE' >Hallo Welt</desc>"+
        "</attributeDescription>"+
        "<attributeDescription writable='false'><name>bar</name><type>int</type>" +
        "</attributeDescription>"+
        "</describe>"

      searchResults = ["a", "b", "c"]
      (expect Serializer.serialize searchResults, searchAct).toEqual ltx.parse "<search xmlns='jabber:iq:joap' >" +
        "<item>a</item>" +
        "<item>b</item>" +
        "<item>c</item>" +
        "</search>"

    it "serializes custom joap data", ->
      customAct  = { type: "foo" }
      customData = { x: "y" }
      xmlData    = ltx.parse "<cutom><data><foo bar='baz' /></data></cutom>"
      (expect Serializer.serialize null, customAct).toEqual ltx.parse "<foo xmlns='jabber:iq:joap' />"
      (expect Serializer.serialize customData, customAct).toEqual ltx.parse "<foo xmlns='jabber:iq:joap' >" +
        "<struct><member><name>x</name><value><string>y</string></value></member></struct></foo>"
        (expect Serializer.serialize xmlData, customAct).toEqual ltx.parse "<foo xmlns='jabber:iq:joap' >" +
        "<cutom><data><foo bar='baz' /></data></cutom>" + "</foo>"
