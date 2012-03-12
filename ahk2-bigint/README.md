BigInt
======

Arbitrary precision integer library for AutoHotkey v2 (alpha)

Goals
-----

* Be easy to use, straightforward, consistent, accurate, and fast
* Ensure accuracy and validity through unit tests
* ***Any*** base as input and output (given char list of course)
* Include as many functions as possible & reasonable for an 
  integer lib
* Pure AHK(2) solution. Not rely on third-party extensions, 
  binaries, dll, or web requests to Wolfram|Alpha. 

Change Requirements
-------------------

These are the requirements for all changes.

* A user function may NOT modify `this` or any args passed. Use 
  `obj.clone()` or `new BigInt(...)` instead, and `return` a 
  different BigInt object
* Any additions or changes to the library must pass all current 
  unit tests, include unit tests relevant to the change,
  AND prove that it does not modify the original objects.
  (see BigIntUnitTest.ahk2 for examples)
* If possible, accept arguments that can be either BigInt 
  instances OR normal ahk numbers.
* User functions should have short names consisting only of 
  lower-case characters, and be at least mildly self-descriptive.
  Internal functions, including functions that may modify `this`
  and other args, should be prefixed with one or more 
  underscores.

ToDo
----
* I'm considering changing it so all functions have a counterpart
  that does modify `this`. They would be prefixed with one
  underscore, and of course have a non-`this`-modifying version
  that acts exactly like the current functions.

Usage Examples
--------------

Regular Math:

    x := new BigInt(55)
    
    MsgBox % x.div(new BigInt(5)).__string()  ; integer division
    
    MsgBox % x.mult(33).__string()  ; multiplication
    
    y := new BigInt(0x800)
    
    MsgBox % y.shl(400).__string()  ; left shift by 400 bits
    
    MsgBox % y.shr().__string()  ; right shift (1 is default)


Take a really big number, and square it a bunch of times: 

    x := new BigInt("abcdef123456789", "hex")
    
    loop 10
        x := x.pow(2)
        
    msgbox % x.__string()  ; this is a really really huge number
