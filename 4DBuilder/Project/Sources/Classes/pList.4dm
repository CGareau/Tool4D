
property file : 4D:C1709.File
property content : Object

property success : Boolean
property errors : Collection
property warnings : Collection

Class constructor($file : Variant)
	
	This:C1470.errors:=New collection:C1472
	This:C1470.warnings:=New collection:C1472
	
	Case of 
			
			//______________________________________________________
		: (Count parameters:C259=0)
			
			This:C1470.errors.push(Current method name:C684+" - Missing file parameter")
			
			//______________________________________________________
		: (Value type:C1509($file)=Is text:K8:3)
			
			If (Position:C15(":"; $file)>0)  // Platform path
				
				This:C1470.file:=File:C1566($file; fk platform path:K87:2)
				
			Else 
				
				This:C1470.file:=File:C1566($file)
				
			End if 
			
			//______________________________________________________
		: (Value type:C1509($file)=Is object:K8:27)
			
			If (OB Instance of:C1731($file; 4D:C1709.File))
				
				This:C1470.file:=$file
				
			Else 
				
				This:C1470.errors.push(Current method name:C684+" - Must be a File")
				
			End if 
			
			//______________________________________________________
	End case 
	
	This:C1470._parse()
	
	//=== === === === === === === === === === === === === === === === === === === ===
Function save
	
	var $key; $node; $root; $t : Text
	
	checkFileWritable(This:C1470.file)
	
	This:C1470.success:=This:C1470.file.isWritable
	
	If (This:C1470.success)
		
		$root:=DOM Create XML Ref:C861("plist")
		This:C1470.success:=Bool:C1537(OK)
		
		If (This:C1470.success)
			
			$t:=DOM Append XML child node:C1080($root; XML DOCTYPE:K45:19; "plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd")
			
			DOM SET XML ATTRIBUTE:C866($root; \
				"version"; "1.0")
			
			$node:=DOM Create XML element:C865($root; "/plist/dict")
			This:C1470.success:=Bool:C1537(OK)
			
			If (This:C1470.success)
				
				For each ($key; This:C1470.content) While (Bool:C1537(OK))
					
					DOM SET XML ELEMENT VALUE:C868(DOM Create XML element:C865($node; "key"); $key)
					This:C1470.success:=This:C1470.success & Bool:C1537(OK)
					
					If (This:C1470.success)
						
						DOM SET XML ELEMENT VALUE:C868(DOM Create XML element:C865($node; "string"); This:C1470.content[$key])
						This:C1470.success:=This:C1470.success & Bool:C1537(OK)
						
					End if 
				End for each 
				
				If (This:C1470.success)
					
					DOM EXPORT TO FILE:C862($root; This:C1470.file.platformPath)
					This:C1470.success:=Bool:C1537(OK)
					
				End if 
			End if 
			
			DOM CLOSE XML:C722($root)
			
		End if 
		
	Else 
		
		This:C1470.errors.push(Current method name:C684+" - File missing or not writable: "+This:C1470.file.path)
		
	End if 
	
	//=== === === === === === === === === === === === === === === === === === === ===
Function CFBundleName($value : Text)->$response
	
	If (Count parameters:C259>=1)
		
		// Set
		$response:=This:C1470.set(New object:C1471("key"; "CFBundleName"; "value"; $value))
		
	Else 
		
		$response:=This:C1470.get("CFBundleName")
		
	End if 
	
	//=== === === === === === === === === === === === === === === === === === === ===
Function CFBundleDisplayName($value : Text)->$response
	
	If (Count parameters:C259>=1)
		
		// Set
		$response:=This:C1470.set(New object:C1471("key"; "CFBundleDisplayName"; "value"; $value))
		
	Else 
		
		$response:=This:C1470.get("CFBundleDisplayName")
		
	End if 
	
	//=== === === === === === === === === === === === === === === === === === === ===
Function CFBundleGetInfoString($value : Text)->$response
	
	If (Count parameters:C259>=1)
		
		// Set
		$response:=This:C1470.set(New object:C1471("key"; "CFBundleGetInfoString"; "value"; $value))
		
	Else 
		
		$response:=This:C1470.get("CFBundleGetInfoString")
		
	End if 
	
	//=== === === === === === === === === === === === === === === === === === === ===
Function CFBundleShortVersionString($value : Text)->$response
	
	If (Count parameters:C259>=1)
		
		// Set
		$response:=This:C1470.set(New object:C1471("key"; "CFBundleShortVersionString"; "value"; $value))
		
	Else 
		
		$response:=This:C1470.get("CFBundleShortVersionString")
		
	End if 
	
	//=== === === === === === === === === === === === === === === === === === === ===
Function CFBundleLongVersionString($value : Text)->$response
	
	If (Count parameters:C259>=1)
		
		// Set
		$response:=This:C1470.set(New object:C1471("key"; "CFBundleLongVersionString"; "value"; $value))
		
	Else 
		
		$response:=This:C1470.get("CFBundleLongVersionString")
		
	End if 
	
	//=== === === === === === === === === === === === === === === === === === === ===
Function NSHumanReadableCopyright($value : Text)->$response
	
	If (Count parameters:C259>=1)
		
		// Set
		$response:=This:C1470.set(New object:C1471("key"; "NSHumanReadableCopyright"; "value"; $value))
		
	Else 
		
		$response:=This:C1470.get("NSHumanReadableCopyright")
		
	End if 
	
	//=== === === === === === === === === === === === === === === === === === === ===
Function CFBundleVersion($value : Text)->$response
	
	If (Count parameters:C259>=1)
		
		// Set
		$response:=This:C1470.set(New object:C1471("key"; "CFBundleVersion"; "value"; $value))
		
	Else 
		
		$response:=This:C1470.get("CFBundleVersion")
		
	End if 
	
	//=== === === === === === === === === === === === === === === === === === === ===
Function get($key : Text)->$value
	
	This:C1470.success:=(This:C1470.content[$key]#Null:C1517)
	
	If (This:C1470.success)
		
		$value:=This:C1470.content[$key]
		This:C1470.success:=True:C214
		
	End if 
	
	//=== === === === === === === === === === === === === === === === === === === ===
Function set($param : Object)->$this : cs:C1710.pList
	
	var $key : Text
	var $value : Variant
	
	$key:=String:C10($param.key)
	
	This:C1470.success:=(Length:C16($key)>0)
	
	If (This:C1470.success)
		
		$value:=String:C10($param.value)
		
		If (Length:C16($value)>0)
			
			This:C1470.content[$key]:=$value
			
		Else 
			
			OB REMOVE:C1226(This:C1470.content; $key)
			
		End if 
		
	Else 
		
		This:C1470.errors.push(Current method name:C684+" - File not found: "+This:C1470.file.path)
		
	End if 
	
	$this:=This:C1470
	
	//=== === === === === === === === === === === === === === === === === === === ===
Function _parse()
	
	var $key; $node; $root; $t; $type : Text
	var $i : Integer
	
	This:C1470.success:=Bool:C1537(This:C1470.file.exists)
	
	If (This:C1470.success)
		
		$t:=This:C1470.file.getText()
		$root:=DOM Parse XML variable:C720($t)
		This:C1470.success:=Bool:C1537(OK)
		
		If (This:C1470.success)
			
			ARRAY TEXT:C222($nodes; 0x0000)
			$nodes{0}:=DOM Find XML element:C864($root; "/plist/dict/key"; $nodes)
			This:C1470.success:=Bool:C1537(OK)
			
			If (This:C1470.success)
				
				This:C1470.content:=New object:C1471
				
				For ($i; 1; Size of array:C274($nodes); 1)
					
					DOM GET XML ELEMENT VALUE:C731($nodes{$i}; $key)
					
					This:C1470.content[$key]:=New object:C1471
					
					$node:=DOM Get next sibling XML element:C724($nodes{$i})
					DOM GET XML ELEMENT NAME:C730($node; $type)
					
					Case of 
							
							//______________________________________________________
						: ($type="string")
							
							DOM GET XML ELEMENT VALUE:C731($node; $t)
							This:C1470.content[$key]:=$t
							
							//______________________________________________________
						Else 
							
							ASSERT:C1129(Structure file:C489#Structure file:C489(*))  // #TODO
							
							//______________________________________________________
					End case 
				End for 
			End if 
			
			DOM CLOSE XML:C722($root)
			
		Else 
			
		End if 
		
	Else 
		
		This:C1470.errors.push(Current method name:C684+" - File not found: "+This:C1470.file.path)
		
	End if 