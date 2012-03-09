class ErrorHandler
{
	static Messages := {  (ERROR.CLEAR) : ""
						, (ERROR.SUCCESS) : "Success!"
						, (ERROR.ABORTED) : "Operation aborted by user."
						, (ERROR.INVALID_CMD) : "Invalid command line options."
						, (ERROR.FIND_INTERFACE) : "The IID for the specified interface name could not be found."
						, (ERROR.READ_NAME) : "The name for the specified IID could not be read."
						, (ERROR.READ_TYPELIB) : "The type library for the specified IID could not be read."
						, (ERROR.READ_TYPELIB_VERSION) : "The type library version for the specified IID could not be read."
						, (ERROR.LOAD_LIBRARY) : "The type library could not be loaded."
						, (ERROR.LOAD_TYPE) : "The specified type could not be loaded from the type library."
						, (ERROR.NAME_MISSING) : "No name was specified."
						, (ERROR.NOT_IMPLEMENTED) : "This action has not yet been implemented." }
}