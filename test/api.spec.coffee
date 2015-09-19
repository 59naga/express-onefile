# Dependencies
onefile= require '../src'
express= require 'express'
supertest= require 'supertest'

spawn= (require 'child_process').spawn

# Environment
jasmine.DEFAULT_TIMEOUT_INTERVAL= 10000

# Specs
describe 'expressOnefile',->
  server= null
  beforeEach (done)->
    spawn 'bower',['install'],{cwd:__dirname}
    .on 'close',->
      app= express()
      app.use onefile {cwd:__dirname}

      server= app.listen done

  afterEach (done)->
    server.close done

  it 'GET pkgs.js',(done)->
    supertest server
    .get '/pkgs.js'
    .expect 200
    .expect 'Content-type','application/javascript'
    .expect /==$/
    .end (error,response)->
      if error then done.fail error else done()

  it 'GET pkgs.min.js',(done)->
    supertest server
    .get '/pkgs.min.js'
    .expect 200
    .expect 'Content-type','application/javascript'
    .expect /;$/
    .end (error,response)->
      if error then done.fail error else done()
