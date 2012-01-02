describe "Router", ->

  joap = require "../lib/node-xmpp-joap"
  ltx  = require "ltx"
  Router = joap.Router

  it "checks the stanzas", ->

    rpc = ltx.parse "<query xmlns='jabber:iq:rpc'></query>"
    nonRpc1 = ltx.parse "<query xmlns='wrong:iq:rpc'></query>"
    nonRpc2 = ltx.parse "<x xmlns='jabber:iq:rpc'></x>"

    joap = ltx.parse "<read xmlns='jabber:iq:joap'/>"
    nonJoap1 = ltx.parse "<read xmlns='jabber:iq:wrong'/>"
    nonJoap2 = ltx.parse "<x xmlns='jabber:iq:joap'/>"

    (expect Router.isRPCStanza rpc).toBeTruthy()
    (expect Router.isRPCStanza nonRpc1).toBeFalsy()
    (expect Router.isRPCStanza nonRpc2).toBeFalsy()

    (expect Router.isJOAPStanza joap).toBeTruthy()
    (expect Router.isJOAPStanza nonJoap1).toBeFalsy()
    (expect Router.isJOAPStanza nonJoap2).toBeFalsy()

  it "checks the type", ->
    read   = ltx.parse "<read xmlns='jabber:iq:joap'/>"
    search = ltx.parse "<search xmlns='jabber:iq:joap'/>"
    rpc    = ltx.parse "<query xmlns='jabber:iq:rpc'></query>"

    (expect Router.getType read).toEqual "read"
    (expect Router.getType search).toEqual "search"
    (expect Router.getType rpc).toEqual "rpc"

  describe "parse", ->

    it "should be accessible", ->
      (expect Router.parse).toBeDefined()

    describe "action", ->

      it "returns an object with type informations", ->
        describe = ltx.parse "<describe xmlns='jabber:iq:joap'/>"
        rpc = ltx.parse "<query xmlns='jabber:iq:rpc'><methodCall>" +
          "<methodName>test</methodName></methodCall></query>"

        (expect Router.parse(describe).type).toEqual "describe"
        (expect Router.parse(rpc).type).toEqual "rpc"

      it "returns the parsed attribute if available", ->
        read1 = ltx.parse "<read xmlns='jabber:iq:joap'>" +
            "<attribute><name>foo</name><value>bar</value></attribute>" +
            "<attribute><name>second</name><value>value</value></attribute>" +
          "</read>"

        read2 = ltx.parse "<read xmlns='jabber:iq:joap' />"
        read3 = ltx.parse "<read xmlns='jabber:iq:joap'><name>foo</name><name>second</name></read>"

        edit = ltx.parse "<edit xmlns='jabber:iq:joap'>" +
            "<attribute><name>foo</name><value><i4>3</i4></value></attribute>" +
            "<attribute>" +
              "<name>bar</name>" +
              "<value>" +
                "<struct>" +
                  "<member>" +
                    "<name>foo</name>" +
                    "<value>" +
                      "<array><data>" +
                      "<value><i4>12</i4></value>" +
                      "<value><string>bar</string></value>" +
                      "<value><boolean>0</boolean></value>" +
                      "<value><int>-31</int></value>" +
                      "</data></array>" +
                    "</value>" +
                  "</member>" +
                "</struct>" +
              "</value>" +
            "</attribute>" +
          "</edit>"

        rpc1 = ltx.parse "<query xmlns='jabber:iq:rpc'><methodCall>" +
          "<methodName>test</methodName></methodCall></query>"

        rpc2 = ltx.parse "<query xmlns='jabber:iq:rpc'><methodCall>" +
          "<methodName>test</methodName>" +
          "<params>" +
            "<param><value>abc</value></param>" +
            "<param><value><boolean>1</boolean></value></param>" +
            "<param><value><double>-0.003</double></value></param>" +
          "</params>" +
          "</methodCall></query>"

        (expect Router.parse read1).toEqual { type: "read", attributes:{ foo: "bar", second:"value"} }
        (expect Router.parse read2).toEqual { type: "read" }
        (expect Router.parse read3).toEqual { type: "read", limits: ["foo", "second"] }
        (expect Router.parse edit).toEqual { type: "edit", attributes: {
          foo: 3, bar: { foo: [12,"bar", false, -31]} }}

        (expect Router.parse rpc1).toEqual { type: "rpc", method: "test" }
        (expect Router.parse rpc2).toEqual { type: "rpc", method: "test", params: ["abc", true, -0.003 ] }

  describe "serialize", ->
      it "serializes basic data types", ->
        obj = {a:"foo", b:2, c: -0.3, d:true, e:[], f:{}}

        (expect Router.serialize "foo" ).toEqual ltx.parse "<string>foo</string>"
        (expect Router.serialize 2 ).toEqual ltx.parse "<i4>2</i4>"
        (expect Router.serialize -0.3 ).toEqual ltx.parse "<double>-0.3</double>"
        (expect Router.serialize true ).toEqual ltx.parse "<boolean>1</boolean>"
        (expect Router.serialize [] ).toEqual ltx.parse "<array><data></data></array>"
        (expect Router.serialize ["x", -0.35, false] ).toEqual ltx.parse "<array><data>" +
          "<value><string>x</string></value><value><double>-0.35</double></value><value>" +
          "<boolean>0</boolean></value></data></array>"
        (expect Router.serialize {a:"foo", b:["bar"]} ).toEqual ltx.parse "<struct>"+
          "<member><name>a</name><value><string>foo</string></value></member>" +
          "<member><name>b</name>" +
            "<value><array><data><value><string>bar</string></value></data></array>" +
            "</value></member>" +
          "</struct>"
