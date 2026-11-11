//%attributes = {}
var $config; $configSVG : Object
var $success : Boolean
$configSVG:=getTestConfig("User Components/4D SVG")

If ($configSVG#Null:C1517)
	
	$success:=build($configSVG; True:C214)
	
	If (Shift down:C543)
		
		SHOW ON DISK:C922($configSVG.make.outputFolder.platformPath)
		
	End if 
	
Else 
	
	ALERT:C41("No config file")
	
End if 

$config:=getTestConfig("User Components/4D ViewPro")
$config.importTargets:=$configSVG.make.targets

If ($config#Null:C1517)
	
	$success:=build($config; True:C214)
	
	If (Shift down:C543)
		
		SHOW ON DISK:C922($config.make.outputFolder.platformPath)
		
	End if 
	
Else 
	
	ALERT:C41("No config file")
	
End if 