// 15.1.2 Function Properties of the Global Object

// 15.1.2.2 parseInt (string , radix)

parseInt = function (string, radix) {
    throw "NotImplemented: parseInt";
};
NoConstructor(parseInt);

// 15.1.2.3 parseFloat (string)

parseFloat = function (string) {
    throw "NotImplemented: parseFloat";
};
NoConstructor(parseFloat);

// 15.1.2.4 isNaN (number)

isNaN = function (number) {
    return IsNaN(ToNumber(number));
};
NoConstructor(isNaN);

// 15.1.2.5 isFinite (number)

isFinite = function (number) {
    var n = ToNumber(number);
    return !(IsNaN(n) || n === +Infinity || n === -Infinity);
};
NoConstructor(isFinite);

// 15.1.3 URI Handling Function Properties

// 15.1.3.1 decodeURI (encodedURI)

decodeURI = function (encodedURI) {
    throw "NotImplemented: decodeURI";
};
NoConstructor(decodeURI);

// 15.1.3.2 decodeURIComponent (encodedURIComponent)

decodeURIComponent = function (encodedURIComponent) {
    throw "NotImplemented: decodeURIComponent";
};
NoConstructor(decodeURIComponent);

// 15.1.3.3 encodeURI (uri)

encodeURI = function (uri) {
    throw "NotImplemented: encodeURI";
};
NoConstructor(encodeURI);

// 15.1.3.4 encodeURIComponent (uriComponent)

encodeURIComponent = function (uriComponent) {
    throw "NotImplemented: encodeURIComponent";
};
NoConstructor(encodeURIComponent);
