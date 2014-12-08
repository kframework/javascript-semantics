// 15.2.3 Properties of the Object Constructor

// 15.2.3.2 Object.getPrototypeOf ( O )

Object.getPrototypeOf = function (O) {
    if (!@IsObject(O)) throw TypeError("Invalid arguments: Object.getPrototypeOf");

    return @GetInternalProperty(O, "Prototype");
};
@NoConstructor(Object.getPrototypeOf);

// 15.2.3.3 Object.getOwnPropertyDescriptor ( O, P )

Object.getOwnPropertyDescriptor = function (O, P) {
    if (!@IsObject(O)) throw TypeError("Invalid arguments: Object.getOwnPropertyDescriptor");

    return @FromPropertyDescriptor(@GetOwnProperty(O, @ToString(P)));
};
@NoConstructor(Object.getOwnPropertyDescriptor);

// 15.2.3.4 Object.getOwnPropertyNames ( O )

Object.getOwnPropertyNames = function (O) {
    if (!@IsObject(O)) throw TypeError("Invalid arguments: Object.getOwnPropertyNames");

    return @ObjectGetOwnPropertyNames(O);
};
@NoConstructor(Object.getOwnPropertyNames);

// 15.2.3.5 Object.create ( O [, Properties] )

Object.create = function (O, Properties) {
    if (!(@IsObject(O) || O === null)) throw TypeError("Invalid arguments: Object.create");

    // Step 2
    var obj = new Object();

    // Step 3
    @SetInternalProperty(obj, "Prototype", O);

    // Step 4
    if (Properties !== undefined) {
        Object.defineProperties(obj, Properties);
    }

    return obj;
};
@NoConstructor(Object.create);

// 15.2.3.6 Object.defineProperty ( O, P, Attributes )

Object.defineProperty = function (O, P, Attributes) {
    if (!@IsObject(O)) throw TypeError("Invalid arguments: Object.defineProperty");

    @DefineOwnProperty(O, @ToString(P), @ToPropertyDescriptor(Attributes), true);
    return O;
};
@NoConstructor(Object.defineProperty);

// 15.2.3.7 Object.defineProperties ( O, Properties )

Object.defineProperties = function (O, Properties) {
    if (!@IsObject(O)) throw TypeError("Invalid arguments: Object.defineProperties");

    // Step 2-6
    for (var name in Properties) {
        if (Properties.hasOwnProperty(name)) {
            Object.defineProperty(O, name, Properties[name]);
        }
    }
    return O;
};
@NoConstructor(Object.defineProperties);

// 15.2.3.8 Object.seal ( O )

Object.seal = function (O) {
    if (!@IsObject(O)) throw TypeError("Invalid arguments: Object.seal");

    // Step 2
    var names = Object.getOwnPropertyNames(O);
    for (var i = 0; i < names.length; ++i) {
        var desc = Object.getOwnPropertyDescriptor(O, names[i]);
        desc.configurable = false;
        Object.defineProperty(O, names[i], desc);
    }

    // Step 3
    @SetInternalProperty(O, "Extensible", false);

    return O;
};
@NoConstructor(Object.seal);

// 15.2.3.9 Object.freeze ( O )

Object.freeze = function (O) {
    if (!@IsObject(O)) throw TypeError("Invalid arguments: Object.freeze");

    // Step 2
    var names = Object.getOwnPropertyNames(O);
    for (var i = 0; i < names.length; ++i) {
        var desc = Object.getOwnPropertyDescriptor(O, names[i]);
        if (desc.hasOwnProperty("value") || desc.hasOwnProperty("writable")) {
            desc.writable = false;
        }
        desc.configurable = false;
        Object.defineProperty(O, names[i], desc);
    }

    // Step 3
    @SetInternalProperty(O, "Extensible", false);

    return O;
};
@NoConstructor(Object.freeze);

// 15.2.3.10 Object.preventExtensions ( O )

Object.preventExtensions = function (O) {
    if (!@IsObject(O)) throw TypeError("Invalid arguments: Object.preventExtensions");

    @SetInternalProperty(O, "Extensible", false);
    return O;
};
@NoConstructor(Object.preventExtensions);

// 15.2.3.11 Object.isSealed ( O )

Object.isSealed = function (O) {
    if (!@IsObject(O)) throw TypeError("Invalid arguments: Object.isSealed");

    // Step 2
    var names = Object.getOwnPropertyNames(O);
    for (var i = 0; i < names.length; ++i) {
        var desc = Object.getOwnPropertyDescriptor(O, names[i]);
        if (desc.configurable) {
            return false;
        }
    }

    // Step 4
    if (@GetInternalProperty(O, "Extensible")) {
        return false;
    }

    // Step 3
    return true;
};
@NoConstructor(Object.isSealed);

// 15.2.3.12 Object.isFrozen ( O )

Object.isFrozen = function (O) {
    if (!@IsObject(O)) throw TypeError("Invalid arguments: Object.isFrozen");

    // Step 2
    var names = Object.getOwnPropertyNames(O);
    for (var i = 0; i < names.length; ++i) {
        var desc = Object.getOwnPropertyDescriptor(O, names[i]);
        if (desc.hasOwnProperty("value") || desc.hasOwnProperty("writable")) {
            if (desc.writable) {
                return false;
            }
        }
        if (desc.configurable) {
            return false;
        }
    }

    // Step 4
    if (@GetInternalProperty(O, "Extensible")) {
        return false;
    }

    // Step 3
    return true;
};
@NoConstructor(Object.isFrozen);

// 15.2.3.13 Object.isExtensible ( O )

Object.isExtensible = function (O) {
    if (!@IsObject(O)) throw TypeError("Invalid arguments: Object.isExtensible");

    return @GetInternalProperty(O, "Extensible");
};
@NoConstructor(Object.isExtensible);

// 15.2.3.14 Object.keys ( O )

Object.keys = function (O) {
    if (!@IsObject(O)) throw TypeError("Invalid arguments: Object.keys");

    var names = new Array();
    for (var name in O) {
        if (O.hasOwnProperty(name)) {
            names.push(name);
        }
    }
    return names;
};
@NoConstructor(Object.keys);

// 15.2.4 Properties of the Object Prototype Object

// 15.2.4.2 Object.prototype.toString ( )

Object.prototype.toString = function () {
    switch (this) {
        case undefined:
            return "[object Undefined]";
        case null:
            return "[object Null]";
        default:
            return "[object " + @GetInternalProperty(@ToObject(this), "Class") + "]";
    }
};
@NoConstructor(Object.prototype.toString);

// 15.2.4.3 Object.prototype.toLocaleString ( )

Object.prototype.toLocaleString = function () {
    return @ToObject(this).toString();
};
@NoConstructor(Object.prototype.toLocaleString);

// 15.2.4.4 Object.prototype.valueOf ( )

Object.prototype.valueOf = function () {
    // NOTE: Step 2 is ignored since we have no host objects.
    return @ToObject(this);
};
@NoConstructor(Object.prototype.valueOf);

// 15.2.4.5 Object.prototype.hasOwnProperty (V)

Object.prototype.hasOwnProperty = function (V) {
    // Step 1-3
    var desc = Object.getOwnPropertyDescriptor(@ToObject(this), @ToString(V));

    // Step 4
    if (desc === undefined) {
        return false;
    }

    // Step 5
    return true;
};
@NoConstructor(Object.prototype.hasOwnProperty);

// 15.2.4.6 Object.prototype.isPrototypeOf (V)

Object.prototype.isPrototypeOf = function (V) {
    if (!@IsObject(V)) {
        return false;
    }

    var o = @ToObject(this);
    while (true) {
        V = Object.getPrototypeOf(V);
        if (V === null) {
            return false;
        }
        if (V === o) {
            return true;
        }
    }
};
@NoConstructor(Object.prototype.isPrototypeOf);

// 15.2.4.7 Object.prototype.propertyIsEnumerable (V)

Object.prototype.propertyIsEnumerable = function (V) {
    // Step 1-3
    var desc = Object.getOwnPropertyDescriptor(@ToObject(this), @ToString(V));

    // Step 4
    if (desc === undefined) {
        return false;
    }

    // Step 5
    return desc.enumerable;
};
@NoConstructor(Object.prototype.propertyIsEnumerable);
