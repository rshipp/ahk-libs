
#Include LSON.ahk

myobj := ["someobject", 1, 7]
dispobj := { 123: [4, 5, 6], test: "this is ""text""", "testing foobar": "abc def", reference: myobj }
dispobj.insert(myobj, "object key value")
msgbox % LSON( dispobj )

parent := { "_me": "parent" }
child  := { "_me": "child", parent: parent }
parent["child"] := child
msgbox % LSON(parent)
msgbox % LSON(child)

myobj := { help: Func("myfunc") }
myobj.self := myobj
msgbox % LSON(myobj)
myfunc() {
    msgbox help me!
}

superobj := {test: "abc", "s p a c e s": ["  "], empty: []}
msgbox % LSON(superobj)
