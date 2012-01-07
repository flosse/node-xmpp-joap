{exec}    = require 'child_process'

task 'test', "runnig tests", ->
  exec "jasmine-node --coffee spec/", (err, out) ->
    console.log err if err?
    console.log out
