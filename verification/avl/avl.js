// AVL Tree in C-like style


// Basics

function make_node(v)
{
  var node = {
    value  : v,
    height : 1,
    left   : null,
    right  : null
  };
  return node;
}

function max(a, b)
{
  return a > b ? a : b;
}

function height(t)
{
  return t ? t.height : 0;
}

function update_height(t)
{
  t.height = max(height(t.left), height(t.right)) + 1;
}

function find_min(t)
{
  if (t.left === null)
    return t.value;
  else
    return find_min(t.left);
}


// Balancing tree

function left_rotate(x)
{
  var y;

  y = x.right;
  x.right = y.left;
  y.left = x;

  update_height(x);
  update_height(y);

  return y;
}

function right_rotate(x)
{
  var y;

  y = x.left;
  x.left = y.right;
  y.right = x;

  update_height(x);
  update_height(y);

  return y;
}

function balance(t)
{
  if (height(t.left) - height(t.right) > 1) {
    if (height(t.left.left) < height(t.left.right))
      t.left = left_rotate(t.left);
    t = right_rotate(t);
  }
  else if (height(t.left) - height(t.right) < -1) {
    if (height(t.right.left) > height(t.right.right))
      t.right = right_rotate(t.right);
    t = left_rotate(t);
  }

  return t;
}


// Tree operations

function find(v, t)
{
  if (t === null)
    return false;
  else if (v === t.value)
    return true;
  else if (v < t.value)
    return find(v, t.left);
  else
    return find(v, t.right);
}

function insert(v, t)
{
  if (t === null)
    return make_node(v);

  if (v < t.value)
    t.left = insert(v, t.left);
  else if (v > t.value)
    t.right = insert(v, t.right);
  else
    return t;

  update_height(t);
  t = balance(t);

  return t;
}

function remove(v, t)
{
  if (t === null)
    return null;

  if (v === t.value) {
    if (t.left === null) {
      return t.right;
    }
    else if (t.right === null) {
      return t.left;
    }
    else {
      var min = find_min(t.right);
      t.right = remove(min, t.right);
      t.value = min;
    }
  }
  else if (v < t.value)
    t.left = remove(v, t.left);
  else
    t.right = remove(v, t.right);

  update_height(t);
  t = balance(t);

  return t;
}



// Test

// function Test() {
//   var avl = null; console.log(avl);
//   avl = insert(1,avl); console.log(avl);
//   avl = insert(2,avl); console.log(avl);
//   avl = insert(3,avl); console.log(avl);
//   console.log(find(1,avl));
//   console.log(find(2,avl));
//   console.log(find(3,avl));
//   console.log(find(4,avl));
//   avl = remove(2,avl); console.log(avl);
// }
// Test();
