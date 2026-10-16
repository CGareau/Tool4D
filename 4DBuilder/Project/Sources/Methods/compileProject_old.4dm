//%attributes = {"invisible":true}
/*

This method uses the old _4D Compile() command.

Don't use it if the new Compile project() is available

*/
#DECLARE($config : Object; $target : Object) : Boolean

var $success : Boolean
var $i; $row : Integer
var $tMessage : Text
var $o; $oSettings : Object

ARRAY OBJECT:C1221($errors; 0)


// Create settings with list of components
$oSettings:=New object:C1471
$oSettings.components:=New collection:C1472

/// Add components previously built
For each ($o; $target.components)
	
	$oSettings.components.push($o.builtStructure.platformPath)
	
End for each 

// Add components from "Components" folder if exists
If ($target.source.folder("Components").exists)
	
	For each ($o; $target.source.folder("Components").folders())
		
		If ($o.file($o.name+".4DZ").exists)
			
			$oSettings.components.push($o.file($o.name+".4DZ").platformPath)
			
		End if 
	End for each 
End if 

// Launch compilation
// When compiling on mac and for release, let's compile for both intel and arm
$tMessage:="Compiling "
If ($config.targets#Null:C1517)
	$oSettings.targets:=$config.targets
	$tMessage:=$tMessage+JSON Stringify:C1217($config.targets)+" "
End if 

$config.report($target; $tMessage+$target.outputStructure.path; "info")
$success:=_4D Compile:C1404($target.outputStructure.platformPath; $oSettings; $errors)

// Check results and report
If (Not:C34($success)\
 & (Size of array:C274($errors)=0))
	
	$config.report($target; "Compilation failed for unknown reason (missing licence?)"; "error")
	
Else 
	
	$target.outputFolder.parent.file("errors").setText(JSON Stringify array:C1228($errors))
	
End if 

var $warningCount; $errorCount : Integer
$warningCount:=0
$errorCount:=0

For ($i; 1; Size of array:C274($errors); 1)
	
	$o:=$errors{$i}
	
	If ($o.name#Null:C1517)
		
		// Use line number in text if available
		// +1 because of the first line %attributes
		
		Case of 
				
				//________________________________________
			: ($o.lineInText#Null:C1517)
				
				$row:=$o.lineInText+1
				
				//________________________________________
			: ($o.line#Null:C1517)
				
				$row:=$o.line+1
				
				//________________________________________
		End case 
		
		// Get full path to source file (posix on windows, dos on windows)
		If (Is macOS:C1572)
			
			// Format according to Xcode
			$tMessage:=Replace string:C233(String:C10($o.path); $target.outputFolder.path; $target.source.path)
			
			If ($row>0)
				
				$tMessage:=$tMessage+":"+String:C10($row)
				
			End if 
			
			$tMessage:=$tMessage+":"
			
		Else 
			
			// Format according to VStudio (google for IgnoreStandardErrorWarningFormat to get doc on format)
			$tMessage:=Replace string:C233(String:C10($o.path); $target.outputFolder.platformPath; $target.source.platformPath)
			
			If ($row>0)
				
				$tMessage:=$tMessage+"("+String:C10($row)+")"
				
			End if 
			
			$tMessage:=$tMessage+":"
			
		End if 
	End if 
	
	$tMessage:=$tMessage+Choose:C955($o.isError; " error: "; " warning: ")+$o.message
	LOG EVENT:C667(6; $tMessage+"\n")  // stdout // TODO use reporter to log... but we need to override file path and line to not use make.json etc...
	// $config.report($target; $tMessage; Choose($o.isError; "error"; "warning"))
	
	If ($o.isError)
		$errorCount:=$errorCount+1
	Else 
		$warningCount:=$warningCount+1
	End if 
	
End for 

If ($success)  // Verify the result on disk
	
	$o:=$target.outputFolder.folder("Project/DerivedData/CompiledCode/")
	$success:=$o.exists
	
	If ($success)
		
		$success:=($o.files().length>0)
		
		If (Not:C34($success))
			
			$config.report($target; "Compilation failed: "+$target.outputStructure.path+" error: 'CompiledCode' folder is empty"; "error")
			
		End if 
		
	Else 
		
		$config.report($target; "Compilation failed: "+$target.outputStructure.path+" error: Missing 'CompiledCode' folder"; "error")
		
	End if 
Else 
	
	$config.report($target; "Compilation failed with errors count "+String:C10($errorCount)+" and warning count "+String:C10($warningCount); "warning")
	
End if 

return $success