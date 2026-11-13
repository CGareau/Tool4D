//%attributes = {"invisible":true}
#DECLARE($config : Object; $target : Object) : Boolean

var $components : Collection
$components:=$target.components.query("builtStructure.exists = true | gitURL # NULL")

return ($components.length=$target.components.length)
