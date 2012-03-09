getFile(name) {
  static files := {}
  if files[name]
    Return files[name]
  file := {}
  loop, read, %name%
  {
    file[A_Index] := A_LoopReadLine
  }
  files[name] := file
  return file
}


getLinesNear(lineNumber, filename) {
  if lineNumber is not number
    throw exception("lineNumber not provided")
  file := getFile(filename)
  lines := ""
  loop, 5
  {
    lines .= file[lineNumber - 3 + A_Index] . "`n"
  }
  return lines
}


getLineSource(lineNumber, filename) {
  if lineNumber is not number
    throw exception("lineNumber not provided")
  file := getFile(filename)
  line := file[lineNumber]
  return Trim(line)
}

getStackTrace(max = 10) {
  if (max > 50)
    max := 50
  stack := object()
  loop{
    if (A_Index < 2)  ; don't need stack for these utility functions
      continue 
    if (A_Index > max)  ; in case we are in a long running coroutine
      break
    s := exception("level " A_Index, 0 - A_Index)
    if s.what < 0
      Break
    s.extra := getLinesNear(s.line, s.file)
    stack[A_Index] := s
  }
  return stack
}

RemoveUTestFunctionsFromStackTrace(stack) {
  max := stack.maxindex()
  loop % max
  {
    s := stack[A_Index]
    if instr(s.What, "runTests"){
      stack[A_Index] := 0
      stack[A_Index - 1] := 0
      level := A_Index
    }
    if (level < max){
      loop % (max - level){
        stack[level + A_Index] := 0
      }
    }
  }
  return stack
}




