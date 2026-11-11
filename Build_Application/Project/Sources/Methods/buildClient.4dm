//%attributes = {"preemptive":"capable"}
#DECLARE($config : Object)->$result : Collection

var $build : cs:C1710.Build4D.Client
var $settings; $archive; $obFile : Object
var $major; $minor; $patch : Integer
var $versionSplitted : Collection
var $fileContent : Text
var $success : Boolean

If (Is macOS:C1572)
	$obFile:=File:C1566($config.projectPath; fk posix path:K87:1).parent.parent.file("buildClientMac.json")
Else 
	$obFile:=File:C1566($config.projectPath; fk platform path:K87:2).parent.parent.file("buildClientWin.json")
End if 
If ($obFile.exists)
	$fileContent:=$obFile.getText()
	If ($fileContent#"")
		$settings:=JSON Parse:C1218($fileContent)
	End if 
Else 
	LOG EVENT:C667(Into system standard outputs:K38:9; "***ERROR*** buildClient.json not found\n"; Error message:K38:3)
End if 

If ($settings#Null:C1517)
	// Define the external project file
	If (Is macOS:C1572)
		$settings.projectFile:=File:C1566($config.projectPath; fk posix path:K87:1)
		LOG EVENT:C667(Into system standard outputs:K38:9; "***INFO*** ProjectFile: "+File:C1566($config.projectPath; fk posix path:K87:1).path+" - "+String:C10(File:C1566($config.projectPath; fk posix path:K87:1).exists)+"\n")
	Else 
		$settings.projectFile:=File:C1566($config.projectPath; fk platform path:K87:2)
		LOG EVENT:C667(Into system standard outputs:K38:9; "***INFO*** ProjectFile: "+File:C1566($config.projectPath; fk platform path:K87:2).path+" - "+String:C10(File:C1566($config.projectPath; fk platform path:K87:2).exists)+"\n")
	End if 
	
	// Define the destination folder
	If (Is macOS:C1572)
		$settings.destinationFolder:=Folder:C1567($config.output; fk posix path:K87:1).folder("Client")
		LOG EVENT:C667(Into system standard outputs:K38:9; "***INFO*** DestinationFolder: "+Folder:C1567($config.output; fk posix path:K87:1).folder("Client").path+" - "+String:C10(Folder:C1567($config.output; fk posix path:K87:1).folder("Client").exists)+"\n")
	Else 
		$settings.destinationFolder:=Folder:C1567($config.output; fk platform path:K87:2).folder("Client")
		LOG EVENT:C667(Into system standard outputs:K38:9; "***INFO*** DestinationFolder: "+Folder:C1567($config.output; fk platform path:K87:2).folder("Client").path+" - "+String:C10(Folder:C1567($config.output; fk platform path:K87:2).folder("Client").exists)+"\n")
	End if 
	
	// Define the 4D Volume Desktop path
	If (Is macOS:C1572)
		$settings.sourceAppFolder:=Folder:C1567(Application file:C491; fk platform path:K87:2).parent.folder("4D Volume Desktop.app")
	Else 
		$settings.sourceAppFolder:=Folder:C1567(Application file:C491; fk platform path:K87:2).parent.parent.folder("4D Volume Desktop")
	End if 
	LOG EVENT:C667(Into system standard outputs:K38:9; "***INFO*** SourceAppFolder: "+$settings.sourceAppFolder.path+" - "+String:C10($settings.sourceAppFolder.exists)+"\n")
	
	// Add the application icon
	If (Is macOS:C1572)
		$settings.iconPath:=File:C1566($config.projectPath; fk posix path:K87:1).parent.parent.folder("Resources").file("myIcon.icns")
	Else 
		$settings.iconPath:=File:C1566($config.projectPath; fk platform path:K87:2).parent.parent.folder("Resources").file("myIcon.ico")
	End if 
	
	// Add buildNumber in the application information
	$settings.versioning.version:=$config.buildNumber
	If ($config.forceClientUpdate)
		$versionSplitted:=Split string:C1554($config.buildNumber; ".")
		If ($versionSplitted.length>2)
			$major:=Num:C11($versionSplitted[0])
			$minor:=Num:C11($versionSplitted[1])
			$patch:=Num:C11($versionSplitted[2])
			$settings.currentVers:=($major*1000000)+($minor*1000)+$patch
		Else 
			$settings.currentVers:=Num:C11($config.buildNumber)
		End if 
		LOG EVENT:C667(Into system standard outputs:K38:9; "***INFO*** currentVers: "+String:C10($settings.currentVers)+"\n")
	End if 
	
	// Create the client application
	$build:=cs:C1710.Build4D.Client.new($settings)
	$success:=$build.build()
	
	// Create the client application archive
	$archive:=$build.buildArchive()
	
	$result:=$build.logs
End if 