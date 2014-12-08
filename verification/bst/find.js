function find (v, t)
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

