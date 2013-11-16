chai        = require 'chai'
expect      = chai.expect

joap = require "../src/node-xmpp-joap"

describe "JOAPClass", ->

  it "is has a constructor", ->
    obj = new joap.object.Class "component.tld"
    (expect typeof obj.jid).to.equal "object"
    (expect typeof obj.creator).to.equal "function"
    (expect typeof obj.attributes).to.equal "object"
    (expect typeof obj.methods).to.equal "object"
    (expect typeof obj.timestamp).to.equal "object"
    (expect typeof obj.description).to.equal "object"
    (expect typeof obj.definitions).to.equal "object"
    (expect typeof obj.definitions.attributes).to.equal "object"
    (expect typeof obj.definitions.methods).to.equal "object"

  it "automatically indicates methods and attributes", ->

     aMethod = (x)-> x*x

     class User
       constructor: (@name, @age)->
       method: ->
       attribute: "attr"
       @staticMethod: aMethod
       @staticAttribute: "test"

     userClz = new joap.object.Class "user@comp.domain.tld",
      creator: User
      required: ["name"]
      protected: ["name"]

     (expect typeof userClz.timestamp).to.equal "object"
     (expect typeof userClz.description).to.equal "object"
     (expect typeof userClz.definitions.methods.staticMethod).to.equal "object"
     (expect typeof userClz.definitions.attributes.staticAttribute).to.equal "object"
     (expect userClz.attributes.staticAttribute).to.equal "test"
     (expect userClz.methods.staticMethod).to.equal aMethod

     defMethods = userClz.definitions.methods
     (expect defMethods.method.classMethod).to.equal false
     (expect defMethods.staticMethod.classMethod).to.equal true

     defAttrs = userClz.definitions.attributes
     (expect defAttrs.staticAttribute.classAttribute).to.equal true
     (expect defAttrs.staticAttribute.required).to.equal false
     (expect defAttrs.name.required).to.equal true
     (expect defAttrs.name.writable).to.equal false


  it "can have a reference to a superclass", ->
    obj = new joap.object.Class "class@comp.tld",
      superclass: "super@comp.tld"
    (expect typeof obj.jid).to.equal "object"
    (expect typeof obj.superclass).to.equal "object"
    (expect obj.superclass.user).to.equal "super"

describe "Description", ->

  it "can have descriptions in multiple languages", ->
    des = new joap.object.Description
        en: "My class"
        de: "Meine Klasse"
    (expect des.en).to.equal "My class"
    (expect des.de).to.equal "Meine Klasse"

describe "Attribute Definition", ->

  it "has a required and a writable flag", ->
    attr = new joap.object.AttributeDefinition
    (expect attr.writable).to.equal true
    (expect attr.required).to.equal false
    attr = new joap.object.AttributeDefinition { writable: true, required: true }
    (expect attr.writable).to.equal true
    (expect attr.required).to.equal true

  it "has a flag that indicates if it is an class attribute ", ->
    attr = new joap.object.AttributeDefinition
    (expect attr.classAttribute).to.equal false

  it "can have a description", ->
    attr = new joap.object.AttributeDefinition description: (new joap.object.Description)
    (expect typeof attr.description).to.equal "object"

  it "describes the data type", ->
    attr = new joap.object.AttributeDefinition
    (expect typeof attr.type).to.equal "string"


describe "Method Definition", ->

  it "has a flag that indicates if it is an class method", ->
    m = new joap.object.MethodDefinition
    (expect m.classMethod).to.equal false

  it "can have parameter descriptions", ->
    m = new joap.object.MethodDefinition parameters: {a: (new joap.object.ParameterDefinition) }
    (expect typeof m.parameters).to.equal "object"
    (expect typeof m.parameters.a.type).to.equal "string"
