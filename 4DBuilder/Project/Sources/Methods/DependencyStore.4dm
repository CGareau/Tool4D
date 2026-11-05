//%attributes = {"invisible":true}
#DECLARE($command : Text; $parameters : Object) : Object

var $o : Object

// ----------------------------------------------------
If (This:C1470[""]=Null:C1517)  // Constructor
	
	$o:=New object:C1471(\
		""; "DependencyStore"; \
		"get"; Formula:C1597(DependencyStore("get"; New object:C1471("name"; $1))); \
		"import"; Formula:C1597(DependencyStore("import"; New object:C1471("targets"; $1)))\
		)
	
	Case of 
			
			//=================================================================
		: ($command="make")
			
			var $target : Object
			$o.targets:=New object:C1471
			For each ($target; $parameters.targets)
				$o.targets[$target.source.fullName]:=$target
			End for each 
			
	End case 
	
Else   // formula
	
	Case of 
			
			//=================================================================
		: ($command="get")
			
			$o:=This:C1470.targets[$parameters.name]
			
/*
If ($o=Null)
//Get from git, perforce or url file?
			$o:=New object("toBuild"; False; \
"path"; $parameters.name; \
"source"; Folder(fk resources folder).folder("Components").folder($parameters.name); \
"builtStructure"; Folder(fk desktop folder))
End if 
*/
			
			//=================================================================
		: ($command="import")
			
			If ($parameters.targets#Null:C1517)
				For each ($target; $parameters.targets)
					This:C1470.targets[$target.source.fullName]:=$target
				End for each 
			End if 
			
	End case 
End if 

// ----------------------------------------------------
return $o