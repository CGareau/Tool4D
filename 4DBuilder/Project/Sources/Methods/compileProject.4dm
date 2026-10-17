//%attributes = {}
#DECLARE($config : Object; $target : Object)->$success : Boolean

var $i; $row : Integer
var $tMessage : Text
var $oneError; $settings; $compiledCodeFolder; $status : Object
var $warningCount; $errorCount : Integer
var $errors : Collection
var $componentFolder : 4D:C1709.Folder
var $componentFile : 4D:C1709.File
var $componentName : Text

// Create settings with list of components
$settings:=New object:C1471
$settings.components:=New collection:C1472

// Add components previously build
var $componentInfo : Object
For each ($componentInfo; $target.components)
	
	$settings.components.push($componentInfo.builtStructure)
	
End for each 

// Add components from "Components" folder if exists
If ($target.source.folder("Components").exists)
	
	For each ($componentFolder; $target.source.folder("Components").folders())
		
		$componentName:=$componentFolder.name
		
		If ($componentFolder.folder("Contents").exists)
			$componentFolder:=$componentFolder.folder("Contents")
		End if 
		
		$componentFile:=$componentFolder.file($componentName+".4DZ")
		If ($componentFile.exists)
			$settings.components.push($componentFile)
		End if 
		
	End for each 
End if 

// Add 4D Application components dependencies
// Warning: no components if tool is used
If ($target.dependencies#Null:C1517)
	
	var $appFolder : 4D:C1709.Folder
	$appFolder:=Folder:C1567(Application file:C491; fk platform path:K87:2)  // FIXME: could be a file...
	$appFolder:=Choose:C955(Is macOS:C1572; $appFolder.folder("Contents"); $appFolder.parent)
	
	var $path : Text
	For each ($path; $target.dependencies)
		
		$componentFolder:=$appFolder.folder("Components").folder($path+".4dbase")
		$componentName:=$componentFolder.name
		
		If ($componentFolder.folder("Contents").exists)
			$componentFolder:=$componentFolder.folder("Contents")
		End if 
		
		$componentFile:=$componentFolder.file($componentName+".4DZ")
		If ($componentFile.exists)
			$settings.components.push($componentFile)
		End if 
		
	End for each 
End if 

// Launch compilation
// When compiling on mac and for release, let's compile for both intel and arm
$tMessage:="Compiling "

If ($config.targets#Null:C1517)
	
	$settings.targets:=$config.targets
	$tMessage+=$config.targets.join(", ")+" "
	
End if 

$config.report($target; $tMessage+$target.outputStructure.path; "info")
$status:=Compile project:C1760($target.outputStructure; $settings)
$success:=$status.success
$errors:=$status.errors

// Check results and report
If (Not:C34($status.success) && ($errors.length=0))
	
	$config.report($target; "Compilation failed for unknown reason (missing licence?)"; "error")
	
End if 

$warningCount:=0
$errorCount:=0

var $severity : Text
var $file : 4D:C1709.File
For each ($oneError; $errors)
	
	If ($oneError.isError)
		$errorCount+=1
	Else 
		$warningCount+=1
	End if 
	
	$severity:=$oneError.isError ? "error" : "warning"
	
	If (($oneError.code#Null:C1517) && ($oneError.code.file#Null:C1517))
		
		$file:=$oneError.code.file
		
		If (Is macOS:C1572)
			$file:=File:C1566(Replace string:C233(Convert path system to POSIX:C1106($file.platformPath); $target.outputFolder.path; $target.source.path))
		Else 
			$file:=File:C1566(Replace string:C233($file.platformPath; $target.outputFolder.platformPath; $target.source.platformPath); fk platform path:K87:2)
		End if 
		
		$config.report($target; $oneError.message; $severity; $file; String:C10(Num:C11($oneError.lineInFile))/*0 if no line*/)
		
	Else 
		
		$config.report($target; $oneError.message; $severity)
		
	End if 
	
End for each 

If ($errorCount>0)
	$target.outputFolder.file("errors").setText(JSON Stringify:C1217($errors.filter(Formula:C1597(Bool:C1537($1.value.isError)))))
End if 
If (($warningCount>0) && (String:C10($config.config)="debug"))
	$target.outputFolder.file("warnings").setText(JSON Stringify:C1217($errors.filter(Formula:C1597(Not:C34(Bool:C1537($1.value.isError))))))
End if 

If ($success)
	
	// Verify the result on disk, only if not a check syntax
	var $verifyResultOnDisk : Boolean:=($settings.targets=Null:C1517) || ($settings.targets.length>0)
	
	If ($verifyResultOnDisk)
		
		$compiledCodeFolder:=$target.outputFolder.folder("Project/DerivedData/CompiledCode/")
		$success:=$compiledCodeFolder.exists
		
		If ($success)
			
			$success:=($compiledCodeFolder.files().length>0)
			
			If (Not:C34($success))
				$config.report($target; "Compilation failed: "+$target.outputStructure.path+" error: 'CompiledCode' folder is empty"; "error")
			End if 
			
		Else 
			
			$config.report($target; "Compilation failed: "+$target.outputStructure.path+" error: Missing 'CompiledCode' folder"; "error")
			
		End if 
		
	End if 
	
Else 
	
	$config.report($target; "Compilation failed with errors count "+String:C10($errorCount)+" and warning count "+String:C10($warningCount); "error")
	
End if 

return $success
