function merge_sort(x) {
  var p = null;
  var y;
  var z;
  var t = null;

  if (x === null || x.next === null) {
    return x;
  }

  y = null;
  z = null;
  while (x !== null) {
    t = x;
    x = x.next;
    t.next = y;
    y = t;

    if (x !== null) {
      t = x;
      x = x.next;
      t.next = z;
      z = t;
    }
  }

  y = merge_sort(y);
  z = merge_sort(z);

  if (y.value < z.value) {
    x = y;
    p = y;
    y = y.next;
  } else {
    x = z;
    p = z;
    z = z.next;
  }
  while (y !== null && z !== null) {
    if (y.value < z.value) {
      p.next = y;
      y = y.next;
    } else {
      p.next = z;
      z = z.next;
    }

    p = p.next;
  }

  if (y !== null) {
    p.next = y;
  } else {
    p.next = z;
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
  var l2 = merge_sort(l);
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
