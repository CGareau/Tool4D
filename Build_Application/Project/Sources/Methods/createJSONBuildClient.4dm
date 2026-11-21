//%attributes = {}
var $settings; $obFile : Object
var $created : Boolean

$settings:={}

// Avoid to run 4D Remote with administrator privileges
If (Is Windows:C1573)
	$settings.startElevated:=True:C214
End if 

// Configure the application
$settings.buildName:="myApp"

// Compiler options
If (Is Windows:C1573)
	$settings.compilerOptions:={targets: ["x86_64_generic"]}
Else 
	$settings.compilerOptions:={targets: ["arm64_macOS_lib"; "x86_64_generic"]}
End if 

// Add the application information
$settings.versioning:={}
$settings.versioning.copyright:="copyright"
$settings.versioning.companyName:="4D SAS"

// Sign if macOS appplication
$settings.signApplication:={}
$settings.signApplication.macSignature:=True:C214
$settings.signApplication.macCertificate:="Developer ID Application: YOUR NAME (TEAMID)"

If (Is macOS:C1572)
	$obFile:=Folder:C1567(fk database folder:K87:14).file("buildClientMac.json")
Else 
	$obFile:=Folder:C1567(fk database folder:K87:14).file("buildClientWin.json")
End if 
If (Not:C34($obFile.exists))
	$created:=$obFile.create()
End if 
$obFile.setText(JSON Stringify:C1217($settings; *))