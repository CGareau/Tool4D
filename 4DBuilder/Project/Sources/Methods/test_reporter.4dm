//%attributes = {}

var $config; $target : Object
//$config:=New object(\
"makeFile";Folder(Temporary folder;fk platform path);\
"destination";6;\
"reporter";"defaultReporter")

$config:=getTestConfig

$target:=New object:C1471("name"; "target"; "source"; New object:C1471("name"; "sourceName"))

$config.report:=Formula from string:C1601($config.reporter+"($1;$2;$3;4)")

$config.report($config; $target; "message"; "error")