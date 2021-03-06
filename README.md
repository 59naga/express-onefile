# ExpressOnefile [![NPM version][npm-image]][npm] [![Build Status][travis-image]][travis] [![Coverage Status][coveralls-image]][coveralls]

> Express4 middleware of bower_components compressor

## Installation

```bash
$ npm install express-onefile --save
```

# API

## expressOnefile(options) -> middleware

```bash
bower init
# yes, yes yes...
bower install jquery --save
# ...

node app.js
# server running at http://localhost:59798
```

`app.js`

```js
var express= require('express');
var onefile= require('express-onefile');

var port= 59798;
var options= {
  cwd: process.cwd(),
  filename: 'pkgs',
}

var app= express();
app.use(onefile(options));
app.listen(port,function(){
  console.log('server running at http://localhost:%s',port);
});
```

Can you access:
* `http://localhost:59798/pkgs.js`
* `http://localhost:59798/pkgs.min.js`

# Related projects
* [onefile](https://github.com/59naga/onefile/)
* __express-onefile__
* [difficult-http-server](https://github.com/59naga/difficult-http-server)

License
---
[MIT][License]

[License]: http://59naga.mit-license.org/

[sauce-image]: http://soysauce.berabou.me/u/59798/express-onefile.svg
[sauce]: https://saucelabs.com/u/59798
[npm-image]:https://img.shields.io/npm/v/express-onefile.svg?style=flat-square
[npm]: https://npmjs.org/package/express-onefile
[travis-image]: http://img.shields.io/travis/59naga/express-onefile.svg?style=flat-square
[travis]: https://travis-ci.org/59naga/express-onefile
[coveralls-image]: http://img.shields.io/coveralls/59naga/express-onefile.svg?style=flat-square
[coveralls]: https://coveralls.io/r/59naga/express-onefile?branch=master
