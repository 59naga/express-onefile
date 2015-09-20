# Dependencies
onefile= require '../src'
express= require 'express'
supertest= require 'supertest'

childProcess= require 'child_process'

# Environment
jasmine.DEFAULT_TIMEOUT_INTERVAL= 10000

# Specs
describe 'expressOnefile',->
  server= null
  beforeEach (done)->
    childProcess.spawnSync 'bower',['install'],{cwd:__dirname}

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
    .expect /# sourceMappingURL=data:application\/json;base64/
    .end (error,response)->
      if error then done.fail error else done()

  it 'GET pkgs.min.js',(done)->
    supertest server
    .get '/pkgs.min.js'
    .expect 200
    .expect 'Content-type','application/javascript'
    .expect /^!function\(e,t\){/
    .expect /# sourceMappingURL=pkgs.min.js.map$/
    .end (error,response)->
      if error then done.fail error else done()

  it 'GET pkgs.min.js.map',(done)->
    supertest server
    .get '/pkgs.min.js.map'
    .expect 200
    .expect 'Content-type','application/json'
    .expect /^{"version":3,/
    .expect /}$/
    .end (error,response)->
      if error then done.fail error else done()
