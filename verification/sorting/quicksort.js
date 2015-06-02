function append(x, y) {
  var p;

  if (x === null)
    return y;

  p = x;
  while (p.next !== null) {
    p = p.next;
  }
  p.next = y;

  return x;
}

function quicksort(x) {
  var p;
  var y;
  var z;
  var t = null;

  if (x === null || x.next === null)
    return x;

  p = x;
  x = x.next;
  p.next = null;
  y = null;
  z = null;
  while (x !== null) {
    t = x;
    x = x.next;
    if (t.value < p.value) {
      t.next = y;
      y = t;
    } else {
      t.next = z;
      z = t;
    }
  }

  y = quicksort(y);
  z = quicksort(z);
  x = append(y, append(p, z));

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
  var l2 = quicksort(l);
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
