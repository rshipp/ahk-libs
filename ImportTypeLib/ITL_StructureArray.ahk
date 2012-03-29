; zero-based
class ITL_StructureArray
{
	__New(type, count)
	{
		this["internal://type-obj"] := type
		, this["internal://instance-count"] := count
		, this["internal://memory-buffer"] := ITL_Mem_Allocate(count * type.GetSize())
		, this["internal://instance-size"] := type.GetSize()
		, this["internal://instance-array"] := []
	}

	__Get(property)
	{
		local buffer, size, index, struct
		if (property != "base" && !RegExMatch(property, "^internal://"))
		{
			count := this["internal://instance-count"]
			if (property == "")
			{
				buffer := this["internal://memory-buffer"], size := this["internal://instance-size"]
				for index, struct in this
				{
					ITL_Mem_Copy(struct["internal://type-instance"], buffer + index * size, size)
				}
				return buffer
			}

			else if property is not integer
			{
				throw Exception(ITL_FormatException("Failed to retrieve an array element."
												, """" property """ is not a valid array index."
												, ErrorLevel)*)
			}
			else if (property < 0 || property >= count)
			{
				throw Exception(ITL_FormatException("Failed to retrieve an array element."
												, """" property """ is out of range."
												, ErrorLevel)*)
			}

			struct := this["internal://instance-array"][property]
			if (!IsObject(struct))
				this["internal://instance-array"][property] := struct := new this["internal://type-obj"]()
			return struct
		}
	}

	__Set(property, value)
	{
		local count := this["internal://instance-count"]
		if (property != "base" && !RegExMatch(property, "^internal://"))
		{
			if property is not integer
			{
				throw Exception(ITL_FormatException("Failed to set an array element."
												, """" property """ is not a valid array index."
												, ErrorLevel)*)
			}
			else if (property < 0 || property >= count)
			{
				throw Exception(ITL_FormatException("Failed to set an array element."
												, """" property """ is out of range."
												, ErrorLevel)*)
			}

			if value is integer
			{
				value := new this["internal://type-obj"](value, true)
			}
			this["internal://instance-array"][property] := value
		}
	}

	__Delete()
	{
		local index, struct, field, value

		for index, struct in this
			this[index] := ""
		ITL_Mem_Release(this["internal://memory-buffer"])
		for field, value in ObjNewEnum(this)
			this[field] := ""
	}

	_NewEnum()
	{
		return ObjNewEnum(this["internal://instance-array"])
	}

	NewEnum()
	{
		return this._NewEnum()
	}

	SetCapacity(newCount)
	{
		local newBuffer := ITL_Mem_Allocate(newCount * this["internal://type-obj"].GetSize())
		, oldBuffer := this["internal://memory-buffer"]
		, oldCount := this["internal://instance-count"]

		ITL_Mem_Copy(oldBuffer, newBuffer, oldCount), ITL_Mem_Release(oldBuffer)
		this["internal://memory-buffer"] := newBuffer, this["internal://instance-count"] := newCount

		if (newCount < oldCount)
		{
			this["internal://instance-array"].Remove(newCount - 1, oldCount - 1)
		}
	}
}