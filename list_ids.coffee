request = require 'request'
async = require 'async'
fs = require 'fs'

ids = []
working = []
seen = []
threads = 3

Array::remove = (e) -> @[t..t] = [] if (t = @indexOf(e)) > -1

grabIds = (task, callback) ->
    working.push task?.href
    fs.appendFile 'working.json', task?.href+'\n', (err) -> throw err if err

    request {url: task?.href, json: true}, (err, res, body) ->
        if body?.collection?.items?
            new_ids = (/\d+/.exec(link.href)?[0] for link in body.collection.items)
            ids.push new_ids...
            fs.appendFile 'ids.json', new_ids, (err) -> throw err if err

        next = body?._links?.next?.href
        addToQueue next if next
        callback()

addToQueue = (href) ->
    unless href in seen.concat working
        q.push {href}, (err) ->
            console.log "pushed href #{href}"
            seen.push href
            working.remove href

q = async.queue grabIds, threads
q.drain = ->
    console.log "#{seen} seen, #{working} working:"
    console.log ids

request 'http://scrapi.org/ids', (err, res, body) ->
    max = + /[0-9]+/.exec(JSON.parse(body)?._links?.last?.href)?[0]
    starting_pages = (Math.max(1,Math.round(max*(thread-1)/threads)) for thread in [1..threads])
    q.push {href: 'http://scrapi.org/ids?page='+page} for page in starting_pages