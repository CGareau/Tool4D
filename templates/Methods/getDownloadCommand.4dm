//%attributes = {}
// Builds the curl command used to download a 4D archive (Server, Volume Desktop, 4D).
//
// Three sources, chosen with environment variables (no credential is stored in this project):
//  1. TOOL4D_DOWNLOAD_REPO ("owner/repository"): the archive is an asset of the GitHub Release
//       <tag> of that repository, tag = 21R4-100203 (R) or 21-100624 (LTS), asset = <os>_<zip>
//     (e.g. win_4D_Server.zip). Public repository: direct download, nothing else needed.
//     TOOL4D_GITHUB_TOKEN (only for a private repository) is sent as "Authorization: Bearer"
//     and the asset is looked up through the GitHub API.
//  2. TOOL4D_DOWNLOAD_BASE (URL): same layout on any HTTP server: <base>/<tag>/<asset>.
//  3. otherwise product-download.4d.com, which requires TOOL4D_TOKEN
//     (an API key delivered by 4D, appended as ?token=...).
// The returned command always fails (non zero exit code) when the archive cannot be found.
#DECLARE($path : Text; $version : Text; $branch : Text; $build : Integer; $os : Text; $zip : Text; $major : Text; $release : Text)->$cmd : Text

var $repo; $base; $token; $ghToken; $tag; $asset; $url; $apiUrl : Text
var $headers; $options; $item : Object
var $request : 4D.HTTPRequest
var $found : Collection
var $assetId : Real

$repo:=getEnvVariable("TOOL4D_DOWNLOAD_REPO")
$base:=getEnvVariable("TOOL4D_DOWNLOAD_BASE")
$tag:=$major+(($release="0") ? "" : ("R"+$release))+"-"+String($build)
$asset:=$os+"_"+Replace string($zip; "%20"; "_")
$ghToken:=getEnvVariable("TOOL4D_GITHUB_TOKEN")

Case of 
	: (($repo#"") && ($ghToken=""))
		// Public repository: direct download of the Release asset. No API call, so no rate limit.
		$cmd:="curl -fL -o \""+$path+"\" \"https://github.com/"+$repo+"/releases/download/"+$tag+"/"+$asset+"\""
		
	: ($repo#"")
		// With a token (private repository): through the GitHub API
		$apiUrl:="https://api.github.com/repos/"+$repo+"/releases"
		$headers:=New object("Accept"; "application/vnd.github+json"; "User-Agent"; "Build_Application")
		If ($ghToken#"")
			$headers.Authorization:="Bearer "+$ghToken
		End if 
		$options:=New object("method"; "GET"; "headers"; $headers; "dataType"; "auto"; "timeout"; 30)
		$request:=4D.HTTPRequest.new($apiUrl+"/tags/"+$tag; $options)
		$request.wait()
		
		$assetId:=0
		If (($request.errors.length=0) && ($request.response.status=200) && (Value type($request.response.body)=Is object))
			$found:=$request.response.body.assets.query("name = :1"; $asset)
			If ($found.length>0)
				$assetId:=$found[0].id
			End if 
		End if 
		
		If ($assetId>0)
			$cmd:="curl -fL "
			If ($ghToken#"")
				$cmd:=$cmd+"-H \"Authorization: Bearer "+$ghToken+"\" "
			End if 
			$cmd:=$cmd+"-H \"Accept: application/octet-stream\" -o \""+$path+"\" \""+$apiUrl+"/assets/"+String($assetId)+"\""
		Else 
			LOG EVENT(Into system standard outputs; "***ERROR*** Asset "+$asset+" not found in release "+$tag+" of "+$repo+" (GitHub API answered "+(($request.response#Null) ? String($request.response.status) : "nothing")+")\n")
			// 404 on purpose: the caller reports "Download failed"
			$cmd:="curl -fsS -o \""+$path+"\" \""+$apiUrl+"/tags/"+$tag+"/missing/"+$asset+"\""
		End if 
		
	: ($base#"")
		While ($base="@/")
			$base:=Substring($base; 1; Length($base)-1)
		End while 
		$cmd:="curl -fL "
		If ($ghToken#"")
			$cmd:=$cmd+"-H \"Authorization: Bearer "+$ghToken+"\" "
		End if 
		$cmd:=$cmd+"-o \""+$path+"\" \""+$base+"/"+$tag+"/"+$asset+"\""
		
	Else 
		$token:=getEnvVariable("TOOL4D_TOKEN")
		$url:="https://product-download.4d.com/release/"+$version+"/"+$branch+"/"+String($build)+"/"+$os+"/"+$zip
		If ($token#"")
			$url:=$url+"?token="+$token
		End if 
		$cmd:="curl -fL -o \""+$path+"\" \""+$url+"\""
End case 
