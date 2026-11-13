//%attributes = {}
#DECLARE($config : Object)->$result : Text

var $Txt_info; $Txt_major; $Txt_minor; $Txt_release; $Txt_version; $key; $api; $version; $branch; $os; $cmd; $zip; $zipVolumeDesktop; $typeVersion : Text
var $file; $folder; $archive; $folderToolPackageManager; $folderPackageManager : Object
var $systemworker : 4D:C1709.SystemWorker
var $build; $versionNum : Integer
var $bool; $created : Boolean
var $blob : Blob

$Txt_version:=Application version:C493($build)
$versionNum:=getVersionNumberFromText($Txt_version)
$Txt_major:=$Txt_version[[1]]+$Txt_version[[2]]  //version number
$Txt_release:=String:C10(Formula from string:C1601("0x"+Substring:C12(Application version:C493; 3; 1)).call())  //Rx
$Txt_minor:=$Txt_version[[4]]  //.x
$Txt_info:=$Txt_major
$Txt_info:=($Txt_release="0") ? $Txt_info+"."+$Txt_minor : $Txt_info+" R"+$Txt_release  //4D x.x or 4D x Rx
$version:=($Txt_release="0") ? $Txt_major+".x" : $Txt_major+"%20Rx"  //20.x or 20%20Rx
$branch:=($Txt_release="0") ? $Txt_major+"."+$Txt_minor : $Txt_major+"%20R"+$Txt_release  //20.6 or 20%20R9

// Exceptions pour la version main (alpha)
$typeVersion:=Substring:C12(Application version:C493(*); 0; 1)  // "F" version finale, "B" version bêta et "A" version alpha
$version:=($typeVersion="A") ? "main" : $version
$branch:=($typeVersion="A") ? "main" : $branch

If (Is macOS:C1572)
	If ($versionNum<5216)  // 20 R6
		$zip:="4D_INTL_x86_64.zip"
	Else 
		If ($versionNum<5264)  // 20 R9
			$zip:="4D_x86_64.zip"
		Else 
			$zip:="4D.zip"
		End if 
	End if 
Else 
	If (Is Windows:C1573)
		If ($versionNum<5216)  // 20 R6
			$zip:="4D_INTL_V64.zip"
		Else 
			$zip:="4D.zip"
		End if 
	End if 
End if 

$os:=(Is macOS:C1572) ? "mac" : "win"
LOG EVENT:C667(Into system standard outputs:K38:9; "***INFO*** Version: "+$Txt_info+" build "+String:C10($build)+"\n")

$file:=Folder:C1567(Application file:C491; fk platform path:K87:2).parent.file("4d.zip")

$cmd:=getDownloadCommand($file.path; $version; $branch; $build; $os; $zip; $Txt_major; $Txt_release)

$systemworker:=4D:C1709.SystemWorker.new($cmd)
$systemworker.wait(600)

If (Undefined:C82($systemworker.exitCode) || ($systemworker.exitCode#0))
	LOG EVENT:C667(Into system standard outputs:K38:9; "***ERROR*** Download 4D failed\n"; Error message:K38:3)
	If (($systemworker#Null:C1517) && (Not:C34(Bool:C1537($systemworker.terminated))))
		$systemworker.terminate()
	End if 
	return 
Else 
	LOG EVENT:C667(Into system standard outputs:K38:9; "***INFO*** Download PackageManager success\n")
End if 

If ($file.exists)
	Try
		$archive:=ZIP Read archive:C1637($file)
	Catch
		LOG EVENT:C667(Into system standard outputs:K38:9; "***ERROR*** ["+Last errors:C1799[Last errors:C1799.length-1].errCode+"] "+Last errors:C1799[Last errors:C1799.length-1].message+"\n"; Error message:K38:3)
	End try
	$folder:=$archive.root.copyTo($file.parent; fk overwrite:K87:5)
	If (Is macOS:C1572)
		$file.delete()
	End if 
End if 

If ($file.parent.folder("4d").exists)
	
	If (Is macOS:C1572)
		$folderToolPackageManager:=Folder:C1567(Application file:C491; fk platform path:K87:2).parent.parent.folder("PackageManager")
	Else 
		$folderToolPackageManager:=Folder:C1567(Application file:C491; fk platform path:K87:2).parent.parent.folder("PackageManager")
	End if 
	LOG EVENT:C667(Into system standard outputs:K38:9; "***INFO*** Destination folder : "+$folderToolPackageManager.path+"\n")
	
	If (Not:C34($folderToolPackageManager.exists))
		$created:=$folderToolPackageManager.create()
	End if 
	
	If (Is macOS:C1572)
		If ($file.parent.folder("4d").folder("4D").folder("4D.app").exists)
			$folder:=$file.parent.folder("4d").folder("4D").folder("4D.app").moveTo($file.parent.folder("4d"))
			$file.parent.folder("4d").folder("4D").delete(Delete with contents:K24:24)
		End if 
		If ($file.parent.folder("4d").folder("4D.app").exists)
			$folderPackageManager:=$file.parent.folder("4d").folder("4D.app").folder("Contents").folder("Resources").folder("Internal Components").folder("packageManager.4dbase")
		End if 
	Else 
		$folderPackageManager:=$file.parent.folder("4d").folder("4D").folder("Resources").folder("Internal Components").folder("packageManager.4dbase")
	End if 
	
	If ($folderPackageManager.exists)
		LOG EVENT:C667(Into system standard outputs:K38:9; "***INFO*** Delete mac hidden files in PackageManager\n")
		deleteHiddenFiles($folderPackageManager)
		LOG EVENT:C667(Into system standard outputs:K38:9; "***INFO*** Copy PackageManager to Tool\n")
		$folderPackageManager:=$folderPackageManager.copyTo($folderToolPackageManager)
		If ($folderPackageManager.exists)
			LOG EVENT:C667(Into system standard outputs:K38:9; "***INFO*** Copy PackageManager successfully\n")
		Else 
			LOG EVENT:C667(Into system standard outputs:K38:9; "***ERROR*** Copy of PackageManager failed\n"; Error message:K38:3)
		End if 
	End if 
End if 