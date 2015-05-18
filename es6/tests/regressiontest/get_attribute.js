      Object.defineProperty(arr, "0", {
        get : (function () 
        {
          supportsArrayIndexGettersOnArrays = true;
          return 0;
        })
      });
