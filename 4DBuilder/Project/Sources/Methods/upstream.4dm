//%attributes = {}
#DECLARE($config : Object; $catchErrors : Boolean)

var $onerr : Text
var $relativePath : Text
var $catch; $success; $isGit : Boolean
var $target; $git; $result : Object
var $remotes : Collection

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
	
	For each ($target; $config.make.targets.filter(Formula:C1597($1.value.externalGitURL#Null:C1517)))
		
		If ($target.source.exists)
			$git:=cs:C1710.git.new($target; $config)
			
			If ($git.isGit)
				
				$remotes:=$git.remotes()
				If (Not:C34($remotes.indexOf("upstream")>=0))
					
					$result:=$git.remoteAdd("upstream"; $target.externalGitURL)
					$git.report($result)
					
				End if 
				
			Else 
				$config.report(Null:C1517; "Ignored  "+$target.source.path+" because not a git repo yet"; "debug")
			End if 
			
		End if 
		
	End for each 
	
End if 

If ($catch)
	ON ERR CALL:C155($onerr)
End if 