# Dependencies
Promise= require 'bluebird'

express= require 'express'
onefile= require 'onefile'

fs= require 'fs'
path= require 'path'

# Private
onefilePlain= ({cache,cwd}={})->
  script= null

  new Promise (resolve)->
    onefile {cwd}
    .on 'data',(file)->
      script= file.contents

      if cache
        fs.writeFileSync path.join(cwd,file.path),file.contents

    .on 'end',->
      resolve [script]

onefileMinify= ({cache,cwd,filename}={})->
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

      if cache
        fs.writeFileSync path.join(cwd,file.path),file.contents

    .on 'end',->
      resolve [min,map]

# Public
expressOnefile= ({cache,cwd,filename}={})->
  middleware= express.Router()

  cache?= process.env.NODE_ENV is 'production'
  cwd?= process.cwd()
  filename?= 'pkgs'

  task= null
  middleware.get '/'+filename+'.js',(req,res)->
    res.set 'Content-type','application/javascript'

    task?= onefilePlain {cache,cwd}

    task
    .spread (script)->
      res.send script

  taskMinify= null
  middleware.get '/'+filename+'.min.js',(req,res)->
    res.set 'Content-type','application/javascript'
    
    taskMinify?= onefileMinify {cache,cwd,filename}

    taskMinify
    .spread (cacheMin,cacheMap)->
      res.send cacheMin

  middleware.get '/'+filename+'.min.js.map',(req,res)->
    res.set 'Content-type','application/json'

    taskMinify?= onefileMinify {cache,cwd,filename}

    taskMinify
    .spread (cacheMin,cacheMap)->
      res.send cacheMap

  middleware

module.exports= expressOnefile
