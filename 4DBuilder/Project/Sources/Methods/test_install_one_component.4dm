//%attributes = {}
var $config : Object

$config:=getTestConfig("Internal User Components/4D Mobile App")

If ($config#Null:C1517)
	
	install($config; True:C214)
	
	If (Shift down:C543)
		
		SHOW ON DISK:C922($config.installFolder.platformPath)
		
	End if 
	
Else 
	
	ALERT:C41("No config file")
	
End if 