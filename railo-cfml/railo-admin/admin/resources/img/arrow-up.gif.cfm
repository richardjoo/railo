<cfset c='R0lGODlhBwAEAJECAL29vb6+vv///wAAACH5BAEAAAIALAAAAAAHAAQAAAIKlGMJgbcBBIOzAAA7'><cfif getBaseTemplatePath() EQ getCurrentTemplatePath()><!---
	
	---><cfsilent>
	<cfapplication name="HTTPCaching" sessionmanagement="no" clientmanagement="no" applicationtimeout="#createtimespan(1,0,0,0)#" />
	<cfif not structKeyExists(application, "oHTTPCaching")>
		<cfset application.oHTTPCaching = createObject("component", "../HTTPCaching") />
	</cfif>
	
	<!--- the string to be used as an Etag - in the response header --->
	<cfset etag = "0AF89AEDB157E5948B396A5A8DC29BB0" />
	<cfset mimetype = "image/gif" />
	
	<!--- check if the content was cached on the browser, and set the ETag header. --->
	<cfif application.oHTTPCaching.handleResponseWhenCached(fileEtag=etag, mimetype=mimetype, expireDays=100)>
		<cfexit method="exittemplate" />
	</cfif>
</cfsilent>

<!--- file was not cached; send the data --->
<cfcontent reset="yes" type="#mimetype#"
	variable="#toBinary(c)#" />
<cfelse>data:image/image/gif;base64,<cfoutput>#c#</cfoutput></cfif>
	
