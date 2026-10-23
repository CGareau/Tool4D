//%attributes = {}
var $versions : Collection
var $corresp : Object
var $vers : Text

$corresp:={}
$versions:=["2000"; "2020"; "2030"; "2040"; "2050"; "2060"; "2070"; "2080"; "2090"; "20A0"; "2100"; "2120"]

For each ($vers; $versions)
	$corresp[$vers]:=getVersionNumberFromText($vers)
End for each 

ALERT:C41(JSON Stringify:C1217($corresp; *))