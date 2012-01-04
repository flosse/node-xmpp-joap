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

router.on "rpc", (action) ->
  console.log "calling #{action.method} with:"
  for param in actions.params
    console.log param
```

## Running tests

```shell
jasmine-node --coffee --color spec/
```
