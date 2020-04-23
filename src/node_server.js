#!/usr/bin/env nodejs
var http = require('http');
http.createServer(function(req,res){
        res.writeHead(200, { 'Content-Type': 'text/plain' });
        res.write(req.url);
      res.end();		
      }).listen(8080);
console.log('Server started on localhost:8080; press Ctrl-C to terminate...!');
