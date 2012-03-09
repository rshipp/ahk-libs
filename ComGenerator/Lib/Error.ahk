/*
File: ERROR.ahk
Script: ComGenerator

Purpose:
	Defines errors and error messages that might occur in ComGenerator.

Authors:
	* maul.esel

Requirements:
	AutoHotkey - AutoHotkey_L v1.1+
	Libraries - CCF (https://github.com/maul-esel/COM-Classes)

License:
	http://unlicense.org
*/
class ERROR
{
	static CLEAR := -1

	static SUCCESS := 0x00

	static ABORTED := 0x01

	static INVALID_CMD := 0x02

	static FIND_INTERFACE := 0x03

	static READ_NAME := 0x04

	static READ_TYPELIB := 0x05

	static READ_TYPELIB_VERSION := 0x06

	static LOAD_LIBRARY := 0x07

	static LOAD_TYPE := 0x08

	static NAME_MISSING := 0x09

	static NOT_IMPLEMENTED := 0x0A
}