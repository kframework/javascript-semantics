// 15.8.2 Function Properties of the Math Object

// 15.8.2.1 abs (x)

Math.abs = function (x) {
    x = @ToNumber(x);
    if (x < 0)
        return -x;
    else
        return x;
};
@NoConstructor(Math.abs);

// 15.8.2.2 acos (x)

Math.acos = function (x) {
    throw "NotImplemented: Math.acos";
};
@NoConstructor(Math.acos);

// 15.8.2.3 asin (x)

Math.asin = function (x) {
    throw "NotImplemented: Math.asin";
};
@NoConstructor(Math.asin);

// 15.8.2.4 atan (x)

Math.atan = function (x) {
    throw "NotImplemented: Math.atan";
};
@NoConstructor(Math.atan);

// 15.8.2.5 atan2 (y, x)

Math.atan2 = function (y, x) {
    throw "NotImplemented: Math.atan2";
};
@NoConstructor(Math.atan2);

// 15.8.2.6 ceil (x)

Math.ceil = function (x) {
    return -Math.floor(-x);
};
@NoConstructor(Math.ceil);

// 15.8.2.7 cos (x)

Math.cos = function (x) {
    throw "NotImplemented: Math.cos";
};
@NoConstructor(Math.cos);

// 15.8.2.8 exp (x)

Math.exp = function (x) {
    throw "NotImplemented: Math.exp";
};
@NoConstructor(Math.exp);

// 15.8.2.9 floor (x)

Math.floor = function (x) {
    x = @ToNumber(x);
    return @MathFloor(x);
};
@NoConstructor(Math.floor);

// 15.8.2.10 log (x)

Math.log = function (x) {
    throw "NotImplemented: Math.log";
};
@NoConstructor(Math.log);

// 15.8.2.11 max ( [ value1 [ , value2 [ , ... ] ] ] )
// The length property of the max method is 2.

Math.max = function (value1, value2) {
    var max = -Infinity;
    for (var i = 0; i < arguments.length; ++i) {
        var value = @ToNumber(arguments[i]);
        if (isNaN(value)) {
            return NaN;
        } else if (value > max) {
            max = value;
        // NOTE: The comparison of values to determine the largest value is done as in 11.8.5
        //       except that +0 is considered to be larger than -0.
        } else if (@IsPositiveZero(value) && @IsNegativeZero(max)) {
            max = value;
        }
    }
    return max;
};
@NoConstructor(Math.max);

// 15.8.2.12 min ( [ value1 [ , value2 [ , ... ] ] ] )
// The length property of the min method is 2.

Math.min = function (value1, value2) {
    var min = +Infinity;
    for (var i = 0; i < arguments.length; ++i) {
        var value = @ToNumber(arguments[i]);
        if (isNaN(value)) {
            return NaN;
        } else if (value < min) {
            min = value;
        // NOTE: The comparison of values to determine the largest value is done as in 11.8.5
        //       except that +0 is considered to be larger than -0.
        } else if (@IsNegativeZero(value) && @IsPositiveZero(min)) {
            min = value;
        }
    }
    return min;
};
@NoConstructor(Math.min);

// 15.8.2.13 pow (x, y)

Math.pow = function (x, y) {
    x = @ToNumber(x);
    y = @ToNumber(y);
    return @MathPow(x,y);
};
@NoConstructor(Math.pow);

// 15.8.2.14 random ( )

Math.random = function () {
    throw "NotImplemented: Math.random";
};
@NoConstructor(Math.random);

// 15.8.2.15 round (x)

Math.round = function (x) {
    throw "NotImplemented: Math.round";
};
@NoConstructor(Math.round);

// 15.8.2.16 sin (x)

Math.sin = function (x) {
//  throw "NotImplemented: Math.sin";
    x = @ToNumber(x);
    if (isFinite(x)) {
        return @MathSin(x);
    } else {
        return NaN;
    }
};
@NoConstructor(Math.sin);

// 15.8.2.17 sqrt (x)

Math.sqrt = function (x) {
    throw "NotImplemented: Math.sqrt";
};
@NoConstructor(Math.sqrt);

// 15.8.2.18 tan (x)

Math.tan = function (x) {
    throw "NotImplemented: Math.tan";
};
@NoConstructor(Math.tan);
