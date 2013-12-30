fs = require 'fs'
{extname} = require 'path'

child_process = require 'child_process'
use_cp = fs.existsSync '/bin/cp'

fs.readFile 'data/paths.json', (err, data) ->
  throw err if err
  paths = JSON.parse data

  async = require 'async'

  threads = 10

  grabImage = (task, callback) ->
    id = task?.id
    source = task?.path.split('\\').join('/').replace('/mma/shares','Volumes')
    dest = 'images/'+id+extname(source).toLowerCase()
    console.log "#{source} => #{dest}"

    if use_cp
      child_process.execFile '/bin/cp', [source, dest]
    else
      fs.createReadStream(source).pipe(fs.createWriteStream(dest))

  q = async.queue grabImage, threads
  q.drain = -> process.exit()
  q.push {id,path} for id,path of paths
  
  process.on 'exit', -> console.log 'goodbye!'   