//%attributes = {}
#DECLARE($config : Object)->$result : Text

var $Txt_info; $Txt_major; $Txt_minor; $Txt_release; $Txt_version; $key; $api; $version; $branch; $os; $cmd; $zipServer; $zipVolumeDesktop; $typeVersion : Text
var $file; $folder; $archive : Object
var $systemworker : 4D:C1709.SystemWorker
var $build; $versionNum : Integer
var $bool : Boolean
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
		$zipServer:="4D%20Server_INTL_x86_64.zip"
		$zipVolumeDesktop:="4D%20Volume%20Desktop_INTL_x86_64.zip"
	Else 
		If ($versionNum<5264)  // 20 R9
			$zipServer:="4D%20Server_x86_64.zip"
			$zipVolumeDesktop:="4D%20Volume%20Desktop_x86_64.zip"
		Else 
			$zipServer:="4D%20Server.zip"
			$zipVolumeDesktop:="4D%20Volume%20Desktop.zip"
		End if 
	End if 
Else 
	If (Is Windows:C1573)
		If ($versionNum<5216)  // 20 R6
			$zipServer:="4D%20Server_INTL_V64.zip"
			$zipVolumeDesktop:="4D%20Volume%20Desktop_INTL_V64.zip"
		Else 
			$zipServer:="4D%20Server.zip"
			$zipVolumeDesktop:="4D%20Volume%20Desktop.zip"
		End if 
	End if 
End if 

$os:=(Is macOS:C1572) ? "mac" : "win"
LOG EVENT:C667(Into system standard outputs:K38:9; "***INFO*** Version: "+$Txt_info+" build "+String:C10($build)+"\n")

If ($config.buildServer)
	If (Is macOS:C1572)
		$file:=Folder:C1567(Application file:C491; fk platform path:K87:2).parent.file("4dserver.zip")
	Else 
		$file:=Folder:C1567(Application file:C491; fk platform path:K87:2).parent.parent.file("4dserver.zip")
	End if 
	
	$cmd:=getDownloadCommand($file.path; $version; $branch; $build; $os; $zipServer; $Txt_major; $Txt_release)
	
	$systemworker:=4D:C1709.SystemWorker.new($cmd)
	$systemworker.wait(600)
	
	If (Undefined:C82($systemworker.exitCode) || ($systemworker.exitCode#0))
		LOG EVENT:C667(Into system standard outputs:K38:9; "***ERROR*** Download 4D Server failed\n"; Error message:K38:3)
		If (($systemworker#Null:C1517) && (Not:C34(Bool:C1537($systemworker.terminated))))
			$systemworker.terminate()
		End if 
		return 
	Else 
		LOG EVENT:C667(Into system standard outputs:K38:9; "***INFO*** Download 4D Server success\n")
	End if 
	
	If ($file.exists)
		$archive:=ZIP Read archive:C1637($file)
		$folder:=$archive.root.copyTo($file.parent; fk overwrite:K87:5)
		If (Is macOS:C1572)
			$file.delete()
		End if 
	End if 
	
	If ($file.parent.folder("4dserver").exists)
		If (Is macOS:C1572)
			If ($file.parent.folder("4D Server.app").exists)
				$file.parent.folder("4D Server.app").delete(Delete with contents:K24:24)
			End if 
		Else 
			If ($file.parent.folder("4D Server").exists)
				$file.parent.folder("4D Server").delete(Delete with contents:K24:24)
			End if 
		End if 
		If (Is macOS:C1572)
			If ($file.parent.folder("4dserver").folder("4D Server").folder("4D Server.app").exists)
				$folder:=$file.parent.folder("4dserver").folder("4D Server").folder("4D Server.app").moveTo($file.parent)
			End if 
		Else 
			If ($file.parent.folder("4dserver").folder("4D Server").exists)
				$folder:=$file.parent.folder("4dserver").folder("4D Server").moveTo($file.parent)
			End if 
		End if 
		If ($file.parent.folder("4dserver").folder("4D Server.app").exists)
			$folder:=$file.parent.folder("4dserver").folder("4D Server.app").moveTo($file.parent)
		End if 
		If ($file.parent.folder("4dserver").exists)
			$file.parent.folder("4dserver").delete(Delete with contents:K24:24)
		End if 
	End if 
End if 

If ($config.buildClient || $config.buildStandalone)
	If (Is macOS:C1572)
		$file:=Folder:C1567(Application file:C491; fk platform path:K87:2).parent.file("4dvolumedesktop.zip")
	Else 
		$file:=Folder:C1567(Application file:C491; fk platform path:K87:2).parent.parent.file("4dvolumedesktop.zip")
	End if 
	
	If ($file.exists)
		$file.delete()
	End if 
	If ($file.parent.folder("4dvolumedesktop").exists)
		$file.parent.folder("4dvolumedesktop").delete(Delete with contents:K24:24)
	End if 
	If (Is macOS:C1572)
		If ($file.parent.folder("4D Volume Desktop.app").exists)
			$file.parent.folder("4D Volume Desktop.app").delete(Delete with contents:K24:24)
		End if 
	Else 
		If ($file.parent.folder("4D Volume Desktop").exists)
			$file.parent.folder("4D Volume Desktop").delete(Delete with contents:K24:24)
		End if 
	End if 
	
	$cmd:=getDownloadCommand($file.path; $version; $branch; $build; $os; $zipVolumeDesktop; $Txt_major; $Txt_release)
	
	$systemworker:=4D:C1709.SystemWorker.new($cmd)
	$systemworker.wait(600)
	
	If (Undefined:C82($systemworker.exitCode) || ($systemworker.exitCode#0))
		LOG EVENT:C667(Into system standard outputs:K38:9; "***ERROR*** Download 4D Volume Desktop failed\n"; Error message:K38:3)
		If (($systemworker#Null:C1517) && (Not:C34(Bool:C1537($systemworker.terminated))))
			$systemworker.terminate()
		End if 
		return 
	Else 
		LOG EVENT:C667(Into system standard outputs:K38:9; "***INFO*** Download 4D Volume Desktop success\n")
	End if 
	
	If ($file.exists)
		$archive:=ZIP Read archive:C1637($file)
		$folder:=$archive.root.copyTo($file.parent; fk overwrite:K87:5)
	End if 
	
	If ($file.parent.folder("4dvolumedesktop").exists)
		If (Is macOS:C1572)
			If ($file.parent.folder("4dvolumedesktop").folder("4D Volume Desktop").folder("4D Volume Desktop.app").exists)
				$folder:=$file.parent.folder("4dvolumedesktop").folder("4D Volume Desktop").folder("4D Volume Desktop.app").moveTo($file.parent)
			End if 
		Else 
			If ($file.parent.folder("4dvolumedesktop").folder("4D Volume Desktop").exists)
				$folder:=$file.parent.folder("4dvolumedesktop").folder("4D Volume Desktop").moveTo($file.parent)
			End if 
		End if 
		If ($file.parent.folder("4dvolumedesktop").folder("4D Volume Desktop.app").exists)
			$folder:=$file.parent.folder("4dvolumedesktop").folder("4D Volume Desktop.app").moveTo($file.parent)
		End if 
	End if 
End if 