{parseString} = require 'xml2js'
request = require 'request'
async = require 'async'
fs = require 'fs'

threads = 10

last_href_page = 0
hrefs_processing = []
ids_processing = []

paths = {}

Array::remove = (e) -> @[t..t] = [] if (t = @indexOf(e)) > -1

processHref = (task, callback) ->
    href = task?.href
    if href in hrefs_processing
        callback()
    else
        hrefs_processing.push href

        request {url: href, json: true}, (err, res, body) ->
            if body?.collection?.items?
                ids = (/\d+/.exec(link.href)?[0] for link in body.collection.items)
                ids_q.push ids..., (err) -> console.log "pushed ids #{ids}"

            if next = body?._links?.next?.href
                hrefs_q.push {href}, (err) -> console.log "pushed href #{href}"
            else unless +(/[0-9]+/.exec(href)?[0]) is max
                hrefs_processing.remove href
                hrefs_q.push {href}, (err) -> console.log "retrying #{href}"

            callback()

processId = (task, callback) ->
    id = task?.id
    if id in ids_processing
        callback()
    else
        retry_id = ->
            ids_processing.remove id
            ids_q.push {id}, (err) -> console.log "retrying #{id}"
            callback()
        ids_processing.push id

        request "http://sgidevis00.metmuseum.org/MetDataService/MetData.asmx/getTmsPublicAccessMediaDataForObjectID?objectID=#{id}", (err, res, body) ->
            retry_id() if err

            parseString body, (err, results) ->
                retry_id() if err
                    for result in results.results.result
                        if +(result.PublicAccess[0]) is 1
                            paths[id] = result.Path+result.FileName
                    callback()

hrefs_q = async.queue processHref, threads
ids_q = async.queue processId, threads

hrefs_q.drain = -> console.log "#{ids.length} ids found"
ids_q.drain = -> writePaths()

writePaths = -> 
    fs.appendFile 'data/paths.json', JSON.stringify(paths), (err) ->
        throw err if err
        process.exit()

# Always try to write some ids
process.on 'exit', -> console.log 'goodbye!'
process.on 'SIGINT', -> writePaths()

# Start by listing all ids with images
request 'http://scrapi.org/ids?images=true', (err, res, body) ->
    max = + /[0-9]+/.exec(JSON.parse(body)?._links?.last?.href)?[0]
    starting_pages = (Math.max(1,Math.round(max*(thread-1)/threads)) for thread in [1..threads])
    id_q.push {href: 'http://scrapi.org/ids?images=true&page='+page} for page in starting_pages