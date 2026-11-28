//%attributes = {"invisible":true}

var $errors : Collection
$errors:=Last errors:C1799

var $callChain : Collection
$callChain:=Call chain:C1662
$callChain.shift()

var $caller : Object
$caller:=$callChain.first()

var $codeLine : Text
$codeLine:=String:C10($caller.line)

var $codeFile : 4D:C1709.File
var $sourceFolder : 4D:C1709.Folder
$sourceFolder:=Folder:C1567(Folder:C1567("/SOURCES/").platformPath; fk platform path:K87:2)
Case of 
	: (String:C10($caller.type)="projectMethod")
		
		$codeFile:=$sourceFolder.folder("Methods").file($caller.name+".4dm")
		
	: (String:C10($caller.type)="databaseMethod")
		
		$codeFile:=$sourceFolder.folder("DatabaseMethods").file($caller.name+".4dm")
		
	: (String:C10($caller.type)="projectForm")
		
		// FIXME: real subfolder
		$codeFile:=$sourceFolder.folder("Forms").file($caller.name+".4dm")
		
	: (String:C10($caller.type)="tableForm")
		
		$codeFile:=$sourceFolder.folder("TableForms").file($caller.name+".4dm")
		
	: (String:C10($caller.type)="trigger")
		
		$codeFile:=$sourceFolder.folder("Triggers").file($caller.name+".4dm")
		
	: (String:C10($caller.type)="class")
		
		$codeFile:=$sourceFolder.folder("Classes").file($caller.name+".4dm")
		
End case 

var $error : Object
For each ($error; $errors)
	
	logMessage(Null:C1517; Null:C1517; $error.message; "error"; $codeFile; $codeLine)
	$codeFile:=Null:C1517  // on for the first maybe have only one
	$codeLine:=""
	
End for each 

QUIT 4D:C291

ABORT:C156