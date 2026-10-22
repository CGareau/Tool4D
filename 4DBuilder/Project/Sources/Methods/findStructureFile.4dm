//%attributes = {"invisible":true}
#DECLARE($package : 4D:C1709.Folder)->$source : 4D:C1709.File

ASSERT:C1129($package.exists; $package.path)

var $project : 4D:C1709.Folder
$project:=$package.folder("Project")

If ($project.exists)
	
	// If there's a "Project" folder, there must be a .4dproject file
	$source:=$project.files().query("extension=.4dproject").pop()
	
Else 
	
	// There's no "Project" folder, there must be a .4db file
	$source:=$package.files().query("extension=.4db").pop()
	
End if 

If ($source=Null:C1517)  // will assert
	
	var $message : Text
	//$message:=($project.exists) ? "can't find the project file: " : "can't find the structure file: "
	//$message+=$package.path
	$message:=Choose:C955($project.exists; "can't find the project file: "; "can't find the structure file: ")+$package.path
	
	//If (($package.files(fk recursive).length=0) && ($package.folders(fk recursive).length>0))
	If ($package.files(fk recursive:K87:7).length=0)
		If ($package.folders(fk recursive:K87:7).length>0)
			
			$message+=". Folder seems to contain only folders, please remove it"
			
		End if 
	End if 
	
	ASSERT:C1129(False:C215; $message)
	
End if 

