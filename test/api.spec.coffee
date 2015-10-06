# Dependencies
Promise= require 'bluebird'

expressOnefile= require '../src'
express= require 'express'
request= require 'request'

childProcess= require 'child_process'
fs= require 'fs'

# Environment
jasmine.DEFAULT_TIMEOUT_INTERVAL= 5000
process.env.PORT?= 59798
url= 'http://localhost:59798'
concurrency= 100

# Specs
describe 'expressOnefile',->
  server= null
  beforeAll (done)->
    childProcess.spawnSync 'bower',['install'],{cwd:__dirname}

    app= express()
    app.use express.static __dirname
    app.use expressOnefile {cache:yes,cwd:__dirname}

    server= app.listen process.env.PORT,done

  afterAll (done)->
    server.close done

    try
      fs.unlinkSync __dirname+'/pkgs.js'
      fs.unlinkSync __dirname+'/pkgs.min.js'
      fs.unlinkSync __dirname+'/pkgs.min.js.map'

  it 'GET /pkgs.js(concurrency 100)',(done)->
    promises=
      for i in [0...concurrency]
        new Promise (resolve,reject)->
          request url+'/pkgs.js'
          ,(error,response)->
            return reject error if error

            expect(response.statusCode).toBe 200
            expect(response.headers['content-type']).toBe 'application/javascript'
            expect(response.body).toMatch /# sourceMappingURL=data:application\/json;base64/

            resolve()

    Promise.all promises
    .then ->
      expect(fs.existsSync __dirname+'/pkgs.js').toBe true
      done()

  it 'GET /pkgs.min.js(concurrency 100)',(done)->
    promises=
      for i in [0...concurrency]
        new Promise (resolve,reject)->
          request url+'/pkgs.min.js'
          ,(error,response)->
            return reject error if error

            expect(response.statusCode).toBe 200
            expect(response.headers['content-type']).toBe 'application/javascript'
            expect(response.body).toMatch /^!function\(e,t\){/
            expect(response.body).toMatch /# sourceMappingURL=pkgs.min.js.map$/

            resolve()

    Promise.all promises
    .then ->
      expect(fs.existsSync __dirname+'/pkgs.min.js').toBe true
      done()

  it 'GET /pkgs.min.js.map(concurrency 100)',(done)->
    promises=
      for i in [0...concurrency]
        new Promise (resolve,reject)->
          request url+'/pkgs.min.js.map'
          ,(error,response)->
            return reject error if error

            expect(response.statusCode).toBe 200
            expect(response.headers['content-type']).toBe 'application/json'
            expect(response.body).toMatch /^{"version":3,/
            expect(response.body).toMatch /}$/

            resolve()

    Promise.all promises
    .then ->
      expect(fs.existsSync __dirname+'/pkgs.min.js.map').toBe true
      done()
