fs = require 'fs'

fs.readFile 'data/ids.json', (err, data) ->
  throw err if err
  ids = JSON.parse(data).ids

  request = require 'request'
  async = require 'async'

  max = 0
  paths = {}
  threads = 10

  grabPath = (task, callback) ->
    id = task?.id

    request "http://sgidevis00.metmuseum.org/MetDataService/MetData.asmx/getTmsPublicAccessMediaDataForObjectID?objectID=#{id}", (err, res, body) ->
      {parseString} = require 'xml2js'
      parseString body, (err, results) ->
        for result in results.results.result
          if +(result.PublicAccess[0]) is 1
            paths[id] = result.Path+result.FileName
        callback()

  q = async.queue grabPath, threads
  q.drain = -> writePaths()
  q.push {id} for id in ids
  
  writePaths = ->
    fs.appendFile 'data/paths.json', JSON.stringify(paths), (err) ->
      throw err if err
      process.exit()

  process.on 'exit', -> console.log 'goodbye!'
  process.on 'SIGINT', ->
    console.log 'interrupt'
    writePaths()