//%attributes = {"preemptive":"capable"}
#DECLARE($folder : Object)

var $files; $subfolders : Collection
var $file; $subfolder : Object
var $name : Text

$files:=$folder.files()
For each ($file; $files)
	$name:=$file.name
	If (Position:C15("._"; $file.fullName)=1)
		$file.delete()
		LOG EVENT:C667(Into system standard outputs:K38:9; "***INFO*** Fichier supprimé : "+$file.path+"\n")
	End if 
End for each 

$subfolders:=$folder.folders()
For each ($subfolder; $subfolders)
	If (Position:C15("._"; $subfolder.fullName)=1)
		$subfolder.delete(Delete with contents:K24:24)
	Else 
		deleteHiddenFiles($subfolder)
	End if 
End for each 