fs = require 'fs'
use_cp = fs.existsSync '/bin/cp'

fs.readFile 'data/paths.json', (err, data) ->
  throw err if err
  paths = JSON.parse data

  async = require 'async'

  threads = 10

  grabImage = (task, callback) ->
    source = task?.path.replace('\\\\mma','/Volumes').replace('\\\\','/')
    id = task?.id
    ext = path.split('.')
    ext = ext[ext.length-1]
    dest = 'images/'+id+'.'+ext
    console.log source +' => '+ dest

    if use_cp
      child_process.execFile '/bin/cp', ['--no-target-directory', source, dest]
    else
      fs.createReadStream(source).pipe(fs.createWriteStream(dest))

  q = async.queue grabImage, threads
  q.drain = -> process.exit()
  q.push {id,path} for id,path of paths
  
  process.on 'exit', -> console.log 'goodbye!'   