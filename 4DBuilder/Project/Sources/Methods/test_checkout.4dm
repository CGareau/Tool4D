//%attributes = {}
var $config : Object
$config:=getTestConfig

If ($config#Null:C1517)
	checkout($config; False:C215)
	
	If (Shift down:C543)
		
		SHOW ON DISK:C922($config.makeFile.parent.folder("build").platformPath)
		
	End if 
Else 
	ALERT:C41("No config file")
End if 
