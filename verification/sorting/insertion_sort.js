function insertion_sort(x) {
  var y;
  var n = null;
  var z = null;

  y = null;
  while (x !== null) {
    n = x;
    x = x.next;
    n.next = null;
    if (y !== null) {
      if (y.value < n.value) {
        z = y;
        while (z.next !== null && z.next.value < n.value) {
          z = z.next;
        }
        n.next = z.next;
        z.next = n;
      } else {
        n.next = y;
        y = n;
      }
    } else {
      y = n;
    }              
  }

  return y;
}

/*
function main() {
  var l = {
    value : 4, next : {
    value : 2, next : {
    value : 1, next : {
    value : 3, next : {
    value : 5, next : null
  }}}}};
  print(l);
  var l2 = insertion_sort(l);
  print(l2);
}
function print(l) {
  var s = "";
  while (l !== null) {
    s = s + l.value;
    l = l.next;
  }
  console.log(s);
}
main();
*/
