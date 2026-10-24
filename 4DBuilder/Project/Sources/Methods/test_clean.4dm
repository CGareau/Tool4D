//%attributes = {}
var $config : Object

$config:=getTestConfig

If ($config#Null:C1517)
	
	clean($config; True:C214)
	
	If (Shift down:C543)
		
		SHOW ON DISK:C922($config.makeFile.parent.platformPath)
		
	End if 
	
Else 
	
	ALERT:C41("No config file")
	
End if 