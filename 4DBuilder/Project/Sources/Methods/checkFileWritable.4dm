//%attributes = {"invisible":true}
#DECLARE($file : Object)

If (($file=Null:C1517) || (Not:C34($file.exists)) || ($file.isWritable))
	return 
End if 

If (Is Windows:C1573)
	
	SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_HIDE_CONSOLE"; "true")
	LAUNCH EXTERNAL PROCESS:C811("attrib.exe -R \""+$file.path+"\"")
	
Else 
	
	LAUNCH EXTERNAL PROCESS:C811("chmod u+rwX '"+$file.path+"'")
	
End if 