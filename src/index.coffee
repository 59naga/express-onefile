# Dependencies
express= require 'express'
onefile= require 'onefile'

# Public
expressOnefile= ({cwd,filename}={})->
  middleware= express.Router()

  cwd?= process.cwd()
  filename?= 'pkgs'

  cache= null
  cacheMin= null
  cacheMap= null

  onefileMinify= (callback)->
    options= {
      cwd
      outputName: filename+'.min'
      mangle: yes
      detachSourcemap: yes
    }

    onefile options
    .on 'data',(file)->
      cacheMin= file.contents if file.path.slice(-3) is '.js'
      cacheMap= file.contents if file.path.slice(-4) is '.map'

    .on 'end',callback

  middleware.get '/'+filename+'.js',(req,res)->
    res.set 'Content-type','application/javascript'

    return res.send cache if cache

    onefile {cwd}
    .on 'data',(file)->
      cache= file.contents

    .on 'end',->
      res.send cache

  middleware.get '/'+filename+'.min.js',(req,res)->
    res.set 'Content-type','application/javascript'

    return res.send cacheMin if cacheMin
      
    onefileMinify ->
      res.send cacheMin

  middleware.get '/'+filename+'.min.js.map',(req,res)->
    res.set 'Content-type','application/json'

    return res.send cacheMap if cacheMap
      
    onefileMinify ->
      res.send cacheMap

  middleware

module.exports= expressOnefile
