<cfscript>
	var udfs = "";
	directory name="udfs" action="list" directory=getDirectoryFromPath(expandPath('./')) & "/flybox/udf/";
	for(var i=1;i<=udfs.recordCount;i++){
		if(listFindNoCase('cfc,cfm',listLast(udfs.name[i],'.')) && udfs.name[i] neq 'udf.cfm'){
			include template="/flybox/udf/" & udfs.name[i];
		}
	}
	directory name="udfs" action="list" directory=getDirectoryFromPath(expandPath('./')) & "/assets/udf/";
	for(var i=1;i<=udfs.recordCount;i++){
		if(listFindNoCase('cfc,cfm',listLast(udfs.name[i],'.')) && udfs.name[i] neq 'udf.cfm'){
			include template="/assets/udf/" & udfs.name[i];
		}
	}
</cfscript>
