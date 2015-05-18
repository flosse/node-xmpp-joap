Router = require "../src/Router"
ltx  = require "ltx"

chai        = require 'chai'
expect      = chai.expect

{ JID } = require "node-xmpp-core"

JOAP_NS = "jabber:iq:joap"
RPC_NS  = "jabber:iq:rpc"

describe "Router", ->

  compJID   = "comp.exmaple.tld"
  clientJID = "client@exmaple.tld"

  xmppComp =
    channels: {}
    send: (data) -> process.nextTick -> xmppClient.onData data
    onData: (data) ->
    on: (channel, cb) ->
      @channels[channel] = cb
    connection: jid: new JID compJID

  xmppClient =
    send: (data) -> process.nextTick -> xmppComp.channels.stanza data
    onData: (data, cb) ->

  beforeEach ->
    @router = new Router xmppComp

  it "ignores stanzas that has an invalid 'from' attribute", (done) ->
    @request = new ltx.Element "iq",
      id:"invalid_req"
      to: "class@comp.example.tld"
      type:'set'
    @request.c "add", xmlns:JOAP_NS
    xmppComp.on "stanza", (data) -> done()
    xmppClient.send @request

  it "returns an err stanzas if 'to' attribute is invalid", (done) ->
    @request = new ltx.Element "iq",
      id:"invalid_req"
      from: "client@example.tld"
      type:'set'
    @request.c "add", xmlns:JOAP_NS
    xmppClient.onData = (data) ->
      errMsg = data.getChildText("error")
      (expect errMsg).to.eql "invalid 'to' attribute in IQ stanza"
      done()
    xmppClient.send @request

  it "supports custom joap actions", (done) ->
    @request = new ltx.Element "iq",
      id:"invalid_req"
      from: "client@example.tld"
      to: "class@comp.example.tld"
      type:'set'
    @request.c "foo", xmlns:JOAP_NS
    @router.on "foo", (action) =>
      @router.sendResponse action, (new ltx.Element "customdata", myAttrs: "custom response")

    xmppClient.onData = (data) ->
      data = data.getChild("foo").getChild("customdata")
      (expect data.attrs.myAttrs).to.equal "custom response"
      done()
    xmppClient.send @request
