//%attributes = {}
#DECLARE($config : Object; $target : Object)->$success : Boolean

/*
WARNING: this code should never be made public
as it puts a 'secret' inside our components to be able
to identify 4D components forked but not renamed as required by our licence.
*/

var $mapFile : 4D:C1709.File
$mapFile:=$target.outputFolder.file("Project/DerivedData/CompiledCode/map.json")

var $markFile : 4D:C1709.File
$markFile:=$target.outputFolder.file("Project/DerivedData/CompiledCode/mark.txt")

var $secret; $timestamp; $digest : Text
$secret:="4D build system:"
$timestamp:=String:C10($mapFile.modificationDate; ISO date GMT:K1:10; Time:C179($mapFile.modificationTime))
$digest:=Generate digest:C1147(($secret+$timestamp); SHA256 digest:K66:4)
$markFile.setText($digest+"\n"+$timestamp; "utf-8"; Document unchanged:K24:18)

return True:C214