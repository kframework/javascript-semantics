#!/usr/bin/env

var fs = require('fs'), 
    esprima = require('esprima');

// ----- main -----
if (process.argv.length < 3) {
    console.log('Usage: parsejs.js file.js');
    process.exit(1);
}

var filename = process.argv[2];
var code = fs.readFileSync(filename);
analyzeCode(code);

function analyzeCode(code) {
  var ast = esprima.parse(code);
  console.log(JSON.stringify(ast, null, 4));
}
