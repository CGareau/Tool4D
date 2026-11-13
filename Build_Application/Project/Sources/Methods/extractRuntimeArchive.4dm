//%attributes = {}
// Extracts a Tool4D Release runtime next to $file.
// Prefers tar.xz (current Fetch 4D binaries assets); falls back to ZIP (older Releases).
#DECLARE($file : 4D.File)->$ok : Boolean

var $archive; $folder : Object
var $cmd : Text
var $systemworker : 4D.SystemWorker
var $failed : Boolean

$ok:=False
If ($file=Null)
	return $ok
End if 
If (Not($file.exists))
	return $ok
End if 

// Legacy Releases shipped .zip assets (pre FTP tar.xz).
$archive:=ZIP Read archive($file)
If (($archive#Null) && ($archive.root#Null))
	$folder:=$archive.root.copyTo($file.parent; fk overwrite)
	If (Is macOS)
		$file.delete()
	End if 
	$ok:=True
	return $ok
End if 

// Current Releases: factory tar.xz (possibly saved under a .zip local name).
If (Is Windows)
	$cmd:="tar -xJf \""+$file.path+"\" -C \""+$file.parent.path+"\""
Else 
	$cmd:="tar -xJf \""+$file.path+"\" -C \""+$file.parent.path+"\""
End if 
$systemworker:=4D.SystemWorker.new($cmd)
$systemworker.wait(1800)
$failed:=False
If (Undefined($systemworker.exitCode))
	$failed:=True
Else 
	If ($systemworker.exitCode#0)
		$failed:=True
	End if 
End if 
If ($failed)
	LOG EVENT(Into system standard outputs; "***ERROR*** Failed to extract runtime archive "+$file.fullName+"\n"; Error message)
	If (($systemworker#Null) && (Not(Bool($systemworker.terminated))))
		$systemworker.terminate()
	End if 
	return False
End if 
If (Is macOS)
	$file.delete()
End if 
$ok:=True
return $ok
