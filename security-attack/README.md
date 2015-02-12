## Security Attack Detection using Symbolic Execution

Being symbolically executable, KJS can be used to detect a known security attack.
For example, consider [a secure message sending program](send.js), as follows:
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
(Refer to [js-config.k](js-config.k) for a complete configuration.)
```
<obj>
    <oid>
        @ObjectProtoOid
    </oid>
    <properties>
        ...
        ?P |-> @desc ( "Value"        |-> ?V 
                       "Enumerable"   |-> true 
                       "Writable"     |-> true 
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

Then we execute [the `send` program](send.js) using K's search mode, asking to reach
a state where the message was sent, as follows:
```
$ krun  -d ../ --smt none --search send.js
```

The symbolic search execution then returns the constraints, as follows,
(Refer to [send.js.out](send.js.out) for a complete result.)
```
Final(search): ... <out>ListItem('#buffer(String(#""Sent msg to http://www.evil.com\n""))) </out> ... /\ _11199:String =? String(#""http://www.evil.com"") /\ _11202:UserVal =? Bool(#"true") 
Final(search): ... <out>ListItem('#buffer(String(#""Sent msg to http://www.evil.com\n""))) </out> ... /\ '_=/=String_(_11202:UserVal,, String(#"""")) =? Bool(#"true") /\ _11199:String =? String(#""http://www.evil.com"") 
Final(search): ... <out>ListItem('#buffer(String(#""Sent msg to http://www.evil.com\n""))) </out> ... /\ '_=/=K_(_11202:UserVal,, '@nz(.KList)) =? Bool(#"true") /\ '_=/=K_(_11202:UserVal,, '@NaN(.KList)) =? Bool(#"true") /\ '_=/=K_(_11202:UserVal,, Int(#"0")) =? Bool(#"true") /\ _11199:String =? String(#""http://www.evil.com"") 
...
```
which essentially means the following constraint:
```
P = "http://www.evil.com" and (V = true or V is a non-empty string or V is a non-zero number)
```

Any global object poisoning scenario that satisfies the above constraint can attack the
`send` program. For example, any of the following can be used to attack:
 * `Object.prototype["http://www.evil.com"] = true;`
 * `Object.prototype["http://www.evil.com"] = "string";`
 * `Object.prototype["http://www.evil.com"] = 1;`
