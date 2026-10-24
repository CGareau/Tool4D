//%attributes = {"preemptive":"capable"}
// Objectif : Convertit "2000" en 5120, "2060" en 5216, "20A0" en 5280, "2100" en 5376, etc. => voir méthode "getVersionCorrespondance"

#DECLARE($versionText : Text)->$versionNum : Integer

var $majorText; $minorText : Text
var $major; $minor : Integer

If (Length:C16($versionText)=4)
	$majorText:=Substring:C12($versionText; 1; 2)  // "20"
	$minorText:=Substring:C12($versionText; 3; 2)  // "A0" ou "60"
	
	$major:=Num:C11($majorText)
	
	// On convertit les 2 derniers caractères en valeur décimale (hexadécimal)
	$minor:=Formula from string:C1601("0x"+Substring:C12($versionText; 3; 2)).call()  // "A0" => 160
	
	$versionNum:=$major*256+$minor  // Ex: 20*256 + 6*16 = 5216 ou 21*256 + 2*16 = 5408
Else 
	$versionNum:=0
End if 