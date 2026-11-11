//%attributes = {}
var $config : Object
$config:=getTestConfig("User Components/4D SVG")

If (Storage:C1525.logs#Null:C1517)
	Use (Storage:C1525.logs)
		Storage:C1525.logs.clear()
	End use 
End if 

$config.reporter:="storage"

var $show : Boolean
$show:=Shift down:C543

If ($config#Null:C1517)
	
	$config.buildNumber:=8858
	$config.forceBuild:=True:C214
	
	var $success : Boolean
	$success:=build($config; True:C214)
	
	If ($show)
		
		SHOW ON DISK:C922($config.make.outputFolder.platformPath)
		
	End if 
	
Else 
	
	ALERT:C41("No config file")
	
End if 