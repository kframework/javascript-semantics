## Security Attack Detection using Symbolic Execution

Being symbolically executable, KJS can be used to detect a known security attack.
For example, consider a secure message sending program [`send.js`](send.js):
```
function mkSend(rawSend) {
  var whiteList = { "http://www.microsoft.com/mail": true,
                    "http://www.microsoft.com/owa" : true };
  function newSend (target, msg) {
    if (whiteList[target]) {
      rawSend(target,msg);
    } else {
      console.log("Rejected.");
    }
  }
  return newSend;
}

send = mkSend(function (target, msg) {
  console.log("Sent " + msg + " to " + target);
});
```
The `send` method sends messages only to addresses in the white list. 
For example, the following should be rejected:
```
send("http://www.evil.com","msg"); // Rejected
```

Suspecting a global object poisoning attack, we construct a
configuration adding a symbolic property `P` with symbolic value `V` in the
`Object.prototype` object, equivalent to executing `Object.prototype[P] = V`,
as follows:
(Refer to [js.k.patch](js.k.patch) for details)
```
<obj>
    <oid>
        @ObjectProtoOid
    </oid>
    <properties>
        ...
        ?P |-> @desc ( "Value"        |-> ?V 
                       "Writable"     |-> true 
                       "Enumerable"   |-> true 
                       "Configurable" |-> true )
        ...
    </properties>
    <internalProperties>
        "Class" |-> "Object"
        "Extensible" |-> true
        "Prototype" |-> @NullOid
    </internalProperties>
</obj>
```

Then we execute [`send.js`](send.js) using K's search mode, asking to reach
a state where the message was sent:
```
$ krun --search send.js
```

The symbolic search execution then returns the constraints:
(Refer to [send.js.out](send.js.out) for a complete result.)
```
...
Final(search): ... <out>ListItem('#buffer(String(#""Sent msg to http://www.evil.com\n"")))  </out> ... /\ '_andBool_('_==K_(_20450:UserVal,, Bool(#"true")),, '_andBool_('_==K_(_20448:String,, String(#""http://www.evil.com"")),, '_==K_(_66670:Bool,, Bool(#"true"))))
Final(search): ... <out>ListItem('#buffer(String(#""Sent msg to http://www.evil.com\n"")))  </out> ... /\ '_andBool_('_==K_(_20450:UserVal,, _66673:String),, '_andBool_('_==K_(_20448:String,, String(#""http://www.evil.com"")),, '_==K_('_==String_(_66673:String,, String(#"""")),, Bool(#"false"))))
Final(search): ... <out>ListItem('#buffer(String(#""Sent msg to http://www.evil.com\n"")))  </out> ... /\ '_andBool_('_==K_(_20450:UserVal,, _66678:Number),, '_andBool_('_==K_(_20448:String,, String(#""http://www.evil.com"")),, '_andBool_('_==K_('_==K_(_66678:Number,, Int(#"0")),, Bool(#"false")),, '_andBool_('_==K_('_==K_(_66678:Number,, '@NaN(.KList)),, Bool(#"false")),, '_==K_('_==K_(_66678:Number,, '@nz(.KList)),, Bool(#"false"))))))
Final(search): ... <out>ListItem('#buffer(String(#""Sent msg to http://www.evil.com\n"")))  </out> ... /\ '_andBool_('_==K_(_20450:UserVal,, _66687:Oid),, '_==K_(_20448:String,, String(#""http://www.evil.com"")))
...
```
which essentially means the following constraint:
```
P = "http://www.evil.com" and (V = true or 
                               V is a non-empty string or 
                               V is a non-zero number or 
                               V is an object)
```

Any global object poisoning scenario that satisfies the above constraint can attack the
`send` program. For example, any of the following can be used to attack:
 * `Object.prototype["http://www.evil.com"] = true;`
 * `Object.prototype["http://www.evil.com"] = "string";`
 * `Object.prototype["http://www.evil.com"] = 1;`
 * `Object.prototype["http://www.evil.com"] = Object;`

You can simply reproduce this result by using [Makefile](Makefile):
```
$ make
```
