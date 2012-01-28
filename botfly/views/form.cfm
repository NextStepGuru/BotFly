<cfscript>
	fields = getMetaData(rc.data)['properties'];
	myFields = structNew();
	for(var i=1;i<=arrayLen(fields);i++){
		if(listFindNoCase(rc.formData.fields,fields[i]['name'])){
			temp 			= structNew();
			temp.id			= fields[i]['formfieldname'] & 'Input';
			temp.name 		= fields[i]['formfieldname'];
			if(structKeyExists(rc.formData,'notrequired') && listFindNoCase(rc.formData['notrequired'],fields[i]['formfieldname'])){
				temp.required 	= false;
			}else{
				temp.required 	= (structKeyExists(fields[i],'required') && fields[i]['required'] ? true : false);
			}
			temp.class		= "validate[" & (temp.required ? 'required' : '') & "]";
			temp.value 		= evaluate("rc.data.get#fields[i]['name']#()");
			temp.title 		= fields[i]['formfieldtitle'];
			temp.type		= (findNoCase('password',fields[i]['formfieldname']) ? "password" : "text");
			temp.maxlength	= (structKeyExists(fields[i],'length') ? fields[i]['length'] : 0);

			myFields[fields[i]['name']] = temp;
		}
	}
</cfscript>
<cfoutput>
	<form action="#rc.formData['url']#" method="post" id="#rc.formData['name']#">
		<fieldset>
			<legend>#rc.formData['title']#</legend>
			<cfloop index="i" list="#rc.formData.fields#">
				<label for="#myFields[i]['name']#">
					<span class="labelTitle">#myFields[i]['title']#:<cfif myFields[i]['required']><span class="required">*</span><cfelse><span class="required">&nbsp;</span></cfif></span>
					<input name="#myFields[i]['name']#" type="#myFields[i]['type']#" id="#myFields[i]['id']#" class="#myFields[i]['class']#" value="<cftry>#myFields[i]['value']#<cfcatch type="any"></cfcatch></cftry>" <cfif myFields[i]['maxlength'] gt 0>maxlength="#myFields[i]['maxlength']#"</cfif>>
				</label>
			</cfloop>
			<label for="submit">
				<span class="labelTitle">&nbsp;</span>
				<input type="submit" name="submit" value="#rc.formData['saveButton']#" class="standard-button">
			</label>
		</fieldset>
	</form>
	<script type="text/javascript">
		$(document).ready(function(){
			$("###rc.formData['name']#").validationEngine('attach',{'promptPosition':<cfif rc.device.isMobileAgent>'topLeft'<cfelse>'centerRight'</cfif>});
		});
	</script>
</cfoutput>
