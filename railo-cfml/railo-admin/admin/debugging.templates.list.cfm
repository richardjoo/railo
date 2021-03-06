

<cftry>
	<cfset stVeritfyMessages = StructNew()>
	<cfswitch expression="#form.mainAction#">
	<!--- UPDATE --->
		<cfcase value="#stText.Buttons.Update#">
			<cfadmin 
				action="updateDebug"
				type="#request.adminType#"
				password="#session["password"&request.adminType]#"
				debug="#form.debug#"
				debugTemplate=""
				remoteClients="#request.getRemoteClients()#">
			
		</cfcase>
	<!--- reset to server setting --->
		<cfcase value="#stText.Buttons.resetServerAdmin#">
			<cfadmin 
				action="updateDebug"
				type="#request.adminType#"
				password="#session["password"&request.adminType]#"
				
                debug=""
				debugTemplate=""
                
				remoteClients="#request.getRemoteClients()#">
			
		</cfcase>
    <!--- delete --->
		<cfcase value="#stText.Buttons.Delete#">
				<cfset data.rows=toArrayFromForm("row")>
				<cfset data.ids=toArrayFromForm("id")>
				<cfloop index="idx" from="1" to="#arrayLen(data.ids)#">
					<cfif isDefined("data.rows[#idx#]") and data.ids[idx] NEQ "">
						<cfadmin 
							action="removeDebugEntry"
							type="#request.adminType#"
							password="#session["password"&request.adminType]#"
							id="#data.ids[idx]#"
							remoteClients="#request.getRemoteClients()#">
						
					</cfif>
				</cfloop>
		</cfcase>
	</cfswitch>
	<cfcatch><cfrethrow>
		<cfset error.message=cfcatch.message>
		<cfset error.detail=cfcatch.Detail>
	</cfcatch>
</cftry>
<!--- 
Redirtect to entry --->
<cfif cgi.request_method EQ "POST" and error.message EQ "" and form.mainAction neq stText.Buttons.verify>
	<cflocation url="#request.self#?action=#url.action#" addtoken="no">
</cfif>

<cfset querySort(debug,"id")>
<cfset qryWeb=queryNew("id,label,iprange,type,custom,readonly,driver")>
<cfset qryServer=queryNew("id,label,iprange,type,custom,readonly,driver")>


<cfloop query="debug">	
	<cfif not debug.readOnly>
    	<cfset tmp=qryWeb>
	<cfelse>
    	<cfset tmp=qryServer>
	</cfif>
	<cfset QueryAddRow(tmp)>
    <cfset QuerySetCell(tmp,"id",debug.id)>
    <cfset QuerySetCell(tmp,"label",debug.label)>
    <cfset QuerySetCell(tmp,"iprange",debug.iprange)>
    <cfset QuerySetCell(tmp,"type",debug.type)>
    <cfset QuerySetCell(tmp,"custom",debug.custom)>
    <cfset QuerySetCell(tmp,"readonly",debug.readonly)>
    <cfif structKeyExists(drivers,debug.type)><cfset QuerySetCell(tmp,"driver",drivers[debug.type])></cfif>
</cfloop>

<cfoutput>
	<!--- Error Output--->
	<cfset printError(error)>
	<script type="text/javascript">
		var drivers={};
		<cfloop collection="#drivers#" item="key">drivers['#JSStringFormat(key)#']='#JSStringFormat(drivers[key].getDescription())#';
		</cfloop>
		function setDesc(id,key){
			var div = document.getElementById(id);
			if(div.hasChildNodes())
				div.removeChild(div.firstChild);
			div.appendChild(document.createTextNode(drivers[key]));
		}
	</script>
	
	<cfform onerror="customError" action="#request.self#?action=#url.action#" method="post" name="debug_settings">
		<table class="maintbl">
			<tbody>
				<tr>
					<th scope="row">#stText.Debug.EnableDebugging#</th>
					<td>
						<cfset lbl=iif(_debug.debug,de(stText.general.yes),de(stText.general.no))>
						<cfif hasAccess>
							<select name="debug">
								<cfif request.admintype EQ "web">
									<option #iif(_debug.debugsrc EQ "server",de('selected'),de(''))# value="">#stText.Regional.ServerProp[request.adminType]# <cfif _debug.debugsrc EQ "server">(#lbl#) </cfif></option>
									<option #iif(_debug.debugsrc EQ "web" and _debug.debug,de('selected'),de(''))# value="true">#stText.general.yes#</option>
									<option #iif(_debug.debugsrc EQ "web" and not _debug.debug,de('selected'),de(''))# value="false">#stText.general.no#</option>
								<cfelse>
									<option #iif(_debug.debug,de('selected'),de(''))# value="true">#stText.general.yes#</option>
									<option #iif(_debug.debug,de(''),de('selected'))# value="false">#stText.general.no#</option>
								</cfif>
							</select>
							<!--- <input type="checkbox" class="checkbox" name="debug" value="yes" <cfif debug.debug>checked</cfif>>--->
						<cfelse>
							<b>#lbl#</b>
							<input type="hidden" name="debug" value="#_debug.debug#">
						</cfif>
						<div class="comment">#stText.Debug.EnableDescription#</div>
					</td>
				</tr>
				<cfif hasAccess>
					<cfmodule template="remoteclients.cfm" colspan="2">
				</cfif>
			</tbody>
			<cfif hasAccess>
				<tfoot>
					<tr>
						<td colspan="2">
							<input type="submit" class="button submit" name="mainAction" value="#stText.Buttons.Update#">
							<input type="reset" class="reset" name="cancel" value="#stText.Buttons.Cancel#">
							<cfif request.adminType EQ "web">
								<input class="button submit" type="submit" name="mainAction" value="#stText.Buttons.resetServerAdmin#">
							</cfif>
						</td>
					</tr>
				</tfoot>
			</cfif>
		</table>
	</cfform>

	<!--- LIST --->
	<cfloop list="server,web" index="k">
		<cfset isWeb=k EQ "web">
		<cfset qry=variables["qry"&k]>
		<cfif qry.recordcount>
			<h2>#stText.debug.list[k & "title"]#</h2>
			<div class="itemintro">#stText.debug.list[k & "titleDesc"]#</div>
			<cfform onerror="customError" action="#request.self#?action=#url.action#" method="post">
				<table class="maintbl">
					<thead>
						<tr>
							<cfif isWeb>
								<th width="3%">
									<input type="checkbox" class="checkbox" name="rowreadonly" onclick="selectAll(this)">
								</th>
							</cfif>
							<th width="25%">#stText.debug.label#</th>
							<th>#stText.debug.ipRange#</th>
							<th width="15%"># stText.debug.type#</td>
							<cfif isWeb>
								<th width="3%"></th>
							</cfif>
						</tr>
					</thead>
					<tbody>
						<cfloop query="qry">
							<cfif IsSimpleValue(qry.driver)>
								<cfcontinue>
							</cfif>
							<tr>
								<cfif isWeb>
									<td>
										<input type="checkbox" class="checkbox" name="row_#qry.currentrow#" value="#qry.currentrow#">
									</td>
								</cfif>
								<td>
									<input type="hidden" name="id_#qry.currentrow#" value="#qry.id#">
									<input type="hidden" name="type_#qry.currentrow#" value="#qry.type#">
									#qry.label#
								</td>
								<td>#replace(qry.ipRange,",","<br />","all")#</td>
								<td>#qry.driver.getLabel()#</td>
								<cfif isWeb>
									<td>
										<a href="#request.self#?action=#url.action#&action2=create&id=#qry.id#" class="btn-mini edit"><span>edit</span></a>
									</td>
								</cfif>
							</tr>
						</cfloop>
					</tbody>
					<cfif isWeb>
						<tfoot>
							<tr>
								<td colspan="#isWeb?5:3#">
									<input type="submit" class="button submit" name="mainAction" value="#stText.Buttons.delete#">
									<input type="reset" class="reset" name="cancel" value="#stText.Buttons.Cancel#">
								</td>	
							</tr>
						</tfoot>
					</cfif>
				</table>
			</cfform>
		</cfif>
	</cfloop>

	<!--- Create debug entry --->
	<cfif access EQ "yes">
		<cfset _drivers=ListSort(StructKeyList(drivers),'textnocase')>
	
		<cfif listLen(_drivers)>
			<h2>#stText.debug.titleCreate#</h2>
			<cfform onerror="customError" action="#request.self#?action=#url.action#&action2=create" method="post">
				<table class="maintbl autowidth" style="width:400px;">
					<tbody>
						<tr>
							<th scope="row">#stText.debug.label#</th>
							<td><cfinput type="text" name="label" value="" class="large" required="yes" 
								message="#stText.debug.labelMissing#"></td>
						</tr>
						<tr>
							<th scope="row">#stText.Settings.gateway.type#</th>
							<td>
								<select name="type" onchange="setDesc('typeDesc',this.value);" class="large">
									<cfloop list="#_drivers#" index="key">
									<cfset driver=drivers[key]>
										<option value="#trim(driver.getId())#">#trim(driver.getLabel())#</option>
									</cfloop>
								</select>
								<div id="typeDesc" style="position:relative"></div>
								<script>setDesc('typeDesc','#JSStringFormat(listFirst(_drivers))#');</script>
							</td>
						</tr>
					</tbody>
					<tfoot>
						<tr>
							<td colspan="2">
								<input type="submit" class="button submit" name="run" value="#stText.Buttons.create#">
								<input type="reset" class="reset" name="cancel" value="#stText.Buttons.Cancel#">
							</td>
						</tr>
					</tfoot>
				</table>   
			</cfform>
		<cfelse>
			#stText.debug.noDriver#
		</cfif>
	<cfelse>
		<cfset noAccess(stText.debug.noAccess)>
	</cfif>
</cfoutput>