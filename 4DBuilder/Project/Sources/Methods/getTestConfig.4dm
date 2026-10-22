//%attributes = {"invisible":true,"preemptive":"capable"}
#DECLARE($posixPath : Text)->$config : Object

var $path; $userParam : Object

$userParam:=New object:C1471
$userParam.verbose:=True:C214
$userParam.config:="release"
$userParam.targets:=New collection:C1472("x86_64_generic"; "arm64_macOS_lib")

// Make file path
$path:=Folder:C1567(Folder:C1567(fk database folder:K87:14).platformPath; fk platform path:K87:2)  // Unsandbox
$path:=$path.parent.parent.parent  // Branch path
$path:=$path.folder("4DComponents")  // 4d component path

If (Length:C16(String:C10($posixPath))>0)
	
	Case of 
			
			//______________________________________________________
		: ($path.folder($posixPath).exists)  // Default is ~/make.json
			
			$path:=$path.folder($posixPath).file("make.json")
			
			//______________________________________________________
		: ($path.file($posixPath).exists)  // Allow to pass a file
			
			$path:=$path.file($posixPath)
			
			//______________________________________________________
		: (File:C1566($posixPath).exists)  // Allow to pass an absolute path
			
			$path:=File:C1566($posixPath)
			
			//______________________________________________________
	End case 
	
	If (Not:C34($path.exists))
		
		$userParam.createMakeFile:=True:C214
		
	End if 
	
Else 
	
	$path:=$path.file("make.json")  // Compile components
	
End if 

$userParam.makeFile:=Choose:C955(Is Windows:C1573; $path.platformPath; $path.path)


// Reporter
// $userParam.reporter:="alert"
// $userParam.reporter:="teamcity"
// $userParam.reporter:="file"
// $userParam.destination:=$path.parent.file("4DBuilder.log").path

// Parse parameters
$config:=parseUserParam(JSON Stringify:C1217($userParam))