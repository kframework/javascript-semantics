#!/usr/bin/env

var fs = require('fs'), 
    esprima = require('esprima');

// ----- main -----
if (process.argv.length < 3) {
    console.log('Usage: analyze.js file.js');
    process.exit(1);
}

var filename = process.argv[2];
//console.log('Reading ' + filename);
var code = fs.readFileSync(filename);
analyzeCode(code);
//console.log('Done');
// ----- main -----

/*
function traverse(node, func) {
    func(node);
    for (var key in node) {
        if (node.hasOwnProperty(key)) {
            var child = node[key];
            if (typeof child === 'object' && child !== null) { //Array, Date, Boolean, RegExp

                if (Array.isArray(child)) {
                    child.forEach(function(node) {
                        traverse(node, func);
                    });
                } else {
                    traverse(child, func);
                }
            }
        }
    }
} */

function analyzeCode(code) {
    result = new Object();
    result.str = "";

    var ast = esprima.parse(code);
//    console.log('ast: \n' + ast + "\n");	
    traverse(ast, 'type');
//    console.log("\nresult: \n" + result.str + "\n");
    console.log(result.str);
}


function traverse(node, key) {

	/*for(var key in node) {*/
		if(node == null){
			result.str += "null";
		} else if(node == NaN){
			result.str += "NaN";
		} else if (node.hasOwnProperty(key)) {
		//    console.log("key " + key + "\n");
        	    var child = node[key];           
		//	console.log(key + ': ' + child);
	            if (typeof node === 'object' && node !== null) { //Array, Date, Boolean, RegExp
			//console.log('child: ' + child);
        	        if (Array.isArray(child)) {
				//console.log('array');
				//console.log(JSON.stringify(child, null, 4));
				var length = child.length;
				var i = 0;
				
				if(length != 1){
					result.str += "_`(_`)('_`,_, _`,`,_(";	
				}
        	        	child.forEach(function(node) {
	                	        traverse(node, 'type');
					if(i != (length-1)){
						result.str += ", ";
					}
					i++;});
				if(length != 1){
					result.str += "))";	
				}
				//traverse(node[0]);
			} else if (typeof child === "object" && !Array.isArray(child)) {
				traverse(child, 'type');
	
			} else {	
 				if (child === 'ArrayExpression') {

				  result.str += "_`(_`)('`[_`], ";
				  traverse(node, 'elements');
				  result.str += ")";
           
				} else if (child === 'AssignmentExpression') {

				  if(node.operator.length == 1){
					  result.str += "_`(_`)('_" + node.operator + "_, _`,`,_(";
					  traverse(node, 'left');
					  result.str += ", ";	
					  traverse(node, 'right');
					  result.str += "))";
				  } else {
					  result.str += "_`(_`)('___, _`,`,_(";
					  traverse(node, 'left');
					  result.str += ", _`(_`)('" + node.operator + ", .KList), ";	
					  traverse(node, 'right');
					  result.str += "))";
				  }
				   
				} else if (child === 'BinaryExpression') {

				  result.str += "_`(_`)('_" + node.operator + "_, _`,`,_(";
				  traverse(node, 'left');
				  result.str += ", ";	
				  traverse(node, 'right');
				  result.str += "))";		
	   
				} else if (child === 'BlockStatement') {

				  result.str += "_`(_`)('`{_`}, ";
				  traverse(node, 'body');
				  result.str += ")";

				} else if (child === 'BrakeStatement') {
				   
				} else if (child === 'CallExpression') {
				   
				} else if (child === 'CatchClause') {
				   
				} else if (child === 'ConditionalExpression') {
				   
				} else if (child === 'ContinueStatement') {
				   
				} else if (child === 'DebuggerStatement') {
				   
				} else if (child === 'DoWhileStatement') {
				   
				} else if (child === 'EmptyStatement') {
				   
				} else if (child === 'ExpressionStatement') {

				  result.str += "_`(_`)('_;, ";
				  traverse(node, 'expression');	
				  result.str += ")";
				   
				} else if (child === 'ForStatement') {
				   
				} else if (child === 'ForInStatement') {
				   
				} else if (child === 'FunctionDeclaration') { //parse params, etc.
/*
				  result.str += "function{";
				  result.str += "'"; 
				  traverse(node, 'id'); 
				  result.str += "(";
				  traverse(node, 'body');
				  result.str += ")";
				  result.str += ")";
*/				   
				} else if (child === 'FunctionExpression') {
				   
				} else if (child === 'Identifier') {

				   result.str += "_`(_`)(";
				   result.str += "#_(#id \"" + node.name + "\"), .KList";
				   result.str += ")";

				} else if (child === 'IfStatement') {

				  result.str += "_`(_`)(";
				  result.str += "'if`(_`)_else_, _`,`,_(";
				  traverse(node, 'test');
				  result.str += ", ";
				  traverse(node, 'consequent');
				  result.str += ", ";
				  traverse(node, 'alternate');	
				  result.str += "))";
						
				} else if (child === 'LabeledStatement') {
				   
				} else if (child === 'Literal') {

				  result.str += "_`(_`)(";
				  if(node.value == null){
				  	result.str += "'" + node.value + ", .KList";
				  } else {
				   	result.str += "#_(" + node.value + "), .KList";
				  }
				  result.str += ")";

				} else if (child === 'MemberExpression') {
				   
				} else if (child === 'NewExpression') {
/*				   
				  result.str += "'_new_(";
				  traverse(node, 'callee');
				  result.str += ",,'args(";
				  traverse(node, 'arguments');
				  result.str += "'.List`{\"`,\"`}(.KList))";
*/
				} else if (child === 'ObjectExpression') {
				   				   
				} else if (child === 'ContinueStatement') {
				   
				} else if (child === 'Program') {

				  traverse(node, 'body');

				} else if (child === 'Property') {
				   
				} else if (child === 'ReturnStatement') {
				   
				} else if (child === 'SequenceExpression') {
				   
				} else if (child === 'SwitchCase') {
				   
				} else if (child === 'SwitchStatement') {
				   
				} else if (child === 'ThisExpression') {
				   
				} else if (child === 'ThrowStatement') {
				   
				} else if (child === 'TryStatement') {
				   
				} else if (child === 'UpdateExpression') { //UnaryExpression

				  if(node.prefix == false){
					  result.str += "_`(_`)('_" + node.operator + ", ";
					  traverse(node, 'argument');
					  result.str += ")";
				  } else {
					  result.str += "_`(_`)('" + node.operator + "_, ";
					  traverse(node, 'argument');
					  result.str += ")";
				  }
				   
				} else if (child === 'VariableDeclaration') {

				  result.str += "_`(_`)(";
				  result.str += "'" + node.kind + "_;, ";
				  traverse(node, 'declarations');
				  result.str += ")";

				} else if (child === 'VariableDeclarator') {

				  if(node.init == null){
				  	  traverse(node, 'id');
				  } else {
					  result.str += "_`(_`)(";
					  result.str += "'__, _`,`,_(";
					  traverse(node, 'id');
					  result.str += ", _`(_`)('=_,";
					  traverse(node, 'init');
					  result.str += ")))";
				  }
				   
				} else if (child === 'WhileStatement') {

				  result.str += "_`(_`)('while`(_`)_, _`,`,_(";
				  traverse(node, 'test');
				  result.str += ", ";
				  traverse(node, 'body');
				  result.str += "))";

				} else if (child === 'WithStatement') {
				   
				}
        	        }
        	    }
		}
		
	//}
}


function ifVisit(node){

	result.str += "'if__else_(\n"
	    + traverse(node, 'test')
	    + ",," + traverse(node, 'consequent')
	    + ",," + traverse(node, 'alternate') + ")\n";	

}

function progVisit(node){

	result.str += "'program(\n"
	    + traverse(node, 'body') + ")\n";
}
