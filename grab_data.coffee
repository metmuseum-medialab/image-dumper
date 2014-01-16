util = require 'util'
fs = require 'fs'

fs.readFile 'data/ids.json', (err, data) ->
  throw err if err
  ids = JSON.parse(data).ids

  request = require 'request'
  async = require 'async'

  max = 0
  paths = {}

  write = (dest, body) ->
    console.log "writing #{dest}"
    fs.writeFile dest, JSON.stringify(body), (err) ->
      throw err if err

  grabPath = (task, callback) ->
    id = task?.id

    request.get {url: "http://scrapi.org/object/#{id}", json: true}, (err, res, object) =>    
      dest = "data/#{id}.json"
      fs.exists dest, (exists) ->
        if exists
          fs.stat dest, (err, stats) ->
            if stats.size > 512
              console.log "#{dest} exists"
              return callback()
            else
              write dest, object
              return callback()
        else
          write dest, object
          return callback()

  q = async.queue grabPath, 2
  q.drain = -> process.exit()
  q.push {id} for id in ids

  process.on 'exit', -> console.log 'goodbye!'
  process.on 'SIGINT', ->
    console.log 'interrupt'
    process.exit()