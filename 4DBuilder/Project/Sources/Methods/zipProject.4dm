//%attributes = {"invisible":true}
#DECLARE($config : Object; $target : Object) : Boolean

var $result : Object

If ($target.outputStructure.extension=".4dproject")
	
	// retrieve project name (will be the zip file name)
	var $name : Text
	$name:=$target.outputStructure.name
	
	var $projectFolder : Object  //4D.Folder
	$projectFolder:=$target.outputFolder.folder("Project")
	
	If ($projectFolder.exists)
		
		$result:=ZIP Create archive:C1640($projectFolder; $target.builtStructure)
		
		If ($result.success)
			
			// deletes the project folder
			$config.report($target; "Removing project folder"; "info")
			$projectFolder.delete(Delete with contents:K24:24)
			
		Else 
			
			$config.report($target; "Zip error "+String:C10($result.code)+" occured. Message: "+String:C10($result.message); "error")
			
		End if 
		
		return $result.success
		
	Else 
		
		$config.report($target; "Missing project folder"; "error")
		
		return False:C215
		
	End if 
	
Else 
	
	return True:C214
	
End if 