//%attributes = {}
// True if the Release asset can be downloaded without any credential (public repository):
// the direct download URL answers with a redirection (3xx) instead of 404.
#DECLARE($repo : Text; $tag : Text; $asset : Text)->$isPublic : Boolean

var $options : Object
var $request : 4D.HTTPRequest

$isPublic:=False

$options:=New object("method"; "HEAD"; "automaticRedirections"; False; "timeout"; 20)
$request:=4D.HTTPRequest.new("https://github.com/"+$repo+"/releases/download/"+$tag+"/"+$asset; $options)
$request.wait()

If (($request.errors.length=0) && ($request.response#Null))
	$isPublic:=(($request.response.status>=300) && ($request.response.status<400))
End if 
