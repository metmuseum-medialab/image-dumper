request = require 'request'
async = require 'async'
fs = require 'fs'

max = 0
ids = []
working = []
seen = []
threads = 10

Array::remove = (e) -> @[t..t] = [] if (t = @indexOf(e)) > -1

grabIds = (task, callback) ->
    working.push task?.href

    request {url: task?.href, json: true}, (err, res, body) ->
        if body?.collection?.items?
            new_ids = (/\d+/.exec(link.href)?[0] for link in body.collection.items)
            ids.push new_ids...

        next = body?._links?.next?.href
        if next?
            addToQueue next
        else
            unless +(/[0-9]+/.exec(task?.href)?[0]) is max
                working.remove task?.href
                q.push {href: task?.href}, (err) ->
                    console.log "retried #{task.href}"

        callback()

addToQueue = (href) ->
    unless href in seen.concat working
        q.push {href}, (err) ->
            console.log "pushed href #{href}"
            seen.push href
            working.remove href

q = async.queue grabIds, threads

q.drain = -> writeIds()

request 'http://scrapi.org/ids?images=true', (err, res, body) ->
    max = + /[0-9]+/.exec(JSON.parse(body)?._links?.last?.href)?[0]
    starting_pages = (Math.max(1,Math.round(max*(thread-1)/threads)) for thread in [1..threads])
    q.push {href: 'http://scrapi.org/ids?images=true&page='+page} for page in starting_pages

writeIds = ->
    fs.appendFile 'data/ids.json', ids, (err) ->
        throw err if err
        process.exit()

process.on 'exit', -> console.log 'goodbye!'
process.on 'SIGINT', ->
    console.log 'interrupt'
    writeIds()