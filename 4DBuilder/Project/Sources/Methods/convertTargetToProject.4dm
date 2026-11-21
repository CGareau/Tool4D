//%attributes = {"invisible":true}
#DECLARE($config : Object; $target : Object) : Boolean

var $indexFile; $result; $settings : Object

If ($target.outputStructure.extension=".4db")
	
	$settings:=New object:C1471
	
	$settings.makeProject:=True:C214  // Undocumented
	$settings.structurePath:=$target.outputStructure.platformPath  // Undocumented
	
	$settings.withLog:=False:C215
	$settings.filter:=New object:C1471
	$settings.filter.projectMethods:=True:C214
	$settings.filter.databaseMethods:=True:C214
	$settings.filter.triggerMethods:=True:C214
	$settings.filter.forms:=True:C214
	$settings.filter.catalog:=True:C214
	$settings.filter.folders:=True:C214
	$settings.filter.settings:=True:C214
	$settings.filter.menus:=True:C214
	$settings.filter.tips:=True:C214
	$settings.filter.lists:=True:C214
	$settings.filter.filters:=True:C214
	$settings.filter.pictures:=True:C214
	
	$config.report($target; "Converting 4db "+$target.outputStructure.platformPath; "info")
	
	$result:=Export structure file:C1565($target.outputStructure.platformPath; $settings)
	
	$result.success:=True:C214  // Temp
	
	If ($result.success)
		
		// Delete .4DB
		$target.outputStructure.delete()
		
		// Delete .4DIndy
		$indexFile:=$target.outputStructure.parent.file($target.outputStructure.name+".4DIndy")
		$indexFile.delete()
		
		// The structure file is now the project file
		$target.outputStructure:=findStructureFile($target.outputFolder)
		ASSERT:C1129($target.outputStructure.extension=".4DProject")
		
	Else 
		
		$config.report($target; "failed to convert 4db "+$target.outputStructure.platformPath; "error")
		
	End if 
	
	return $result.success
	
Else 
	
	return True:C214
	
End if 