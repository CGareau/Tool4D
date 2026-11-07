//%attributes = {"invisible":true}
#DECLARE($config : Object; $target : Object) : Boolean

var $toErase : 4D:C1709.Folder
$toErase:=$target.outputFolder
If (Bool:C1537($target.eraseParent))
	$toErase:=$toErase.parent
End if 

$config.report($target; "Erasing output folder "+$toErase.path; "info")

var $ok : Boolean
$ok:=$toErase.delete(Delete with contents:K24:24)
If (True:C214)  // bug:$ok)
	$ok:=$target.outputFolder.create()
End if 

return $ok
