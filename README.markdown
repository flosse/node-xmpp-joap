# node-xmpp-joap

Jabber Object Access Protocol
[XEP-0075](http://xmpp.org/extensions/xep-0075.html) library for
[node-xmpp](https://github.com/astro/node-xmpp).

[![Build Status](https://secure.travis-ci.org/flosse/node-xmpp-joap.png)](http://travis-ci.org/flosse/node-xmpp-joap)

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
mgr.hasPermission = (action, next) ->
  if myACLRules(action) then next null, action
  else next (new joap.Error "You are not allowed to do that :-P"), 403
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
    mgr.saveInstance = (action, obj, next) ->
      if action.class is "User"
        users.save obj.id, obj, (err) -> next err, action
      else
        next (new Error "Storage for this class is not available"), a

    # override
    mgr.loadInstance = (action, next) ->
      if action.class is "User"
        users.get id, (err, inst) -> next err, action, inst
      else
        next (new Error "Storage for this class is not available"), a

    # override
    mgr.queryInstances = (a, next) ->
      if a.class is "User"
        if a.attributess?
          @users.find a.attributes, (err, res) -> next err, a, (id for id of res)
        else
          @users.all (err, res) -> next err, a, (id for id of res)
      else
        next (new Error "Storage for this class is not available"), a

    # override
    mgr.deleteInstance = (a, next) ->
      if a.class is "User"
        users.remove id, (err) -> next err, a
      else
        next (new Error "Storage for this class is not available"), a
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
    router.sendError (new joap.Error "'#{action.class}' does't exists.", 404), action

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
