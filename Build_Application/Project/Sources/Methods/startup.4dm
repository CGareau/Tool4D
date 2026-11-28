//%attributes = {}
var $action; $startupParam; $severity : Text
var $numBuild; $4dversion : Integer
var $config; $log; $msg : Object
var $logs : Collection
var $dummy : Real

$4dversion:=getVersionNumberFromText(Application version:C493($numBuild))
If ($4dversion>5232)  // 20 R7
	//WARN - Cooperative process doesn't yield enough, by default 500 ms
	SET DATABASE PARAMETER:C642(132; 30000)
End if 

$dummy:=Get database parameter:C643(User param value:K37:94; $startupParam)

If ((Length:C16($startupParam)>0) && (Match regex:C1019("^\\{.*\\}$"; $startupParam; 1)))
	$config:=JSON Parse:C1218($startupParam)
	Case of 
		: ($config.methodToExecute="download4DComponents")
			LOG EVENT:C667(Into system standard outputs:K38:9; "\nSTART DOWNLOAD 4D COMPONENTS\n")
			download4DComponents
			LOG EVENT:C667(Into system standard outputs:K38:9; "END DOWNLOAD 4D COMPONENTS\n\n")
			
		: ($config.methodToExecute="downloadPackageManager")
			LOG EVENT:C667(Into system standard outputs:K38:9; "\nSTART DOWNLOAD PACKAGE MANAGER\n")
			downloadPackageManager
			LOG EVENT:C667(Into system standard outputs:K38:9; "END DOWNLOAD PACKAGE MANAGER\n\n")
			
		: ($config.methodToExecute="cleaningHiddenFiles")
			If (($config.methodParam#Null:C1517) && ($config.methodParam#""))
				LOG EVENT:C667(Into system standard outputs:K38:9; "\nSTART CLEANING HIDDEN FILES\n")
				cleaningHiddenFiles($config.methodParam)
				LOG EVENT:C667(Into system standard outputs:K38:9; "END CLEANING HIDDEN FILES\n\n")
			Else 
				LOG EVENT:C667(Into system standard outputs:K38:9; "\nCLEANING HIDDEN FILES FAILED, NO PATH TO CLEAN\n"; Error message:K38:3)
			End if 
			
		: ($config.methodToExecute="buildComponent")
			LOG EVENT:C667(Into system standard outputs:K38:9; "\nSTART BUILD COMPONENT\n")
			$logs:=buildComponent($config)
			If (($logs#Null:C1517) && ($config.verbose))
				For each ($log; $logs)
					Case of 
						: ($log.severity=0) || ($log.messageSeverity=0)
							$severity:="***INFO*** "
						: ($log.severity=1) || ($log.messageSeverity=1)
							$severity:="***WARNING*** "
						: ($log.severity=2) || ($log.messageSeverity=2)
							$severity:="***ERROR*** "
							If ($log.message="Compilation failed.")
								For each ($msg; $log.result.errors)
									LOG EVENT:C667(Into system standard outputs:K38:9; $severity+$msg.message+"\n")
								End for each 
							End if 
						Else 
							$severity:="***UNKNOWN*** "
					End case 
					LOG EVENT:C667(Into system standard outputs:K38:9; $severity+(($log.function) || ($log.errorMethod))+": "+(($log.message) || ($log.errorFormula))+"\n")
				End for each 
			End if 
			LOG EVENT:C667(Into system standard outputs:K38:9; "END BUILD COMPONENT\n\n")
			
		Else 
			LOG EVENT:C667(Into system standard outputs:K38:9; "\nSTART DOWNLOAD 4D APPLICATION\n")
			download4DApplication($config)
			LOG EVENT:C667(Into system standard outputs:K38:9; "END DOWNLOAD 4D APPLICATION\n\n")
			
			If ($config.buildClient)
				LOG EVENT:C667(Into system standard outputs:K38:9; "START BUILD CLIENT\n")
				$logs:=buildClient($config)
				If (($logs#Null:C1517) && ($config.verbose))
					For each ($log; $logs)
						Case of 
							: ($log.severity=0) || ($log.messageSeverity=0)
								$severity:="***INFO*** "
							: ($log.severity=1) || ($log.messageSeverity=1)
								$severity:="***WARNING*** "
							: ($log.severity=2) || ($log.messageSeverity=2)
								$severity:="***ERROR*** "
								If ($log.message="Compilation failed.")
									For each ($msg; $log.result.errors)
										LOG EVENT:C667(Into system standard outputs:K38:9; $severity+$msg.message+"\n")
									End for each 
								End if 
							Else 
								$severity:="***UNKNOWN*** "
						End case 
						LOG EVENT:C667(Into system standard outputs:K38:9; $severity+(($log.function) || ($log.errorMethod))+": "+(($log.message) || ($log.errorFormula))+"\n")
					End for each 
				End if 
				LOG EVENT:C667(Into system standard outputs:K38:9; "END BUILD CLIENT\n\n")
			End if 
			
			If ($config.buildServer)
				LOG EVENT:C667(Into system standard outputs:K38:9; "START BUILD SERVER\n")
				$logs:=buildServer($config)
				If (($logs#Null:C1517) && ($config.verbose))
					For each ($log; $logs)
						Case of 
							: ($log.severity=0) || ($log.messageSeverity=0)
								$severity:="***INFO*** "
							: ($log.severity=1) || ($log.messageSeverity=1)
								$severity:="***WARNING*** "
							: ($log.severity=2) || ($log.messageSeverity=2)
								$severity:="***ERROR*** "
								If ($log.message="Compilation failed.")
									For each ($msg; $log.result.errors)
										LOG EVENT:C667(Into system standard outputs:K38:9; $severity+$msg.message+"\n")
									End for each 
								End if 
							Else 
								$severity:="***UNKNOWN*** "
						End case 
						LOG EVENT:C667(Into system standard outputs:K38:9; $severity+(($log.function) || ($log.errorMethod))+": "+(($log.message) || ($log.errorFormula))+"\n")
						
					End for each 
				End if 
				LOG EVENT:C667(Into system standard outputs:K38:9; "END BUILD SERVER\n\n")
			End if 
			
			If ($config.buildStandalone)
				LOG EVENT:C667(Into system standard outputs:K38:9; "START BUILD STANDALONE\n")
				$logs:=buildStandalone($config)
				If (($logs#Null:C1517) && ($config.verbose))
					For each ($log; $logs)
						Case of 
							: ($log.severity=0) || ($log.messageSeverity=0)
								$severity:="***INFO*** "
							: ($log.severity=1) || ($log.messageSeverity=1)
								$severity:="***WARNING*** "
							: ($log.severity=2) || ($log.messageSeverity=2)
								$severity:="***ERROR*** "
								If ($log.message="Compilation failed.")
									For each ($msg; $log.result.errors)
										LOG EVENT:C667(Into system standard outputs:K38:9; $severity+$msg.message+"\n")
									End for each 
								End if 
							Else 
								$severity:="***UNKNOWN*** "
						End case 
						LOG EVENT:C667(Into system standard outputs:K38:9; $severity+(($log.function) || ($log.errorMethod))+": "+(($log.message) || ($log.errorFormula))+"\n")
						
					End for each 
				End if 
				LOG EVENT:C667(Into system standard outputs:K38:9; "END BUILD STANDALONE\n\n")
			End if 
	End case 
	QUIT 4D:C291
End if 