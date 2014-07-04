// 15.3.4 Properties of the Function Prototype Object

// 15.3.4.2 Function.prototype.toString ( )

Function.prototype.toString = function () {
    if (!IsFunction(this)) throw TypeError("Invalid arguments: Function.prototype.toString");

    return FunctionPrototypeToString(this);
};
NoConstructor(Function.prototype.toString);

// 15.3.4.3 Function.prototype.apply (thisArg, argArray)
// The length property of the apply method is 2.

Function.prototype.apply = function (thisArg, argArray) {
    if (!IsFunction(this)) throw TypeError("Invalid arguments: Function.prototype.apply");

    return FunctionPrototypeApply(this, thisArg, argArray);
};
NoConstructor(Function.prototype.apply);

// 15.3.4.4 Function.prototype.call (thisArg [ , arg1 [ , arg2, ... ] ] )
// The length property of the call method is 1.

Function.prototype.call = function (thisArg) {
    if (!IsFunction(this)) throw TypeError("Invalid arguments: Function.prototype.call");

    var argArray = [];
    for (var i = 1; i < arguments.length; ++i) {
        argArray.push(arguments[i]);
    }

    return this.apply(thisArg, argArray);
};
NoConstructor(Function.prototype.call);

// 15.3.4.5 Function.prototype.bind (thisArg [, arg1 [, arg2, ...]])
// The length property of the bind method is 1.

Function.prototype.bind = function (thisArg) {
    if (!IsFunction(this)) throw TypeError("Invalid arguments: Function.prototype.bind");

    var argArray = [];
    for (var i = 1; i < arguments.length; ++i) {
        argArray.push(arguments[i]);
    }

    return FunctionPrototypeBind(this, thisArg, argArray);
};
NoConstructor(Function.prototype.bind);
