//%attributes = {"invisible":true}
#DECLARE($startupParam : Text)->$config : Object

Case of 
		
		//______________________________________________________
	: (Match regex:C1019("^\\{.*\\}$"; $startupParam; 1))
		
		$config:=JSON Parse:C1218($startupParam)
		
		If (Value type:C1509($config.makeFile)=Is text:K8:3)
			
			$config.makeFile:=File:C1566($config.makeFile; Choose:C955(Is Windows:C1573; fk platform path:K87:2; fk posix path:K87:1))
			
		End if 
		
		//______________________________________________________
	Else 
		
		$config:=New object:C1471
		$config.makeFile:=File:C1566($startupParam; Choose:C955(Is Windows:C1573; fk platform path:K87:2; fk posix path:K87:1))
		
		//______________________________________________________
End case 

If ($config#Null:C1517)
	
	// Prepare reporter
	If (($config.reporter=Null:C1517)\
		 | (Length:C16(String:C10($config.reporter))=0))
		
		$config.reporter:="default"
		
	End if 
	
	$config.report:=Formula:C1597(EXECUTE METHOD:C1007($config.reporter+"Reporter"; *; $config; $1; $2; $3; $4; $5))
	
	If ($config.destination=Null:C1517)
		
		$config.destination:=Into system standard outputs:K38:9
		
	End if 
End if 