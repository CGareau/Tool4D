//%attributes = {"invisible":true}
#DECLARE($config : Object; $catchErrors : Boolean)

var $onerr : Text
var $cmd; $in; $out; $err : Text
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
		
		// we want to force git, even if there is source (NOT ASK, could be removed), so we remove
		// alternative, just bare checkout in temp dir and move .git it to target source (so we have potential diff
		If (Bool:C1537($config.gitify))  // call it force?
			If (Not:C34($git.isGit) & $target.source.exists)
				$config.report(Null:C1517; "Deleting  "+$target.source.path; "info")
				$target.source.delete(fk recursive:K87:7)
			End if 
		End if 
		
		// two case: perforce(or no vcs) or git parent repo
		If ($git.isInGit)
			// case 1: support submodule for git repo?
			If ($target.source.exists)
				If ($git.isGit)
					$result:=$git.rebase($git.parentCurrentBranch)
				Else 
					$config.report(Null:C1517; "Ignored  "+$target.source.path+" because not a git repo yet"; "debug")
				End if 
			Else 
				$result:=$git.submoduleAdd()
			End if 
			
		Else 
			// case  2: normal case for perforce or no vcs
			If ($target.source.exists)
				If ($git.isGit)
					$result:=$git.rebase()
				End if 
			Else 
				$result:=$git.clone()
			End if 
			
		End if 
		
	End for each 
	
End if 

If ($catch)
	ON ERR CALL:C155($onerr)
End if 