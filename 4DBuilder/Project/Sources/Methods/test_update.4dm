//%attributes = {}
var $config : Object
$config:=getTestConfig

If ($config#Null:C1517)
	update($config; False:C215)
Else 
	ALERT:C41("No config file")
End if 
