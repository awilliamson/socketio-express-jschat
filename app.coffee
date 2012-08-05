#Server Side

express = require('express')
routes = require('./routes')# Require some of our defined routes.
http = require('http')
cache = []


app = express()
app.set 'env', 'development'
server = http.createServer(app)
io = require('socket.io').listen(server)# As express didn't return a HTTP server :s This is the new way as of 3.x

#########################
# Configure Express     #
#########################

app.configure ->
  app.set 'views', __dirname + '/views'
  app.set 'view options', {layout: false} #Not using layout files :S
  app.engine 'html', require('ejs').renderFile #app.register is app.engine in express 3.0. Works nice for html serving
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static(__dirname + '/public')

app.configure 'development', -> #Configure dev mode
  app.use express.errorHandler( {dumpExceptions: true, showStack: true} )

app.configure 'production', -> #Configure production mode
  app.use express.errorHandler()

#########################
# Setup Routing         #
#########################

app.get "/", routes.index# Domain.com/ will be served, what's defined in routes/index

io.configure 'production', ->
  io.enable "browser client minification" # send minified client
  io.enable "browser client etag" # apply etag caching logic based on version number
  io.enable "browser client gzip" # gzip the file
  io.set "log level", 1 # reduce logging
  # enable all transports (optional if you want flashsocket)
  io.set "transports", ["websocket", "flashsocket", "htmlfile", "xhr-polling", "jsonp-polling"]

io.configure 'development', ->
  io.enable "browser client minification" # send minified client
  io.enable "browser client etag" # apply etag caching logic based on version number
  io.enable "browser client gzip" # gzip the file
  io.set "log level", 3 # reduce logging
  # enable all transports (optional if you want flashsocket)
  io.set "transports", ["websocket", "flashsocket", "htmlfile", "xhr-polling", "jsonp-polling"]

#########################
# Socket Handling Stuff #
#########################

io.sockets.on 'connection', (socket) -> # On connection

  socket.emit 'id', {id: socket.id}
  socket.emit 'cache', cache

  #socket.emit, similar to a PM to only that client.
  #socket.broadcast.emit, broadcasts to all but the current client
  #io.sockets.emit, way of hacking a broadcast to ALL connected clients

  socket.on 'set nick', (nick) ->
    
    socket.set 'nickname', (if nick? and nick isnt "" then nick else 'Guest')
    #Set nickname attribute if nick exists and isn't empty

    socket.get 'nickname', (err,nickname) -># Way of getting nickname attribute
      socket.broadcast.emit 'system', {type: "system", msg:"#{nickname} has joined."}

  socket.on 'message', (msg) -> #When server receives a message
    cache.shift() if cache.length > 10
    cache.push msg
    #This way allows system messages like "x has joined" to be omitted

    io.sockets.emit 'system', msg

  socket.on 'disconnect', -># When a client disconnects through leaving or timeout

    socket.get 'nickname', (err,nickname) ->
      socket.broadcast.emit 'system', {type: "system", msg:"#{nickname} has left."}

server.listen 80 #Listen port 80.
