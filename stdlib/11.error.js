// 15.11.4 Properties of the Error Prototype Object

// 15.11.4.4 Error.prototype.toString ( )

Error.prototype.toString = function () {
    // Step 1-2
    if (!IsObject(this)) throw TypeError("Error.prototype.toString");

    // Step 3-4
    var name = (this.name    === undefined) ? "Error" : ToString(this.name);
    // Step 5-7
    var msg  = (this.message === undefined) ? ""      : ToString(this.message);

    // Step 8-9
    if (name === "") return msg;
    if (msg  === "") return name;

    // Step 10
    return name + ": " + msg;
};
NoConstructor(Error.prototype.toString);
