//%attributes = {"invisible":true}
#DECLARE($config : Object; $target : Object; $message : Text; $severity : Text; $file : 4D:C1709.File; $line : Text)

var $msg : Text
var $importance : Integer

If (($severity#"info") | Bool:C1537($config.verbose))
	
	var $msgFile : 4D:C1709.File
	$msgFile:=(($file=Null:C1517) && ($config#Null:C1517)) ? $config.makeFile : $file
	
	$msg:=""
	If ($msgFile#Null:C1517)
		
		$msg+=$msgFile.platformPath
		If (Length:C16($line)>0)
			$msg+="("+$line+")"
		End if 
		$msg+=":"
		// Else ?
	End if 
	
	$importance:=Information message:K38:1
	Case of 
		: ($severity="error")
			$msg+=" error: "
			$importance:=Error message:K38:3
			
		: ($severity="warning")
			$msg+=" warning: "
			$importance:=Warning message:K38:2
			
		: ($severity="info")
			$msg:=$msg+Choose:C955(Is Windows:C1573; " "; " note: ")
			
	End case 
	
	If ($target#Null:C1517)
		$msg+=$target.source.name+": "
	End if 
	
	$msg+=$message
	
	If (($config#Null:C1517) && ($config.destination#Null:C1517))
		LOG EVENT:C667($config.destination; $msg+"\n"; $importance)
	Else 
		LOG EVENT:C667(Into system standard outputs:K38:9; $msg+"\n"; $importance)
	End if 
End if 
