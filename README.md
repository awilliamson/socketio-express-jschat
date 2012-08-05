## Overview

A Javascript chat server, using [Express](http://expressjs.com) and [SocketIO](http://socket.io), styling with [Bootstrap CSS](http://twitter.github.com/bootstrap/) (heavily edited) aswell as plain HTML views.
This project was coded in [coffeescript](http://coffeescript.org), the js files are present thanks to the `cake file` for watching and compiling changes, whilst also running the node server and outputting anything from node through to console.

Currently set up for localhost running only, this can be change easily within `./public/javascripts/index.coffee` and changing:

	socket = io.connect('http://localhost')

to 

	socket = io.connect('http://domain.com')

Aslong as it connects to the server which will be running the main app.

## Execution/Run

Be sure to `npm install` when in the root, this will install all the modules defined in `package.json`
Feel free to check out `app.coffee` and change app.set `'env', 'development'` from dev to production if you want. See SocketIO docs for what each configuration option does. Main difference is logging.

When all the above is done, `cake watch` to watch coffeescript files, and recompile on change. This will also run the node server for you, and will display output from coffeescript and node in terminal.


## Background

I'm a 17 year old budding computer scientist, i'm pretty new to javascript and web development, let alone MVC and prototypes. This was my first attempt at creating such an application (interacting without using canvas) and my aim was to create a chat server which would use node, and would be fairly lightweight.

I am by no means an expert this took me around a week of on/off work, considering major reworks were done, and entire library changes (from sockJS to socketIO), any feedback is welcome.

## Plans for the future

Will hopefully continue work on this to create a better service, panel for connected users, fully functional chat commands like /pm nick msg and other such commands like MOTD, permissions for admins. Basically, IRC.