//%attributes = {}
#DECLARE($config : Object)->$result : Collection

var $settings; $obFile; $components4DFolder; $component; $resourcesFolder; $pluginsFolder; $file : Object
var $versionSplitted; $components : Collection
var $major; $minor; $patch : Integer
var $build : cs:C1710.Build4D.Server
var $fileContent : Text
var $success : Boolean

If (Is macOS:C1572)
	$obFile:=File:C1566($config.projectPath; fk posix path:K87:1).parent.parent.file("buildServerMac.json")
Else 
	$obFile:=File:C1566($config.projectPath; fk platform path:K87:2).parent.parent.file("buildServerWin.json")
End if 
If ($obFile.exists)
	$fileContent:=$obFile.getText()
	If ($fileContent#"")
		$settings:=JSON Parse:C1218($fileContent)
	End if 
Else 
	LOG EVENT:C667(Into system standard outputs:K38:9; "***ERROR*** buildServer.json not found\n"; Error message:K38:3)
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
		$settings.destinationFolder:=Folder:C1567($config.output; fk posix path:K87:1).folder("Server")
		LOG EVENT:C667(Into system standard outputs:K38:9; "***INFO*** DestinationFolder: "+Folder:C1567($config.output; fk posix path:K87:1).folder("Server").path+" - "+String:C10(Folder:C1567($config.output; fk posix path:K87:1).folder("Server").exists)+"\n")
	Else 
		$settings.destinationFolder:=Folder:C1567($config.output; fk platform path:K87:2).folder("Server")
		LOG EVENT:C667(Into system standard outputs:K38:9; "***INFO*** DestinationFolder: "+Folder:C1567($config.output; fk platform path:K87:2).folder("Server").path+" - "+String:C10(Folder:C1567($config.output; fk platform path:K87:2).folder("Server").exists)+"\n")
	End if 
	
	// Define the 4D Server path
	If (Is macOS:C1572)
		$settings.sourceAppFolder:=Folder:C1567(Application file:C491; fk platform path:K87:2).parent.folder("4D Server.app")
	Else 
		$settings.sourceAppFolder:=Folder:C1567(Application file:C491; fk platform path:K87:2).parent.parent.folder("4D Server")
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
			$settings.rangeVersMin:=($major*1000000)+($minor*1000)+$patch
			$settings.rangeVersMax:=(($major+1)*1000000)+($minor*1000)+$patch
			$settings.currentVers:=($major*1000000)+($minor*1000)+$patch
		Else 
			$settings.rangeVersMin:=Num:C11($config.buildNumber)
			$settings.rangeVersMax:=Num:C11($config.buildNumber)+1
			$settings.currentVers:=Num:C11($config.buildNumber)
		End if 
		LOG EVENT:C667(Into system standard outputs:K38:9; "***INFO*** rangeVersMin: "+String:C10($settings.rangeVersMin)+"\n")
		LOG EVENT:C667(Into system standard outputs:K38:9; "***INFO*** rangeVersMax: "+String:C10($settings.rangeVersMax)+"\n")
		LOG EVENT:C667(Into system standard outputs:K38:9; "***INFO*** currentVers: "+String:C10($settings.currentVers)+"\n")
	End if 
	
	// Add the client archives
	If (Is macOS:C1572)
		If (Folder:C1567($config.output; fk posix path:K87:1).folder("Client").file("update.mac.4darchive").exists)
			$settings.macOSClientArchive:=Folder:C1567($config.output; fk posix path:K87:1).folder("Client").file("update.mac.4darchive")
			LOG EVENT:C667(Into system standard outputs:K38:9; "***INFO*** macOSClientArchive: "+$settings.macOSClientArchive.path+" - "+String:C10($settings.macOSClientArchive.exists)+"\n")
		End if 
		If (Folder:C1567($config.output; fk posix path:K87:1).file("update.win.4darchive").exists)
			$settings.windowsClientArchive:=Folder:C1567($config.output; fk posix path:K87:1).file("update.win.4darchive")
			LOG EVENT:C667(Into system standard outputs:K38:9; "***INFO*** windowsClientArchive: "+$settings.windowsClientArchive.path+" - "+String:C10($settings.windowsClientArchive.exists)+"\n")
		End if 
	Else 
		If (Folder:C1567($config.output; fk platform path:K87:2).folder("Client").file("update.win.4darchive").exists)
			$settings.windowsClientArchive:=Folder:C1567($config.output; fk platform path:K87:2).folder("Client").file("update.win.4darchive")
			LOG EVENT:C667(Into system standard outputs:K38:9; "***INFO*** windowsClientArchive: "+$settings.windowsClientArchive.path+" - "+String:C10($settings.windowsClientArchive.exists)+"\n")
		End if 
		If (Folder:C1567($config.output; fk platform path:K87:2).file("update.mac.4darchive").exists)
			$settings.macOSClientArchive:=Folder:C1567($config.output; fk platform path:K87:2).file("update.mac.4darchive")
			LOG EVENT:C667(Into system standard outputs:K38:9; "***INFO*** macOSClientArchive: "+$settings.macOSClientArchive.path+" - "+String:C10($settings.macOSClientArchive.exists)+"\n")
		End if 
	End if 
	
	If (Is Windows:C1573)
		If (($config.macCompiledProject#Null:C1517) && ($config.macCompiledProject#"") && (Folder:C1567($config.macCompiledProject; fk platform path:K87:2).exists))
			$settings.macCompiledProject:=Folder:C1567($config.macCompiledProject; fk platform path:K87:2)
			LOG EVENT:C667(Into system standard outputs:K38:9; "***INFO*** macCompiledProject: "+$settings.macCompiledProject.path+" - "+String:C10($settings.macCompiledProject.exists)+"\n")
		End if 
	End if 
	
	// load 4D components
	If (Is Windows:C1573)
		$components4DFolder:=Folder:C1567(Application file:C491; fk platform path:K87:2).parent.folder("Components")
	Else 
		$components4DFolder:=Folder:C1567(Application file:C491; fk platform path:K87:2).folder("Contents").folder("Components")
	End if 
	$components:=[]
	If ($components4DFolder.exists)
		For each ($component; $components4DFolder.folders())
			$components.push($component.folder("Contents").files().query("extension = .4DZ").first())
		End for each 
	End if 
	
	// load project components required for compilation
	$components4DFolder:=$settings.projectFile.parent.parent.folder("Components")
	$components:=[]
	
	// Include the folders and files
	$settings.includePaths:=[]
	
	$pluginsFolder:=$settings.projectFile.parent.parent.folder("Plugins")
	If ($pluginsFolder.exists)
		$settings.includePaths.push({source: $pluginsFolder.path; destination: "../"})
		LOG EVENT:C667(Into system standard outputs:K38:9; "***INFO*** Plugins folder found and added to the server package: "+$pluginsFolder.path+" - "+String:C10($pluginsFolder.exists)+"\n")
	End if 
	
	$resourcesFolder:=$settings.projectFile.parent.parent.folder("Resources")
	If ($resourcesFolder.exists)
		$settings.includePaths.push({source: $resourcesFolder.path; destination: "../Server Database/"})
		LOG EVENT:C667(Into system standard outputs:K38:9; "***INFO*** Resources folder found and added to the server package: "+$resourcesFolder.path+" - "+String:C10($resourcesFolder.exists)+"\n")
	End if 
	
	If ($components4DFolder.exists)
		For each ($component; $components4DFolder.folders())
			If ($component.folder("Contents").exists)
				$component:=$component.folder("Contents")
			End if 
			$file:=$component.files().query("extension = .4DZ AND fullName != ._@").first()
			If ($file#Null:C1517)
				$components.push($file)
				$settings.includePaths.push({source: $component.path; destination: "../Components/"})
				LOG EVENT:C667(Into system standard outputs:K38:9; "***INFO*** "+$file.name+" folder found and added to the server package: "+$file.path+" - "+String:C10($file.exists)+"\n")
			End if 
		End for each 
	End if 
	$settings.compilerOptions.components:=$components
	
	// Launch the build
	$build:=cs:C1710.Build4D.Server.new($settings)
	$success:=$build.build()
	
	$result:=$build.logs
End if 