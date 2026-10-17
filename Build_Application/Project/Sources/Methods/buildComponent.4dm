//%attributes = {"preemptive":"capable"}
#DECLARE($config : Object)->$result : Collection

var $build : cs:C1710.Build4D.Component
var $settings; $component; $componentsFolder : Object
var $components : Collection
var $configFolder : Text
var $success : Boolean

$settings:=New object:C1471()

// Define the external project file
If (Is macOS:C1572)
	$settings.projectFile:=File:C1566($config.projectPath; fk posix path:K87:1)
	LOG EVENT:C667(Into system standard outputs:K38:9; "***INFO*** ProjectFile: "+File:C1566($config.projectPath; fk posix path:K87:1).path+" - "+String:C10(File:C1566($config.projectPath; fk posix path:K87:1).exists)+"\n")
Else 
	$settings.projectFile:=File:C1566($config.projectPath; fk platform path:K87:2)
	LOG EVENT:C667(Into system standard outputs:K38:9; "***INFO*** ProjectFile: "+File:C1566($config.projectPath; fk platform path:K87:2).path+" - "+String:C10(File:C1566($config.projectPath; fk platform path:K87:2).exists)+"\n")
End if 

// Define the destination folder: <output>/<config (default "release")>
$configFolder:=(($config.config#Null:C1517) && ($config.config#"")) ? $config.config : "release"
If (Is macOS:C1572)
	$settings.destinationFolder:=Folder:C1567($config.output; fk posix path:K87:1).folder($configFolder)
	LOG EVENT:C667(Into system standard outputs:K38:9; "***INFO*** DestinationFolder: "+Folder:C1567($config.output; fk posix path:K87:1).folder($configFolder).path+" - "+String:C10(Folder:C1567($config.output; fk posix path:K87:1).exists)+"\n")
Else 
	$settings.destinationFolder:=Folder:C1567($config.output; fk platform path:K87:2).folder($configFolder)
	LOG EVENT:C667(Into system standard outputs:K38:9; "***INFO*** DestinationFolder: "+Folder:C1567($config.output; fk platform path:K87:2).folder($configFolder).path+" - "+String:C10(Folder:C1567($config.output; fk platform path:K87:2).exists)+"\n")
End if 

// Component name (the final structure is <destinationFolder>/<buildName>.4dbase/Contents/<buildName>.4DZ)
If (($config.buildName#Null:C1517) && ($config.buildName#""))
	$settings.buildName:=$config.buildName
	LOG EVENT:C667(Into system standard outputs:K38:9; "***INFO*** BuildName: "+$config.buildName+"\n")
Else 
	LOG EVENT:C667(Into system standard outputs:K38:9; "***WARNING*** buildName not provided, using project name\n")
End if 

// Pack the compiled project as a single .4DZ file
$settings.packedProject:=True:C214

// Obfuscation (optional, defaults to false)
If ($config.obfuscated=True:C214)
	$settings.obfuscated:=True:C214
End if 

// Versioning
If (($config.buildNumber#Null:C1517) && ($config.buildNumber#""))
	$settings.versioning:=New object:C1471("version"; String:C10($config.buildNumber))
	LOG EVENT:C667(Into system standard outputs:K38:9; "***INFO*** Version: "+String:C10($config.buildNumber)+"\n")
End if 

// Load components sitting next to the project (Components folder) as compiler dependencies
$componentsFolder:=$settings.projectFile.parent.parent.folder("Components")
LOG EVENT:C667(Into system standard outputs:K38:9; "***INFO*** ComponentsFolder: "+$componentsFolder.path+" - "+String:C10($componentsFolder.exists)+"\n")

$components:=[]
If ($componentsFolder.exists)
	For each ($component; $componentsFolder.folders())
		If ($component.folder("Contents").exists)
			$component:=$component.folder("Contents")
		End if 
		$components.push($component.files().query("extension = .4DZ AND fullName != ._@").first())
		LOG EVENT:C667(Into system standard outputs:K38:9; "***INFO*** "+$component.name+" found and added as compiler dependency: "+$component.path+"\n")
	End for each 
End if 
$settings.compilerOptions:=New object:C1471("components"; $components)

// Launch the build
$build:=cs:C1710.Build4D.Component.new($settings)
$success:=$build.build()

$result:=$build.logs
