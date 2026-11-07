//%attributes = {"invisible":true}
#DECLARE($config : Object; $target : Object)->$buildNeeded : Boolean

var $date; $date2 : Date
var $time; $time2 : Time
var $c1; $c2; $files : Collection

$buildNeeded:=True:C214

var $missingBuiltLibrary; $missingBuiltStructure : Boolean

$missingBuiltStructure:=Not:C34($target.builtStructure.exists)

If ($target.builtLibrary#Null:C1517)
	
	$missingBuiltLibrary:=Not:C34($target.builtLibrary.exists)
	
Else 
	
	// Force to false
	$missingBuiltLibrary:=False:C215
	
End if 

// Check if any file in sources has been modified after output file
If ($missingBuiltStructure | $missingBuiltLibrary)
	
	$buildNeeded:=True:C214
	
Else 
	
	$date:=$target.builtStructure.modificationDate
	$time:=$target.builtStructure.modificationTime
	
	// Also check built library if any
	If ($target.builtLibrary#Null:C1517)
		
		$date2:=$target.builtLibrary.modificationDate
		$time2:=$target.builtLibrary.modificationTime
		
		If (($date>$date2)\
			 | (($date=$date2)\
			 & ($time>$time2)))
			
			$date:=$date2
			$time:=$time2
			
		End if 
	End if 
	
	// $files:=$target.source.files(fk recursive)
	// Ignore the invisible files and the ".git" folder
	// Ignore Info.plist et InfoPlist.strings files
	$files:=$target.source.files(fk recursive:K87:7).query("fullName != .@ AND fullName != 'Info.plist' AND fullName != 'InfoPlist.strings'")
	$files:=$files.query("parent.fullName != .git AND parent.parent.fullName != .git AND parent.parent.parent.fullName != .git")  // XXX maybe find a better way to exclude .git folder
	
	// Add make file as dependency to rebuild if it has changed
	If ($config.makeFile#Null:C1517)
		
		$files.push($config.makeFile)
		
	End if 
	
	// Get modified source files
	$c1:=$files.query("modificationDate>:1 OR (modificationDate=:1 AND modificationTime>:2)"; $date; $time)
	
	// Get modified dependencies
	$c2:=$target.components.query("builtStructure.modificationDate>:1 OR (builtStructure.modificationDate=:1 AND builtStructure.modificationTime>:2)"; $date; $time)
	
	$buildNeeded:=($c1.length#0) | ($c2.length#0)
	
	If ($buildNeeded && Bool:C1537($config.buildNeededVerbose))
		
		var $message : Text
		$message:="Builded needed because of:"
		
		If ($c1.length#0)
			$message+="\n- source files: "+Replace string:C233($c1.extract("path").join(","); $target.source.path; "")
		End if 
		If ($c2.length#0)
			$message+="\n- dependencies: "+$c2.extract("path").join(",")
		End if 
		
		$date:=$target.builtStructure.modificationDate
		$time:=$target.builtStructure.modificationTime
		$message+="\nby comparing with date "+String:C10($date; ISO date:K1:8; $time)
		If ($target.builtLibrary#Null:C1517)
			$date:=$target.builtLibrary.modificationDate
			$time:=$target.builtLibrary.modificationTime
			$message+=" or "+String:C10($date; ISO date:K1:8; $time)
		End if 
		
		$config.report($target; $message; "info")
		
	End if 
	
End if 