"BEGIN PRELUDE";

/*
var __globalObject = Function("return this;")();
function fnGlobalObject() {
     return __globalObject;
}
*/
function fnGlobalObject() {
     return window;
}

/*
function $ERROR(msg) {
    print("ERROR: " + msg + "\n");
}
*/

function $PRINT(msg) {
    print("PRINT: " + msg + "\n");
}

function runTestCase(testcase) {
    if (testcase() !== true) {
        $ERROR("Test case returned non-true value!");
    }
}

var Test262Error = function () {}

/*
var NotEarlyErrorString = "NotEarlyError";
var EarlyErrorRePat = "^((?!" + NotEarlyErrorString + ").)*$";
var NotEarlyError = new Error(NotEarlyErrorString);
*/
var NotEarlyError = "NotEarlyError";

function fnExists(/*arguments*/) {
    for (var i = 0; i < arguments.length; i++) {
        if (typeof (arguments[i]) !== "function") return false;
    }
    return true;
}

"END PRELUDE";
