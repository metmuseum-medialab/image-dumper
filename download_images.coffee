fs = require 'fs'
{extname} = require 'path'
n = 0

fs.readFile 'data/paths.json', (err, data) ->
  throw err if err
  paths = JSON.parse data
  console.log Object.keys(paths).length + " images to copy"

  async = require 'async'

  copy = (source, dest) ->
    console.log "#{source} => #{dest}"
    n++
    fs.createReadStream(source).pipe(fs.createWriteStream(dest))

  grabImage = (task, callback) ->
    id = task?.id
    source = task?.path.split('\\').join('/').replace('/mma/shares','Volumes')
    dest = 'images/'+id+extname(source).toLowerCase()

    fs.exists dest, (exists) ->
      if exists
        fs.stat dest, (err, stats) ->
          if stats.size > 1024
            console.log "#{dest} exists"
            return callback()
          else
            console.log "recopying #{dest} because its too small"
            copy source, dest
            return callback()
      else
        copy source, dest
        return callback()

  q = async.queue grabImage, 2
  q.drain = -> drain()
  q.push {id, path} for id,path of paths
  
  drain = ->
    console.log "copied #{n} images"
    process.exit()

  process.on 'exit', -> console.log 'goodbye!'
  process.on 'SIGINT', ->
    console.log 'interrupt'
    drain()