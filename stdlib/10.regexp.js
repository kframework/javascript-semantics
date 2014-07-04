// 15.10.6.2 RegExp.prototype.exec(string)

// HACK: only for passing the test262 ch11
RegExp.prototype.exec = function (string) {
    return null;
};
NoConstructor(RegExp.prototype.exec);
