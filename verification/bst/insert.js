function make_node(v)
{
  var node = {
    value : v,
    left  : null,
    right : null
  };
  return node;
}

function insert(v, t)
{
  if (t === null)
    return make_node(v);

  if (v < t.value)
    t.left = insert(v, t.left);
  else if (v > t.value) 
    t.right = insert(v, t.right);

  return t;
}

