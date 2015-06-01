function bubble_sort(x) {
  var change;
  var y = null;
  var temp = "";

  if (x === null || x.next === null)
    return x;

  change = true;
  while (change) {
    change = false;
    y = x;
    while (y.next !== null) {
      if (y.value > y.next.value) {
        change = true;
        temp = y.value;
        y.value = y.next.value;
        y.next.value = temp;
      }
      y = y.next;
    }
  }

  return x;
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
  var l2 = bubble_sort(l);
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
