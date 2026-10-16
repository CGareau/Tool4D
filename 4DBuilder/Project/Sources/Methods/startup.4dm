//%attributes = {}
var $dummy : Real
var $action; $startupParam : Text
var $config : Object

$dummy:=Get database parameter:C643(User param value:K37:94; $startupParam)

If (Length:C16($startupParam)>0)
	
	SET ASSERT ENABLED:C1131(False:C215)  // No assert when building from dev tools
	
	$config:=parseUserParam($startupParam)
	
	Case of 
			
			//________________________________________
		: ($config=Null:C1517)
			
			// Nothing to do
			
			//________________________________________
		: (Value type:C1509($config.actions)=Is collection:K8:32)
			
			For each ($action; $config.actions)
				
				EXECUTE METHOD:C1007($action; *; $config)
				
			End for each 
			
			//________________________________________
		: ((Value type:C1509($config.actions)=Is text:K8:3) && (Length:C16($config.actions)>0))
			
			For each ($action; Split string:C1554($config.actions; ","))
				
				EXECUTE METHOD:C1007($action; *; $config)
				
			End for each 
			
			//________________________________________
		Else 
			
			// Default actions is "build"
			build($config)
			
			//________________________________________
	End case 
	
	SET ASSERT ENABLED:C1131(True:C214)
	
	QUIT 4D:C291
	
Else 
	
	If (Not:C34(Is compiled mode:C492))
		
		ARRAY TEXT:C222($componentsArray; 0)
		COMPONENT LIST:C1001($componentsArray)
		
		If (Find in array:C230($componentsArray; "4DPop QuickOpen")>0)
			
			// Installing quickOpen
			EXECUTE METHOD:C1007("quickOpenInit"; *; Formula:C1597(MODIFIERS); Formula:C1597(KEYCODE))
			ON EVENT CALL:C190("quickOpenEventHandler"; "$quickOpenListener")
			
		End if 
	End if 
End if 