//%attributes = {}
// WIP
var $4dPath; $cmd; $err; $in; $out; $projectPath : Text
var $shift : Boolean
var $branchPath; $databasePath; $makePath; $outputFolder; $temporary; $temporaryProject : Object
var $userParam : Object

$shift:=Shift down:C543

$userParam:=New object:C1471
$userParam.verbose:=True:C214

//$userParam.actions:=New collection("clean"; "build"; "install")
$userParam.actions:=New collection:C1472("clean"; "build")
$userParam.install:=Folder:C1567(Application file:C491; fk platform path:K87:2).path

$databasePath:=Folder:C1567(Folder:C1567(fk database folder:K87:14).platformPath; fk platform path:K87:2)  // Unsandbox
$branchPath:=$databasePath.parent.parent.parent
$makePath:=$branchPath.folder("4DComponents").file("make.json")  // Compile component
$userParam.makeFile:=$makePath.path

$4dPath:=$branchPath.path+"buildChain/mac/bin/tool4d.app/Contents/MacOS/4D"

// Copy project
$temporary:=Folder:C1567(Temporary folder:C486; fk platform path:K87:2).folder("4dbuilder"+Generate UUID:C1066)
$temporary.create()
$temporaryProject:=$databasePath.copyTo($temporary)

$projectPath:=$temporaryProject.path+"Project/builder.4DProject"

// Output definition
$outputFolder:=$temporary.folder("OutputComponents")
$userParam.output:=$outputFolder.path

$userParam.buildNumber:="8858"

// Launch command
$cmd:="'"+$4dPath+"' --headless --dataless -s '"+$projectPath+"' --user-param '"+JSON Stringify:C1217($userParam)+"'"

LAUNCH EXTERNAL PROCESS:C811($cmd; $in; $out; $err)

If (Length:C16($out)>0)
	
	$temporary.file("4dbuild.log").setText($out)
	
End if 

// Clean
If (Not:C34($shift))
	
	$temporary.delete(Delete with contents:K24:24)
	
Else 
	
	SHOW ON DISK:C922($temporary.file("4dbuild.log").platformPath)
	
End if 