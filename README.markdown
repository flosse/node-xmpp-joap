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
  constructor: (params) ->
    { @name, @age } = params

mgr = new joap.Manager comp
mgr.addClass "User", User, ["name"]
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

router.on "action", (action, clazz, instance, iq) ->
  if clazz? and instance? and action.type is "read"
    router.sendResponse joap.serialize(objects[clazz][instance], action), iq

router.on "read", (action, clazz, instance, iq) ->
  console.log "read iq received"

router.on "edit", (action, clazz, instance, iq) ->
  console.log "edit iq received"

router.on "add", (action, clazz, instance, iq) ->

  console.log "add iq received"

  if not classes[clazz]?
    router.sendError "add", 404, "The class '#{clazz}' does not exist.", iq

  # ...

router.on "rpc", (action, clazz, instance, iq) ->
  console.log "calling #{action.method} with:"
  for param in actions.params
    console.log param
```

## Running tests

```shell
jasmine-node --coffee --color spec/
```
