//%attributes = {"invisible":true}
#DECLARE($config : Object; $target : Object)

If ($config.installFolder=Null:C1517)
	If ($config.install#Null:C1517)
		$config.installFolder:=Folder:C1567($config.install; fk posix path:K87:1)  // from config
	Else 
		$config.installFolder:=Folder:C1567(Application file:C491; fk platform path:K87:2)  // current 4d
	End if 
	
	If (Is macOS:C1572)
		$config.installFolder:=$config.installFolder.folder("Contents")  // 4D.app/Contents
	Else 
		$config.installFolder:=$config.installFolder.parent  // sibling 4D.exe
	End if 
End if 

var $success : Boolean
$success:=configureTarget($config; $target)

If ($success)
	
	If ($target.outputFolder.exists)
		If ($target.path=Null:C1517)
			$target.path:=$target.source.name
		End if 
		// 4d rules, not generic
		If (Position:C15("User Components"; $target.path)=1)
			$target.installFolder:=$config.installFolder.folder(Replace string:C233($target.path; "User Components"; "Components")+".4dbase")
		Else 
			$target.installFolder:=$config.installFolder.folder("Components").folder($target.path+".4dbase")
		End if 
		
		$target.installFolder.delete(Delete with contents:K24:24)
		$target.outputFolder.copyTo($target.installFolder.parent)
		
		If ($target.installFolder.exists)
			$config.report($target; "Install "+$target.path+" successful"; "info")
		Else 
			$config.report($target; "Install "+$target.path+" failed"; "warning")
		End if 
		
	Else 
		
		$config.report($target; "Nothing to install"; "warning")
		
	End if 
	
End if 