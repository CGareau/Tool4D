//%attributes = {"invisible":true}
#DECLARE($buildOrder : Collection; $targetStore : Object; $targetIn : Object; $config : Object) : Boolean

var $target : Object
var $oneDependency : Text

var $ok : Boolean
$ok:=True:C214

Case of 
		
		//________________________________________
	: (String:C10($targetIn.dependenciesState)="")
		
		$targetIn.dependenciesState:="during"
		var $components : Collection
		$components:=New collection:C1472
		
		If (Value type:C1509($targetIn.components)=Is collection:K8:32)
			
			For each ($oneDependency; $targetIn.components) While ($ok)
				
				$target:=$targetStore.get($oneDependency)
				
				If ($target#Null:C1517)
					
					$components.push($target)
					$ok:=addDependency($buildOrder; $targetStore; $target; $config)
					
				Else 
					
					$config.report($targetIn; "Dependency '"+$oneDependency+"' not found."; "error")
					$ok:=False:C215
					
				End if 
			End for each 
		End if 
		
		$targetIn.dependenciesState:="done"
		
		If ($ok)
			
			If ($targetIn.toBuild=Null:C1517)  // If specified False, do not build
				
				$targetIn.toBuild:=True:C214
				
			End if 
			
			$targetIn.components:=$components
			$buildOrder.push($targetIn)
			
		End if 
		
		//________________________________________
	: (String:C10($targetIn.dependenciesState)="during")
		
		$config.report($targetIn; "Cyclic dependencies."; "error")
		$ok:=False:C215
		
		//________________________________________
	: (String:C10($targetIn.dependenciesState)="done")
		
		//________________________________________
End case 

return $ok