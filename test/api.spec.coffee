# Dependencies
Promise= require 'bluebird'

expressOnefile= require '../src'
express= require 'express'
supertest= require 'supertest'

childProcess= require 'child_process'

# Environment
jasmine.DEFAULT_TIMEOUT_INTERVAL= 5000
concurrency= 100

# Specs
describe 'expressOnefile',->
  server= null
  beforeAll (done)->
    childProcess.spawnSync 'bower',['install'],{cwd:__dirname}

    app= express()
    app.use expressOnefile {cwd:__dirname}

    server= app.listen done

  afterAll (done)->
    server.close done

  it 'GET pkgs.js(concurrency 100)',(done)->
    promises=
      for i in [0...concurrency]
        new Promise (resolve,reject)->
          supertest server
          .get '/pkgs.js'
          .expect 200
          .expect 'Content-type','application/javascript'
          .expect /# sourceMappingURL=data:application\/json;base64/
          .end (error,response)->
            unless error then resolve() else reject error

    Promise.all promises
    .then done

  it 'GET pkgs.min.js(concurrency 100)',(done)->
    promises=
      for i in [0...concurrency]
        new Promise (resolve,reject)->
          supertest server
          .get '/pkgs.min.js'
          .expect 200
          .expect 'Content-type','application/javascript'
          .expect /^!function\(e,t\){/
          .expect /# sourceMappingURL=pkgs.min.js.map$/
          .end (error,response)->
            unless error then resolve() else reject error

    Promise.all promises
    .then done

  it 'GET pkgs.min.js.map(concurrency 100)',(done)->
    promises=
      for i in [0...concurrency]
        new Promise (resolve,reject)->
          supertest server
          .get '/pkgs.min.js.map'
          .expect 200
          .expect 'Content-type','application/json'
          .expect /^{"version":3,/
          .expect /}$/
          .end (error,response)->
            unless error then resolve() else reject error

    Promise.all promises
    .then done
