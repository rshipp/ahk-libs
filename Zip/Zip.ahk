
/*!
    Library: Zip, version 1.0
        Zip arrays.
        
        Supports AutoHotkey_L and AutoHotkey v2 Alpha
    Author: infogulch
    Version: 1.0
*/

/*!
    Function: Zip( [mode,] array1 [..., arrayN] )

    Parameters:
        mode - (Optional) If the first arg is a string it is interpreted as the mode specifier
            which modifies the function's behavior when arrays have differing sizes.
        array1...arrayN - Arrays to zip.

    Returns:
        An array of arrays where the *i*-th array contains the *i*-th element from all of the parameter arrays.  
        E.g. passing arrays `[1,2,3]` and `["a","b","c"]`  would return `[[1,"a"],[2,"b"],[3,"c"]]`

    Throws:
        Non object arg passed.

    Extra:
        ## Remarks
        
        ### Behavior when arrays have different sizes
            This is changed by specifying the `mode` parameter.
            
            * default (omitted or when options param is any string other than `all` or `copy`)  
                When one array is longer than another, truncate the longer array to the length 
                of the shorter array.  
                See example A
            
            * all
                When one array is shorter than another it is extended with empty values (skipped).  
                This can result in sparsely populated return arrays like: `{3: "c", 5: "e"}`  
                See example B  
                Since nothing is truncated in this mode the result is 100% reversible. (Example C)
            
            * copy
                When one array is shorter than another, the last value in the
                array is copied to extended it.  
                See example D
        
        ### Unzipping
            zip() in conjunction with the \* operator can be used to unzip zipped arrays.  
            See example C
        
        ### Examples
            These are referred to in the examples.  
            When they're lined up like this, you can look down the columns to see the values it will return.
            > a1 := ["a","b","c"]
            > a2 := ["A","B","C"]
            > a3 := [ 1 , 2 , 3 , 4]   ; this one has 4 elements
            A:
            > zipped := zip(a1, a2, a3)
            > ; [["a", "A", 1], ["b", "B", 2], ["c", "C", 3]]
            > ; notice that the value 4 has been omitted entirely
            B:
            > zipped := zip("all", a1, a2, a3)
            > ; [["a", "A", 1], ["b", "B", 2], ["c", "C", 3], {3: 4}]
            > ; notice the sparsely-populated fourth array
            C:
            > unzipped := zip(zipped*)
            > ; [["a","b","c"],["A","B","C"],[1,2,3,4]]
            > ; using zip again unzips and returns the originals
            D:
            > zipped := zip("copy", a1, a2, a3)
            > ; [["a", "A", 1], ["b", "B", 2], ["c", "C", 3], ["c", "C", 4]]
            > ; notice where "all" produced a sparsely-populated fourth array, this copies 
            > ;    the last value of the smaller arrays to fill in missing indexes
            E: side-effects of "copy" mode
            > unzipped := zip(zipped*)
            > ; [["a", "b", "c", "c"], ["A", "B", "C", "C"], [1, 2, 3, 4]]
            > ; notice the extra "c" and "C" where they were too short.
        
        ### See also
            [AutoHotkey Forum topic](http://www.autohotkey.com/forum/viewtopic.php?t=77832)
            
            The default mode is similar to [Python's zip](http://docs.python.org/library/functions.html#zip)
        
        ### License
            > Copyright (c) 2011, infogulch
            > All rights reserved.
            > 
            > Redistribution and use in source and binary forms, with or without modification, are permitted 
            > provided that the following conditions are met:
            > 
            >     * Redistributions of source code must retain the above copyright notice, this list of 
            >       conditions and the following disclaimer.
            >     * Redistributions in binary form must reproduce the above copyright notice, this list 
            >       of conditions and the following disclaimer in the documentation and/or other materials 
            >       provided with the distribution.
            > 
            > THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR 
            > IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY 
            > AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR 
            > CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
            > CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
            > SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY 
            > THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
            > OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
            > POSSIBILITY OF SUCH DAMAGE.
*/

Zip( arrays* )
{
    if !IsObject(arrays[1])
        mod := arrays.remove(1), mod := (mod = "all") + (mod = "copy")*2
    
    count := arrays[1].MaxIndex()
    loop % arrays.MaxIndex()
    {
        if !IsObject(arrays[A_Index])
            throw Exception("Zip() only accepts arrays", -1)
        c := arrays[A_Index].MaxIndex()
        if (mod ? c > count : c < count)
            count := c
    }
    
    ret := []
    i := 0
    loop % count
        loop % (arrays.MaxIndex(), i++)
            if (arrays[A_Index].HasKey(i))
                ret[i,A_Index] := arrays[A_Index, i]
            else if (mod == 2 && i > arrays[A_Index].MaxIndex())
                ret[i,A_Index] := arrays[A_Index, arrays[A_Index].MaxIndex()]
    return ret
}
