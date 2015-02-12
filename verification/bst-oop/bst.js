// Binary Search Tree

BST = function () {
  this.root = null;
};

BST.prototype.insert = function (v) {
  if (this.root == null) {
    this.root = new BST.Node(v);
  } else {
    this.root.insert(v);
  }
};

BST.prototype.find = function (v) {
  if (this.root == null) {
    return false;
  } else {
    return this.root.find(v);
  }
};

// Binary Search Tree Node

BST.Node = function (v) {
  this.value = v;
  this.left  = null;
  this.right = null;
};

BST.Node.prototype.insert = function (v) {
  if (v < this.value) {
    if (this.left == null) {
      this.left = new BST.Node(v);
    } else {
      this.left.insert(v);
    }
  } else if (v > this.value) {
    if (this.right == null) {
      this.right = new BST.Node(v);
    } else {
      this.right.insert(v);
    }
  }
};

BST.Node.prototype.find = function (v) {
  if (v < this.value) {
    if (this.left == null) {
      return false;
    } else {
      return this.left.find(v);
    }
  } else if (v > this.value) {
    if (this.right == null) {
      return false;
    } else {
      return this.right.find(v);
    }
  } else {
    return true;
  }
};






// function Main() {
//   var t = new BST();
//   t.insert(2);
//   t.insert(1);
//   t.insert(3);
//   console.log(t);
//   console.log(t.find(1));
//   console.log(t.find(2));
//   console.log(t.find(3));
//   console.log(t.find(4));
// }
// Main();
