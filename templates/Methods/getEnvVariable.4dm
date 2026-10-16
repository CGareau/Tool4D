//%attributes = {}
// Returns the value of an operating system environment variable ("" if not defined).
// 4D has no command to read the process environment, so a shell is asked to print it.
#DECLARE($name : Text)->$value : Text

var $worker : 4D.SystemWorker

$value:=""

If (Is Windows)
	$worker:=4D.SystemWorker.new("cmd /c echo %"+$name+"%").wait(10)
Else 
	$worker:=4D.SystemWorker.new("/usr/bin/printenv "+$name).wait(10)
End if 

If (($worker#Null) && (String($worker.response)#""))
	$value:=Replace string(Replace string(String($worker.response); Char(13); ""); Char(10); "")
End if 

// cmd.exe prints the unexpanded name when the variable is not defined
If (Is Windows && ($value=("%"+$name+"%")))
	$value:=""
End if 
