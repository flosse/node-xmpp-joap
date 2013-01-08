joap = require "../lib/node-xmpp-joap"
ltx  = require "ltx"

JOAP_NS = "jabber:iq:joap"
RPC_NS  = "jabber:iq:rpc"

describe "Router", ->

  compJID   = "comp.exmaple.tld"
  clientJID = "client@exmaple.tld"

  xmppComp =
    channels: {}
    send: (data) -> xmppClient.onData data
    onData: (data) ->
    on: (channel, cb) ->
      @channels[channel] = cb
    jid: compJID

  xmppClient =
    send: (data) -> xmppComp.channels.stanza data
    onData: (data, cb) ->

  beforeEach ->
    @router = new joap.Router xmppComp

  it "ignores stanzas that has an invalid 'from' attribute", ->
    @request = new ltx.Element "iq",
      id:"invalid_req"
      to: "class@comp.example.tld"
      type:'set'
    @request.c "add", xmlns:JOAP_NS
    xmppClient.send @request

  it "returns an err stanzas if 'to' attribute is invalid", ->
    @request = new ltx.Element "iq",
      id:"invalid_req"
      from: "client@example.tld"
      type:'set'
    @request.c "add", xmlns:JOAP_NS
    done = false
    xmppClient.onData = (data) ->
      errMsg = data.getChildText("error")
      (expect errMsg).toEqual "invalid 'to' attribute in IQ stanza"
      done = true
    xmppClient.send @request
    waitsFor -> done
