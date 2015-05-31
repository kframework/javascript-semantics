function head(x) { // 2
  return x.value;
}

function tail(x) { // 4
  return x.next;
}

function add(v, x) { // 6
  var y = {
    value : v,
    next  : x
  };
  return y;
}

function swap(x) { // 8
  var p;

  p = x;
  x = x.next;
  p.next = x.next;
  x.next = p;

  return x;
}

function length_recursive(x) { // 10
  if (x === null)
    return 0;

  return 1 + length_recursive(x.next);
}

function length_iterative(x) { // 12
  var y = 0;

  while (x !== null) {
    y = y + 1;
    x = x.next;
  }

  return y;
}

function sum_recursive(x) { // 14
  if (x === null)
    return 0;

  return x.value + sum_recursive(x.next);
}

function sum_iterative(x) { // 16
  var s = 0;

  while (x !== null) {
    s = s + x.value;
    x = x.next;
  }

  return s;
}

function reverse(x) { // 18
  var p = null;
  var y;

  while(x !== null) {
    y = x.next;
    x.next = p;
    p = x;
    x = y;
  }

  return p;
}

function append(x, y) { // 20
  var p;

  if (x === null)
    return y;

  p = x;
  while(p.next !== null) {
    p = p.next;
  }
  p.next = y;

  return x;
}

function copy(x) { // 22
  var y;
  var iterx;
  var itery;
  var node = null;

  if (x === null)
    return null;

  y = {
    value : x.value,
    next  : null
  };

  iterx = x.next;
  itery = y;
  while(iterx !== null) {
    node = {
      value : iterx.value,
      next  : null
    };
    itery.next = node;
    iterx = iterx.next;
    itery = itery.next;
  }

  return y;
}


/*
function main() {
  var l = null;
  var l2, l3;
  l = add(1,l);
  l = add(2,l);
  l = add(3,l);
  console.log(l);
  l = swap(l);
  console.log(l);
  console.log(length_recursive(l));
  console.log(length_iterative(l));
  console.log(sum_recursive(l));
  console.log(sum_iterative(l));
  l2 = copy(l);
  l3 = reverse(l);
  console.log(l2);
  console.log(l3);
}
main();
*/
