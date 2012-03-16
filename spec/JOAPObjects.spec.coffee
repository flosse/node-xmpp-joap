joap = require "../lib/node-xmpp-joap"

describe "JOAPClass", ->

  it "is has a constructor", ->
    obj = new joap.object.Class "component.tld"
    (expect typeof obj.jid).toEqual "object"
    (expect typeof obj.creator).toEqual "function"
    (expect typeof obj.attributes).toEqual "object"
    (expect typeof obj.methods).toEqual "object"
    (expect typeof obj.timestamp).toEqual "object"
    (expect typeof obj.description).toEqual "object"
    (expect typeof obj.definitions).toEqual "object"
    (expect typeof obj.definitions.attributes).toEqual "object"
    (expect typeof obj.definitions.methods).toEqual "object"

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

     (expect typeof userClz.timestamp).toEqual "object"
     (expect typeof userClz.description).toEqual "object"
     (expect typeof userClz.definitions.methods.staticMethod).toEqual "object"
     (expect typeof userClz.definitions.attributes.staticAttribute).toEqual "object"
     (expect userClz.attributes.staticAttribute).toEqual "test"
     (expect userClz.methods.staticMethod).toEqual aMethod

     defMethods = userClz.definitions.methods
     (expect defMethods.method.classMethod).toEqual false
     (expect defMethods.staticMethod.classMethod).toEqual true

     defAttrs = userClz.definitions.attributes
     (expect defAttrs.staticAttribute.classAttribute).toEqual true
     (expect defAttrs.staticAttribute.required).toEqual false
     (expect defAttrs.name.required).toEqual true
     (expect defAttrs.name.writable).toEqual false


  it "can have a reference to a superclass", ->
    obj = new joap.object.Class "class@comp.tld",
      superclass: "super@comp.tld"
    (expect typeof obj.jid).toEqual "object"
    (expect typeof obj.superclass).toEqual "object"
    (expect obj.superclass.user).toEqual "super"

describe "Description", ->

  it "can have descriptions in multiple languages", ->
    des = new joap.object.Description
        en: "My class"
        de: "Meine Klasse"
    (expect des.en).toEqual "My class"
    (expect des.de).toEqual "Meine Klasse"

describe "Attribute Definition", ->

  it "has a required and a writable flag", ->
    attr = new joap.object.AttributeDefinition
    (expect attr.writable).toEqual true
    (expect attr.required).toEqual false
    attr = new joap.object.AttributeDefinition { writable: true, required: true }
    (expect attr.writable).toEqual true
    (expect attr.required).toEqual true

  it "has a flag that indicates if it is an class attribute ", ->
    attr = new joap.object.AttributeDefinition
    (expect attr.classAttribute).toEqual false

  it "can have a description", ->
    attr = new joap.object.AttributeDefinition description: (new joap.object.Description)
    (expect typeof attr.description).toEqual "object"

  it "describes the data type", ->
    attr = new joap.object.AttributeDefinition
    (expect typeof attr.type).toEqual "string"


describe "Method Definition", ->

  it "has a flag that indicates if it is an class method", ->
    m = new joap.object.MethodDefinition
    (expect m.classMethod).toEqual false

  it "can have parameter descriptions", ->
    m = new joap.object.MethodDefinition parameters: {a: (new joap.object.ParameterDefinition) }
    (expect typeof m.parameters).toEqual "object"
    (expect typeof m.parameters.a.type).toEqual "string"
