// 15.4.3 Properties of the Array Constructor

// 15.4.3.2 Array.isArray ( arg )

Array.isArray = function (arg) {
    if (!@IsObject(arg)) {
        return false;
    }
    return @GetInternalProperty(arg, "Class") === "Array";
};
@NoConstructor(Array.isArray);

// 15.4.4 Properties of the Array Prototype Object

// 15.4.4.2 Array.prototype.toString ( )

Array.prototype.toString = function () {
    // Step 1
    var array = @ToObject(this);

    // Step 2
    var func = array.join;

    // Step 3
    if (!@IsCallable(func)) {
        func = Object.prototype.toString;
    }

    // Step 4
    return func.call(array);
};
@NoConstructor(Array.prototype.toString);

// 15.4.4.3 Array.prototype.toLocaleString ( )

Array.prototype.toLocaleString = function () {
    throw "NotImplemented: Array.prototype.toLocaleString";
};
@NoConstructor(Array.prototype.toLocaleString);

// 15.4.4.4 Array.prototype.concat ( [ item1 [ , item2 [ , ... ] ] ] )
// The length property of the concat method is 1.

Array.prototype.concat = function ( _ ) {
    // Step 1
    var o = @ToObject(this);
    // Step 2
    var a = new Array();

    // Step 4-5
    merge(a,o);
    for (var i = 0; i < arguments.length; ++i) {
        merge(a,arguments[i]);
    }
    function merge (arr, elem) {
        // Step 5.b
        if (Array.isArray(elem)) {
            // Step 5.b.iii
            for (var k = 0; k < elem.length; ++k) {
                arr.push(elem[k]);
            }
        // Step 5.c
        } else {
            arr.push(elem);
        }
    }

    // Step 6
    return a;
};
@NoConstructor(Array.prototype.concat);

// 15.4.4.5 Array.prototype.join (separator)

Array.prototype.join = function (separator) {
    // Step 1
    var o = @ToObject(this);
    // Step 2-3
    var len = @ToUint32(o.length);

    // Step 4-5
    if (separator === undefined)
        separator = ",";
    else
        separator = @ToString(separator);

    // Step 6
    if (len === 0)
        return "";

    // Step 7-8
    var r = get(o,0);
    // Step 9-10
    for (var i = 1; i < len; ++i) {
        r += separator + get(o,i);
    }
    function get (o,i) {
        return (o[i] === undefined || o[i] === null) ? "" : @ToString(o[i]);
    }

    // Step 11
    return r;
};
@NoConstructor(Array.prototype.join);

// 15.4.4.6 Array.prototype.pop ( )

Array.prototype.pop = function () {
    throw "NotImplemented: Array.prototype.pop";
};
@NoConstructor(Array.prototype.pop);

// 15.4.4.7 Array.prototype.push ( [ item1 [ , item2 [ , ... ] ] ] )
// The length property of the push method is 1.

Array.prototype.push = function ( _ ) {
    // Step 1
    var o = @ToObject(this);
    // Step 2-3
    var len = @ToUint32(o.length);

    // Step 4-5
    for (var i = 0; i < arguments.length; ++i) {
        o[len+i] = arguments[i];
    }

    // Step 6
    // NOTE: Array's @DefineOwnProperty method automatically increases the length property.

    // Step 7
    return o.length;
};
@NoConstructor(Array.prototype.push);

// 15.4.4.8 Array.prototype.reverse ( )

Array.prototype.reverse = function () {
    throw "NotImplemented: Array.prototype.reverse";
};
@NoConstructor(Array.prototype.reverse);

// 15.4.4.9 Array.prototype.shift ( )

Array.prototype.shift = function () {
    throw "NotImplemented: Array.prototype.shift";
};
@NoConstructor(Array.prototype.shift);

// 15.4.4.10 Array.prototype.slice (start, end)

Array.prototype.slice = function (start, end) {
    throw "NotImplemented: Array.prototype.slice";
};
@NoConstructor(Array.prototype.slice);

// 15.4.4.11 Array.prototype.sort (comparefn)
// NOTE: This was came from the Tachyon library

Array.prototype.sort = function (comparefn) {
    var o = @ToObject(this);
    var len = o.length;

    if (comparefn === undefined)
        comparefn = function (x, y)
        {
            if (String(x) > String(y))
                return 1;
            else
                return -1;
        };

    /* Iterative mergesort algorithm */

    if (len >= 2)
    {
        /* Sort pairs in-place */

        for (var start=((len-2)>>1)<<1; start>=0; start-=2)
        {
            if (comparefn(o[start], o[start+1]) > 0)
            {
                var tmp = o[start];
                o[start] = o[start+1];
                o[start+1] = tmp;
            }
        }

        if (len > 2)
        {
            /*
             * For each k>=1, merge each pair of groups of size 2^k to
             * form a group of size 2^(k+1) in a second array.
             */

            var a1 = o;
            var a2 = new Array(len);

            var k = 1;
            var size = 2;

            do
            {
                var start = ((len-1)>>(k+1))<<(k+1);
                var j_end = len;
                var i_end = start+size;

                if (i_end > len)
                    i_end = len;

                while (start >= 0)
                {
                    var i = start;
                    var j = i_end;
                    var x = start;

                    for (;;)
                    {
                        if (i < i_end)
                        {
                            if (j < j_end)
                            {
                                if (comparefn(a1[i], a1[j]) > 0)
                                    a2[x++] = a1[j++];
                                else
                                    a2[x++] = a1[i++];
                            }
                            else
                            {
                                while (i < i_end)
                                    a2[x++] = a1[i++];
                                break;
                            }
                        }
                        else
                        {
                            while (j < j_end)
                                a2[x++] = a1[j++];
                            break;
                        }
                    }

                    j_end = start;
                    start -= 2*size;
                    i_end = start+size;
                }

                var t = a1;
                a1 = a2;
                a2 = t;

                k++;
                size *= 2;
            } while (len > size);

            if ((k & 1) === 0)
            {
                /* Last merge was into second array, so copy it back to o. */

                for (var i=len-1; i>=0; i--)
                    o[i] = a1[i];
            }
        }
    }

    return o;
};
@NoConstructor(Array.prototype.sort);

// 15.4.4.12 Array.prototype.splice (start, deleteCount [ , item1 [ , item2 [ , ... ] ] ] )
// The length property of the splice method is 2.

Array.prototype.splice = function (start, deleteCount) {
    throw "NotImplemented: Array.prototype.splice";
};
@NoConstructor(Array.prototype.splice);

// 15.4.4.13 Array.prototype.unshift ( [ item1 [ , item2 [ , ... ] ] ] )
// The length property of the unshift method is 1.

Array.prototype.unshift = function ( _ ) {
    throw "NotImplemented: Array.prototype.unshift";
};
@NoConstructor(Array.prototype.unshift);

// 15.4.4.14 Array.prototype.indexOf ( searchElement [ , fromIndex ] )
// The length property of the indexOf method is 1.

Array.prototype.indexOf = function (searchElement) {
    throw "NotImplemented: Array.prototype.indexOf";
};
@NoConstructor(Array.prototype.indexOf);

// 15.4.4.15 Array.prototype.lastIndexOf ( searchElement [ , fromIndex ] )
// The length property of the lastIndexOf method is 1.

Array.prototype.lastIndexOf = function (searchElement) {
    throw "NotImplemented: Array.prototype.lastIndexOf";
};
@NoConstructor(Array.prototype.lastIndexOf);

// 15.4.4.16 Array.prototype.every ( callbackfn [ , thisArg ] )
// The length property of the every method is 1.

Array.prototype.every = function (callbackfn) {
    throw "NotImplemented: Array.prototype.every";
};
@NoConstructor(Array.prototype.every);

// 15.4.4.17 Array.prototype.some ( callbackfn [ , thisArg ] )
// The length property of the some method is 1.

Array.prototype.some = function (callbackfn) {
    throw "NotImplemented: Array.prototype.some";
};
@NoConstructor(Array.prototype.some);

// 15.4.4.18 Array.prototype.forEach ( callbackfn [ , thisArg ] )
// The length property of the forEach method is 1.

Array.prototype.forEach = function (callbackfn) {
    throw "NotImplemented: Array.prototype.forEach";
};
@NoConstructor(Array.prototype.forEach);

// 15.4.4.19 Array.prototype.map ( callbackfn [ , thisArg ] )
// The length property of the map method is 1.

Array.prototype.map = function (callbackfn) {
    throw "NotImplemented: Array.prototype.map";
};
@NoConstructor(Array.prototype.map);

// 15.4.4.20 Array.prototype.filter ( callbackfn [ , thisArg ] )
// The length property of the filter method is 1.

Array.prototype.filter = function (callbackfn) {
    throw "NotImplemented: Array.prototype.filter";
};
@NoConstructor(Array.prototype.filter);

// 15.4.4.21 Array.prototype.reduce ( callbackfn [ , initialValue ] )
// The length property of the reduce method is 1.

Array.prototype.reduce = function (callbackfn) {
    throw "NotImplemented: Array.prototype.reduce";
};
@NoConstructor(Array.prototype.reduce);

// 15.4.4.22 Array.prototype.reduceRight ( callbackfn [ , initialValue ] )
// The length property of the reduceRight method is 1.

Array.prototype.reduceRight = function (callbackfn) {
    throw "NotImplemented: Array.prototype.reduceRight";
};
@NoConstructor(Array.prototype.reduceRight);

/* _________________________________________________________________________
 *
 *             Tachyon : A Self-Hosted JavaScript Virtual Machine
 *
 *
 *  This file is part of the Tachyon JavaScript project. Tachyon is
 *  distributed at:
 *  http://github.com/Tachyon-Team/Tachyon
 *
 *
 *  Copyright (c) 2011, Universite de Montreal
 *  All rights reserved.
 *
 *  This software is licensed under the following license (Modified BSD
 *  License):
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are
 *  met:
 *    * Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *    * Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *    * Neither the name of the Universite de Montreal nor the names of its
 *      contributors may be used to endorse or promote products derived
 *      from this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
 *  IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 *  TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 *  PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL UNIVERSITE DE
 *  MONTREAL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 *  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 *  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * _________________________________________________________________________
 */
