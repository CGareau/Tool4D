//%attributes = {"preemptive":"capable"}
// Builds a single-user (standalone) application with 4D Volume Desktop.
// Settings come from buildStandaloneMac.json / buildStandaloneWin.json (next to the project folder),
// completed here with the project, the destination, 4D Volume Desktop, the icon and the version.
#DECLARE($config : Object)->$result : Collection

var $build : cs.Build4D.Standalone
var $settings; $obFile : Object
var $fileContent : Text
var $success : Boolean

If (Is macOS)
	$obFile:=File($config.projectPath; fk posix path).parent.parent.file("buildStandaloneMac.json")
Else 
	$obFile:=File($config.projectPath; fk platform path).parent.parent.file("buildStandaloneWin.json")
End if 
If ($obFile.exists)
	$fileContent:=$obFile.getText()
	If ($fileContent#"")
		$settings:=JSON Parse($fileContent)
	End if 
Else 
	LOG EVENT(Into system standard outputs; "***ERROR*** "+$obFile.fullName+" not found\n"; Error message)
End if 

If ($settings#Null)
	// External project file
	If (Is macOS)
		$settings.projectFile:=File($config.projectPath; fk posix path)
		$settings.destinationFolder:=Folder($config.output; fk posix path).folder("Standalone")
	Else 
		$settings.projectFile:=File($config.projectPath; fk platform path)
		$settings.destinationFolder:=Folder($config.output; fk platform path).folder("Standalone")
	End if 
	LOG EVENT(Into system standard outputs; "***INFO*** ProjectFile: "+$settings.projectFile.path+" - "+String($settings.projectFile.exists)+"\n")
	LOG EVENT(Into system standard outputs; "***INFO*** DestinationFolder: "+$settings.destinationFolder.path+"\n")
	
	// 4D Volume Desktop
	If (Is macOS)
		$settings.sourceAppFolder:=Folder(Application file; fk platform path).parent.folder("4D Volume Desktop.app")
	Else 
		$settings.sourceAppFolder:=Folder(Application file; fk platform path).parent.parent.folder("4D Volume Desktop")
	End if 
	LOG EVENT(Into system standard outputs; "***INFO*** SourceAppFolder: "+$settings.sourceAppFolder.path+" - "+String($settings.sourceAppFolder.exists)+"\n")
	
	// Application icon
	If (Is macOS)
		$settings.iconPath:=File($config.projectPath; fk posix path).parent.parent.folder("Resources").file("myIcon.icns")
	Else 
		$settings.iconPath:=File($config.projectPath; fk platform path).parent.parent.folder("Resources").file("myIcon.ico")
	End if 
	
	// License: none unless the json gives a file path (or "auto"); an explicit null is required
	If (Not(OB Is defined($settings; "license")))
		$settings.license:=Null
	Else 
		If (Value type($settings.license)=Is text)
			If (($settings.license#"auto") && ($settings.license#""))
				$settings.license:=File($settings.license; Is macOS ? fk posix path : fk platform path)
			Else 
				$settings.license:=($settings.license="auto") ? "auto" : Null
			End if 
		End if 
	End if 
	
	// Version
	If ($settings.versioning=Null)
		$settings.versioning:={}
	End if 
	$settings.versioning.version:=$config.buildNumber
	
	$build:=cs.Build4D.Standalone.new($settings)
	$success:=$build.build()
	
	$result:=$build.logs
End if 
