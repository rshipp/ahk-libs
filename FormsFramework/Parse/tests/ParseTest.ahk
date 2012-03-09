#include UTest.ahk
return


Test_Options() {
	o = w800|h600|Style:Resize ToolWindow|font:s12 bold, Courier New|HWND12|show|dummy:red
	no := Parse(o, "s|a:c1)w# h# red? HWND# style font dummy show?", w, h, bRed, HWND, style, font, d, bShow)
	Assert_True(w=800, h=600, bRed="", hwnd=12, style="", font="s12 bold, Courier New", d="red", bShow, no=7)
}

Test_Extra() {
	o = AlwaysOnTop Resize T50 TCFFFFFF
	Parse(o, "t# tc*", t, tc, extra)
	Assert_True(t=50, tc="ffffff", extra="AlwaysOnTop Resize")
}

Test_Style() {	
	o = style='FLAT TOOLTIPS'
	no := Parse(o, "x# y# w# h# style IL* g*", x, y,w,h,style,il,handler)
	Assert_True(style="FLAT TOOLTIPS", x="", y="", w="", h="", il="", handler="")
}

Test_Quotes() {
	o = 48 53.66 tooltip='some =tooltip' show=1 input='2' 101
	no := Parse(o, "tooltip show input 1 2 6", p1, p2,p3, p4, p5, p6)
	Assert_True("Test1", p1="some =tooltip", p2=1, p3=2, p4=48, p5=53.66, p6=101, no=6)

	o = x'  bleh ' y'mislim dakle postojim'
	no := Parse(o, "y*", p1, extra)
	Assert_True("Test2", no=2, p1="mislim dakle postojim", extra="x'  bleh '")
}

Test_Escape() {
	o =	'param`=`' meh'
	no := Parse(o, "1", p1, no)
	Assert_True(p1, no=1, p1="param`=`' meh")

	
;	o =	'param1' 'param2' 'param`=`'param3' param4
;	no := Parse(o, "1 2 3 4", p1, p2, p3, p4)
;	Assert_True("Normal", p1="param1", p2="param2", p3="param='param3", p4="param4", no=4)
;
;	o =	"param1" "param2" "param`=`"param3" param4
;	no := Parse(o, "q"")1 2 3 4", p1, p2, p3, p4)
;	Assert_True("Custom", p1="param1", p2="param2", p3="param=""param3", p4="param4", no=4)
}
Test_AHKGuiLike() {
	o = x20 y40 w0 h0 red HWNDvar gLabel                                                     
	no := Parse(o, "x# y# w# h# red? HWND* g*", x, y, w, h, red, hwnd, g)	
	Assert_True(x=20, y=40, w=0, h=0, red=1, hwnd="var", g="Label", no=7)
}

Test_AHKGuiLikeEx() {
	o = w800 h600 style='Resize ToolWindow' font='s12 bold, Courier New' HWND12 show dummy=red
	no := Parse(o, "w# h# red? HWND# style font dummy show?", w, h, bRed, HWND, style, font, d, bShow)
	Assert_True(w=800, h=600, bRed="", hwnd=12, style="Resize ToolWindow", font="s12 bold, Courier New", d="red", bShow, no=7)

	o = hidden h23
	no := Parse(o, "h# hidden?", h, bHidden)
	Assert_True(no=2, h=23, bHidden)
}

Test_ByPosition(){ 
	o = 'mika je car' 'pera je car' laza='laza je car'
	no := Parse(o, "laza 1 2", p1, p2, p3)
	Assert_True(no=3, p1="laza je car", p2="mika je car", p3="pera je car")
}

#include ..\Parse.ahk