//%attributes = {"preemptive":"capable"}
#DECLARE($filePath : Text)
var $folderToClean : 4D:C1709.Folder
$folderToClean:=Folder:C1567($filePath; fk platform path:K87:2)
If ($folderToClean.exists)
	LOG EVENT:C667(Into system standard outputs:K38:9; "***INFO*** Delete hidden files\n")
	deleteHiddenFiles($folderToClean)
Else 
	LOG EVENT:C667(Into system standard outputs:K38:9; "***Error*** The following folder doesn't exist: "+$filePath+"\n"; Error message:K38:3)
End if 