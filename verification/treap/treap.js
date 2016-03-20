function make_node(v, p) {
  var n = {
    value    : v,
    priority : p,
    left     : null,
    right    : null
  };
  return n;
}

function left_rotate(x) {
  var y;
  y = x.right;
  x.right = y.left;
  y.left = x;
  return y;
}

function right_rotate(x) {
  var y;
  y = x.left;
  x.left = y.right;
  y.right = x;
  return y;
}

function find(v, t) {
  if (t === null) {
    return false;
  } else if (v === t.value) {
    return true;
  } else if (v < t.value) {
    return find(v, t.left);
  } else {
    return find(v, t.right);
  }
}

function insert(v, p, t) {
  if (t === null) {
    return make_node(v, p);
  }
  if (v < t.value) {
    t.left = insert(v, p, t.left);
    if (t.left.priority > t.priority) {
      t = right_rotate(t);
    }
  } else if (v > t.value) {
    t.right = insert(v, p, t.right);
    if (t.right.priority > t.priority) {
      t = left_rotate(t);
    }
  }
  return t;
}

function remove_root(t) {
  if (t.left === null) {
    t = t.right;
  } else if (t.right === null) {
    t = t.left;
  } else {
    if (t.left.priority < t.right.priority) {
      t = left_rotate(t);
      t.left = remove_root(t.left);
    } else {
      t = right_rotate(t);
      t.right = remove_root(t.right);
    }
  }
  return t;
}

function remove(v, t) {
  if (t === null) {
    return null;
  }
  if (v === t.value) {
    t = remove_root(t);
  } else if (v < t.value) {
    t.left = remove(v, t.left);
  } else {
    t.right = remove(v, t.right);
  }
  return t;
}

/*
function main() {
  var t = null;
  t = insert(1,10,t); console.log(t);
  t = insert(2,30,t); console.log(t);
  t = insert(3,20,t); console.log(t);
  t = remove(2,t);    console.log(t);
  return 0;
}
main();
*/
