chai        = require 'chai'
sinon       = require 'sinon'
sinonChai   = require 'sinon-chai'

chai.use sinonChai
should      = chai.should()

ltx         = require 'ltx'
Application = require '../src/Application'
{ JID }     = require "node-xmpp-core"
JOAP_NS     = "jabber:iq:joap"

compJID   = "comp.exmaple.tld"
clientJID = "client@exmaple.tld"

mockComp =
  channels: {}
  send: (data) ->
    process.nextTick -> mockClient.onData data
  onData: (data) ->
  on: (channel, cb) ->
    @channels[channel] = cb
  connection: jid: new JID compJID

mockClient =
  send: (data) ->
    process.nextTick -> mockComp.channels.stanza data
  onData: (data) ->

describe "Application", ->

  beforeEach ->

    mockClient.onData = ->
    @app = new Application mockComp
    @req = new ltx.Element "iq",
      id:"test"
      to: "class@comp.example.tld"
      from: "user@example.tld"
      type:'set'
    @req.c "describe", xmlns:JOAP_NS

    @addReq = new ltx.Element "iq",
      id:"add"
      to: "class@comp.example.tld"
      from: "user@example.tld"
      type:'set'

    @addReq.c "add", xmlns:JOAP_NS

  it "is a function", ->
    Application.should.be.a.function

  it "takes a xmpp component as first argumen", ->
    (-> new Application).should.throw()
    (-> new Application {connection:{}}).should.throw()
    (-> new Application mockComp).should.not.throw()
    (new Application mockComp).xmpp.should.equal mockComp

  describe "'use' method", ->

    it "is a function", ->
      Application::use.should.be.a.function
      @app.use.should.be.a.function

    it "takes a function that gets called on every received message", (done) ->
      spy = new sinon.spy()
      cb = (req, res, next) ->
        spy()
        next()
      @app.use cb
      i = 0
      @app.use (req, res, next) ->
        if ++i is 2
          spy.should.have.been.calledTwice
          done()
      mockClient.send @req
      mockClient.send @req

    it "runs the functions asynchonously and in series", (done) ->
      cb1 = new sinon.spy()
      cb2 = new sinon.spy()
      @app.use (req, res, next) ->
        cb2.should.not.have.been.called
        cb1()
        next()
      @app.use (req, res, next) ->
        cb1.should.have.been.calledOnce
        cb2.should.not.have.been.called
        cb2()
        next()
      @app.use (req, res, next) ->
        cb1.should.have.been.calledOnce
        cb2.should.have.been.calledOnce
        done()
      mockClient.send @req

    it "passes the request and result objects", (done) ->
      @app.use (req, res, next) ->
        req.foo = "bar"
        res.bar = 99
        next()
      @app.use (req, res, next) ->
        req.foo.should.equal "bar"
        res.bar.should.equal 99
        next()
        done()
      mockClient.send @req

  describe "'add' method", ->

    it "is a function", ->
      Application::add.should.be.a.function
      @app.add.should.be.a.function

    it "takes a function that gets called on an 'add' request", (done) ->

      @app.add (req, res, next) ->
        req.type.should.equal 'add'
        next()
        done()
      mockClient.send @addReq

    it "only calles the function on an 'add' request", (done) ->

      cb = new sinon.spy()
      @app.add (req, res, next) ->
        cb()
        next()
        cb.should.have.been.calledOnce
        done()
      mockClient.send @req
      mockClient.send @addReq

  describe "result object", ->

    it "has an end method", (done) ->
      @app.use (req, res, next) ->
        res.end.should.be.a.function
        done()
      mockClient.send @req

    it "has a error method", (done) ->
      @app.use (req, res, next) ->
        res.error.should.be.a.function
        res.error new Error "foo"
      mockClient.send @req
      mockClient.onData = (data) ->
        data.children[1].name.should.equal 'error'
        done()
