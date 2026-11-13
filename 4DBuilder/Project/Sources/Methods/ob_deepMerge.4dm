//%attributes = {"invisible":true,"preemptive":"capable"}
// ----------------------------------------------------
// Project method : ob_deepMerge
// ----------------------------------------------------
// Description:
// Copy object properties from source to target
// ----------------------------------------------------
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// !!!!!!!!!!!!!!!!!! NOT FINALIZED !!!!!!!!!!!!!!!!!!!
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// ----------------------------------------------------
// Declarations
#DECLARE($Obj_target : Object; $Obj_source : Object) : Object

var $Lon_i; $Lon_parameters; $Lon_sourceType; $Lon_targetType : Integer

// ----------------------------------------------------
// Initialisations
$Lon_parameters:=Count parameters:C259

If (Asserted:C1132($Lon_parameters>=2; "Missing parameter"))
	
	If ($Obj_target=Null:C1517)
		
		$Obj_target:=New object:C1471
		
	End if 
	
Else 
	
	ABORT:C156
	
End if 

//TRACE

// ----------------------------------------------------
var $Txt_property : Text
For each ($Txt_property; $Obj_source)
	
	$Lon_sourceType:=Value type:C1509($Obj_source[$Txt_property])
	
	Case of 
			
			//________________________________________
		: ($Lon_sourceType=Is object:K8:27)
			
			If ($Obj_target[$Txt_property]=Null:C1517)
				
				$Obj_target[$Txt_property]:=OB Copy:C1225($Obj_source[$Txt_property])
				
			Else 
				
				If (Value type:C1509($Obj_target[$Txt_property])#Is object:K8:27)
					
					$Obj_target[$Txt_property]:=New object:C1471
					
				End if 
				
				$Obj_target[$Txt_property]:=ob_deepMerge(\
					$Obj_target[$Txt_property]; \
					OB Copy:C1225($Obj_source[$Txt_property]))
				
			End if 
			
			//________________________________________
		: ($Lon_sourceType=Is collection:K8:32)
			
			If ($Obj_target[$Txt_property]=Null:C1517)
				
				$Obj_target[$Txt_property]:=$Obj_source[$Txt_property].copy()
				
			Else 
				
				$Obj_target[$Txt_property]:=New collection:C1472.resize($Obj_source[$Txt_property].length)
				
				For ($Lon_i; 0; $Obj_source[$Txt_property].length-1; 1)
					
					$Lon_sourceType:=Value type:C1509($Obj_source[$Txt_property][$Lon_i])
					
					Case of 
							
							//______________________________________________________
						: ($Lon_sourceType=Is object:K8:27)
							
							$Lon_targetType:=Value type:C1509($Obj_target[$Txt_property][$Lon_i])
							
							Case of 
									
									//______________________________________________________
								: ($Obj_target[$Txt_property][$Lon_i]=Null:C1517)
									
									$Obj_target[$Txt_property][$Lon_i]:=OB Copy:C1225($Obj_source[$Txt_property][$Lon_i])
									
									//______________________________________________________
								: ($Lon_targetType=Is object:K8:27)
									
									$Obj_target[$Txt_property][$Lon_i]:=ob_deepMerge(\
										$Obj_target[$Txt_property][$Lon_i]; \
										OB Copy:C1225($Obj_source[$Txt_property][$Lon_i]))
									
									//______________________________________________________
								: ($Lon_targetType=Is collection:K8:32)
									
									If (Not:C34($Obj_target[$Txt_property][$Lon_i].equal($Obj_target[$Txt_property][$Lon_i]; ck diacritical:K85:3)))
										
										//#MARK_TODO
										
									End if 
									
									//______________________________________________________
								Else 
									
									$Obj_target[$Txt_property][$Lon_i]:=$Obj_source[$Txt_property][$Lon_i]
									
									//______________________________________________________
							End case 
							
							//______________________________________________________
						: ($Lon_sourceType=Is collection:K8:32)
							
							//#MARK_TODO
							
							//______________________________________________________
						Else 
							
							$Obj_target[$Txt_property]:=$Obj_source[$Txt_property]
							
							//______________________________________________________
					End case 
				End for 
			End if 
			
			//________________________________________
		Else 
			
			$Obj_target[$Txt_property]:=$Obj_source[$Txt_property]
			
			//________________________________________
	End case 
End for each 

// ----------------------------------------------------
return $Obj_target
