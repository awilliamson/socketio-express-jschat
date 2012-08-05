$(document).ready ->

  socket = io.connect('http://localhost')

  class MsgModel extends Backbone.Model
    defaults: #Defaults will take effect if the field isn't stated in creation.
      id: false
      type: 'message'
      msg: "Some Message"

  class ChatLog extends Backbone.Collection #Our Collection of messages
    model: MsgModel

  class MsgView extends Backbone.View #View for a message
    tagName: "p" #Could be li or a whatever HTML floats your boat.
    initialize: ->
      _.bindAll(@,"render") # look up underscore bindAll, real handy.

    render: -> #Self rendering messages :D
      $(@el).attr('class', @model.get 'type' ) #Set the class attrib to the type of message
      $(@el).append @model.get 'msg'
      return @

  class ChatView extends Backbone.View #ChatView, the whole thing.

    el: $('#msgarea') #Look at index.html for that id

    self = @

    $("#chatForm").bind 'submit', (e) ->
      e.preventDefault() #Instantly stop the page thinking we want a refresh!!!
      return if $('#message').val() is ''
      self.sendMessage({msg: "<b>#{self.nick}</b>: #{$('#message').val()}", type: 'message', id: MsgModel.prototype.defaults.id}) # Send the messsage to the server
      $('#message').val('') #Set the field blank

    initialize: ->
      _.bindAll(@, 'render','addMsg', 'appendMsg', 'sendMessage')

      @collection = new ChatLog() #Define our collection
      @collection.bind 'add', @appendMsg #bind @collection.add whatever to go onto the chatview.appendmsg func

      @render() #Render our view

    render: ->
      self = @
      $(@el).html("<p class='system'>Connecting...</p>") #Initial message
      _(@collection.models).each (item) -> #Just incase the collection isn't empty
        self.appendMsg(msg)

      ,this

    addMsg: (data)->
      msg = new MsgModel data #Make a new MsgModel with out message data
      @collection.add msg #Add to collection, which will invoke appendMsg with msg

    appendMsg: (msg) ->
      msgView = new MsgView model: msg #Make message view, passing it the msg model.
      $(@el).append(msgView.render().el) # Message is self rendering
      @el.scrollTop(@el[0].scrollHeight) #Set the scroll height, so we'll always see the latest message

    sendMessage: (data) -># Send data to the server
      return if !data || !data.id
      socket.emit 'message', data #Send the data to server under 'message'

    socket.on 'id', (data) -> #When we get the message from the server about ID

      if MsgModel.prototype.defaults.id is not data.id #If the id sent differs from our version
        MsgModel.prototype.defaults.id = data.id #Update the prototype (so it propagates through all known instances)

    socket.on 'connect', -> #Soon as we connect
      socket.emit 'set nick', self.nick = prompt("Enter your username: ")
      self.addMsg {type: "message", msg: "Welcome to RadonChat, your username is <b>#{self.nick}</b>."} #Add a welcome message clientSide

    socket.on 'system', (data) ->
      if data.id is MsgModel.prototype.defaults.id #If the message and client ID's match
        data.type = 'me'# Then the type is 'me' because the message was obviously sent from us

      self.addMsg data# So add it

    socket.on 'cache', (cache) -> #When we get the history, cycle and add
      for data in cache
        self.addMsg data

  chatView = new ChatView