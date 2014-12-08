function find_min(t)
{
  if (t.left === null)
    return t.value;
  else
    return find_min(t.left);
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

  return t;
}

