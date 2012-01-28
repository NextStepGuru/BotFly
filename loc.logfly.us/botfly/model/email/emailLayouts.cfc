component  hint="EmailAppender Format Layout Model" output="false" extends="coldbox.system.logging.Layout"
{
	public  function format(required coldbox.system.logging.LogEvent logEvent){
		var messageArray = listToArray(logEvent.getMessage(),chr(10));
		var data = "<style type='text/css'>" & fileRead("/coldbox/system/includes/css/cbox-debugger.pack.css") & "</style>";
		data = data & '<table border="0" cellpadding="0" cellspacing="3" class="fw_errorTables" align="center">';

		data = data & '<tr>' & '<th colspan=2><b>Stack Trace:</b></th>' & '</tr>';

		data = data & '<tr><td colspan="2" style="font-size:10pt;">';

		var templateError = listToArray(replace(messageArray[arrayLen(messageArray)],'??;','??;|','ALL'),'|');
		data = data & templateError[1] & '<br>';
		for(var i=2;i<=arrayLen(templateError);i++){
			data = data & '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' & templateError[i] & '<br>';
		}
		data = data & '</td></tr>';

		data = data & '<tr><td colspan="2" style="font-size:12pt;">' & messageArray[1];
		for(var i=2;i<arrayLen(messageArray);i++){
			data = data & '<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' & messageArray[i];
		}
		data = data & '</td></tr>';

		data = data & '<tr>' & '<th colspan=2><b>Debug Info:</b></th>' & '</tr>';

		data = data & '<tr><td align=right valign=top class="fw_errorTablesTitles"><b>Timestamp:</td><td>#now()#</td></tr>';

		data = data & '<tr><td align=right valign=top class="fw_errorTablesTitles"><b>Host:</td><td>#cgi.http_host#</td></tr>';

		if(isObject(arguments.logEvent.getExtraInfo()) && isArray(arguments.logEvent.getExtraInfo().getTagContext())){

			data = data & '<tr>' & '<th colspan=2><b>Tag Context:</b></th>' & '</tr>';

			for(var i=1;i<=arrayLen(arguments.logEvent.getExtraInfo().getTagContext());i++)
			{
				data = data & '<tr>';
					data = data & '<td align=right valign=top class="fw_errorTablesTitles"><b>Line:</b></td><td>' & arguments.logEvent.getExtraInfo().getTagContext()[1]['codePrintHTML'] & '</td>';
				data = data & '</tr><tr>';
					data = data & '<td align=right valign=top class="fw_errorTablesTitles"><b>Column:</b></td><td>' & arguments.logEvent.getExtraInfo().getTagContext()[1]['column'] & '</td>';
				data = data & '</tr><tr>';
					data = data & '<td align=right valign=top class="fw_errorTablesTitles"><b>ID:</b></td><td>' & arguments.logEvent.getExtraInfo().getTagContext()[1]['id'] & '</td>';
				data = data & '</tr><tr>';
					data = data & '<td align=right valign=top class="fw_errorTablesTitles"><b>Line:</b></td><td>' & arguments.logEvent.getExtraInfo().getTagContext()[1]['line'] & '</td>';
				data = data & '</tr><tr class="fw_errorTablesBreak">';
					data = data & '<td align=right valign=top class="fw_errorTablesTitles"><b>Template:</b></td><td>' & arguments.logEvent.getExtraInfo().getTagContext()[1]['template'] & '</td>';
				data = data & '</tr>';
			}
		}

		var scopes=['url','cgi','form','server','session'];
		for(var b=1;b<=arrayLen(scopes);b++){
			try{

				if(isStruct(evaluate(scopes[b])) && listLen(structKeyList(evaluate(scopes[b]))) gt 1){
					var myObj = evaluate(scopes[b]);
					var myList = structKeyList(myObj);
					data = data & '<tr>' & '<th colspan=2><b>#scopes[b]#:</b></th>' & '</tr>';

					for(var i=1;i<=listLen(myList);i++)
					{
						if(!isStruct(myObj[listGetAt(myList,i)]) && len(myObj[listGetAt(myList,i)]) gt 0){
							data = data & '<tr>';
								data = data & '<td align=right valign=top class="fw_errorTablesTitles"><b>#ListGetAt(myList,i)#:</b></td><td>' & myObj[listGetAt(myList,i)] & '</td>';
							data = data & '</tr>';
						}else if(!isStruct(myObj[listGetAt(myList,i)]) && len(myObj[listGetAt(myList,i)]) eq 0){
							//
						}else{
							data = data & '<tr>';
								data = data & '<td align=right valign=top class="fw_errorTablesTitles"><b>#ListGetAt(myList,i)#:</b></td><td>' & serializeJSON(myObj[listGetAt(myList,i)]) & '</td>';
							data = data & '</tr>';
						}
					}
				}
			}catch(any e){
			}
		}


		if(isObject(arguments.logEvent.getExtraInfo())){

			data = data & '<tr>' & '<th colspan=2><b>Stack Trace:</b></th>' & '</tr>';

			data = data & '<tr class="fw_errorTablesBreak"><td align="right" valign="top" class="fw_errorTablesTitles"><b>Stack Trace</b></td><td>' & replace(arguments.logEvent.getExtraInfo().getStackTrace(),chr(10),'<br>&nbsp;&nbsp;&nbsp;','all') & "</td></tr>";

			data = data & '</table>';
		}

		return data;
	}

}
