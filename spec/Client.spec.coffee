joap = require "../src/node-xmpp-joap"
ltx  = require "ltx"
xmpp = require "node-xmpp"

chai        = require 'chai'
expect      = chai.expect

{ JID } = xmpp

JOAP_NS = "jabber:iq:joap"
RPC_NS  = "jabber:iq:rpc"

describe "Client", ->

  compJID   = "comp.exmaple.tld"

  xmppComp =
    channels: {}
    send: (data) ->
    onData: (data) ->
    on: (channel, cb) ->
      @channels[channel] = cb
    removeListener: ->
    connection: jid: new JID compJID

  beforeEach -> @c = new joap.Client xmppComp

  it "is a class", ->
   (expect typeof joap.Client).to.equal "function"

  it "takes an xmpp object as first argument", ->
   (expect (new joap.Client xmppComp).xmpp).to.equal xmppComp

  it "provides methods to perform JOAP actions", ->
    c = new joap.Client xmppComp
    (expect typeof c.describe).to.equal "function"
    (expect typeof c.read).to.equal "function"
    (expect typeof c.add).to.equal "function"
    (expect typeof c.edit).to.equal "function"
    (expect typeof c.search).to.equal "function"

  describe "description method", ->

    it "sends a correct iq", (done) ->

      iq = null
      xmppComp.send = (req) ->
        iq = req
        res = new ltx.Element "iq", type: 'result', id: iq.tree().attrs.id
        res.c("describe")
          .c("attributedescription")
            .c("name").t("foo").up()
            .c("type").t("int").up()
            .c("desc", "xml:lang": 'en-US').t("foo").up()
            .c("desc", "xml:lang": 'de-DE').t("bar").up().up()
          .c("methoddescription")
            .c("name").t("myMethod").up()
            .c("returnType").t("boolean").up()
            .c("desc", "xml:lang": 'en-US').t("great method").up()

        xmppComp.channels.stanza res
      @c.describe "class@c.domain.tld", (err, s, res) ->
        (expect s.tree().name).to.equal 'iq'
        (expect s.tree().attrs.id).to.equal iq.tree().attrs.id
        (expect res).to.deep.equal
          desc: {}
          attributes:
            foo:
              name: "foo"
              type: "int"
              desc:
                'en-US': "foo"
                'de-DE': "bar"
          methods:
            myMethod:
              name: "myMethod"
              returnType: 'boolean'
              desc: 'en-US': "great method"
          classes: []

        (expect iq.tree().name).to.equal 'iq'
        (expect iq.tree().children[0].toString()).to.equal '<describe ' +
        'xmlns="jabber:iq:joap"/>'

        done()

  describe "add method", ->

    it "sends a correct iq", (done) ->

      iq = null
      xmppComp.send = (req) ->
        iq = req.tree()
        res = new ltx.Element "iq", type: 'result', id: iq.tree().attrs.id
        res.c("add", xmlns: JOAP_NS)
          .c("newAddress").t("class@example.org/instance")
        xmppComp.channels.stanza res

      @c.add "class@c.domain.tld", {x:"y"}, (err, s, res) ->
        (expect s.tree().name).to.equal 'iq'
        (expect res).to.equal "class@example.org/instance"
        done()

  describe "read method", ->

    it "sends a correct iq", (done) ->

      iq = null
      xmppComp.send = (req) ->
        iq = req
        res = new ltx.Element "iq", type: 'result', id: iq.tree().attrs.id
        res.c("read", xmlns: JOAP_NS)
          .c("attribute")
            .c("name").t("magic").up()
            .c("value").c("i4").t(23)
        xmppComp.channels.stanza res

      @c.read "class@c.domain.tld/x", ["magic"], (err, s, res) ->
        (expect s.tree().name).to.equal 'iq'
        (expect res).to.eql {magic: 23}
        done()

  describe "read method", ->

    it "sends a correct iq", (done) ->

      iq = null
      xmppComp.send = (req) ->
        iq = req
        res = new ltx.Element "iq", type: 'result', id: iq.tree().attrs.id
        res.c("edit", xmlns: JOAP_NS)
          .c("newAddress").t("x@y.z/0")
        xmppComp.channels.stanza res

      @c.edit "class@c.domain.tld/x", { "magic":6 } , (err, s, res) ->
        (expect s.tree().name).to.equal 'iq'
        (expect res).to.equal "x@y.z/0"
        done()

  describe "search method", ->

    it "sends a correct iq", (done) ->

      xmppComp.send = (req) ->
        iq = req
        res = new ltx.Element "iq", type: 'result', id: iq.tree().attrs.id
        res.c("search", xmlns: JOAP_NS)
          .c("item").t("x@y.z/0")
        xmppComp.channels.stanza res

      @c.search "class@c.domain.tld", { "magic":6 } , (err, s, res) ->
        (expect res).to.eql ["x@y.z/0"]
        done()

  describe "rpc method", ->

    it "sends a correct iq", (done) ->

      xmppComp.send = (req) ->
        iq = req.tree()
        mName = iq.getChild "query"
          .getChild "methodCall"
          .getChild "methodName"
          .text()
        (expect mName).to.equal "myMethod"
        res = new ltx.Element "iq", type: 'result', id: iq.tree().attrs.id
        res.c("query", xmlns: RPC_NS)
          .c "methodResponse"
            .c "params"
              .c "param"
                .c("value").c("int").t(7)
        xmppComp.channels.stanza res.tree()

      @c.methodCall "myMethod", "class@c.domain.tld", ["avalue"] , (err, s, res) ->
        (expect res).to.equal 7
        done()

  describe "delete method", ->

    it "sends a correct iq", (done) ->
      xmppComp.send = (req) ->
        iq = req.tree()
        (expect iq.getChild("delete")).to.exist
        res = new ltx.Element "iq", type: 'result', id: iq.tree().attrs.id
        res.c("delete", xmlns: JOAP_NS)
        xmppComp.channels.stanza res

      @c.delete "class@c.domain.tld/inst", (err, s, res) -> done()
