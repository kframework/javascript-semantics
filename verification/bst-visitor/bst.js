BST = function () {
};

BST.prototype.root = null;

BST.prototype.insert = function (v) {
  if (this.root == null) {
    this.root = new BST.Node(v);
    return;
  }
  this.traverse(function (current) {
    var next = null;
    if (v < current.value) {
      next = current.left;
      if (current.left == null) {
        current.left = new BST.Node(v);
      }
    } else if (v > current.value) {
      next = current.right;
      if (current.right == null) {
        current.right = new BST.Node(v);
      }
    }
    return next;
  });
};

BST.prototype.find = function (v) {
  var found = false;
  this.traverse(function (current) {
    var next = null;
    if (v < current.value) {
      next = current.left;
    } else if (v > current.value) {
      next = current.right;
    } else {
      found = true;
    }
    return next;
  });
  return found;
};

BST.prototype.traverse = function (f) {
  var current = this.root;
  while (current) {
    current = f.call(this, current);
  }
};


BST.Node = function (v) {
  this.value = v;
};

BST.Node.prototype.left  = null;

BST.Node.prototype.right = null;


// var t = new BST();
// t.insert(2);
// t.insert(1);
// t.insert(3);
// console.log(t);
// console.log(t.find(1));
// console.log(t.find(2));
// console.log(t.find(3));
// console.log(t.find(4));
