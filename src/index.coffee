# Dependencies
Promise= require 'bluebird'

express= require 'express'
onefile= require 'onefile'

# Private
onefilePlain= ({cwd}={})->
  script= null

  new Promise (resolve)->
    onefile {cwd}
    .on 'data',(file)->
      script= file.contents

    .on 'end',->
      resolve [script]

onefileMinify= ({cwd,filename}={})->
  options= {
    cwd
    outputName: filename+'.min'
    mangle: yes
    detachSourcemap: yes
  }

  new Promise (resolve)->
    min= null
    map= null

    onefile options
    .on 'data',(file)->
      min= file.contents if file.path.slice(-3) is '.js'
      map= file.contents if file.path.slice(-4) is '.map'

    .on 'end',->
      resolve [min,map]

# Public
expressOnefile= ({cwd,filename}={})->
  middleware= express.Router()

  cwd?= process.cwd()
  filename?= 'pkgs'

  task= null
  middleware.get '/'+filename+'.js',(req,res)->
    res.set 'Content-type','application/javascript'

    task?= onefilePlain {cwd}

    task
    .spread (script)->
      res.send script

  taskMinify= null
  middleware.get '/'+filename+'.min.js',(req,res)->
    res.set 'Content-type','application/javascript'
    
    taskMinify?= onefileMinify {cwd,filename}

    taskMinify
    .spread (cacheMin,cacheMap)->
      res.send cacheMin

  middleware.get '/'+filename+'.min.js.map',(req,res)->
    res.set 'Content-type','application/json'

    taskMinify?= onefileMinify {cwd,filename}

    taskMinify
    .spread (cacheMin,cacheMap)->
      res.send cacheMap

  middleware

module.exports= expressOnefile
