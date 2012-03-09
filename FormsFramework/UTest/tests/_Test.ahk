#include ..\UTest.ahk

Test_TrueOK(){
	Assert_True(1=1, 2=2, 3=3)
}

Test_FalseOK(){
	Assert_False(1=2, 2=3, 3=4)
}

Test_TrueFAIL(){
	Assert_True(1=1, 2=2, 3=5)
}

Test_FalseFAIL(){
	Assert_False(1=2, 2=3, 3=3)
}
