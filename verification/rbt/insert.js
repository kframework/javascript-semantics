// Basics

function make_node(v)
{
  var node = {
    value  : v,
    color  : 0, // RED
    left   : null,
    right  : null
  };
  return node;
}

function color(t)
{
  return t ? t.color : 1; // BLACK
}

function find_min(t)
{
  if (t.left === null)
    return t.value;
  else
    return find_min(t.left);
}

function left_rotate(x)
{
  var y;
  y = x.right;
  x.right = y.left;
  y.left = x;
  return y;
}

function right_rotate(x)
{
  var y;
  y = x.left;
  x.left = y.right;
  y.right = x;
  return y;
}


// Insert

function insert_aux(value, tree)
{
  if (tree == null) {
    return make_node(value);
  }
  if (value < tree.value) {
    tree.left = insert_aux(value, tree.left);
    if (color(tree.left) != 1 /* RED */) {
      if (color(tree.right) != 1 /* RED */) { // case 3
        if (color(tree.left.left) != 1 /* RED */ || color(tree.left.right) != 1 /* RED */) {
          tree.left.color = 1 /* BLACK */;
          tree.right.color = 1 /* BLACK */;
          tree.color = 0 /* RED */;
        }
      }
      else {
        if (color(tree.left.right) != 1 /* RED */) { // case 4
          tree.left = left_rotate(tree.left);
        }
        if (color(tree.left.left) != 1 /* RED */) { // case 5; case 4 falls through
          tree = right_rotate(tree);
          tree.color = 1 /* BLACK */;
          tree.right.color = 0 /* RED */;
        }
      }
    }
  }
  else if (value > tree.value) {
    tree.right = insert_aux(value, tree.right);
    if (color(tree.right) != 1 /* RED */) {
      if (color(tree.left) != 1 /* RED */) {
        if (color(tree.right.right) != 1 /* RED */ || color(tree.right.left) != 1 /* RED */) { // case 3
          tree.right.color = 1 /* BLACK */;
          tree.left.color = 1 /* BLACK */;
          tree.color = 0 /* RED */;
        }
      }
      else {
        if (color(tree.right.left) != 1 /* RED */) { // case 4
          tree.right = right_rotate(tree.right);
        }
        if (color(tree.right.right) != 1 /* RED */) { // case 5; case 4 falls through
          tree = left_rotate(tree);
          tree.color = 1 /* BLACK */;
          tree.left.color = 0 /* RED */;
        }
      }
    }
  }
  return tree;
}

function insert(value, tree)
{
  tree = insert_aux(value, tree);
  if (color(tree) != 1 /* RED */) {
    tree.color = 1 /* BLACK */;
  }
  return tree;
}
