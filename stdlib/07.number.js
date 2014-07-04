// 15.7.4 Properties of the Number Prototype Object

// 15.7.4.2 Number.prototype.toString ( [ radix ] )

Number.prototype.toString = function (radix) {
    var n = Number.prototype.valueOf.call(this);
    var r;
    if (radix === undefined) {
        r = 10;
    } else {
        r = ToInteger(radix);
        if (!(r >= 2 && r <= 36)) {
            throw RangeError("Invalid arguments: Number.prototype.toString");
        }
    }
    return NumberToString(n, r);
};
NoConstructor(Number.prototype.toString);

// 15.7.4.3 Number.prototype.toLocaleString()

Number.prototype.toLocaleString = function () {
    throw "NotImplemented: Number.prototype.toLocaleString";
};
NoConstructor(Number.prototype.toLocaleString);

// 15.7.4.4 Number.prototype.valueOf ( )

Number.prototype.valueOf = function () {
    if (typeof this === 'string') {
        return this;
    } else if (IsObject(this) && GetInternalProperty(this, "Class") === "Number") {
        return GetInternalProperty(this, "PrimitiveValue");
    } else {
        throw TypeError("Invalid arguments: Number.prototype.valueOf");
    }
};
NoConstructor(Number.prototype.valueOf);

// 15.7.4.5 Number.prototype.toFixed (fractionDigits)

Number.prototype.toFixed = function (fractionDigits) {
//  throw "NotImplemented: Number.prototype.toFixed";
    return NumberPrototypeToFixed(this, fractionDigits);
};
NoConstructor(Number.prototype.toFixed);

// 15.7.4.6 Number.prototype.toExponential (fractionDigits)

Number.prototype.toExponential = function (fractionDigits) {
    throw "NotImplemented: Number.prototype.toExponential";
};
NoConstructor(Number.prototype.toExponential);

// 15.7.4.7 Number.prototype.toPrecision (precision)

Number.prototype.toPrecision = function (precision) {
    throw "NotImplemented: Number.prototype.toPrecision";
};
NoConstructor(Number.prototype.toPrecision);
