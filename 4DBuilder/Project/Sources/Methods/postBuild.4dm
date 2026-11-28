//%attributes = {"invisible":true}
#DECLARE($config : Object; $target : Object)->$success : Boolean

$success:=True:C214

var $ouput; $postBuild; $source : Object
$postBuild:=$target.postBuild
$source:=$target.source
$ouput:=$target.outputStructure

var $file : 4D:C1709.File

// MARK:- CREATE Info.plist
If (Bool:C1537($postBuild.InfoPlist) || Bool:C1537($config.make.contents))
	
	var $ideVersion; $ideSemanticVersion : Text
	var $ideBuild : Integer
	$ideVersion:=Application version:C493($ideBuild)
	
	If ($ideVersion[[3]]="0")
		
		$ideSemanticVersion:=$ideVersion[[1]]+$ideVersion[[2]]+".0."+$ideVersion[[4]]
		$ideVersion:=$ideVersion[[1]]+$ideVersion[[2]]+Choose:C955($ideVersion[[4]]#"0"; "."+$ideVersion[[4]]; "")  // .x
		
	Else 
		
		var $r:=String:C10(Formula from string:C1601("0x"+$ideVersion[[3]]).call())
		
		$ideSemanticVersion:=$ideVersion[[1]]+$ideVersion[[2]]+".R"+$r+"."+$ideVersion[[4]]
		$ideVersion:=$ideVersion[[1]]+$ideVersion[[2]]+"R"+$r  // RX
		
	End if 
	
	var $versionString; $shortVersionString; $longVersionString : Text
	
	$versionString:=$ideSemanticVersion
	$shortVersionString:=$ideSemanticVersion
	$longVersionString:=$ideSemanticVersion
	
	If ($config.git#Null:C1517)
		If (Value type:C1509($config.git.branch)=Is text:K8:3)
			//$versionString:=$config.git.branch
			//$shortVersionString:=$versionString
			//$longVersionString:=$versionString
			// XXX: we do not have the semantic current version with branch: main? 20.x?, we do not have market version
			// so not used now
		End if 
		
		If (Value type:C1509($config.git.changelist)=Is text:K8:3)
			$versionString+="."+$config.git.changelist
			$longVersionString+="."+$config.git.changelist
		End if 
		
		If (Value type:C1509($config.git.commit)=Is text:K8:3)
			$longVersionString+=" - "+$config.git.commit  // submodule commit
		End if 
		
	End if 
	
	var $revision : Text
	$revision:=Try(cs:C1710.git.new({source: $source}; {}).revision())
	If ((Length:C16($revision)>0) && ($longVersionString=$versionString))
		$longVersionString+=" - "+$revision  // real revision of submodule
	End if 
	
	$file:=$target.outputFolder.file("Info.plist")
	
	If ($file.exists)
		
		$config.report($target; "Update the Info.plist"; "info")
		
	Else 
		
		$config.report($target; "Create the Info.plist"; "info")
		$file:=File:C1566("/RESOURCES/Info.template").copyTo($target.outputFolder; "Info.plist")
		
	End if 
	
	If ($file.exists)
		
		var $pList : cs:C1710.pList
		$pList:=cs:C1710.pList.new($file)
		
		$pList.CFBundleName($ouput.name)
		$pList.CFBundleDisplayName($ouput.name)
		$pList.CFBundleGetInfoString($ouput.name)
		
		If (Bool:C1537($postBuild.buildNumber))  // automatic build number increment
			
			var $buildNumber : Integer
			$buildNumber:=($config.buildNumber#Null:C1517) ? Num:C11($config.buildNumber) : (Num:C11($pList.CFBundleVersion())+1)
			
			$shortVersionString:=$shortVersionString+" ("+String:C10($buildNumber)+")"
			$versionString:=String:C10($buildNumber)
			
		End if 
		
		$pList.CFBundleVersion($versionString)
		$pList.CFBundleShortVersionString($shortVersionString)
		// not official ones
		$pList.CFBundleLongVersionString($longVersionString)
		$pList.set(New object:C1471("key"; "com.4D.compiler.version"; "value"; $ideVersion))
		$pList.set(New object:C1471("key"; "com.4D.compiler.build"; "value"; String:C10($ideBuild)))
		If (Length:C16($revision)>0)
			$pList.set(New object:C1471("key"; "com.4D.git.commit.hash"; "value"; String:C10($revision)))
		End if 
		
		var $owner : Text
		$owner:=String:C10($postBuild.owner)
		
		var $copyright : Text
		$copyright:=String:C10($pList.NSHumanReadableCopyright())
		
		If ((Length:C16($owner)=0) && (Length:C16($copyright)=0))
			$owner:=String:C10($config.make.owner)  // a default one if nothing defined elsewhere
		End if 
		
		If (Length:C16($owner)>0)
			
			$copyright:="©"+String:C10($owner)+" "+String:C10(Year of:C25(Current date:C33))
			
		Else 
			
			ARRAY LONGINT:C221($pos; 0x0000)
			ARRAY LONGINT:C221($len; 0x0000)
			
			If (Match regex:C1019("(?m-si)(?:(-*)(\\d{4})$)|(\\d{4}$)"; $copyright; 1; $pos; $len))
				
				var $year : Text
				$year:=String:C10(Year of:C25(Current date:C33))
				
				If ($len{1}=0)
					
					If (Substring:C12($copyright; $pos{0})#$year)
						
						$copyright:=$copyright+"-"+$year
						
					End if 
					
				Else 
					
					$copyright:=Substring:C12($copyright; 1; $pos{0})+$year
					
				End if 
			End if 
		End if 
		
		$pList.NSHumanReadableCopyright($copyright)
		$pList.save()
		
		If ($file.exists)
			
			//MARK: Create InfoPlist.strings
			
			$file:=$target.outputFolder.file("Resources/InfoPlist.strings")
			// XXX: warn if already exists?, do a merge?
			
			$config.report($target; "Create the 'InfoPlist.strings' file"; "info")
			
			var $content : Text
			$content:=File:C1566("/RESOURCES/InfoPlist.template").getText()
			$content:=Replace string:C233($content; "{name}"; $ouput.name)
			$content:=Replace string:C233($content; "{version}"; $pList.CFBundleShortVersionString())
			$content:=Replace string:C233($content; "{build}"; $pList.CFBundleVersion())
			$content:=Replace string:C233($content; "{copyright}"; String:C10($pList.NSHumanReadableCopyright()))
			$file.setText($content; "UTF-16")
			
		End if 
		
	Else 
		
		$config.report($target; "Info.plist has not been updated successfully."; "warning")
		
	End if 
End if 

// MARK:- FILES/FOLDERS TO REMOVE FROM TARGET
If (($postBuild#Null:C1517) && ($postBuild.remove#Null:C1517))
	
	For each ($t; $postBuild.remove)
		
		$file:=(Substring:C12($t; Length:C16($t))="/") ? Null:C1517 : Try($target.outputFolder.file($t))
		
		If (($file#Null:C1517) && $file.exists)
			
			checkFileWritable($file)
			
			$config.report($target; "Delete file: "+$file.path; "info")
			$file.delete()
			
		Else 
			
			var $folder : 4D:C1709.Folder
			$folder:=Try($target.outputFolder.folder($t))
			
			If (($folder#Null:C1517) && $folder.exists)
				
				If (Is Windows:C1573)
					
					SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_HIDE_CONSOLE"; "true")
					SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_CURRENT_DIRECTORY"; $folder.platformPath)
					LAUNCH EXTERNAL PROCESS:C811("attrib.exe -R /D /S")
					
				Else 
					
					LAUNCH EXTERNAL PROCESS:C811("chmod u+rwX '"+$folder.path+"'")
					
				End if 
				
				$config.report($target; "Delete folder: "+$folder.path; "info")
				$folder.delete(fk recursive:K87:7)
				
			Else 
				
				$config.report($target; "Missing file/folder "+$t+" to remove"; "warning")
				
			End if 
		End if 
	End for each 
End if 