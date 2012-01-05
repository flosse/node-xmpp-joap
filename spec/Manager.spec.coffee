joap = require "node-xmpp-joap"
ltx  = require "ltx"

JOAP_NS = "jabber:iq:joap"

describe "Manager", ->

  compJID   = "comp.exmaple.tld"
  clientJID = "client@exmaple.tld"

  createErrorIq = (type, code, msg, clazz, instance) ->
    from = compJID
    from = "#{clazz}@#{from}" if clazz?
    from += "/#{instance}"    if instance?
    errMsg = new joap.ErrorIq type, code, msg,
      to:   clientJID
      from: from
      id:   "#{type}_id_0"

  createRequest = (type, clazz, instance) ->
    to = compJID
    to = "#{clazz}@#{to}" if clazz?
    to += "/#{instance}"  if instance?
    iq = new ltx.Element "iq",
      to: to
      from:clientJID
      id:"#{type}_id_0"
      type:'set'
    iq.c type, xmlns:JOAP_NS
    iq

  xmppComp =
    channels: {}
    send: (data) -> xmppClient.onData data
    onData: (data) ->
    on: (channel, cb) ->
      @channels[channel] = cb
    jid: compJID

  xmppClient =
    send: (data) -> xmppComp.channels.stanza data
    onData: (data) ->

  run = ->
    spy = jasmine.createSpy "spy"
    xmppClient.onData = (data) =>
      (expect data.toString()).toEqual @result.toString()
      spy()
    xmppClient.send @request
    (expect spy).toHaveBeenCalled()

  it "creates objects for caching objetcs and classes", ->

    mgr = new joap.Manager xmppComp
    (expect typeof mgr.classes).toEqual "object"
    (expect typeof mgr.objects).toEqual "object"

  describe "add", ->

    createAddRequest = (clazz, instance) -> createRequest("add", clazz, instance)
    createAddErrorIq = (code, msg, clazz, instance) -> createErrorIq("add", code, msg, clazz, instance)

    beforeEach ->
      @mgr = new joap.Manager xmppComp
      @request = createAddRequest "User"

    it "returns an error if you are not authorized", ->
      @result = createAddErrorIq '403', "You are not authorized", "User"
      @mgr.hasPermission = -> false
      run.call @

    it "returns an error if address isn't a class", ->
      @request.attrs.to += "/instance"
      @result = createAddErrorIq 405, "'User@#{compJID}/instance' isn't a class", "User", "instance"
      run.call @

    it "returns an error if class doesn't exists", ->
      @result = createAddErrorIq 404, "Class 'User' does not exists", "User"
      run.call @

    it "returns an error if required attributes are not available", ->
      class User
      @mgr.addClass "User", User, ["name"]
      @result = createAddErrorIq 406, "Invalid constructor parameters", "User"
      run.call @

    it "returns an error if required attributes are not correct", ->
      class User
      @mgr.addClass "User", User, ["name"]
      @request.getChild("add").cnode(new joap.Attribute "age", 33)
      @result = createAddErrorIq 406, "Invalid constructor parameters", "User"
      run.call @

    it "returns the address of the new instance", ->
      class User
        constructor: (@name, @age)->
          @id = "foo"
      @mgr.addClass "User", User, ["name"]
      @request.getChild("add")
        .cnode(new joap.Attribute "name", "Markus").up()
        .cnode(new joap.Attribute "age", 99).up()
      @result = createAddRequest()
      @result = new ltx.Element "iq",
        to:clientJID
        from:"User@#{compJID}"
        id:'add_id_0'
        type:'result'
      @result.c("add", xmlns:JOAP_NS).c("newAddress").t("User@#{compJID}/foo")
      run.call @
      instance = @mgr.objects.User.foo
      (expect instance.id).toEqual "foo"
      (expect instance.name).toEqual "Markus"
      (expect instance.age).toEqual 99

    it "takes care of the attribute names", ->
      class User
        constructor: (@name, @age)->
          @id = "foo"
      @mgr.addClass "User", User, ["name"]
      @request.getChild("add")
        .cnode(new joap.Attribute "age", 99).up()
        .cnode(new joap.Attribute "name", "Markus").up()
      @result = createAddRequest()
      @result = new ltx.Element "iq",
        to:clientJID
        from:"User@#{compJID}"
        id:'add_id_0'
        type:'result'
      @result.c("add", xmlns:JOAP_NS).c("newAddress").t("User@#{compJID}/foo")
      run.call @
      instance = @mgr.objects.User.foo
      (expect instance.name).toEqual "Markus"
      (expect instance.age).toEqual 99

  describe "read", ->

    beforeEach ->
      @mgr = new joap.Manager xmppComp
      @request = createRequest "read", "User", "foo"

    it "returns an error if you are not authorized", ->
      @result = createErrorIq "read", '403', "You are not authorized", "User", "foo"
      @mgr.hasPermission = -> false
      run.call @

    it "returns an error if the class doesn't exists", ->
      @result = createErrorIq "read", 404, "Class 'User' does not exists", "User", "foo"
      run.call @

    it "returns an error if the instance doesn't exists", ->
      @mgr.addClass "User", (->)
      @result = createErrorIq "read", 404, "Object 'foo' does not exists", "User", "foo"
      run.call @

    it "returns an error if the specified attribute doesn't exists", ->
      class User
        constructor: ->
          @id = "foo"
      @mgr.addClass "User", User
      @mgr.createInstance {class:"User"}, =>
        @request.getChild("read").c("name").t("age")
        @result = createErrorIq "read", 406, "Requested attribute 'age' doesn't exists", "User", "foo"
        run.call @

    it "returns all attributes if nothing was specified", ->
      class User
        constructor: ->
          @id = "foo"
          @name = "Markus"
      @mgr.addClass "User", User
      @mgr.createInstance {class:"User"}, =>
        @result = new ltx.Element "iq",
          to:clientJID
          from:"User@#{compJID}/foo"
          id:'read_id_0'
          type:'result'
        @result.c("read", {xmlns: JOAP_NS})
          .cnode(new joap.Attribute "id", "foo").up()
          .cnode(new joap.Attribute "name", "Markus")
        run.call @

    it "returns only the specified attributes", ->
      class User
        constructor: ->
          @id = "foo"
          @name = "Markus"
      @mgr.addClass "User", User
      @mgr.createInstance {class:"User"}, =>
        @request.getChild("read").c("name").t("name")
        @result = new ltx.Element "iq",
          to:clientJID
          from:"User@#{compJID}/foo"
          id:'read_id_0'
          type:'result'
        @result.c("read", {xmlns: JOAP_NS})
          .cnode(new joap.Attribute "name", "Markus")
        run.call @

  describe "edit", ->

    class User
      constructor: (@name, @age) ->
        @id = "foo"

    beforeEach ->
      @mgr = new joap.Manager xmppComp
      @mgr.addClass "User", User, ["name"], ["id"]
      @mgr.objects.User.foo = new User "Markus", 123
      @request = createRequest "edit", "User", "foo"

    it "returns an error if you are not authorized", ->
      @result = createErrorIq "edit", '403', "You are not authorized", "User", "foo"
      @mgr.hasPermission = -> false
      run.call @

    it "returns an error if the instance doesn't exists", ->
      @request = createRequest "edit", "User", "oof"
      @result = createErrorIq "edit", 404, "Object 'oof' does not exists", "User", "oof"
      run.call @

    it "returns an error if specified object attributes are not writeable", ->
      @request.getChild("edit").cnode(new joap.Attribute "id", "oof")
      @result = createErrorIq "edit", 406, "Attribute 'id' of class 'User' is not writeable", "User", "foo"
      run.call @

    it "changes the specified attributes", ->
      @request.getChild("edit")
        .cnode(new joap.Attribute "name", "oof").up()
        .cnode(new joap.Attribute "new", "attr")
      @result = new ltx.Element "iq",
        to:clientJID
        from:"User@#{compJID}/foo"
        id:'edit_id_0'
        type:'result'
      @result.c("edit", {xmlns: JOAP_NS})
      run.call @
      instance = @mgr.objects.User.foo
      (expect instance.name).toEqual "oof"
      (expect instance.new).toEqual "attr"

  describe "delete", ->

    class User
      constructor: (@name, @age) ->
        @id = "foo"

    beforeEach ->
      @mgr = new joap.Manager xmppComp
      @mgr.addClass "User", User, ["name"], ["id"]
      @mgr.objects.User.foo = new User "Markus", 123
      @request = createRequest "delete", "User", "foo"

    it "returns an error if you are not authorized", ->
      @result = createErrorIq "delete", '403', "You are not authorized", "User", "foo"
      @mgr.hasPermission = -> false
      run.call @

    it "returns an error if the instance doesn't exists", ->
      @request = createRequest "delete", "User", "oof"
      @result = createErrorIq "delete", 404, "Object 'oof' does not exists", "User", "oof"
      run.call @

    it "returns an error if address is not an instance", ->
      @request = createRequest "delete"
      @result = createErrorIq "delete", 405, "'#{compJID}' is not an instance"
      run.call @

    it "deletes the specified instance", ->
      @result = new ltx.Element "iq",
        to:clientJID
        from:"User@#{compJID}/foo"
        id:'delete_id_0'
        type:'result'
      @result.c("delete", {xmlns: JOAP_NS})
      users = @mgr.objects.User
      (expect users.foo).toBeDefined()
      run.call @
      (expect users.foo).toBeUndefined()

  describe "describe", ->

    class User
      constructor: (@name, @age) ->
        @id = "foo"

    beforeEach ->
      @mgr = new joap.Manager xmppComp
      @mgr.addClass "User", User, ["name"], ["id"]
      @mgr.objects.User.foo = new User "Markus", 123
      @request = createRequest "describe"

    it "returns the describtion of the object server", ->
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
        .c("class").t("User").up()
      run.call @
