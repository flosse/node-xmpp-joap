joap = require "../lib/node-xmpp-joap"
ltx  = require "ltx"

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
    jid: compJID

  beforeEach ->
    @c = new joap.Client xmppComp

  it "is a class", ->
   (expect typeof joap.Client).toEqual "function"

  it "takes an xmpp object as first argument", ->
   (expect (new joap.Client xmppComp).xmpp).toEqual xmppComp

  it "provides methods to perform JOAP actions", ->
    c = new joap.Client xmppComp
    (expect typeof c.describe).toEqual "function"
    (expect typeof c.read).toEqual "function"
    (expect typeof c.add).toEqual "function"
    (expect typeof c.edit).toEqual "function"
    (expect typeof c.search).toEqual "function"

  describe "description method", ->

    it "sends a correct iq", ->

      done = false
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
        (expect s.tree().name).toEqual 'iq'
        (expect s.tree().attrs.id).toEqual iq.tree().attrs.id
        (expect res).toEqual
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
          classes: {}

        done = true

      (expect iq.tree().name).toEqual 'iq'
      (expect iq.tree().children[0].toString()).toEqual '<describe ' +
        'xmlns="jabber:iq:joap"/>'
      waitsFor -> done

  describe "add method", ->

    it "sends a correct iq", ->

      done = false
      iq = null
      xmppComp.send = (req) ->
        iq = req.tree()
        res = new ltx.Element "iq", type: 'result', id: iq.tree().attrs.id
        res.c("add", xmlns: JOAP_NS)
          .c("newAddress").t("class@example.org/instance")
        xmppComp.channels.stanza res

      @c.add "class@c.domain.tld", {x:"y"}, (err, s, res) ->
        (expect s.tree().name).toEqual 'iq'
        (expect res).toEqual "class@example.org/instance"
        done = true

      waitsFor -> done

  describe "read method", ->

    it "sends a correct iq", ->

      done = false
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
        (expect s.tree().name).toEqual 'iq'
        (expect res).toEqual {magic: 23}
        done = true

      waitsFor -> done
