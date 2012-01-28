component output="false"{

	property name="logger"				inject="coldbox:plugin:logger";
	property name="log" 				inject="logbox:logger:{this}";
	property name="messageBox"			inject="coldbox:plugin:MessageBox";
	property name="validator"			inject="coldbox:plugin:Validator";

//******************************************* PUBLIC EVENTS *******************************************//

	public 	void 	function index(required any event,required any rc,required any prc){

		var tables = fetchTables();

		for(var i=1;i<=tables.recordCount;i++){
			var myTable = tables['table_name'][i];
			writeCFCDataToFile(buildQueryForFile(myTable),myTable);
		}

		arguments.event.noRender();
		setDebugMode(false);
	}

//******************************************** PRIVATE EVENTS *******************************************//

	private void	function writeCFCDataToFile(required query qryData,required string table){
		var qry = arguments.qryData;
		var myFile = expandPath('./') & 'model/' & listFirst(arguments.table,'_') & '/' & camelCase(arguments.table) & '.cfc';
		var groupTitles = "Primary Key,Fields,Relationships: One-to-One,Relationships: Many-to-One,Relationships: One-to-Many";

		fileWrite(myFile,"/**#chr(13)#* I am a '#arguments.table#' entity#chr(13)#**/#chr(13)#component persistent=""true"" table=""#arguments.table#"" {#chr(13)#");

		for(var l=0;l<=4;l++){
			var tmpQry = new query(sql="SELECT * FROM qry WHERE [$type] = #l#;",qry=qry,dbtype='query').execute().getResult();
			var cols = tmpQry.columnList;
			var colsStruct = structNew();
			var t = "";
			for(var c=1;c<=listLen(cols);c++){
				if(left(listGetAt(cols,c),1) neq "$"){
					colsStruct[listGetAt(cols,c)]=1;
					for(var r=1;r<=tmpQry.recordCount;r++){
						t = listGetAt(cols,c) & "=""" & tmpQry[listGetAt(cols,c)][r] & """";
						if(len(t) gt colsStruct[listGetAt(cols,c)]){
							colsStruct[listGetAt(cols,c)]=len(t);
						}
					}
				}
			}

			var total = 0;
			var charLength = arrayNew(1);

			file action="append" file=myFile output="#chr(13)#	//" & listGetAt(groupTitles,l+1);

			for(var i=1;i<=tmpQry.recordCount;i++){
				var line = "property ";
				for(var c=1;c<=listLen(tmpQry.columnList);c++){
					var fld = lcase(listGetAt(tmpQry.columnList,c));
					if(len(tmpQry[fld][i]) && fld neq '$type'){
						line = line & lJustify(fld & '="' & tmpQry[fld][i] & '" ',colsStruct[fld]+1);
					}
				}
				var line = trim(line) & ';';
				file action="append" file=myFile output="	" & line;
			}
		}
		file action="append" file=myFile output="#chr(13)#}#chr(13)#";
	}

	private query	function buildRelationships(required query qryData,required string table,required string datasource=fetchDatasource()){
		var qry = arguments.qryData;
		var allTables = new query(sql="SELECT * FROM d WHERE TABLE_NAME != '#arguments.table#';",d=fetchTables(arguments.datasource),dbtype='query').execute().getResult();

		var newFields = "name,type,fieldtype,cfc,fkcolumn,update,insert,lazy,missingrowignored,cascade";
		for(var b=1;b<=listLen(newFields);b++){
			if(!listFindNoCase(qry.columnList,listGetAt(newFields,b))){
				queryAddColumn(qry,trim(listGetAt(newFields,b)),'string',arrayNew(1));
			}
		}

		// many to one linking table
		var findLinkingField = new query(sql="SELECT * FROM d WHERE COLUMN_NAME LIKE '%_id';",d=fetchFields(arguments.table),dbtype='query').execute().getResult();
		for(var i=1;i<=findLinkingField.recordCount;i++){
			var checkTableExists = new query(sql="SELECT * FROM d WHERE TABLE_NAME LIKE '#left(findLinkingField['COLUMN_NAME'][i],len(findLinkingField['COLUMN_NAME'][i])-3)#%' AND TABLE_NAME != '#arguments.table#';",d=fetchTables(arguments.datasource),dbtype='query').execute().getResult();


			if(checkTableExists.recordCount gt 0){
				var checkQueryExists = new query(sql="SELECT * FROM d WHERE name = '#camelCase(checkTableExists['TABLE_NAME'])#';",d=qry,dbtype='query').execute().getResult();
				if(checkQueryExists.recordCount eq 0){
					queryAddRow(qry,1);
					querySetCell(qry,'$type',whatCFCTypeAMI('many-to-one'),qry.recordCount);
					querySetCell(qry,'name',camelCase(checkTableExists['TABLE_NAME']),qry.recordCount);
					querySetCell(qry,'type','array',qry.recordCount);
					querySetCell(qry,'fieldtype','one-to-many',qry.recordCount);
					querySetCell(qry,'cfc','model.' & listFirst(checkTableExists['TABLE_NAME'],'_') & '.' & camelCase(checkTableExists['TABLE_NAME']),qry.recordCount);
					querySetCell(qry,'fkcolumn',findLinkingField['column_name'],qry.recordCount);
					querySetCell(qry,'update',false,qry.recordCount);
					querySetCell(qry,'insert',false,qry.recordCount);
					querySetCell(qry,'lazy',true,qry.recordCount);
					querySetCell(qry,'missingrowignored',true,qry.recordCount);
				}
			}else if(checkTableExists.recordCount gt 0){

				// does NOT currently update any new changes from database - need to implement this ASAP

			}
		}

		// one to many linking table
		for(var i=1;i<=allTables.recordCount;i++){
			var findLinkingField = new query(sql="SELECT * FROM d WHERE COLUMN_NAME LIKE '#arguments.table#_id';",d=fetchFields(allTables['table_name'][i]),dbtype='query').execute().getResult();

			if(findLinkingField.recordCount){

				var linkingFieldExists = new query(sql="SELECT * FROM d WHERE name LIKE '#pluralCamelCase(findLinkingField['table_name'])#';",d=qry,dbtype='query').execute().getResult();
				if(linkingFieldExists.recordCount eq 0){
					queryAddRow(qry,1);
					querySetCell(qry,'$type',whatCFCTypeAMI('one-to-many'),qry.recordCount);
					querySetCell(qry,'name',pluralCamelCase(findLinkingField['table_name']),qry.recordCount);
					querySetCell(qry,'type','array',qry.recordCount);
					querySetCell(qry,'fieldtype','one-to-many',qry.recordCount);
					querySetCell(qry,'cfc','model.' & listFirst(findLinkingField['table_name'],'_') & '.' & camelCase(findLinkingField['table_name']),qry.recordCount);
					querySetCell(qry,'fkcolumn',findLinkingField['column_name'],qry.recordCount);
					querySetCell(qry,'update',false,qry.recordCount);
					querySetCell(qry,'insert',false,qry.recordCount);
					querySetCell(qry,'lazy',true,qry.recordCount);
					querySetCell(qry,'missingrowignored',true,qry.recordCount);
					querySetCell(qry,'cascade','all-delete-orphan',qry.recordCount);
				}else{
					// does NOT currently update any new changes from database - need to implement this ASAP
				}
			}
		}

		return qry;
	}

	private query 	function buildQueryForFile(required string table,required string datasource=fetchDatasource()){
		var fileArray = fetchFileContents(expandPath('./') & 'model/' & arguments.table & '/' & arguments.table & '.cfc');
		var databaseQry = buildQueryFromDatabase(arguments.table);
		var qry = combineDatabaseFileData(databaseQry,fileArray,arguments.table,arguments.datasource);

		return qry;
	}

	private query	function combineDatabaseFileData(required query dbData,required array fileData,required string table,required string datasource=fetchDatasource()){
		var qry = arguments.dbData;

		for(var r=1;r<=arraylen(arguments.fileData);r++){
			var row = arguments.fileData[r];
			if(r gt qry.recordCount){
				queryAddRow(qry,1);
				querySetCell(qry,'$type',1,qry.recordCount);
			}
			for(var c=1;c<=arrayLen(row);c++){
				// makes sure the column exists
				if(isStruct(row[c])){
					if(!listFindNoCase(qry.columnList,trim(row[c]['name']))){
						queryAddColumn(qry,trim(row[c]['name']),'string',arrayNew(1));
					}

					// sets the data
					querySetCell(qry,trim(row[c]['name']),trim(row[c]['value']),r);
				}
			}
		}

		// make sure the primary key & linking tables are properly sorted and defined.
		if(listFindNoCase(qry.columnList,'fieldtype')){
			for(var i=1;i<=qry.recordCount;i++){
				querySetCell(qry,'$type',whatCFCTypeAMI(qry['fieldtype'][i]),i);
			}
		}

		// need to find new relationships and add them
		qry = buildRelationships(qry,arguments.table,arguments.datasource);


		// override data b/c it might be bad
		for(var r=1;r<=qry.recordCount;r++){
			querySetCell(qry,'nullable',javaCast('null',''),r);
			if(qry['default'][r] eq 'CURRENT_TIMESTAMP'){
				querySetCell(qry,'default',javaCast('null',''),r);
			}
			if(qry['type'][r] eq 'timestamp'){
				querySetCell(qry,'default',javaCast('null',''),r);
			}
			try{
				if(qry['notnull'][r] eq false && qry['type'][r] eq 'string'){
					querySetCell(qry,'default',javaCast('null',''),r);
				}
			}catch(any e){

			}
		}

//if(arguments.table eq 'button_type'){writedump(qry);abort;}
		return qry;
	}

	private numeric	function whatCFCTypeAMI(required string str){
		switch(arguments.str){
			case "many-to-one":
				return 3;
				break;
			case "one-to-many":
				return 4;
				break;
			case "one-to-one":
				return 2;
				break;
			case "id":
				return 0;
				break;
			default:
				return 1;
		}
	}

	private query	function buildQueryFromDatabase(required string table){
		var qry = queryNew("$type,name,column,type,default,datatype,nullable,length,fieldtype,generator",'numeric,string,string,string,string,string,boolean,numeric,string,string');
		var fields = fetchFields(arguments.table);
		for(var i=1;i<=fields.recordCount;i++){
			queryAddRow(qry,1);
			querySetCell(qry,'$type',1,qry.recordCount);
			querySetCell(qry,'name',camelCase(fields['column_name'][i]),qry.recordCount);
			querySetCell(qry,'column',fields['column_name'][i],qry.recordCount);
			querySetCell(qry,'type',lookupColdFusionDataType(fields['TYPE_NAME'][i]),qry.recordCount);
			querySetCell(qry,'datatype',lookupDatabaseDataType(fields['TYPE_NAME'][i]),qry.recordCount);
			querySetCell(qry,'nullable',fields['NULLABLE'][i],qry.recordCount);
			querySetCell(qry,'default',fields['COLUMN_DEFAULT_VALUE'][i],qry.recordCount);
			querySetCell(qry,'length',fields['CHAR_OCTET_LENGTH'][i],qry.recordCount);
			if(fields['IS_PRIMARYKEY'][i] eq 'yes'){
				querySetCell(qry,'$type',0,qry.recordCount);
				querySetCell(qry,'generator','identity',qry.recordCount);
				querySetCell(qry,'fieldtype','id',qry.recordCount);
				querySetCell(qry,'name','ID',qry.recordCount);
			}
		}
		return qry;
	}

	private string 	function lookupDatabaseDataType(required string type){

		return listFirst(arguments.type,' .');
	}

	private string	function lookupColdFusionDataType(required string type){
		var data = "";
		switch(listFirst(arguments.type,' .')){
			case "int": case "tinyint": case "integer": case "bigint": case "float": case "double": case "decimal": case "smallint": case "mediumint":
				data = "numeric";
				break;
			 case "timestamp": case "datetime": case "date": case "time": case "year":
			 	data = "timestamp";
			 	break;
			 case "binary": case "varbinary": case "blob": case "tinyblob":
			 	data = "binary";
			 	break;
			default:
				data = "string";
				break;
		}
		return data;
	}

	private array 	function fetchFileContents(required string file){
		var arr = arrayNew(1);

		if(fileExists(arguments.file)){
			var tmpArr = listToArray(fileRead(arguments.file),chr(10) & chr(13));

			for(var i=1;i<=arrayLen(tmpArr);i++){
				if(len(trim(tmpArr[i])) gt 5 && left(trim(tmpArr[i]),8) eq 'property'){
					arrayAppend(arr,fetchPropertyContent(tmpArr[i]));
				}
			}
		}
		return arr;
	}

	private array 	function fetchPropertyContent(required string property){
		var arr = arrayNew(1);
		var str = removeChars(arguments.property,1,10);
		str = replace(left(str,len(str)-1),""" ","""|",'all');
		arr = listToArray(str,'|');
		for(var i=1;i<=arrayLen(arr);i++){
			var tempStr = trim(arr[i]);
			if(len(tempStr)){
				var tempName = removeChars(tempStr,find('=',tempStr),len(tempStr));
				var tempVal = removeChars(tempStr,1,find('=',tempStr));
					tempVal = removeChars(left(tempVal,len(tempVal)-1),1,1);
				arr[i] = structNew();
				arr[i]['name'] = tempName;
				arr[i]['value'] = tempVal;
			}
		}
		return arr;
	}

	private query	function fetchFields(required string tableName,required string datasource=fetchDatasource(),required string filter=""){
		var data = "";
		if(len(arguments.filter)){
			dbinfo type="columns" datasource=arguments.datasource name="data" table=arguments.tableName pattern=arguments.filter;
		}else{
			dbinfo type="columns" datasource=arguments.datasource name="data" table=arguments.tableName;
		}

		return data;
	}

	private query	function fetchTables(required string datasource=fetchDatasource()){
		var data = "";
		dbinfo type="tables" datasource=arguments.datasource name="data";
		return data;
	}

	private string	function fetchDatasource(){

		return application.getApplicationSettings()['datasource'];
	}

	private string	function titleCase(required string str){
		var arr = listToArray(arguments.str,'_');
		var data = "";
		for(var i=1;i<=arrayLen(arr);i++){
			if(arguments.str eq "UUID" || len(arguments.str) lte 3){
				data = ucase(arguments.str);
				break;
			}else if(arr[i] neq 'id'){
				data = data & ucase(left(arr[i],1)) & lcase(right(arr[i],len(arr[i])-1)) & " ";
			}
		}

		return data;
	}

	private string 	function camelCase(required string str){
		var arr = listToArray(arguments.str,'_');
		var data = arr[1];
		for(var i=2;i<=arrayLen(arr);i++){
			if(arr[i] eq 'id'){
				data = data & "ID";
			}else{
				data = data & uCase(left(arr[i],1)) & lcase(right(arr[i],len(arr[i])-1));
			}
		}

		return data;
	}

	private string 	function pluralCamelCase(required string str){
		var data = camelCase(arguments.str);

		if(right(data,1) eq "y"){
			data = left(data,len(data)-1) & 'ies';
		}else if(right(data,2) eq "es"){
			//already plural
		}else if(right(data,1) eq "s"){
			data = data & 'es';
		}else{
			data = data & 's';
		}

		return data;
	}

//******************************************* OLD EVENTS **********************************************//

	public 	void 	function oldindex(required any event,required any rc,required any prc){
		arguments.rc.meta.title = 'CFC Box';

		var allTables = new query(sql="SHOW TABLES;").execute().getResult();
		var findColumnName = allTables.columnList;
		var findTables = arrayNew(1);
		for(var i=1;i<=allTables.recordCount;i++){
			arrayAppend(findTables,allTables[findColumnName][i]);
		}
		var findTables = arrayToList(findTables);

		for(var z=1;z<=allTables.recordCount;z++){

			var tablename = listGetAt(findTables,z);
			var foreignTableArray = arrayNew(1);
			for(var f=1;f<=allTables.recordCount;f++){
				var foreignTables = new query(sql="SHOW COLUMNS FROM #listGetAt(findTables,f)# WHERE Field = '#tablename#_id'").execute().getResult();
				if(foreignTables.recordCount gt 0 && tablename neq listGetAt(findTables,f)){
					arrayAppend(foreignTableArray,listGetAt(findTables,f));
				}
			}

			var mydirectory = getDirectoryFromPath(expandPath('./')) & "model/" & listFirst(lcase(tablename),'_');
			if(!directoryExists(mydirectory)){
				directory action="create" directory=mydirectory;
			}
			if(!fileExists(mydirectory & '/' & camelCase(tablename) & "Service" & ".cfc")){
				fileWrite(mydirectory & '/' & camelCase(tablename) & "Service" & ".cfc","/**#chr(13)#* Service to handle #camelCase(tablename)#Service operations.#chr(13)#* @author Jeremy DeYoung#chr(13)#*/#chr(13)#component extends=""coldbox.system.orm.hibernate.VirtualEntityService"" singleton {#chr(13)##chr(13)#	/**#chr(13)#	* Constructor#chr(13)#	*/#chr(13)#	public #camelCase(tablename)#Service function init(){#chr(13)##chr(13)#		super.init(entityName=""#camelCase(tablename)#"");#chr(13)##chr(13)#		return this;#chr(13)##chr(13)#	}#chr(13)##chr(13)#}");
			}

			var myfile = mydirectory & '/' & camelCase(tablename) & ".cfc";
			var oldData = new query(sql="SHOW COLUMNS FROM #tablename#;").execute().getResult();
			var oldDataCols = oldData.columnList;
			var qry = queryNew(oldDataCols);
			for(var i=1;i<=oldData.recordCount;i++){
				queryAddRow(qry,1);
				for(var c=1;c<=listLen(oldDataCols);c++){
					querySetCell(qry,listGetAt(oldDataCols,c),evaluate("oldData.#listGetAt(oldDataCols,c)#[#i#]"),qry.recordCount);
				}
			}

			var arr = arrayNew(1);
			var bool = arrayNew(1);
			var num = arrayNew(1);
			var tablenamesArray = arrayNew(1);

			for(var i=1;i<=qry.recordCount;i++){
				arrayAppend(arr,"");
				arrayAppend(num,0);
				arrayAppend(bool,false);
			}
			QueryAddColumn(qry,'name','string',arr);
			QueryAddColumn(qry,'column','string',arr);
			QueryAddColumn(qry,'datatype','string',arr);
			QueryAddColumn(qry,'notnull','boolean',bool);
			QueryAddColumn(qry,'required','boolean',bool);
			QueryAddColumn(qry,'length','numeric',num);
			QueryAddColumn(qry,'formFieldName','string',arr);
			QueryAddColumn(qry,'formFieldTitle','string',arr);
			QueryAddColumn(qry,'formFieldValidator','string',arr);
			QueryAddColumn(qry,'formFieldMin','numeric',arr);
			QueryAddColumn(qry,'formFieldMax','numeric',arr);
			QueryAddColumn(qry,'setter','string',arr);
			QueryAddColumn(qry,'generator','string',arr);
			QueryAddColumn(qry,'fieldtype','string',arr);

			for(var i=1;i<=qry.recordCount;i++){
				var typeArray = listToArray(qry['type'][i],'( )');

				querySetCell(qry,'datatype',typeArray[1],i);
				if(qry['null'][i] eq "NO"){
					querySetCell(qry,'notnull',true,i);
					querySetCell(qry,'required',true,i);
				}else{
					querySetCell(qry,'notnull',false,i);
					querySetCell(qry,'required',false,i);
				}

				if(qry['key'][i] eq 'pri'){
					querySetCell(qry,'formFieldName',"ID",i);
					querySetCell(qry,'setter',false,i);
					querySetCell(qry,'generator','identity',i);
					typeArray[1] = 'key';
					querySetCell(qry,'type',"numeric",i);
					querySetCell(qry,'fieldtype',"id",i);
					querySetCell(qry,'length',"",i);
					querySetCell(qry,'null',"",i);
					querySetCell(qry,'notnull','',i);
					querySetCell(qry,'required','',i);
				}else{
					querySetCell(qry,'formFieldName',camelCase(qry['field'][i]),i);
					querySetCell(qry,'formFieldTitle',titleCase(qry['field'][i]),i);
				}

				switch(typeArray[1]){
					case "bit":
						querySetCell(qry,'formFieldMin',0,i);
						querySetCell(qry,'formFieldMax',1,i);
						querySetCell(qry,'length',typeArray[2],i);
						querySetCell(qry,'type',"boolean",i);
						querySetCell(qry,'formFieldValidator',"boolean",i);
						break;
					case "tinyint":
						if(arrayLen(typeArray) eq 3 && typeArray[3] eq 'unsigned'){
							querySetCell(qry,'formFieldMin',0,i);
							querySetCell(qry,'formFieldMax',255,i);
						}else{
							querySetCell(qry,'formFieldMin',-127,i);
							querySetCell(qry,'formFieldMax',127,i);
						}
						querySetCell(qry,'length',typeArray[2],i);
						querySetCell(qry,'type',"boolean",i);
						querySetCell(qry,'formFieldValidator',"boolean",i);
						break;
					case "smallint":
						if(arrayLen(typeArray) eq 3 && typeArray[3] eq 'unsigned'){
							querySetCell(qry,'formFieldMin',0,i);
							querySetCell(qry,'formFieldMax',65535,i);
						}else{
							querySetCell(qry,'formFieldMin',-32767,i);
							querySetCell(qry,'formFieldMax',32767,i);
						}
						querySetCell(qry,'type',"numeric",i);
						querySetCell(qry,'length',typeArray[2],i);
						querySetCell(qry,'formFieldValidator',"numeric",i);
						break;
					case "mediumint":
						if(arrayLen(typeArray) eq 3 && typeArray[3] eq 'unsigned'){
							querySetCell(qry,'formFieldMin',0,i);
							querySetCell(qry,'formFieldMax',16777215,i);
						}else{
							querySetCell(qry,'formFieldMin',-8388607,i);
							querySetCell(qry,'formFieldMax',8388607,i);
						}
						querySetCell(qry,'type',"numeric",i);
						querySetCell(qry,'length',typeArray[2],i);
						querySetCell(qry,'formFieldValidator',"numeric",i);
						break;
					case "int":
						if(arrayLen(typeArray) eq 3 && typeArray[3] eq 'unsigned'){
							querySetCell(qry,'formFieldMin',0,i);
							querySetCell(qry,'formFieldMax',4294967295,i);
						}else{
							querySetCell(qry,'formFieldMin',-2147483647,i);
							querySetCell(qry,'formFieldMax',2147483647,i);
						}
						querySetCell(qry,'type',"numeric",i);
						querySetCell(qry,'length',typeArray[2],i);
						querySetCell(qry,'formFieldValidator',"numeric",i);
						break;
					case "bigint":
						if(arrayLen(typeArray) eq 3 && typeArray[3] eq 'unsigned'){
							querySetCell(qry,'formFieldMin',0,i);
							querySetCell(qry,'formFieldMax',18446744073709551615,i);
						}else{
							querySetCell(qry,'formFieldMin',-9223372036854775808,i);
							querySetCell(qry,'formFieldMax',9223372036854775808,i);
						}
						querySetCell(qry,'type',"numeric",i);
						querySetCell(qry,'length',typeArray[2],i);
						querySetCell(qry,'formFieldValidator',"numeric",i);
						break;
					case "float":
						if(arrayLen(typeArray) eq 3 && typeArray[3] eq 'unsigned'){
							querySetCell(qry,'formFieldMin',0,i);
							querySetCell(qry,'formFieldMax',360,i);
						}else{
							querySetCell(qry,'formFieldMin',-360,i);
							querySetCell(qry,'formFieldMax',360,i);
						}
						querySetCell(qry,'type',"numeric",i);
						querySetCell(qry,'length',12,i);
						querySetCell(qry,'default',0.00,i);
						querySetCell(qry,'formFieldValidator',"numeric",i);
						break;
					case "varchar":
						querySetCell(qry,'formFieldMin',0,i);
						querySetCell(qry,'formFieldMax',typeArray[2],i);
						querySetCell(qry,'length',typeArray[2],i);
						querySetCell(qry,'type',"string",i);
						querySetCell(qry,'formFieldValidator',"string",i);
						break;
					case "text":
						querySetCell(qry,'type',"string",i);
						querySetCell(qry,'formFieldValidator',"string",i);
						break;
					case "timestamp":
						querySetCell(qry,'default','',i);
						querySetCell(qry,'length','',i);
						querySetCell(qry,'type',"timestamp",i);
						querySetCell(qry,'formFieldValidator',"",i);
						querySetCell(qry,'formFieldTitle',"",i);
						querySetCell(qry,'notnull',false,i);
						querySetCell(qry,'required',false,i);
						querySetCell(qry,'setter',false,i);
						break;
					case "datetime":
						querySetCell(qry,'default','',i);
						querySetCell(qry,'type',"string",i);
						querySetCell(qry,'formFieldValidator',"datetime",i);
						break;
				}

				switch(qry['field'][i]){
					case "email":
						querySetCell(qry,'formFieldValidator',"email",i);
						break;
					case "ccn":
						querySetCell(qry,'formFieldValidator',"creditcard",i);
						break;
					case "phone":
						querySetCell(qry,'formFieldValidator',"telephone",i);
						break;
					case "state":
						querySetCell(qry,'formFieldValidator',"state",i);
						break;
					case "postal":
						querySetCell(qry,'formFieldValidator',"postalcode",i);
						break;
				}

				querySetCell(qry,'name',qry['formFieldName'][i],i);
				querySetCell(qry,'column',qry['field'][i],i);

			}
			queryDeleteColumn(qry,'extra');
			queryDeleteColumn(qry,'key');
			queryDeleteColumn(qry,'field');
			queryDeleteColumn(qry,'null');

			// read in old files if they exists and handle overriding
			if(fileExists(myFile)){
				var myFileData = fileRead(myFile);
				var myFileDataArray = listToArray(myFileData,chr(13) & ";{}");
				var newFileDataArray = arrayNew(1);
				for(var i=1;i<=arraylen(myFileDataArray);i++){

					if(left(trim(myFileDataArray[i]),8) eq 'property' && !findNoCase(' cfc=',myFileDataArray[i])){
						var tmp = arrayNew(1);
						var findData = trim(removeChars(trim(myFileDataArray[i]),1,8));
						do{
							var start = find('"',findData);
								start = find('"',findData,start+1);
							try{
								arrayAppend(tmp,trim(removeChars(findData,start+1,len(findData))));
							}catch(any e){
								arrayAppend(tmp,trim(removeChars(findData,start,len(findData))));
							}
						findData = removeChars(findData,1,start);
						}while(find(' ',findData));
						arrayAppend(newFileDataArray,tmp);
					}
				}

				for(var i=1;i<=arrayLen(newFileDataArray);i++){
					var uFieldname = listLast(newFileDataArray[i][1],'="');
					for(var b=1;b<=arrayLen(newFileDataArray[i]);b++){
						var tmp = listToArray(newFileDataArray[i][b],'="');
						for(var c=1;c<=qry.recordCount;c++){
							if(arrayLen(tmp) gte 2 && qry.name[c] eq uFieldname){
								try{
									querySetCell(qry,tmp[1],tmp[2],c);
									break;
								}catch(database e){
									QueryAddColumn(qry,tmp[1],'string',arr);
									querySetCell(qry,tmp[1],tmp[2],c);
									break;
								}
							}
						}
					}
				}
			}

			fileWrite(myfile,'');
			var myfile = fileOpen(myfile,"append");

			var clist = qry.ColumnList;
				clist = replaceNoCase(clist,',name,',',');
				clist = replaceNoCase(clist,',column,',',');
			    clist = listToArray("name,column," & clist);
			var csize = arrayNew(1);
			try{
				for(var i=1;i<=arrayLen(clist);i++){
					var t = new query(sql="SELECT max(length(#clist[i]#)) AS ct FROM qry",dbtype="query",qry=qry).execute().getResult();
					try{
						arrayAppend(csize,t['ct'][1]+5+len(clist[i]));
					}catch(any e){
						arrayAppend(csize,0);
					}
				}
				csize = arrayToList(csize);
			}catch(any e){

			}

			for(var i=1;i<=qry.recordCount;i++){
				if(right(qry.column[i],3) eq "_id" && qry.fieldtype[i] neq 'id'){
					var mytable = left(qry.column[i],len(qry.column[i])-3);
					if(listFindNoCase(findTables,mytable)){
						arrayAppend(tablenamesArray,qry.column[i]);
					}
				}
			}

			var qry = new query(sql="SELECT * FROM qry ORDER BY fieldtype DESC,default DESC,type,name",dbtype="query",qry=qry).execute().getResult();

			var line = "";
			var start = 10;
			//header
			fileWriteLine(myfile,"/**" & chr(13) & "* I am a '" & tablename & "' entity" & chr(13) & "**/" & chr(13));
			filewriteline(myfile,"component persistent=""true"" table=""" & tablename & """ {" & chr(13) & chr(13));
			filewriteline(myfile,"	//Properties" & chr(13) & chr(13));

			for(var i=1;i<=qry.recordCount;i++){
				line = "property  ";
				for(var c=1;c<=arrayLen(clist);c++){
					start = start + listGetAt(csize,c);
					if(i eq 0){
						if(len(qry[clist[c]][i])){
							line = line & lcase(clist[c]) & "=""" & trim(qry[clist[c]][i]) & """  ";
						}
					}else if(len(qry[clist[c]][i])){
						var current = start-len(line);
						if(current lte 0){
							current = 0;
						}else if((current - listGetAt(csize,c)) gt 0){
							line = line & repeatString(" ",current - listGetAt(csize,c));
							var current = start-len(line);
						}
						line = line & lJustify(trim(lcase(clist[c])) & "=""" & trim(qry[clist[c]][i]) & """",current);
					}
				}
				start = 10;
				fileWriteLine(myfile,"	" & trim(line) & ";");
			}
			fileWriteLine(myfile,chr(13) & chr(13) & "	//Relationships" & chr(13));

			for(var i=1;i<=arrayLen(tablenamesArray);i++){
				var mytable = left(tablenamesArray[i],len(tablenamesArray[i])-3);
				fileWriteLine(myfile,"	property name=""#camelCase(mytable)#"" cfc=""model.#listFirst(mytable,'_')#.#camelCase(mytable)#"" fieldtype=""many-to-one"" fkcolumn=""#mytable#_id"" type=""array"" fetch=""select"" update=""false"" insert=""false"" lazy=""true"" missingrowignored=""true"";");
			}

			for(var i=1;i<=arrayLen(foreignTableArray);i++){
				var check = new query(sql="SHOW COLUMNS FROM #foreignTableArray[i]# WHERE Field = 'sort_order'").execute().getResult();
				var checkWhere = new query(sql="SHOW COLUMNS FROM #foreignTableArray[i]# WHERE Field = 'deleted' OR Field = 'discontinued'").execute().getResult();
				if(check.recordCount GT 0){
					if(checkWhere.recordCount gt 0){
						fileWriteLine(myfile,"	property name=""#pluralCamelCase(foreignTableArray[i])#"" cfc=""model.#listFirst(foreignTableArray[i],'_')#.#camelCase(foreignTableArray[i])#"" fieldtype=""one-to-many"" fkcolumn=""#tablename#_id"" type=""array"" fetch=""select"" update=""false"" insert=""false"" lazy=""true"" orderby=""sortOrder"" missingrowignored=""true"" cascade=""all-delete-orphan"" where=""#checkWhere['Field']#=0"";");
					}else{
						fileWriteLine(myfile,"	property name=""#pluralCamelCase(foreignTableArray[i])#"" cfc=""model.#listFirst(foreignTableArray[i],'_')#.#camelCase(foreignTableArray[i])#"" fieldtype=""one-to-many"" fkcolumn=""#tablename#_id"" type=""array"" fetch=""select"" update=""false"" insert=""false"" lazy=""true"" orderby=""sortOrder"" missingrowignored=""true"" cascade=""all-delete-orphan"";");
					}
				}else{
					if(checkWhere.recordCount gt 0){
						fileWriteLine(myfile,"	property name=""#pluralCamelCase(foreignTableArray[i])#"" cfc=""model.#listFirst(foreignTableArray[i],'_')#.#camelCase(foreignTableArray[i])#"" fieldtype=""one-to-many"" fkcolumn=""#tablename#_id"" type=""array"" fetch=""select"" update=""false"" insert=""false"" lazy=""true"" missingrowignored=""true"" cascade=""all-delete-orphan"" where=""#checkWhere['Field']#=0"";");
					}else{
						fileWriteLine(myfile,"	property name=""#pluralCamelCase(foreignTableArray[i])#"" cfc=""model.#listFirst(foreignTableArray[i],'_')#.#camelCase(foreignTableArray[i])#"" fieldtype=""one-to-many"" fkcolumn=""#tablename#_id"" type=""array"" fetch=""select"" update=""false"" insert=""false"" lazy=""true"" missingrowignored=""true"" cascade=""all-delete-orphan"";");
					}
				}
			}

			fileWriteLine(myfile,chr(13) & chr(13) & "	//Dependencies via WireBox" & chr(13));
			fileWriteLine(myfile,chr(13) & chr(13) & "}" & chr(13));
			fileClose(myFile);
		}
		arguments.event.noRender();
	}

}

