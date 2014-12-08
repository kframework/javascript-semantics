// 8.12.4 [[CanPut]] (P), Step 8.a

// 8. Else, inherited must be a DataDescriptor
//     a. If the [[Extensible]] internal property of O is false, return false.
//     b. ...

// If O inherits P, which is data descriptor, but O is not extensible, then CanPut is false.

// In this example, the assignment is ignored, since CanPut is false.

var o = Object.create( { x : 0 } );
Object.freeze(o); // Set o's [[Extensible]] false
o.x = 1; // [[CanPut]] is false, thus Nop
if (!(o.x === 0)) {
  $ERROR('var o = Object.create( { x : 0 } ); Object.freeze(o); o.x = 1; o.x is 0. Actual: ' + o.x);
}
