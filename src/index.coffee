# Dependencies
express= require 'express'
onefile= require 'onefile'

# Public
expressOnefile= ({cwd,filename}={})->
  middleware= express.Router()

  cwd?= process.cwd()
  filename?= 'pkgs'

  cache= null
  middleware.get '/'+filename+'.js',(req,res)->
    res.set 'Content-type','application/javascript'

    if cache
      res.send cache

    else
      onefile {cwd}
      .on 'data',(file)->
        cache= file.contents

      .on 'end',->
        res.send cache

  cacheMin= null
  cacheMap= null
  middleware.get '/'+filename+'.min.js',(req,res)->
    res.set 'Content-type','application/javascript'

    if cacheMin
      res.send cacheMin
      
    else
      minify ->
        res.send cacheMin

  middleware.get '/'+filename+'.min.js.map',(req,res)->
    res.set 'Content-type','application/json'

    if cacheMap
      res.send cacheMap
      
    else
      minify ->
        res.send cacheMap

  minify= (callback)->
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

  middleware

module.exports= expressOnefile
