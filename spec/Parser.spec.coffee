describe "Parser", ->

  joap = require "../lib/node-xmpp-joap"
  ltx  = require "ltx"

  it "checks the stanzas", ->

    rpc = ltx.parse "<query xmlns='jabber:iq:rpc'></query>"
    nonRpc1 = ltx.parse "<query xmlns='wrong:iq:rpc'></query>"
    nonRpc2 = ltx.parse "<x xmlns='jabber:iq:rpc'></x>"

    joapRead = ltx.parse "<read xmlns='jabber:iq:joap'/>"
    nonJoap1 = ltx.parse "<read xmlns='jabber:iq:wrong'/>"
    nonJoap2 = ltx.parse "<x xmlns='jabber:iq:joap'/>"

    (expect joap.Parser.isRPCStanza rpc).toBeTruthy()
    (expect joap.Parser.isRPCStanza nonRpc1).toBeFalsy()
    (expect joap.Parser.isRPCStanza nonRpc2).toBeFalsy()

    (expect joap.Parser.isJOAPStanza joapRead).toBeTruthy()
    (expect joap.Parser.isJOAPStanza nonJoap1).toBeFalsy()
    (expect joap.Parser.isJOAPStanza nonJoap2).toBeFalsy()

  it "checks the type", ->
    read   = ltx.parse "<read xmlns='jabber:iq:joap'/>"
    search = ltx.parse "<search xmlns='jabber:iq:joap'/>"
    rpc    = ltx.parse "<query xmlns='jabber:iq:rpc'></query>"

    (expect joap.Parser.getType read).toEqual "read"
    (expect joap.Parser.getType search).toEqual "search"
    (expect joap.Parser.getType rpc).toEqual "rpc"

  it "checks custom jaop actions", ->
    (expect joap.Parser.isCustomJOAPAction "read").toEqual false
    (expect joap.Parser.isCustomJOAPAction "foo").toEqual true

  describe "parse", ->

    it "should be accessible", ->
      (expect joap.Parser.parse).toBeDefined()

    describe "action", ->

      it "returns an object with type informations", ->
        describe = ltx.parse "<describe xmlns='jabber:iq:joap'/>"
        unknown = ltx.parse "<foo xmlns='jabber:iq:joap'/>"
        rpc = ltx.parse "<query xmlns='jabber:iq:rpc'><methodCall>" +
          "<methodName>test</methodName></methodCall></query>"

        (expect joap.Parser.parse(describe).type).toEqual "describe"
        (expect joap.Parser.parse(rpc).type).toEqual "rpc"
        (expect joap.Parser.parse(unknown).type).toEqual "foo"

      it "returns the parsed attribute if available", ->
        read1 = ltx.parse "<read xmlns='jabber:iq:joap'>" +
            "<attribute><name>foo</name><value>bar</value></attribute>" +
            "<attribute><name>second</name><value>value</value></attribute>" +
          "</read>"

        read2 = ltx.parse "<read xmlns='jabber:iq:joap' />"
        read3 = ltx.parse "<read xmlns='jabber:iq:joap'><name>foo</name><name>second</name></read>"

        edit = ltx.parse "<edit xmlns='jabber:iq:joap'>" +
            "<attribute><name>foo</name><value><int>3</int></value></attribute>" +
            "<attribute>" +
              "<name>bar</name>" +
              "<value>" +
                "<struct>" +
                  "<member>" +
                    "<name>foo</name>" +
                    "<value>" +
                      "<array><data>" +
                      "<value><int>12</int></value>" +
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

        (expect joap.Parser.parse read1).toEqual { type: "read", attributes:{ foo: "bar", second:"value"} }
        (expect joap.Parser.parse read2).toEqual { type: "read" }
        (expect joap.Parser.parse read3).toEqual { type: "read", limits: ["foo", "second"] }
        (expect joap.Parser.parse edit).toEqual { type: "edit", attributes: {
          foo: 3, bar: { foo: [12,"bar", false, -31]} }}

        (expect joap.Parser.parse rpc1).toEqual { type: "rpc", method: "test" }
        (expect joap.Parser.parse rpc2).toEqual { type: "rpc", method: "test", params: ["abc", true, -0.003 ] }
