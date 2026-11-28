//%attributes = {"invisible":true}
#DECLARE($config : Object; $dontCachErrors : Boolean)

var $onerr : Text
var $success : Boolean

// By default, we capture errors
If (Not:C34($dontCachErrors))
	
	$onerr:=Method called on error:C704
	ON ERR CALL:C155("onerr")
	
End if 

$success:=getMake($config)

If ($success)
	
	If ($config.make.outputFolder.exists)
		
		$config.report(Null:C1517; "Cleaning directory "+$config.make.outputFolder.path; "info")
		$success:=$config.make.outputFolder.delete(Delete with contents:K24:24)
		
	End if 
End if 

If (Not:C34($dontCachErrors))
	
	ON ERR CALL:C155($onerr)
	
End if 