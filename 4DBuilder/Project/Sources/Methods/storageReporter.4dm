//%attributes = {}
#DECLARE($config : Object; $target : Object; $message : Text; $severity : Text; $file : 4D:C1709.File; $line : Text)

If (($severity#"info") | Bool:C1537($config.verbose))
	
	var $logRecord : Object
	$logRecord:=New shared object:C1526()
	
	Use ($logRecord)
		
		If ($target#Null:C1517)
			$logRecord.target:=$target.source.name
		End if 
		
		$logRecord.message:=$message
		$logRecord.severity:=$severity
		If ($file#Null:C1517)
			$logRecord.file:=$file.path
		End if 
		If (Length:C16($line)>0)
			$logRecord.line:=$line
		End if 
		
	End use 
	
	Use (Storage:C1525)
		If (Storage:C1525.logs=Null:C1517)
			Storage:C1525.logs:=New shared collection:C1527()
		End if 
	End use 
	
	Use (Storage:C1525.logs)
		Storage:C1525.logs.push($logRecord)
	End use 
	
	
End if 