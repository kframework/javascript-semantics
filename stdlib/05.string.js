// 15.5.3 Properties of the String Constructor

// 15.5.3.2 String.fromCharCode ( [ char0 [ , char1 [ , ... ] ] ] )
// The length property of the fromCharCode function is 1.

String.fromCharCode = function ( _ ) {
    var s = "";
    for (var i = 0; i < arguments.length; ++i) {
        s += @Int2Char(@ToUint16(arguments[i]));
    }
    return s;
};
@NoConstructor(String.fromCharCode);

// 15.5.4 Properties of the String Prototype Object

// 15.5.4.2 String.prototype.toString ( )

String.prototype.toString = function () {
    return String.prototype.valueOf.call(this);
};
@NoConstructor(String.prototype.toString);

// 15.5.4.3 String.prototype.valueOf ( )

String.prototype.valueOf = function () {
    if (typeof this === 'string') {
        return this;
    } else if (@IsObject(this) && @GetInternalProperty(this, "Class") === "String") {
        return @GetInternalProperty(this, "PrimitiveValue");
    } else {
        throw TypeError("Invalid arguments: String.prototype.valueOf");
    }
};
@NoConstructor(String.prototype.valueOf);

// 15.5.4.4 String.prototype.charAt (pos)

String.prototype.charAt = function (pos) {
    // Step 1
    @CheckObjectCoercible(this);
    // Step 2
    var s = @ToString(this);
    // Step 3
    var position = @ToInteger(pos);
    // Step 4
    var size = @LengthString(s);
    // Step 5
    if (position < 0 || position >= size) {
        return "";
    // Step 6
    } else {
        return @CharAt(s, position);
    }
};
@NoConstructor(String.prototype.charAt);

// 15.5.4.5 String.prototype.charCodeAt (pos)

String.prototype.charCodeAt = function (pos) {
    // Step 1
    @CheckObjectCoercible(this);
    // Step 2
    var s = @ToString(this);
    // Step 3
    var position = @ToInteger(pos);
    // Step 4
    var size = @LengthString(s);
    // Step 5
    if (position < 0 || position >= size) {
        return NaN;
    // Step 6
    } else {
        return @Char2Int(@CharAt(s, position));
    }
};
@NoConstructor(String.prototype.charCodeAt);

// 15.5.4.6 String.prototype.concat ( [ string1 [ , string2 [ , ... ] ] ] )
// The length property of the concat method is 1.

String.prototype.concat = function ( _ ) {
    // Step 1
    @CheckObjectCoercible(this);
    // Step 2
    var s = @ToString(this);

    // Step 4
    var r = s;
    // Step 5
    for (var i = 0; i < arguments.length; ++i)
        r += @ToString(arguments[i]);

    // Step 6
    return r;
};
@NoConstructor(String.prototype.concat);

// 15.5.4.7 String.prototype.indexOf (searchString, position)
// The length property of the indexOf method is 1.

String.prototype.indexOf = function ( searchString /* , position */ ) {
    var position = arguments[1]; // NOTE: length property = 1

    // Step 1
    @CheckObjectCoercible(this);

    // Step 2
    var s = @ToString(this);
    // Step 3
    var searchStr = @ToString(searchString);
    // Step 4
    var pos = position === undefined ? 0 : @ToInteger(position);

    // Step 5
    var len = @LengthString(s);
    // Step 6
    var start = Math.min(Math.max(pos,0), len);

    // Step 8
    return @FindString(s, searchStr, start);
};
@NoConstructor(String.prototype.indexOf);

// 15.5.4.8 String.prototype.lastIndexOf (searchString, position)
// The length property of the lastIndexOf method is 1.

String.prototype.lastIndexOf = function (searchString /* , position */) {
    throw "NotImplemented: String.prototype.lastIndexOf";
};
@NoConstructor(String.prototype.lastIndexOf);

// 15.5.4.9 String.prototype.localeCompare (that)

String.prototype.localeCompare = function (that) {
    throw "NotImplemented: String.prototype.localeCompare";
};
@NoConstructor(String.prototype.localeCompare);

// 15.5.4.10 String.prototype.match (regexp)

String.prototype.match = function (regexp) {
    throw "NotImplemented: String.prototype.match";
};
@NoConstructor(String.prototype.match);

// 15.5.4.11 String.prototype.replace (searchValue, replaceValue)

String.prototype.replace = function (searchValue, replaceValue) {
    // From Tachyon
    if (typeof searchValue === "string")
    {
        var pos = this.indexOf(searchValue);

        if (typeof replaceValue === "function")
        {
            var ret = replaceValue(searchValue, pos, this.toString());

            return this.substring(0, pos).concat(
                new String(ret).toString(),
                this.substring(pos + @LengthString(searchValue)));
        }
        else
        {
            return this.substring(0, pos).concat(
                replaceValue.toString(),
                this.substring(pos + @LengthString(searchValue)));
        }
    }
    else if (searchValue instanceof RegExp)
    {
        throw "NotImplemented: String.prototype.replace";
    }
    return this.toString();

};
@NoConstructor(String.prototype.replace);

// 15.5.4.12 String.prototype.search (regexp)

String.prototype.search = function (regexp) {
    throw "NotImplemented: String.prototype.search";
};
@NoConstructor(String.prototype.search);

// 15.5.4.13 String.prototype.slice (start, end)

String.prototype.slice = function (start, end) {
    throw "NotImplemented: String.prototype.slice";
};
@NoConstructor(String.prototype.slice);

// 15.5.4.14 String.prototype.split (separator, limit)

String.prototype.split = function (separator, limit) {
    // From Tachyon
    var res = new Array();
    if (limit === 0) return res;

    var len = this.length;
    if (len === 0) return res;

    if (separator === undefined)
        return [this];

    var pos = this.indexOf(separator);
    var start = 0;
    var sepLen = separator.length;

    while (pos >= 0)
    {
        res.push(this.substring(start, pos));
        if (res.length === limit) return res;
        start = pos + sepLen;
        pos = this.indexOf(separator, pos + sepLen);
    }

    if (start <= len)
    {
        res.push(this.substring(start));
    }

    return res;
};
@NoConstructor(String.prototype.split);

// 15.5.4.15 String.prototype.substring (start, end)
// The length property of the substring method is 2.

String.prototype.substring = function (start, end) {
    // Step 1
    @CheckObjectCoercible(this);

    // Step 2
    var s = @ToString(this);
    // Step 3
    var len = @LengthString(s);

    // Step 4-5
    var intStart = @ToInteger(start);
    var intEnd = end === undefined ? len : @ToInteger(end);

    // Step 6-7
    var finalStart = Math.min(Math.max(intStart,0), len);
    var finalEnd   = Math.min(Math.max(intEnd,  0), len);

    // Step 8-9
    var from = Math.min(finalStart, finalEnd);
    var to   = Math.max(finalStart, finalEnd);

    // Step 10
    return @SubstrString(s, from, to);
};
@NoConstructor(String.prototype.substring);

// 15.5.4.16 String.prototype.toLowerCase ( )

String.prototype.toLowerCase = function () {
    throw "NotImplemented: String.prototype.toLowerCase";
};
@NoConstructor(String.prototype.toLowerCase);

// 15.5.4.17 String.prototype.toLocaleLowerCase ( )

String.prototype.toLocaleLowerCase = function () {
    throw "NotImplemented: String.prototype.toLocaleLowerCase";
};
@NoConstructor(String.prototype.toLocaleLowerCase);

// 15.5.4.18 String.prototype.toUpperCase ( )

String.prototype.toUpperCase = function () {
    throw "NotImplemented: String.prototype.toUpperCase";
};
@NoConstructor(String.prototype.toUpperCase);

// 15.5.4.19 String.prototype.toLocaleUpperCase ( )

String.prototype.toLocaleUpperCase = function () {
    throw "NotImplemented: String.prototype.toLocaleUpperCase";
};
@NoConstructor(String.prototype.toLocaleUpperCase);

// 15.5.4.20 String.prototype.trim ( )

String.prototype.trim = function () {
    // Step 1
    @CheckObjectCoercible(this);
    // Step 2
    var s = @ToString(this);
    // Step 3-4
    return @Trim(s);
};
@NoConstructor(String.prototype.trim);

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
