joap = require "../lib/node-xmpp-joap"
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
    onData: (data, cb) ->

  run = (cb)->
    done = false
    result = null
    xmppClient.onData = (data) ->
      result = data
      done = true
    xmppClient.send @request
    waitsFor -> done
    runs ->
      cb?.call @, result

  compare = (res)->
    (expect res.toString()).toEqual @result.toString()

  it "creates objects for caching objetcs and classes", ->

    mgr = new joap.Manager xmppComp
    (expect typeof mgr.classes).toEqual "object"
    (expect typeof mgr.objects).toEqual "object"

  describe "add", ->

    createAddRequest = (clazz, instance) -> createRequest("add", clazz, instance)
    createAddErrorIq = (code, msg, clazz, instance) -> createErrorIq("add", code, msg, clazz, instance)

    beforeEach ->
      @mgr = new joap.Manager xmppComp
      @request = createAddRequest "user"
      class User
        constructor: (@name, @age)-> @id = "foo"
      @mgr.addClass "user", User, ["name"]

    it "returns an error if you are not authorized", ->
      @result = createAddErrorIq '403', "You are not authorized", "user"
      @mgr.hasPermission = (a, next) -> next false, a
      run.call @, compare

    it "returns an error if address isn't a class", ->
      @request.attrs.to += "/instance"
      @result = createAddErrorIq 405, "'user@#{compJID}/instance' isn't a class", "user", "instance"
      run.call @, compare

    it "returns an error if class doesn't exists", ->
      @result = createAddErrorIq 404, "Class 'sun' does not exists", "sun"
      @request = createAddRequest "sun"
      run.call @, compare

    it "returns an error if required attributes are not available", ->
      @result = createAddErrorIq 406, "Invalid constructor parameters", "user"
      run.call @, compare

    it "returns an error if required attributes are not correct", ->
      @request.getChild("add").cnode(new joap.Attribute "age", 33)
      @result = createAddErrorIq 406, "Invalid constructor parameters", "user"
      run.call @, compare

    it "returns the address of the new instance", ->
      @request.getChild("add")
        .cnode(new joap.Attribute "name", "Markus").up()
        .cnode(new joap.Attribute "age", 99).up()
      @result = new ltx.Element "iq",
        to:clientJID
        from:"user@#{compJID}"
        id:'add_id_0'
        type:'result'
      @result.c("add", xmlns:JOAP_NS).c("newAddress").t("user@#{compJID}/foo")
      run.call @, (result) ->
        compare.call @, result
        instance = @mgr.objects.user.foo
        (expect instance.id).toEqual "foo"
        (expect instance.name).toEqual "Markus"
        (expect instance.age).toEqual 99

    it "takes care of the attribute names", ->
      @request.getChild("add")
        .cnode(new joap.Attribute "age", 99).up()
        .cnode(new joap.Attribute "name", "Markus").up()
      @result = new ltx.Element "iq",
        to:clientJID
        from:"user@#{compJID}"
        id:'add_id_0'
        type:'result'
      @result.c("add", xmlns:JOAP_NS).c("newAddress").t("user@#{compJID}/foo")
      run.call @, (result) ->
        compare.call @, result
        instance = @mgr.objects.user.foo
        (expect instance.name).toEqual "Markus"
        (expect instance.age).toEqual 99

    it "creates a new ID", ->
      class Sun
      @mgr.addClass "sun", Sun
      @request = createAddRequest "sun"
      run.call @, (result) ->
        id = result.getChild("add").getChildText("newAddress").split('/')[1]
        (expect id).toNotEqual "foo"
        (expect id).toNotEqual ""
        (expect false).toNotEqual ""

    it "preserve an ID", ->
      class Sun
        constructor: (@id)->
      @mgr.addClass "sun", Sun
      @request = createAddRequest "sun"
      @request.getChild("add")
        .cnode(new joap.Attribute "id", 99.3)
      run.call @, (result) ->
        id = result.getChild("add").getChildText("newAddress").split('/')[1]
        (expect id).toEqual '99.3'

  describe "read", ->

    beforeEach ->
      @mgr = new joap.Manager xmppComp
      @request = createRequest "read", "user", "foo"

    it "returns an error if you are not authorized", ->
      @result = createErrorIq "read", '403', "You are not authorized", "user", "foo"
      @mgr.hasPermission = (a, next) -> next false
      run.call @, compare

    it "returns an error if the class doesn't exists", ->
      @result = createErrorIq "read", 404, "Class 'user' does not exists", "user", "foo"
      run.call @, compare

    it "returns an error if the instance doesn't exists", ->
      @mgr.addClass "user", (->)
      @result = createErrorIq "read", 404, "Object 'foo' does not exists", "user", "foo"
      run.call @, compare

    it "returns an error if the specified attribute doesn't exists", ->
      class User
        constructor: -> @id = "foo"
      @mgr.addClass "user", User
      @mgr.saveInstance {class:"user"}, (new User),  (err, a, addr) =>
        @request.getChild("read").c("name").t("age")
        @result = createErrorIq "read", 406, "Requested attribute 'age' doesn't exists", "user", "foo"
        run.call @, compare

    it "returns all attributes if nothing was specified", ->
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
          .cnode(new joap.Attribute "id", "foo").up()
          .cnode(new joap.Attribute "name", "Markus")
        run.call @, compare

    it "returns only the specified attributes", ->
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
          .cnode(new joap.Attribute "name", "Markus")
        run.call @, compare

  describe "edit", ->

    class User
      constructor: (@name, @age) -> @id = "foo"

    beforeEach ->
      @mgr = new joap.Manager xmppComp
      @mgr.addClass "user", User, ["name"], ["protected"]
      @mgr.objects.user.foo = new User "Markus", 123
      @request = createRequest "edit", "user", "foo"

    it "returns an error if you are not authorized", ->
      @result = createErrorIq "edit", '403', "You are not authorized", "user", "foo"
      @mgr.hasPermission = (a, next) -> next false
      run.call @, compare

    it "returns an error if the instance doesn't exists", ->
      @request = createRequest "edit", "user", "oof"
      @result = createErrorIq "edit", 404, "Object 'oof' does not exists", "user", "oof"
      run.call @, compare

    it "returns an error if specified object attributes are not writeable", ->
      @request.getChild("edit").cnode(new joap.Attribute "protected", "oof")
      @result = createErrorIq "edit", 406, "Attribute 'protected' of class 'user' is not writeable", "user", "foo"
      run.call @, compare

    it "changes the specified attributes", ->
      @request.getChild("edit")
        .cnode(new joap.Attribute "name", "oof").up()
        .cnode(new joap.Attribute "new", "attr")
      @result = new ltx.Element "iq",
        to:clientJID
        from:"user@#{compJID}/foo"
        id:'edit_id_0'
        type:'result'
      @result.c("edit", {xmlns: JOAP_NS})
      run.call @, ->
        instance = @mgr.objects.user.foo
        (expect instance.name).toEqual "oof"
        (expect instance.new).toEqual "attr"

    it "returns a new address if the id changed", ->
      @request.getChild("edit")
        .cnode(new joap.Attribute "id", "newId")
      @result = new ltx.Element "iq",
        to:clientJID
        from:"user@#{compJID}/foo"
        id:'edit_id_0'
        type:'result'
      @result.c("edit", {xmlns: JOAP_NS})
        .c("newAddress").t("user@#{compJID}/newId")
      run.call @, (res)->
        compare.call @, res
        instance = @mgr.objects.user.newId
        (expect typeof instance).toEqual "object"
        (expect instance.id).toEqual "newId"

  describe "delete", ->

    class User
      constructor: (@name, @age) -> @id = "foo"

    beforeEach ->
      @mgr = new joap.Manager xmppComp
      @mgr.addClass "user", User, ["name"], ["id"]
      @mgr.objects.user.foo = new User "Markus", 123
      @request = createRequest "delete", "user", "foo"

    it "returns an error if you are not authorized", ->
      @result = createErrorIq "delete", '403', "You are not authorized", "user", "foo"
      @mgr.hasPermission = (a, next) -> next false
      run.call @, compare

    it "returns an error if the instance doesn't exists", ->
      @request = createRequest "delete", "user", "oof"
      @result = createErrorIq "delete", 404, "Object 'oof' does not exists", "user", "oof"
      run.call @, compare

    it "returns an error if address is not an instance", ->
      @request = createRequest "delete"
      @result = createErrorIq "delete", 405, "'#{compJID}' is not an instance"
      run.call @, compare

    it "deletes the specified instance", ->
      @result = new ltx.Element "iq",
        to:clientJID
        from:"user@#{compJID}/foo"
        id:'delete_id_0'
        type:'result'
      @result.c("delete", {xmlns: JOAP_NS})
      users = @mgr.objects.user
      (expect users.foo).toBeDefined()
      run.call @, ->
        (expect users.foo).toBeUndefined()

  describe "describe", ->

    class User
      constructor: (@name, @age) ->
        @id = "foo"

    beforeEach ->
      @mgr = new joap.Manager xmppComp
      @mgr.addClass "user", User, ["name"], ["id"]
      @mgr.objects.user.foo = new User "Markus", 123
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
        .c("class").t("user").up()
      run.call @
