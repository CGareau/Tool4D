//%attributes = {}
#DECLARE($config : Object; $catchErrors : Boolean)

var $onerr : Text
var $catch; $success; $isGit : Boolean
var $target; $git; $result : Object

If ($catchErrors=Null:C1517)
	$catch:=True:C214
Else 
	$catch:=$catchErrors
End if 

$onerr:=Method called on error:C704
If ($catch)
	//ON ERR CALL("onerr")
End if 

$success:=getMake($config)

If ($success)
	
	For each ($target; $config.make.targets.filter(Formula:C1597($1.result:=$1.value.gitURL#Null:C1517)))
		
		$git:=cs:C1710.git.new($target; $config)
		
		// only if git
		If ($git.isInGit)
			
			// case 1: support submodule for git repo?
			If ($target.source.exists)
				If ($git.isGit)
					$result:=$git.submoduleUpdate()
					$git.report($result)
					$result:=$git.add()
					$git.report($result)
				Else 
					$config.report(Null:C1517; "Ignored  "+$target.source.path+" because not a git repo yet"; "debug")
				End if 
			End if 
			
		End if 
		
		// Else perforce ignore (we could rebase if a git repo is present but nobody must use perfoce!)
		
	End for each 
	
End if 

If ($catch)
	ON ERR CALL:C155($onerr)
End if 