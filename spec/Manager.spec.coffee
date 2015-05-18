chai        = require 'chai'
expect      = chai.expect

joap = require "../lib/node-xmpp-joap"
ltx  = require "ltx"

{ JID } = require "node-xmpp-core"

JOAP_NS = "jabber:iq:joap"
RPC_NS  = "jabber:iq:rpc"

describe "Manager", ->

  compJID   = "comp.exmaple.tld"
  clientJID = "client@exmaple.tld"

  createErrorIq = (type, code, msg, clazz, instance) ->
    from = compJID
    from = "#{clazz}@#{from}" if clazz?
    from += "/#{instance}"    if instance?
    errMsg = new joap.stanza.ErrorIq type, code, msg,
      to    : clientJID
      from  : from
      id    : "#{type}_id_0"

  createRequest = (type, clazz, instance) ->
    to = compJID
    to = "#{clazz}@#{to}" if clazz?
    to += "/#{instance}"  if instance?
    iq = new ltx.Element "iq",
      to    : to
      from  : clientJID
      id    : "#{type}_id_0"
      type  : 'set'
    if type is "query"
      iq.c type, xmlns:RPC_NS
    else
      iq.c type, xmlns:JOAP_NS
    iq

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
    @mgr = new joap.Manager xmppComp
    @compare = (res) ->
      (expect res.toString()).to.equal @result.toString()
    @run = (cb) ->
      xmppClient.onData = (data) -> cb data
      xmppClient.send @request

  it "creates objects for caching objetcs and classes", ->

    mgr = new joap.Manager xmppComp
    (expect typeof mgr.classes).to.equal "object"
    (expect typeof mgr._objects).to.equal "object"

  describe "registration of classes", ->


    it "supports a method to register classes", ->

      class User
        constructor: (@name, @age) ->

      @mgr.addClass "user", User,
        required: ["name"]
        protected: ["name"]

      userClz = @mgr.classes.user
      defAttrs = userClz.definitions.attributes
      (expect defAttrs.name.required).to.equal true
      (expect defAttrs.name.writable).to.equal false

  describe "add", ->

    createAddRequest = (clazz, instance) -> createRequest("add", clazz, instance)
    createAddErrorIq = (code, msg, clazz, instance) -> createErrorIq("add", code, msg, clazz, instance)

    beforeEach ->
      @request = createAddRequest "user"
      class User
        constructor: (@name) -> @id = "foo"
      @mgr.addClass "user", User,
        required: ["name"],
        protected: ["id"]

    it "returns an error if you are not authorized", (done) ->
      @result = createAddErrorIq '403', "You are not authorized", "user"
      @mgr.hasPermission = (a, next) -> next false, a
      @run (res) => @compare res; done()

    it "returns an error if address isn't a class", (done) ->
      @request.attrs.to += "/instance"
      @result = createAddErrorIq 405, "'user@#{compJID}/instance' isn't a class", "user", "instance"
      @run (res) => @compare res; done()

    it "returns an error if class doesn't exists", (done) ->
      @result = createAddErrorIq 404, "Class 'sun' does not exists", "sun"
      @request = createAddRequest "sun"
      @run (res) => @compare; done()

    it "returns an error if required attributes are not available", (done) ->
      @result = createAddErrorIq 406, "Invalid constructor parameters", "user"
      @run (res) => @compare res; done()

    it "returns an error if required attributes are not correct", (done) ->
      @request.getChild("add").cnode(new joap.stanza.Attribute "age", 33)
      @result = createAddErrorIq 406, "Invalid constructor parameters", "user"
      @run (res) => @compare res; done()

    it "returns the address of the new instance", (done) ->
      @request.getChild("add")
        .cnode(new joap.stanza.Attribute "name", "Markus").up()
        .cnode(new joap.stanza.Attribute "age", 99).up()
      @result = new ltx.Element "iq",
        to:clientJID
        from:"user@#{compJID}"
        id:'add_id_0'
        type:'result'
      @result.c("add", xmlns:JOAP_NS).c("newAddress").t("user@#{compJID}/foo")
      @run (result) =>
        @compare result
        instance = @mgr._objects.user.foo
        (expect instance.id).to.equal "foo"
        (expect instance.name).to.equal "Markus"
        (expect instance.age).to.equal 99
        done()

    it "takes care of the attribute names", (done) ->
      @request.getChild("add")
        .cnode(new joap.stanza.Attribute "age", 99).up()
        .cnode(new joap.stanza.Attribute "name", "Markus").up()
      @result = new ltx.Element "iq",
        to:clientJID
        from:"user@#{compJID}"
        id:'add_id_0'
        type:'result'
      @result.c("add", xmlns:JOAP_NS).c("newAddress").t("user@#{compJID}/foo")
      @run (result) =>
        @compare result
        instance = @mgr._objects.user.foo
        (expect instance.name).to.equal "Markus"
        (expect instance.age).to.equal 99
        done()

    it "creates a new ID", (done)->
      class Sun
      @mgr.addClass "sun", Sun
      @request = createAddRequest "sun"
      @run (result) ->
        id = result.getChild("add").getChildText("newAddress").split('/')[1]
        (expect id).not.to.equal "foo"
        (expect id).not.to.equal ""
        (expect false).not.to.equal ""
        done()

    it "preserve an ID", (done) ->
      class Sun
        constructor: (@id)->
      @mgr.addClass "sun", Sun
      @request = createAddRequest "sun"
      @request.getChild("add")
        .cnode(new joap.stanza.Attribute "id", 99.3)
      @run (result) ->
        id = result.getChild("add").getChildText("newAddress").split('/')[1]
        (expect id).to.equal '99.3'
        done()

  describe "read", ->

    beforeEach ->
      @request = createRequest "read", "user", "foo"

    it "returns an error if you are not authorized", (done) ->
      @result = createErrorIq "read", '403', "You are not authorized", "user", "foo"
      @mgr.hasPermission = (a, next) -> next false
      @run (res) => @compare res; done()

    it "returns an error if the class doesn't exists", (done) ->
      @result = createErrorIq "read", 404, "Class 'user' does not exists", "user", "foo"
      @run (res) => @compare res; done()

    it "returns an error if the instance doesn't exists", (done) ->
      @mgr.addClass "user", (->)
      @result = createErrorIq "read", 404, "Object 'foo' does not exists", "user", "foo"
      @run (res) => @compare res; done()

    it "returns an error if the specified attribute doesn't exists", (done) ->
      class User
        constructor: -> @id = "foo"
      @mgr.addClass "user", User
      @mgr.saveInstance {class:"user"}, (new User),  (err, a, addr) =>
        @request.getChild("read").c("name").t("age")
        @result = createErrorIq "read", 406, "Requested attribute 'age' doesn't exists", "user", "foo"
        @run (res) => @compare res; done()

    it "returns all attributes if nothing was specified", (done) ->
      class User
        constructor: ->
          @id = "foo"
          @name = "Markus"
      @mgr.addClass "user", User
      @mgr.saveInstance {class:"user"}, (new User),  (err, a, addr) =>
        @result = new ltx.Element "iq",
          to:clientJID
          from:"user@#{compJID}/foo"
          id:'read_id_0'
          type:'result'
        @result.c("read", {xmlns: JOAP_NS})
          .cnode(new joap.stanza.Attribute "id", "foo").up()
          .cnode(new joap.stanza.Attribute "name", "Markus")
        @run (res) => @compare res; done()

    it "returns only the specified attributes", (done) ->
      class User
        constructor: ->
          @id = "foo"
          @name = "Markus"
      @mgr.addClass "user", User
      @mgr.saveInstance {class:"user"}, (new User),  (err, a, addr) =>
        @request.getChild("read").c("name").t("name")
        @result = new ltx.Element "iq",
          to:clientJID
          from:"user@#{compJID}/foo"
          id:'read_id_0'
          type:'result'
        @result.c("read", {xmlns: JOAP_NS})
          .cnode(new joap.stanza.Attribute "name", "Markus")
        @run (res) => @compare res; done()

  describe "edit", ->

    class User
      constructor: (@name, @age) ->
        @id = "foo"
        @instMethod = ->
      myMethod: ->
      @classMethod: ->

    beforeEach ->
      @mgr.addClass "user", User,
        required: ["name"]
        protected: ["protected"]
      @mgr._objects.user.foo = new User "Markus", 123
      @request = createRequest "edit", "user", "foo"

    it "returns an error if you are not authorized", (done) ->
      @result = createErrorIq "edit", '403', "You are not authorized", "user", "foo"
      @mgr.hasPermission = (a, next) -> next false
      @run (res) => @compare res; done()

    it "returns an error if the instance doesn't exists", (done) ->
      @request = createRequest "edit", "user", "oof"
      @result = createErrorIq "edit", 404, "Object 'oof' does not exists", "user", "oof"
      @run (res) => @compare res; done()

    it "returns an error if specified object attributes are not writeable", (done) ->
      @request.getChild("edit").cnode(new joap.stanza.Attribute "protected", "oof")
      @result = createErrorIq "edit", 406, "Attribute 'protected' of class 'user' is not writeable", "user", "foo"
      @run (res) => @compare res; done()

    it "returns an error if specified object attribute is a method", (done) ->
      @request.getChild("edit").cnode(new joap.stanza.Attribute "myMethod", "fn")
      @result = createErrorIq "edit", 406, "Attribute 'myMethod' of class 'user' is not writeable", "user", "foo"
      @run (res) => @compare res; done()

    it "returns an error if specified object attribute is an instance method", (done) ->
      @request.getChild("edit").cnode(new joap.stanza.Attribute "instMethod", "fn")
      @result = createErrorIq "edit", 406, "Attribute 'instMethod' of class 'user' is not writeable", "user", "foo"
      @run (res) => @compare res; done()

    it "returns an error if specified object attribute is a class method", (done) ->
      @request.getChild("edit").cnode(new joap.stanza.Attribute "classMethod", "fn")
      @result = createErrorIq "edit", 406, "Attribute 'classMethod' of class 'user' is not writeable", "user", "foo"
      @run (res) => @compare res; done()

    it "changes the specified attributes", (done) ->
      @request.getChild("edit")
        .cnode(new joap.stanza.Attribute "name", "oof").up()
        .cnode(new joap.stanza.Attribute "new", "attr")
      @result = new ltx.Element "iq",
        to:clientJID
        from:"user@#{compJID}/foo"
        id:'edit_id_0'
        type:'result'
      @result.c("edit", {xmlns: JOAP_NS})
      @run (res) =>
        instance = @mgr._objects.user.foo
        (expect instance.name).to.equal "oof"
        (expect instance.new).to.equal "attr"
        done()

    it "returns a new address if the id changed", (done) ->
      @request.getChild("edit")
        .cnode(new joap.stanza.Attribute "id", "newId")
      @result = new ltx.Element "iq",
        to:clientJID
        from:"user@#{compJID}/foo"
        id:'edit_id_0'
        type:'result'
      @result.c("edit", {xmlns: JOAP_NS})
        .c("newAddress").t("user@#{compJID}/newId")
      @run (res) =>
        @compare res
        instance = @mgr._objects.user.newId
        (expect typeof instance).to.equal "object"
        (expect instance.id).to.equal "newId"
        done()

    it "can be modified before editing", (done) ->
      @request.getChild("edit").cnode(new joap.stanza.Attribute "foo", "bar").up()
      @result = new ltx.Element "iq",
        to:clientJID
        from:"user@#{compJID}/foo"
        id:'edit_id_0'
        type:'result'
      @result.c("edit", {xmlns: JOAP_NS})
      @mgr.onEnter "edit", (a, next) ->
        a.attributes.foo = "modified"
        next null, a
      (expect @mgr._handlers.enter.edit.length).to.equal 1
      @run =>
        instance = @mgr._objects.user.foo
        (expect instance.foo).to.equal "modified"
        done()

    it "returns an error if a modifying function failed", (done) ->
      @request.getChild("edit").cnode(new joap.stanza.Attribute "foo", "bar").up()
      @result = new ltx.Element "iq",
        to:clientJID
        from:"user@#{compJID}/foo"
        id:'edit_id_0'
        type:'result'
      @result.c("edit", {xmlns: JOAP_NS})
      @mgr.onEnter "edit", (a, next) -> next (new Error "an error occoured"), a
      (expect @mgr._handlers.enter.edit.length).to.equal 1
      @run (res) ->
        (expect res.getChild "error").to.exist
        done()


  describe "delete", ->

    class User
      constructor: (@name, @age) -> @id = "foo"

    beforeEach ->
      @mgr = new joap.Manager xmppComp
      @mgr.addClass "user", User,
        required: ["name"]
        protected: ["id"]
      @mgr._objects.user.foo = new User "Markus", 123
      @request = createRequest "delete", "user", "foo"

    it "returns an error if you are not authorized", (done) ->
      @result = createErrorIq "delete", '403', "You are not authorized", "user", "foo"
      @mgr.hasPermission = (a, next) -> next false
      @run (res) => @compare res; done()

    it "returns an error if the instance doesn't exists", (done) ->
      @request = createRequest "delete", "user", "oof"
      @result = createErrorIq "delete", 404, "Object 'oof' does not exists", "user", "oof"
      @run (res) => @compare res; done()

    it "returns an error if address is not an instance", (done) ->
      @request = createRequest "delete"
      @result = createErrorIq "delete", 405, "'#{compJID}' is not an instance"
      @run (res) => @compare res; done()

    it "deletes the specified instance", (done) ->
      @result = new ltx.Element "iq",
        to:clientJID
        from:"user@#{compJID}/foo"
        id:'delete_id_0'
        type:'result'
      @result.c("delete", {xmlns: JOAP_NS})
      users = @mgr._objects.user
      (expect users.foo).to.exist
      @run (res) =>
        (expect users.foo).not.to.exist
        done()

  describe "describe", ->

    class User
      constructor: (@name, @age) ->
        @id = "foo"

    beforeEach ->
      @mgr.addClass "user", User,
        required: ["name"]
        protected: ["id"]
      @mgr._objects.user.foo = new User "Markus", 123
      @request = createRequest "describe"

    it "returns the describtion of the object server", (done) ->
      serverDesc = "This server manages users"
      @mgr.serverDescription = { "en-US":serverDesc }
      @mgr.serverAttributes =
        x: {type: "int", desc: {"en-US": "a magic number"}, writable: false }
      @result = new ltx.Element "iq",
        to:clientJID
        from:compJID
        id:'describe_id_0'
        type:'result'
      @result.c("describe", {xmlns: JOAP_NS})
        .c("desc", "xml:lang":'en-US').t(serverDesc).up()
        .c("attributeDescription", writable:'false')
          .c("name").t("x").up()
          .c("type").t("int").up()
          .c("desc","xml:lang":'en-US').t("a magic number").up().up()
        .c("class").t("user").up()
      @run (res) => @compare res; done()

  describe "rpc", ->

    class User
      constructor: (@name, @age) ->
        @id = "foo"
      getAge: -> @age
      @classMethod: (nr) -> 50 + nr

    beforeEach ->
      @mgr.addClass "user", User,
        required: ["name", "age"]
        protected: ["id"]
      @mgr.addServerMethod "serverMethod", (param) -> 2 * param
      @mgr._objects.user.foo = new User "Markus", 432

    it "can handle an instance rpc request", (done) ->
      @request = createRequest "query", "user", "foo"
      @request.children[0].c("methodCall").c("methodName").t("getAge")
      @result = new ltx.Element "iq",
        to:clientJID
        from:"user@#{compJID}/foo"
        id:'query_id_0'
        type:'result'
      @result.c("query", {xmlns: RPC_NS})
        .c("methodResponse").c("params").c("param").c("value").c("int").t("432")
      @run (res) => @compare res; done()

    it "can handle a class rpc request", (done) ->
      @request = createRequest "query", "user"
      @request.children[0].c("methodCall")
        .c("methodName").t("classMethod").up()
        .c("params").c("param").c("value").c("int").t("5")
      @result = new ltx.Element "iq",
        to:clientJID
        from:"user@#{compJID}"
        id:'query_id_0'
        type:'result'
      @result.c("query", {xmlns: RPC_NS})
        .c("methodResponse").c("params").c("param").c("value").c("int").t("55")
      @run (res) => @compare res; done()

    it "can handle a server rpc request", (done) ->
      @request = createRequest "query"
      @request.children[0].c("methodCall")
        .c("methodName").t("serverMethod").up()
        .c("params").c("param").c("value").c("int").t("3")
      @result = new ltx.Element "iq",
        to:clientJID
        from: compJID
        id:'query_id_0'
        type:'result'
      @result.c("query", {xmlns: RPC_NS})
        .c("methodResponse").c("params").c("param").c("value").c("int").t("6")
      @run (res) => @compare res; done()

    it "sends an rpc error if something went wrong", (done) ->
      @request = createRequest "query", "user", "foo"
      @request.children[0].c("methodCall").c("methodName").t("invalidMethod")
      @result = new ltx.Element "iq",
        to:clientJID
        from:"user@#{compJID}/foo"
        id:'query_id_0'
        type:'error'
      @result.c("query", {xmlns: RPC_NS})
        .c("methodResponse").c("fault").c("value").c("struct")
          .c("member")
            .c("name").t("faultCode").up()
            .c("value").c("int").t("0").up().up().up()
          .c("member")
            .c("name").t("faultString").up()
            .c("value").c("string").t("Instance method 'invalidMethod' does not exist").up().up()
      @run (res) => @compare res; done()
