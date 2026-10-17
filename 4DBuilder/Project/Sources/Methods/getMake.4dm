//%attributes = {"invisible":true}
#DECLARE($config : Object)->$success : Boolean

var $make; $makeFile; $oneTarget; $store; $target : Object
var $buildOrder : Collection

If (Value type:C1509($config.makeFile)=Is object:K8:27)
	
	$makeFile:=$config.makeFile
	
Else 
	
	If (Value type:C1509($config.makeFile)=Is text:K8:3)
		
		$makeFile:=File:C1566($config.makeFile)
		
	Else 
		
		$config.report(Null:C1517; "makeFile must be Text (pathname) or Object (4D.File)"; "error")
		
	End if 
End if 

$config.report(Null:C1517; "Reading make file "+$makeFile.path; "info")

If (Not:C34(Bool:C1537($makeFile.exists)))
	
	If (Bool:C1537($config.createMakeFile))
		
		$makeFile.setText(JSON Stringify:C1217(New object:C1471))  // Do not fill targets, let following code do it in memory
		
	End if 
End if 

$make:=JSON Parse:C1218($makeFile.getText("utf-8"); Is object:K8:27)
$success:=($make#Null:C1517)

If ($success)
	
	If (Length:C16(String:C10($config.output))>0)
		
		$make.outputFolder:=Folder:C1567($config.output)
		
	Else 
		
		If (Length:C16(String:C10($make.output))=0)
			
			$make.output:=".build"  // Default build directory if not defined
			
		End if 
		
		$make.outputFolder:=$makeFile.parent.folder($make.output)
		
	End if 
	
	// Resolve full paths to .4dbase
	If ($make.targets=Null:C1517)
		
		$make.targets:=New collection:C1472(New object:C1471(\
			"path"; ""))  // Target on current path if no target specified
		
	End if 
	
	For each ($target; $make.targets)
		
		If (Length:C16(String:C10($target.path))=0)
			
			// Support make file inside project
			$target.source:=$makeFile.parent
			
		Else 
			
			$target.source:=$makeFile.parent.folder($target.path)
			
		End if 
		
		If ($target.gitURL=Null:C1517)
			ASSERT:C1129($target.source.exists; $target.source.path)
		End if 
		
	End for each 
	
	// Check for additional make dependencies files
	For each ($target; $make.targets)
		
		subMake($target)
		
	End for each 
	
	// Map by target full path in a store object
	$store:=DependencyStore("make"; $make)
	
	If ($config.importTargets#Null:C1517)
		
		$store.import($config.importTargets)
		
	End if 
	
	// Build order
	$buildOrder:=New collection:C1472
	
	For each ($oneTarget; $make.targets)
		
		addDependency($buildOrder; $store; $oneTarget; $config)
		
	End for each 
	
	// Replace make file targets with ordered collection
	$make.targets:=$buildOrder
	$config.make:=$make
	
End if 