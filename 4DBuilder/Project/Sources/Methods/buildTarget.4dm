//%attributes = {"invisible":true}
#DECLARE($config : Object; $target : Object) : Boolean

var $step : Text
var $success : Boolean

$step:="configureTarget"
// try to checkout if needed
var $isTargetEmpty : Boolean
$isTargetEmpty:=$target.source.folders().combine($target.source.files()).length=0

If ($target.gitURL#Null:C1517)
	
	If (Not:C34($target.source.exists) | $isTargetEmpty)
		
		var $gitTarget; $gitResult : Object
		$gitTarget:=cs:C1710.git.new($target; $config)
		
		If ($gitTarget.isInGit)
			
			$gitResult:=$gitTarget.submoduleInit()
			$gitTarget.report($gitResult)
			
			$isTargetEmpty:=$target.source.folders().combine($target.source.files()).length=0
			
		End if 
	End if 
End if 

If (Not:C34($isTargetEmpty)\
 | ($target.gitURL=Null:C1517))
	
	$success:=configureTarget($config; $target)
	
Else 
	
	$config.report($target; "Ignored temporary if not source and git url exists (code must be checkouted)"; "info")
	$success:=False:C215  // TEMPORARY not failed with assert if source not checkouted
	
End if 

If ($success)
	
	Case of 
			
			//________________________________________
		: (Not:C34(targetDependenciesExist($config; $target)))
			
			$config.report($target; "Missing dependency"; "error")
			
			//________________________________________
		: (Not:C34(buildNeeded($config; $target)))\
			 & (Not:C34(Bool:C1537($config.forceBuild)))
			
			$config.report($target; "Nothing to build"; "info")
			
			//________________________________________
		Else 
			
			$config.report($target; Timestamp:C1445+" build start"; "info")
			
			If ($success)
				
				$step:="cleanOutput"
				$success:=cleanOutput($config; $target)
				
			End if 
			
			If ($success)
				
				$step:="copyTarget"
				$success:=copyTarget($config; $target)
				
			End if 
			
			If ($success)
				
				$step:="convertTargetToProject"
				$success:=convertTargetToProject($config; $target)
				
			End if 
			
			If ($success)
				
				$step:="compileProject"
				
				If (_4D With feature:C1524("WITH_COMPILE_COMMAND"))
					
					$success:=compileProject($config; $target)
					
				Else 
					
					$success:=compileProject_old($config; $target)
					
				End if 
			End if 
			
			If ($success)
				
				$step:="deleteProjectSourcess"
				$success:=deleteProjectSources($config; $target)
				
			End if 
			
			If ($success)
				$success:=markComponent($config; $target)
			End if 
			
			If ($success)
				
				$step:="buildCompiledStructure"
				$success:=buildCompiledStructure($config; $target)
				
				If ($success)
					
					$step:="postBuild"
					$success:=postBuild($config; $target)
					
				End if 
			End if 
			
			If ($success)
				
				$config.report($target; Timestamp:C1445+" build successful"; "info")
				
			Else 
				
				$config.report($target; Timestamp:C1445+" build failed at step "+$step; "warning")
				
			End if 
			
			//________________________________________
	End case 
End if 

return $success