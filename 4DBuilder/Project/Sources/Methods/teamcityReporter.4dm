//%attributes = {"invisible":true}
#DECLARE($config : Object; $target : Object; $message : Text; $severity : Text; $file : 4D:C1709.File; $line : Text)

var $msg; $text; $details : Text
var $importance : Integer

$text:=Replace string:C233($message; "'"; "`")

$msg:="##teamcity[message text='"+$text+"'"

If (($severity#"info") | Bool:C1537($config.verbose))
	
	$details:=""
	If ($config#Null:C1517)
		$details:=String:C10($config.makeFile.path)
	End if 
	
	If ($target#Null:C1517)
		$details+=String:C10($target.source.name)
	End if 
	
	If (Length:C16($details)>0)
		$details:=Replace string:C233($details; "'"; "`")
		$msg+=" errorDetails='"+$details+"'"
	End if 
	
	Case of 
		: ($severity="error")
			$msg+=" status='ERROR'"
			$importance:=2
			
		: ($severity="warning")
			$msg+=" status='WARNING'"
			$importance:=1
			
		Else 
			$msg+=" status='NORMAL'"
			$importance:=0
			
	End case 
	
	
	$msg+="]"
	
	If (($config#Null:C1517) && ($config.destination#Null:C1517))
		LOG EVENT:C667($config.destination; $msg+"\n"; $importance)
	Else 
		LOG EVENT:C667(Into system standard outputs:K38:9; $msg+"\n"; $importance)
	End if 
	
End if 