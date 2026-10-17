//%attributes = {"invisible":true}
#DECLARE($config : Object; $target : Object)->$success : Boolean

var $configFolder; $relativePath : Text
var $sourceStructure : 4D:C1709.File

$sourceStructure:=findStructureFile($target.source)
$success:=$sourceStructure#Null:C1517

If ($success)
	
	$success:=$sourceStructure.exists
	
End if 

If ($success)
	
	$relativePath:=Substring:C12($sourceStructure.path; Length:C16($target.source.path)+1)
	If (Length:C16($relativePath)=0)  // maybe link
		$relativePath:=Substring:C12($sourceStructure.path; Length:C16($target.source.folders()[0].parent.path)+1)  // tricky: use files() or folders() to have resolved path
	End if 
	
	$configFolder:=Choose:C955(String:C10($config.config)=""; "release"; $config.config)
	$target.outputFolder:=$config.make.outputFolder.folder($configFolder+"/"+$target.source.name+".4dbase")
	If (Bool:C1537($config.make.contents))
		$target.outputFolder:=$target.outputFolder.folder("Contents")
		$target.eraseParent:=True:C214
	End if 
	$target.outputStructure:=$target.outputFolder.file($relativePath)
	$target.builtStructure:=$target.outputFolder.file($sourceStructure.name+".4DZ")
	
	If ($config.targets#Null:C1517)
		
		If ($config.targets.indexOf("arm64_macOS_lib")>=0)
			
			$target.builtLibrary:=$target.outputFolder.file("Libraries/lib4d-arm64.dylib")  // Tbd: should be more generic
			
		End if 
	End if 
	
Else 
	
	$config.report($target; "Can't find source structure "; "error")
	
End if 