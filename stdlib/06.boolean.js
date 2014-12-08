// 15.6.4 Properties of the Boolean Prototype Object

// 15.6.4.2 Boolean.prototype.toString ( )

Boolean.prototype.toString = function () {
    // Step 2-4
    var b = Boolean.prototype.valueOf.call(this);
    // Step 5
    if (b) {
        return "true";
    } else {
        return "false";
    }
};
@NoConstructor(Boolean.prototype.toString);

// 15.6.4.3 Boolean.prototype.valueOf ( )

Boolean.prototype.valueOf = function () {
    var b;
    // Step 2
    if (typeof this === 'boolean') {
        b = this;
    // Step 3
    } else if (@IsObject(this) && @GetInternalProperty(this, "Class") === "Boolean") {
        b = @GetInternalProperty(this, "PrimitiveValue");
    // Step 4
    } else {
        throw TypeError("Invalid arguments: Boolean.prototype.valueOf");
    }
    // Step 5
    return b;
};
@NoConstructor(Boolean.prototype.valueOf);
