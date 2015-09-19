# Dependencies
express= require 'express'
onefile= require 'onefile'

# Public
expressOnefile= ({cwd,filename}={})->
  middleware= express.Router()

  cwd?= process.cwd()
  filename?= 'pkgs'

  cacheDevelop= null
  middleware.get '/'+filename+'.js',(req,res)->
    res.set 'Content-type','application/javascript'

    if cacheDevelop
      res.send cacheDevelop

    else
      onefile {cwd}
      .on 'data',(file)->
        cacheDevelop= file.contents

      .on 'end',->
        res.send cacheDevelop

  cacheProduction= null
  middleware.get '/'+filename+'.min.js',(req,res)->
    res.set 'Content-type','application/javascript'

    if cacheProduction
      res.send cacheProduction
      
    else
      onefile {cwd,mangle:yes}
      .on 'data',(file)->
        cacheProduction= file.contents

      .on 'end',->
        res.send cacheProduction

  middleware

module.exports= expressOnefile
