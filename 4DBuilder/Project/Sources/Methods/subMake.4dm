//%attributes = {"invisible":true}
#DECLARE($target : Object)

var $makeComponentFile : Object
$makeComponentFile:=$target.source.file("make.json")
If ($makeComponentFile.exists)
	var $makeComponentObject : Object
	$makeComponentObject:=JSON Parse:C1218($makeComponentFile.getText("utf-8"); Is object:K8:27)
	ob_deepMerge($target; $makeComponentObject)
End if 