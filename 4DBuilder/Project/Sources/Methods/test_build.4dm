//%attributes = {}
var $config : Object
$config:=getTestConfig

If (Storage:C1525.logs#Null:C1517)
	Use (Storage:C1525.logs)
		Storage:C1525.logs.clear()
	End use 
End if 
$config.reporter:="storage"

var $show; $beep; $trace : Boolean
$show:=Shift down:C543
$beep:=Macintosh control down:C544 || Windows Ctrl down:C562
$trace:=Macintosh option down:C545 || Windows Alt down:C563

If ($config#Null:C1517)
	
	var $success : Boolean
	$success:=build($config; True:C214)
	
	If ($show)
		
		SHOW ON DISK:C922($config.make.outputFolder.platformPath)
		
	End if 
	
	If ($beep)
		BEEP:C151
	End if 
	
	If ($trace)
		TRACE:C157
	End if 
	
Else 
	
	ALERT:C41("No config file")
	
End if 