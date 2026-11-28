


Class constructor($serverSettings : Object; $macSettings : Object; $winSettings : Object)
	
	
	This:C1470._server:=cs:C1710.Build4D.Server.new($serverSettings)
	
	$serverSettings:=This:C1470._server.settings
	
	If ($macSettings#Null:C1517)
		
		If ($serverSettings.signApplication#Null:C1517)
			$macSettings.signApplication:=OB Copy:C1225($serverSettings.signApplication)
		End if 
		
		$macSettings.destinationFolder:=$serverSettings.destinationFolder.parent.path+"Client/mac/"
		
		$macSettings.hardLink:=$serverSettings.hardLink
		
		$macSettings.buildName:=This:C1470._server.buildName
		
		$macSettings.publishName:=This:C1470._server.publishName
		
		If (Value type:C1509($serverSettings.IPAddress)=Is text:K8:3) && ($serverSettings.IPAddress#"")
			
			$macSettings.IPAddress:=$serverSettings.IPAddress
			
		End if 
		
		If (Value type:C1509($serverSettings.portNumber)=Is real:K8:4) && ($serverSettings.portNumber>0) && ($serverSettings.portNumber<32768)
			
			$macSettings.portNumber:=$serverSettings.portNumber
			
		End if 
		
		$macSettings.obfuscated:=($serverSettings.obfuscated=Null:C1517) ? Null:C1517 : $serverSettings.obfuscated
		$macSettings.useSDI:=($serverSettings.useSDI=Null:C1517) ? Null:C1517 : $serverSettings.useSDI
		
		This:C1470._mac:=cs:C1710.Build4D.Client.new($macSettings)
		
	End if 
	
	If ($winSettings#Null:C1517)
		
		$winSettings.destinationFolder:=$serverSettings.destinationFolder.parent.path+"Client/win/"  // update 
		
		$winSettings.hardLink:=$serverSettings.hardLink
		
		$winSettings.buildName:=This:C1470._server.buildName
		
		$winSettings.publishName:=This:C1470._server.publishName
		
		If (Value type:C1509($serverSettings.IPAddress)=Is text:K8:3) && ($serverSettings.IPAddress#"")
			
			$winSettings.IPAddress:=$serverSettings.IPAddress
			
		End if 
		
		
		If (Value type:C1509($serverSettings.portNumber)=Is real:K8:4) && ($serverSettings.portNumber>0) && ($serverSettings.portNumber<32768)
			
			$winSettings.portNumber:=$serverSettings.portNumber
			
		End if 
		
		
		$winSettings.obfuscated:=($serverSettings.obfuscated=Null:C1517) ? Null:C1517 : $serverSettings.obfuscated
		$winSettings.useSDI:=($serverSettings.useSDI=Null:C1517) ? Null:C1517 : $serverSettings.useSDI
		
		This:C1470._win:=cs:C1710.Build4D.Client.new($winSettings)
		
	End if 
	
	
	
Function get valid : Boolean
	
	var $server_ok; $mac_ok; $win_ok : Boolean
	
	$server_ok:=This:C1470._server._validInstance
	$mac_ok:=(This:C1470._mac._validInstance=Null:C1517) ? True:C214 : This:C1470._mac._validInstance
	$win_ok:=(This:C1470._win._validInstance=Null:C1517) ? True:C214 : This:C1470._win._validInstance
	
	return $mac_ok & $win_ok & $server_ok
	
	//Function zip
	
	
	
	
Function get server_settings : Object
	return This:C1470._server.settings
	
	//MARK:-
	
	
Function buildZip()->$result : Object
	
	$result:={}
	
	If (This:C1470._server._validInstance)
		$result.server:=This:C1470._server.buildZip()
		
	End if 
	
	If (This:C1470._mac._validInstance)
		$result.mac:=This:C1470._mac.buildZip()
	End if 
	
	
	If (This:C1470._win._validInstance)
		$result.win:=This:C1470._win.buildZip()
	End if 
	
Function show() : cs:C1710.CS
	
	SHOW ON DISK:C922(This:C1470.server_settings.destinationFolder.parent.platformPath)
	
	return This:C1470
	
	
Function _build_mac : Boolean
	
	var $mac : Object
	
	If (This:C1470._mac#Null:C1517)
		
		If (This:C1470._mac.build())
			
			$mac:=This:C1470._mac.buildArchive()
			
			If ($mac.success)
				
				This:C1470.server_settings.macOSClientArchive:=$mac.archive
				
				return True:C214
			End if 
			
		End if 
		
	End if 
	
Function _build_win : Boolean
	
	var $win : Object
	If (This:C1470._win#Null:C1517)
		If (This:C1470._win.build())
			
			$win:=This:C1470._win.buildArchive()
			
			If ($win.success)
				
				This:C1470.server_settings.windowsClientArchive:=$win.archive
				return True:C214
			End if 
			
		End if 
	End if 
	
Function build() : Boolean
	
	var $abort : Boolean
	
	Case of 
			
		: (This:C1470._mac=Null:C1517)
			
		: (This:C1470._build_mac())
			
		Else 
			$abort:=True:C214
	End case 
	
	
	Case of 
			
		: ($abort)
			
		: (This:C1470._win=Null:C1517)
			
		: (This:C1470._build_win())
			
		Else 
			$abort:=True:C214
			
	End case 
	
	Case of 
			
		: ($abort)
			
		: (This:C1470._server=Null:C1517)
			
		: (This:C1470._server.build())
			
			return True:C214
			
	End case 
	
	
Function logs : Object
	
	return {\
		server: This:C1470._server.logs(); \
		mac: This:C1470._mac=Null:C1517 ? Null:C1517 : This:C1470._mac.logs(); \
		win: This:C1470._win=Null:C1517 ? Null:C1517 : This:C1470._win.logs()\
		}
	