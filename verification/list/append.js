function append(x, y)
{
  if (x === null)
    return y;

  var p = x;
  while(p.next !== null)
  {
    p = p.next;
  }
  p.next = y;

  return x;
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
//    next  : null 
//  };
//  console.log(n2);
//  console.log(n3);
//  var n = append(n2, n3);
//  console.log(n);
//}
// 
//main();

