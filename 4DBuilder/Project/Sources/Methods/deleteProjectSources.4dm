//%attributes = {"invisible":true,"preemptive":"capable"}
#DECLARE($config : Object; $target : Object) : Boolean

var $t : Text
var $folder; $sourcesFolder : 4D:C1709.Folder
var $file : 4D:C1709.File

// Deletes invisible files and folders at the root level (git…)
For each ($file; $target.outputFolder.files().query("fullName=.@"))
	
	$config.report($target; "Removing file "+$file.path; "info")
	$file.delete()
	
End for each 

For each ($folder; $target.outputFolder.folders().query("fullName=.@"))
	
	$config.report($target; "Removing folder "+$folder.path; "info")
	$folder.delete(Delete with contents:K24:24)
	
End for each 

If (String:C10($config.config)#"debug")
	
	$config.report($target; "Removing private files"; "info")
	
	$file:=$target.outputFolder.file("make.json")
	If ($file.exists)
		checkFileWritable($file)
		$file.delete()
	End if 
	
	If (Not:C34(Bool:C1537($config.make.contents)))
		// Deprecated code if contents=true become the only value
		For each ($t; ["Info.plist"; "Resources/InfoPlist.strings"])
			
			$file:=$target.outputFolder.file($t)
			
			If ($file.exists)
				checkFileWritable($file)
				$file.delete()
			End if 
			
		End for each 
		
	End if 
	
	$sourcesFolder:=$target.outputFolder.folder("Project/Sources")
	
	If ($sourcesFolder.exists)
		
		$file:=$sourcesFolder.file("folders.json")
		If ($file.exists)
			checkFileWritable($file)
			$file.delete()
		End if 
		
		// Delete 4dm files
		$config.report($target; "Removing method source files"; "info")
		
		For each ($file; $sourcesFolder.files(fk recursive:K87:7).query("extension=.4dm"))
			
			$file.delete()
			
		End for each 
		
		// Delete 'Methods', 'Triggers', 'DatabaseMethods', 'Classes' folders if empty
		For each ($t; New collection:C1472("Classes"; "Methods"; "Triggers"; "DatabaseMethods"; "/Resources"))
			
			$folder:=$sourcesFolder
			
			While ($t[[1]]=".")\
				 | ($t[[1]]="/")
				
				$folder:=$folder.parent
				$t:=Delete string:C232($t; 1; 1)
				
			End while 
			
			$folder:=$folder.folder($t)
			
			If ($folder.exists)
				
				If ($folder.files().length=0)\
					 & ($folder.folders().length=0)
					
					$folder.delete()
					
				End if 
			End if 
		End for each 
		
		// Delete form objects methods
		For each ($folder; $sourcesFolder.folder("Forms").folders(fk recursive:K87:7).query("fullName=ObjectMethods"))
			
			$folder.delete(Delete with contents:K24:24)
			
		End for each 
		
		// Delete form methods
		For each ($file; $sourcesFolder.folder("Forms").files(fk recursive:K87:7).query("extension=.4dm"))
			
			$file.delete()
			
		End for each 
	End if 
End if 

// Deletes the Trash
$folder:=$target.outputFolder.folder("Project/Trash")

If ($folder.exists)
	
	$config.report($target; "Removing trash folder"; "info")
	$folder.delete(Delete with contents:K24:24)
	
End if 

// Delete the Logs folder
$folder:=$target.outputFolder.folder("Logs")

If ($folder.exists)
	
	$config.report($target; "Removing logs folder"; "info")
	$folder.delete(Delete with contents:K24:24)
	
End if 

// Delete the Preferences folder
$folder:=$target.outputFolder.folder("Preferences")

If ($folder.exists)
	
	$config.report($target; "Removing Preferences folder"; "info")
	$folder.delete(Delete with contents:K24:24)
	
End if 

// Delete the Settings folder
$folder:=$target.outputFolder.folder("Settings")

If ($folder.exists)
	
	$config.report($target; "Removing Settings folder"; "info")
	$folder.delete(Delete with contents:K24:24)
	
End if 

// Delete the user preference folders
For each ($folder; $target.outputFolder.folders().query("name=userPreferences"))
	
	$config.report($target; "Removing preferences folder "+$folder.path; "info")
	$folder.delete(Delete with contents:K24:24)
	
End for each 

// Delete some other unused files
For each ($file; $target.outputFolder.files().query("extension=.4DD OR extension=.Match"))
	
	$file.delete()
	
End for each 

return True:C214