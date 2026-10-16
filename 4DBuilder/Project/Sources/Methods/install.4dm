//%attributes = {"invisible":true}
#DECLARE($config : Object; $dontCachErrors : Boolean)

var $onerr : Text
var $success : Boolean
var $target : Object

// By default, we capture errors
If (Not:C34($dontCachErrors))
	
	$onerr:=Method called on error:C704
	ON ERR CALL:C155("onerr")
	
End if 

$success:=getMake($config)

If ($success)
	
	If ($config.make.outputFolder.exists)
		
		For each ($target; $config.make.targets)
			
			installTarget($config; $target)
			
		End for each 
		
	Else 
		
		ASSERT:C1129(False:C215; "Nothing to install")
		
	End if 
End if 

If (Not:C34($dontCachErrors))
	
	ON ERR CALL:C155($onerr)
	
End if 