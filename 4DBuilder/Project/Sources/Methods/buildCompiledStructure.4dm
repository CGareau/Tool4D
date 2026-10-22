//%attributes = {"invisible":true}
#DECLARE($config : Object; $target : Object) : Boolean

Case of 
		
		//________________________________________
	: ($target.outputStructure.extension=".4dproject")
		
		return zipProject($config; $target)
		
		//________________________________________
	: ($target.outputStructure.extension=".4db")
		
		// should do a .4dc
		$config.report($target; "Building a .4DC is not implemented"; "error")
		return False:C215
		
		//________________________________________
	Else 
		
		$config.report($target; "Unknown output structure extension"; "error")
		return False:C215
		
		//________________________________________
End case 