//%attributes = {"invisible":true}
#DECLARE($config : Object; $target : Object) : Boolean

var $success : Boolean
$success:=True:C214

If ($success)
	$success:=copyTarget($config; $target)
End if 

If ($success)
	$success:=convertTargetToProject($config; $target)
End if 

If ($success)
	If (_4D With feature:C1524("WITH_COMPILE_COMMAND"))
		$success:=compileProject($config; $target)
	Else 
		$success:=compileProject_old($config; $target)
	End if 
End if 

If ($success)
	$success:=deleteProjectSources($config; $target)
End if 

If ($success)
	$success:=buildCompiledStructure($config; $target)
End if 

return $success