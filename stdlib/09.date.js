// 15.9.5.2 Date.prototype.toString ( )

Date.prototype.toString = function () {
    return DatePrototypeToString(this);
};
NoConstructor(Date.prototype.toString);

// 15.9.5.8 Date.prototype.valueOf ( )

Date.prototype.valueOf = function () {
    return GetInternalProperty(this, "PrimitiveValue");
};
NoConstructor(Date.prototype.valueOf);
