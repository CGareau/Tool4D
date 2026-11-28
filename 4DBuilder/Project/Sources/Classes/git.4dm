property exe : Text
property target : Object
property config : Object

/*
Wrapper to git commands on specific target
*/
Class constructor($target : Object; $config : Object)
	If (Is Windows:C1573)
		This:C1470.exe:="git.exe"
	Else 
		This:C1470.exe:="git"
	End if 
	This:C1470.target:=$target
	This:C1470.config:=$config
	
	// Report using config reporter, a standard git result
Function report($result : Object)
	If (Length:C16(String:C10($result.out))>0)
		This:C1470.config.report(This:C1470.target; $result.out; "info")
	End if 
	If (Length:C16(String:C10($result.err))>0)
		This:C1470.config.report(This:C1470.target; $result.err; "info"/*git log into error some info*/)
	End if 
	
Function _pathQuote($path : Text)->$result : Text
	If (Is Windows:C1573)
		$result:="\""+$path+"\""
	Else 
		$result:="'"+$path+"'"
	End if 
	
	// MARK:- configuration
	
	// Where to make git command
Function get into->$folder : 4D:C1709.Folder
	$folder:=This:C1470.target.source
	
Function get intoPathQuoted->$result : Text
	$result:=This:C1470._pathQuote(This:C1470.target.source.path)
	
Function get intoRelative->$path : Text
	$path:=Replace string:C233(This:C1470.target.source.path; This:C1470.parentFolder.path; "")
	
Function get intoRelativePathQuoted->$result : Text
	$result:=This:C1470._pathQuote(This:C1470.intoRelative)
	
	// The wanted origin url
Function get url->$url : Text
	// CLEAN: if not valid url set empty?
	$url:=This:C1470.target.gitURL
	
	// Get the wanted branch for target
Function get branch->$branch : Text
	$branch:=This:C1470.target.branch  // a target force it (useful to test a branch feature)
	If (Length:C16($branch)=0)
		$branch:=This:C1470.config.branch  // global configuration
		If (Length:C16($branch)=0)
			// if nothing defined, try to do the best
			If (Not:C34(This:C1470.isInGit))
				$branch:=This:C1470.config.makeFile.parent.parent.name  // <branch>/4DComponents/make.json
				// XXX will not work if moved or other make file, could do a loop to find specific <branch>/file
			Else 
				$branch:=This:C1470.currentBranch
				If (Length:C16($branch)=0)
					$branch:=This:C1470.parentCurrentBranch
				End if 
				If (Position:C15("/"; $branch)>0)  // we are in feature/xxx or fix/xxx (4D dev must respect that or pass the branch as parameter)
					$branch:="main"
				End if 
			End if 
		End if 
	End if 
	// TODO cache it ?(if cache, need reset if change
	
Function remotes($verbose : Boolean)->$remotes : Collection
	This:C1470._setEnv()
	var $result : Object
	If ($verbose)
		$result:=This:C1470.lep("remote -v")
	Else 
		$result:=This:C1470.lep("remote")
	End if 
	$remotes:=Split string:C1554($result.out; "\n").filter(Formula:C1597(Length:C16($1.value)>0))
	
	If ($verbose)
		$remotes:=$remotes.map(Formula:C1597(Split string:C1554($1.value; "\t"))).map(Formula:C1597(New object:C1471("name"; $1.value[0]; "url"; $1.value[1])))
	End if 
	
	// MARK:- commands
	
Function checkout($branch : Text)->$result : Object
	This:C1470._setEnv()
	If (Length:C16($branch)=0)
		$branch:=This:C1470.branch
	End if 
	
	This:C1470._setEnv()
	If (Not:C34(Position:C15("fatal:"; This:C1470.lep("rev-parse --verify "+$branch).out)=1))  // branch exists?
		This:C1470._setEnv()
		$result:=This:C1470.lep("checkout -b "+This:C1470._pathQuote($branch)+" "+This:C1470._pathQuote(This:C1470.origin+"/"+$branch))
	End if 
	
	This:C1470.config.report(Null:C1517; "Checkout branch "+$branch+"' into '"+This:C1470.into.path+"'"; "info")
	This:C1470._setEnv()
	$result:=This:C1470.lep("checkout -b "+This:C1470._pathQuote($branch))
	
Function rebase($branch : Text)->$result : Object
	If (This:C1470.isBadBranch)
		This:C1470.checkout()
	End if 
	
	This:C1470.config.report(Null:C1517; "Rebasing "+This:C1470.url+"' source into '"+This:C1470.into.path+"'"; "info")
	This:C1470._setEnv()
	$result:=This:C1470.lep("rebase "+$branch)
	
Function submoduleUpdate($merge : Boolean)->$result : Object
	This:C1470._setParentEnv()
	If (Bool:C1537($merge))
		$result:=This:C1470.lep("submodule update --remote --merge "+This:C1470.intoRelativePathQuoted)
	Else 
		$result:=This:C1470.lep("submodule update --remote "+This:C1470.intoRelativePathQuoted)
	End if 
	
Function submoduleInit()->$result : Object
	This:C1470._setParentEnv()
	$result:=This:C1470.lep("submodule update --init "+This:C1470.intoRelativePathQuoted)
	
Function submoduleAdd()->$result : Object
	This:C1470.config.report(Null:C1517; "Cloning "+This:C1470.url+"' source as submodule into '"+This:C1470.into.path+"'"; "info")
	
	var $cmd : Text
	$cmd:="submodule -q add -b "+This:C1470._pathQuote(This:C1470.branch)+" "+This:C1470._pathQuote(This:C1470.url)+" "+This:C1470._pathQuote(This:C1470.into.path)
	
	This:C1470._setParentEnv()
	$result:=This:C1470.lep($cmd)  // TODO: test if relative path to git root is needed or not
	
Function add()->$result : Object
	This:C1470._setParentEnv()
	$result:=This:C1470.lep("add "+This:C1470.intoRelativePathQuoted)
	
Function clone()->$result : Object
	This:C1470.config.report(Null:C1517; "Cloning "+This:C1470.url+"' source into '"+This:C1470.into.path+"'"; "info")
	$result:=This:C1470.lep("clone -q "+This:C1470._pathQuote(This:C1470.url)+" -b "+This:C1470._pathQuote(This:C1470.branch)+" "+This:C1470._pathQuote(This:C1470.into.path))
	
Function remoteAdd($name : Text; $url : Text)->$result : Object
	This:C1470._setEnv()
	$result:=This:C1470.lep("remote add "+$name+" "+$url)
	
Function revision($short : Boolean) : Text
	This:C1470._setEnv()
	return Replace string:C233(This:C1470.lep(Bool:C1537($short) ? "rev-parse --short HEAD" : "rev-parse HEAD").out; "\n"; "")
	
	// MARK:- composed commands
	
Function rebaseOrSubmoduleUpdate()->$result : Object
/*If (This.isInGit)
$result:=This.submoduleUpdate()
Else */
	$result:=This:C1470.rebase()
/*End if */
	
Function cloneOrSubmoduleAdd()->$result : Object
	If (This:C1470.isInGit)
		$result:=This:C1470.submoduleAdd()
	Else 
		$result:=This:C1470.clone()
	End if 
	
	// MARK:- Git info
	
Function get isGit->$is : Boolean
	$is:=This:C1470.into.folder(".git").exists || This:C1470.isGitSubmodule
	
Function get isGitSubmodule->$is : Boolean
	$is:=This:C1470.into.file(".git").exists
	
	// alternative:
	// $is:=Position("fatal:"; This.status().err)=0 // check if working with not english, better is to receive process status code
	
Function get originURL->$url : Text
	This:C1470._setEnv()
	$url:=Replace string:C233(This:C1470.lep("config --get remote."+This:C1470.origin+".url").out; "\n"; "")
	
Function get origin->$origin : Text
	$origin:="origin"  // see if we want to support other name
	
Function get currentBranch->$branch : Text
	This:C1470._setEnv()
	$branch:=Replace string:C233(This:C1470.lep("rev-parse --abbrev-ref HEAD").out; "\n"; "")
	
	
Function get isBadBranch->$rots : Boolean
	$rots:=This:C1470.branch#This:C1470.parentCurrentBranch
	
Function status()->$result : Object
	This:C1470._setEnv()
	$result:=This:C1470.lep("status -s")
	
	// MARK:- parent git
	
Function get isInGit->$is : Boolean
	$is:=False:C215
	var $folder : 4D:C1709.Folder
	$folder:=This:C1470.into.parent
	While ($folder#Null:C1517 & Not:C34($is))
		$is:=$folder.folder(".git").exists
		$folder:=$folder.parent
	End while 
	
Function get parentCurrentBranch->$branch : Text
	SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_CURRENT_DIRECTORY"; This:C1470.into.parent.platformPath)
	$branch:=Replace string:C233(This:C1470.lep("rev-parse --abbrev-ref HEAD").out; "\n"; "")
	
Function get parentFolder->$folder : 4D:C1709.Folder
	var $is : Boolean
	$is:=False:C215
	
	$folder:=This:C1470.into.parent
	$is:=$folder.folder(".git").exists
	While ($folder#Null:C1517 & Not:C34($is))
		$folder:=$folder.parent
		If ($folder#Null:C1517)
			$is:=$folder.folder(".git").exists
		Else 
			$is:=False:C215
		End if 
	End while 
	
	// $is:=Position("fatal:"; This.parentStatus().err)=0  // check if work not english, better is to receive process status code
	
Function parentStatus()->$result : Object
	SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_CURRENT_DIRECTORY"; This:C1470.into.parent.platformPath)
	$result:=This:C1470.lep("status -s")
	
	// MARK:- process
Function _setEnv
	SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_CURRENT_DIRECTORY"; This:C1470.into.platformPath)
	
Function _setParentEnv
	SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_CURRENT_DIRECTORY"; This:C1470.parentFolder.platformPath)
	
	// simple lep
Function lep($cmd)->$result : Object
	$result:=New object:C1471
	
	var $in; $out; $err : Text
	
	If (Bool:C1537(This:C1470.config.verbose))
		This:C1470.config.report(Null:C1517; "cmd:"+This:C1470.exe+" "+$cmd; "debug")
	End if 
	
	LAUNCH EXTERNAL PROCESS:C811(This:C1470.exe+" "+$cmd; $in; $out; $err)
	// XXX replace by synchrone system worker with process status code
	
	If (Bool:C1537(This:C1470.config.verbose))
		If (Length:C16($out)>0)
			This:C1470.config.report(Null:C1517; "stdout:"+$out; "debug")
		End if 
		If (Length:C16($err)>0)
			This:C1470.config.report(Null:C1517; "stderr:"+$err; "debug")  // not log into error, could be simple info
		End if 
	End if 
	
	$result.out:=$out
	$result.err:=$err