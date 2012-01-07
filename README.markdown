# node-xmpp-joap

Jabber Object Access Protocol
[XEP-0075](http://xmpp.org/extensions/xep-0075.html) library for
[node-xmpp](https://github.com/astro/node-xmpp).

## Installation

With package manager [npm](http://npmjs.org/):

    npm install node-xmpp-joap

## Usage

### Manager

```coffeescript
xmpp = require "node-xmpp"
joap = require "node-xmpp-joap"

comp = new xmpp.Component
  jid       : "mycomponent"
  password  : "secret"
  host      : "127.0.0.1"
  port      : "8888"

class User
  constructor: (@name, @age) ->

# create a new manager instance
mgr = new joap.Manager comp

# add a class
mgr.addClass "User", User, ["name", "age"], ["name"]

# implement the ACL by overriding the method
mgr.hasPermission = (action) ->

  if myACLRules(action.from, action.type, action.class, action.instance)
    true
  else
    false
```

#### Persistence

If you want to persist the objects in a database you can simply override the
methods `saveInstance`, `loadInstance` and `deleteInstance`.
In this example we use [nStore](https://github.com/creationix/nstore).

```coffeescript
nStore  = require "nstore"

# create database
users = nStore.new './data/users.db', (err) ->

  if err?
    console.error err
  else

    # override
    mgr.saveInstance = (clazz, id, obj, next) ->
      if clazz is "User"
        users.save id, obj, next
      else
        next new Error "Storage for this class is not available"

    # override
    mgr.loadInstance = (clazz, id, next) ->
      if clazz is "User"
        users.get id, next
      else
        next new Error "Storage for this class is not available"

    # override
    mgr.queryInstances = (clazz, attrs, next) ->
      if clazz is "User"
        next = attrs; attrs = null if typeof attrs is "function"
        if attrs?
          @users.find attrs, (err, res) -> next err, (id for id of res)
        else @users.all (err, res) -> next err, (id for id of res)
      else
        next new Error "Storage for this class is not available"

    # override
    mgr.deleteInstance = (clazz, id, next) ->
      if clazz is "User"
        users.remove id, next
      else
        next new Error "Storage for this class is not available"
```

### Router

```coffeescript
xmpp = require "node-xmpp"
joap = require "node-xmpp-joap"

comp = new xmpp.Component
  jid       : "mycomponent"
  password  : "secret"
  host      : "127.0.0.1"
  port      : "8888"

classes = {}
objects = {}

router = new joap.Router comp

router.on "action", (a) ->
  if a.class? and a.instance? and a.type is "read"
    router.sendResponse a, objects[a.class][a.instance]

router.on "read", (action) ->
  console.log "read iq received"

router.on "edit", (action) ->
  console.log "edit iq received"

router.on "add", (action) ->
  console.log "add iq received"

  if not classes[action.class]?
    router.sendError "add", 404, "The class '#{action.class}' does not exists."

  # ...

router.on "search", (action) ->

router.on "rpc", (action) ->
  console.log "calling #{action.method} with:"
  for param in actions.params
    console.log param
```

## Running tests

[jasmine-node](https://github.com/mhevery/jasmine-node)
is required (`npm install -g jasmine-node`) for running the tests.

```shell
cake test
```

## JOAP client implementations

- [strophe.js plugin](https://github.com/metajack/strophejs-plugins/tree/master/joap)

## ToDo's

- describe support
- Jabber RPC support

## License

node-xmpp-joap is licensed under the MIT-Licence (see LICENSE.txt)
