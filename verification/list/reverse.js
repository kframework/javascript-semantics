function reverse(x)
{
  var p = null;
  var y;

  while(x !== null)
  {
    y = x.next;
    x.next = p;
    p = x;
    x = y;
  }

  return p;
}

//function main()
//{
//  var n1 = {
//    value : 1,
//    next  : null
//  };
//  var n2 = {
//    value : 2,
//    next  : n1
//  };
//  var n3 = {
//    value : 3,
//    next  : n2
//  };
//  console.log(n3);
//  var n = reverse(n3);
//  console.log(n);
//}
//
//main();

