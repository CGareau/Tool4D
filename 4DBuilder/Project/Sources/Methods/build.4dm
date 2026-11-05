//%attributes = {"invisible":true}
#DECLARE($config : Object; $dontCachErrors : Boolean) : Boolean

var $onerr : Text
var $success; $allSuccess : Boolean
var $target : Object

// By default, we capture errors
If (Not:C34($dontCachErrors))
	
	$onerr:=Method called on error:C704
	ON ERR CALL:C155("onerr")
	
End if 

$allSuccess:=True:C214

If (getMake($config))
	
	For each ($target; $config.make.targets)
		
		$success:=True:C214
		
		If (Bool:C1537($target.toBuild))
			
			Case of 
					
					//______________________________________________________
				: ($target.platforms#Null:C1517)
					
					Case of 
							
							//……………………………………………………………………………………………………………
						: (Value type:C1509($target.platforms)=Is collection:K8:32)
							
							// <NOTHING MORE TO DO>
							
							//……………………………………………………………………………………………………………
						: (Value type:C1509($target.platforms)=Is text:K8:3)
							
							$target.platforms:=Split string:C1554($target.platforms; ",")
							
							//……………………………………………………………………………………………………………
						Else 
							
							$config.report(Null:C1517; "'platforms' key must be a Text (list separated comma) or a Collection"; "error")
							$success:=False:C215
							
							//……………………………………………………………………………………………………………
					End case 
					
					Case of 
							
							//……………………………………………………………………………………………………………
						: (Not:C34($success))
							
							// <NOTHING MORE TO DO>
							
							//……………………………………………………………………………………………………………
						: (Is macOS:C1572)
							
							$success:=$target.platforms.indexOf("macos")#-1
							
							//……………………………………………………………………………………………………………
						: (Is Windows:C1573)
							
							$success:=$target.platforms.indexOf("windows")#-1
							
							//……………………………………………………………………………………………………………
						Else 
							
							$success:=$target.platforms.indexOf("linux")#-1
							
							//……………………………………………………………………………………………………………
					End case 
					
					//______________________________________________________
				: ($target.excludedPlatforms#Null:C1517)
					
					Case of 
							
							//……………………………………………………………………………………………………………
						: (Value type:C1509($target.excludedPlatforms)=Is collection:K8:32)
							
							// <NOTHING MORE TO DO>
							
							//……………………………………………………………………………………………………………
						: (Value type:C1509($target.excludedPlatforms)=Is text:K8:3)
							
							$target.excludedPlatforms:=Split string:C1554($target.excludedPlatforms; ",")
							
							//……………………………………………………………………………………………………………
						Else 
							
							$config.report(Null:C1517; "'excludedPlatforms' key must be a Text (list separated comma) or a Collection"; "error")
							$success:=False:C215
							
							//……………………………………………………………………………………………………………
					End case 
					
					Case of 
							
							//……………………………………………………………………………………………………………
						: (Not:C34($success))
							
							// <NOTHING MORE TO DO>
							
							//……………………………………………………………………………………………………………
						: (Is macOS:C1572)
							
							$success:=$target.excludedPlatforms.indexOf("macos")=-1
							
							//……………………………………………………………………………………………………………
						: (Is Windows:C1573)
							
							$success:=$target.excludedPlatforms.indexOf("windows")=-1
							
							//……………………………………………………………………………………………………………
						Else 
							
							$success:=$target.excludedPlatforms.indexOf("linux")=-1
							
							//……………………………………………………………………………………………………………
					End case 
					
					//______________________________________________________
			End case 
			
			If ($success)
				
				$success:=buildTarget($config; $target)
				
			End if 
			
		Else 
			
			$config.report($dontCachErrors; "Skip build:"+String:C10($target.source.fullName); "info")
			
		End if 
		
		$allSuccess:=$allSuccess && $success
		
	End for each 
End if 

If (Not:C34($dontCachErrors))
	
	ON ERR CALL:C155($onerr)
	
End if 

return $allSuccess