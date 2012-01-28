component{

	public query function buildAssetsData(){

		return queryNew("asset,priority,code,head","string,numeric,string,boolean");
	}

	public struct function buildMetaData(){

		return structNew();
	}

	public string function renderHeaderAssets(){
		var returnArr = arrayNew(1);
		var assets = arrayNew(1);
		var combinCSS = arrayNew(1);
		var combinJS = arrayNew(1);
		var qry = new query(sql="SELECT * FROM prc WHERE head = 1 ORDER BY priority DESC",prc=prc.assets,dbtype='query').execute().getResult();
		var prefix = "";
		if(settingExists('jsmin_prefix_url')){
			prefix = getSetting('jsmin_prefix_url');
		}

		for(var i=1;i<=qry.recordCount;i++){
			if(left(qry.asset[i],4) neq 'http' && right(qry.asset[i],4) neq '.ico'){
				if(right(qry.asset[i],3) eq '.js'){
					arrayAppend(combinJS,qry.asset[i]);
				}else{
					arrayAppend(combinCSS,qry.asset[i]);
				}
			}else{
				arrayAppend(returnArr,qry.code[i]);
			}
		}
		if(arrayLen(combinCSS) gt 0){
			arrayAppend(returnArr,replace(getMyPlugin("JSMin").minify(arrayToList(combinCSS)),'/assets/',prefix & '/assets/'));
		}
		if(arrayLen(combinJS) gt 0){
			arrayAppend(returnArr,replace(getMyPlugin("JSMin").minify(arrayToList(combinJS)),'/assets/',prefix & '/assets/'));
		}

		return arrayToList(returnArr,'');
	}

	public string function renderFooterAssets(){
		var returnArr = arrayNew(1);
		var assets = arrayNew(1);
		var combinCSS = arrayNew(1);
		var combinJS = arrayNew(1);
		var qry = new query(sql="SELECT * FROM prc WHERE head = 0 ORDER BY priority DESC",prc=prc.assets,dbtype='query').execute().getResult();
		var prefix = "";
		if(settingExists('jsmin_prefix_url')){
			prefix = getSetting('jsmin_prefix_url');
		}

		for(var i=1;i<=qry.recordCount;i++){
			if(left(qry.asset[i],4) neq 'http' && right(qry.asset[i],4) neq '.ico'){
				if(right(qry.asset[i],3) eq '.js'){
					arrayAppend(combinJS,qry.asset[i]);
				}else{
					arrayAppend(combinCSS,qry.asset[i]);
				}
			}else{
				arrayAppend(returnArr,qry.code[i]);
			}
		}
		if(arrayLen(combinCSS) gt 0){
			arrayAppend(returnArr,replace(getMyPlugin("JSMin").minify(arrayToList(combinCSS)),'/assets/',prefix & '/assets/'));
		}
		if(arrayLen(combinJS) gt 0){
			arrayAppend(returnArr,replace(getMyPlugin("JSMin").minify(arrayToList(combinJS)),'/assets/',prefix & '/assets/'));
		}
		return arrayToList(returnArr,'');
	}


	public void function addAssetLibrary(required string library='jquery',required boolean sendToHeader=false,required boolean async=false,required numeric priority=0){
		switch(arguments.library){
			case "formalize":
				//formalize
				addAsset(asset="/botfly/css/formalize/formalize.css",sendToHeader=true,priority=arguments.priority,assetType='css');
				addAsset(asset="/botfly/js/formalize/formalize.js",sendToHeader=false,priority=arguments.priority,assetType='js');
				break;
			case "normalizeCSS":
				//normalizeCSS
				addAsset(asset="/botfly/css/normalize/normalize.css",sendToHeader=true,priority=arguments.priority,assetType='css');
				break;
			case "framelessGrid":
				//framelessGrid
				addAsset(asset="/assets/css/frameless.css",sendToHeader=true,priority=arguments.priority,assetType='css');

				if(settingExists('framelessGrid_debug') && getSetting('framelessGrid_debug')){
					//only display the grid if debug it turned on in settings within Coldbox Config
					addAsset(asset="/botfly/js/frameless/frameless.js",sendToHeader=true,priority=arguments.priority,assetType='js');
				}
				break;
			case "jquery":
				//jquery 1.7.1
				addAsset(asset="/botfly/js/jQuery/jQuery.js",sendToHeader=true,priority=arguments.priority);
				break;
			case "jqueryUI":
				//jqueryUI 1.8.16
				addAsset(asset="/botfly/css/jQueryUI/ui-lightness/jquery-ui-1.8.16.custom.css",sendToHeader=arguments.sendToHeader,priority=arguments.priority,assetType='css');
				addAsset(asset="/botfly/js/jQueryUI/jQueryUI.js",sendToHeader=arguments.sendToHeader,priority=arguments.priority);
				break;
			case "jqueryValidate":
				addAsset(asset="/botfly/css/validationEngine/validationEngine.jquery.css",sendToHeader=arguments.sendToHeader,priority=arguments.priority,assetType='css');
				addAsset(asset="/botfly/js/validationEngine/jquery.validationEngine.js",sendToHeader=arguments.sendToHeader,priority=arguments.priority);
				addAsset(asset="/botfly/js/validationEngine/languages/jquery.validationEngine-en.js",sendToHeader=arguments.sendToHeader,priority=arguments.priority);
				break;
			default:
				throw('Unknown Asset Library','addAssetLibrary.UDF');
		}

	}

	public void function addAsset(required string asset,required boolean sendToHeader=false,required boolean async=false,required numeric priority=0,required string assetType='js'){
		var prc = controller.getRequestService().getContext().getCollection(private=true);
		var returnCode = arguments.asset;
		var returnAsset = arguments.asset;

		if(arguments.assetType eq 'js'){
			if(arguments.async){
				returnCode = chr(60) & 'script src="' & returnAsset & '" type="text/javascript" async ' & chr(62) & chr(60) & '/script' & chr(62);
			}else{
				returnCode = chr(60) & 'script src="' & returnAsset & '" type="text/javascript"' & chr(62) & chr(60) & '/script' & chr(62);
			}
		}else if(arguments.assetType eq 'css'){
			returnCode =  chr(60) & 'link href="' & returnAsset & '" rel="stylesheet" type="text/css"' & chr(62);
		}else if(arguments.assetType eq 'ico'){
			returnCode =  chr(60) & 'link href="' & returnAsset & '" rel="shortcut icon" type="image/x-icon"' & chr(62);
		}

		var checkQry = new query(sql="SELECT * FROM prc WHERE asset = :a;",prc=prc.assets,dbtype='query');
			checkQry.addParam(name="a",value=returnAsset);

		if(checkQry.execute().getResult().recordCount eq 0){
			queryAddRow(prc.assets,1);
			querySetCell(prc.assets,'asset',returnAsset,prc.assets.recordCount);
			querySetCell(prc.assets,'code',returnCode,prc.assets.recordCount);
			if(arguments.assetType eq 'css'){
				querySetCell(prc.assets,'priority',(arguments.priority+1)*100,prc.assets.recordCount);
				querySetCell(prc.assets,'head',true,prc.assets.recordCount);
			}else if(arguments.assetType eq 'ico'){
				querySetCell(prc.assets,'head',true,prc.assets.recordCount);
			}else{
				querySetCell(prc.assets,'priority',arguments.priority,prc.assets.recordCount);
				querySetCell(prc.assets,'head',arguments.sendToHeader,prc.assets.recordCount);
			}
		}

	}

	public string function renderHeadAssets(){
		var results = arrayNew(1);
		if(structKeyExists(prc,'meta')){
			if(structKeyExists(prc.meta,'title')){
				arrayAppend(results,'<title>#prc.meta.title#</title>');
			}
			if(structKeyExists(prc.meta,'keywords')){
				arrayAppend(results,'<meta name="keywords" content="#lCase(prc.meta.keywords)#">');
			}
			if(structKeyExists(prc.meta,'description')){
				arrayAppend(results,'<meta name="description" content="#prc.meta.description#">');
			}
			if(structKeyExists(prc.meta,'refresh')){
				arrayAppend(results,'<meta http-equiv="refresh" content="#prc.meta.refresh.time#; url=#prc.meta.refresh.url#">');
			}
			if(structKeyExists(prc.meta,'contentType')){
				arrayAppend(results,'<meta http-equiv="Content-Type" content="#prc.meta.contentType#">');
			}
			if(structKeyExists(prc.meta,'robots')){
				arrayAppend(results,'<meta http-equiv="robots" content="#prc.meta.robots#">');
				arrayAppend(results,'<meta http-equiv="googlebot" content="#prc.meta.robots#">');
			}
			if(structKeyExists(prc.meta,'cacheControl')){
				arrayAppend(results,'<meta http-equiv="cache-control" content="#prc.meta.cacheControl#">');
				arrayAppend(results,'<meta http-equiv="pragma" content="#prc.meta.cacheControl#">');
			}
		}

		return arrayToList(results,'');
	}
	public struct function buildField(required string name,required string value="",required string type="text",required string css,required string id=""){
		var s = structNew();
		s.name = arguments.fieldname;
		s.value = arguments.fieldvalue;
		s.type = arguments.fieldtype;
		s.css = arguments.css;
		s.id = arguments.id;

		return s;
	}
}
