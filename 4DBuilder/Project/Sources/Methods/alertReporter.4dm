//%attributes = {"invisible":true}
#DECLARE($config : Object; $target : Object; $message : Text; $severity : Text; $file : 4D:C1709.File; $line : Text)

var $msg : Text
$msg:=""

var $msgFile : 4D:C1709.File
$msgFile:=(($file=Null:C1517) && ($config#Null:C1517)) ? $config.makeFile : $file

If ($msgFile#Null:C1517)
	$msg+=((Is Windows:C1573) ? $msgFile.platformPath : $msgFile.path)
End if 
If (Length:C16($line)>0)
	$msg+="("+$line+")"
End if 
$msg+=":\n"

If ($target#Null:C1517)
	$msg+=$target.source.name
	$msg+=":\n"
End if 

$msg+=$message

ALERT:C41($msg)  // TODO replace by a form with text area, and append message