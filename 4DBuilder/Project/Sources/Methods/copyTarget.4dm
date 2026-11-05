//%attributes = {"invisible":true}
#DECLARE($config : Object; $target : Object) : Boolean

$config.report($target; "Copying source folder to "+$target.outputFolder.path; "info")

var $success : Boolean
var $copy : Object

If (Position:C15($target.source.path; $target.outputFolder.path)=1)  // child folder, we compile inside project
	$success:=True:C214
	// first copy files
	var $file : Object  // 4D.File?
	For each ($file; $target.source.files())
		$copy:=$file.copyTo($target.outputFolder)
		$success:=($copy#Null:C1517) && $success
	End for each 
	// then folder, without destination folder
	var $folder : Object  // 4D.Folder?
	For each ($folder; $target.source.folders())
		If (Position:C15($folder.path; $target.outputFolder.path)#1)  // but not the child folder
			$copy:=$folder.copyTo($target.outputFolder)
			$success:=($copy#Null:C1517) && $success
		End if 
	End for each 
	
Else 
	$copy:=$target.source.copyTo($target.outputFolder.parent; $target.outputFolder.fullName)
	$success:=($copy#Null:C1517)
End if 

return $success