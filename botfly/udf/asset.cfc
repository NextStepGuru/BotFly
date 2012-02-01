component{

	public query function buildAssetsData(){

		return queryNew("asset,priority,code,head,filter","string,numeric,string,boolean,string");
	}

	public struct function buildMetaData(){

		return structNew();
	}

	public string function renderHeaderAssets(){
		var returnArr = arrayNew(1);
		var assets = arrayNew(1);
		var combinCSS = arrayNew(1);
		var combinJS = arrayNew(1);
		if(rc.device.isMobileAgent eq true && rc.device.isTablet eq false){
			var filter = 'mobile';
		}else{
			var filter = 'web';
		}
		var qry = new query(sql="SELECT * FROM prc WHERE head = 1 AND (filter = 'any' OR filter='#filter#') ORDER BY priority DESC",prc=prc.assets,dbtype='query').execute().getResult();
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

		return arrayToList(returnArr,chr(10));
	}

	public string function renderFooterAssets(){
		var returnArr = arrayNew(1);
		var assets = arrayNew(1);
		var combinCSS = arrayNew(1);
		var combinJS = arrayNew(1);
		if(rc.device.isMobileAgent eq true && rc.device.isTablet eq false){
			var filter = 'mobile';
		}else{
			var filter = 'web';
		}
		var qry = new query(sql="SELECT * FROM prc WHERE head = 0 AND (filter = 'any' OR filter='#filter#') ORDER BY priority DESC",prc=prc.assets,dbtype='query').execute().getResult();
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
		return arrayToList(returnArr,chr(10));
	}


	public void function addAssetLibrary(required string library='jquery',required boolean sendToHeader=false,required boolean async=false,required numeric priority=0){
		switch(arguments.library){
			case "formalize":
				addAsset(asset="/botfly/github/formalize/assets/css/formalize.css",sendToHeader=true,priority=arguments.priority,assetType='css');
				addAsset(asset="/botfly/github/formalize/assets/js/formalize.js",sendToHeader=false,priority=arguments.priority,assetType='js');
				break;
			case "normalizeCSS":
				addAsset(asset="/botfly/github/normalize.css/normalize.css",sendToHeader=true,priority=arguments.priority,assetType='css');
				break;
			case "framelessGrid":
				addAsset(asset="/botfly/github/Frameless/frameless.css",sendToHeader=true,priority=arguments.priority,assetType='css');
				if(settingExists('framelessGrid_debug') && getSetting('framelessGrid_debug')){
					addAsset(asset="/botfly/github/Frameless/frameless.js",sendToHeader=true,priority=arguments.priority,assetType='js');
				}
				break;
			case "jquery":
				addAsset(asset="/botfly/github/jquery/dist/jquery.js",sendToHeader=true,priority=1000,assetType='js');
				break;
			case "jqueryUI":
				addAsset(asset="/botfly/github/jquery-ui/ui/jquery.ui.core.js",sendToHeader=true,priority=500,assetType='js');
				addAsset(asset="/botfly/github/jquery-ui/ui/jquery.effects.core.js",sendToHeader=true,priority=499,assetType='js');
				var coreFiles = "jquery.ui.core.js,jquery.ui.widget.js,jquery.ui.mouse.js,jquery.ui.draggable.js,jquery.ui.droppable.js,jquery.ui.resizable.js,jquery.ui.selectable.js,jquery.ui.sortable.js,jquery.effects.core.js";
				for(var i=1;i<=listLen(coreFiles);i++){
					addAsset(asset="/botfly/github/jquery-ui/ui/#trim(listGetAt(coreFiles,i))#",sendToHeader=true,priority=evaluate(250-i),assetType='js');
				}
				var files = getJQueryUIFiles('js');
				for(var i=1;i<=files.recordCount;i++){
					if(!listFind(coreFiles,files.name[i])){
						addAsset(asset="/botfly/github/jquery-ui/ui/#files.name[i]#",sendToHeader=arguments.sendToHeader,priority=evaluate(200-i),assetType='js');
					}
				}
				var coreFiles = "jquery.ui.core.js,jquery.ui.widget.js,jquery.ui.mouse.js,jquery.ui.draggable.js,jquery.ui.droppable.js,jquery.ui.resizable.js,jquery.ui.selectable.js,jquery.ui.sortable.js,jquery.effects.core.js";
				var files = getJQueryUIFiles('css');
				addAsset(asset="/botfly/github/jquery-ui/themes/base/jquery.ui.core.css",sendToHeader=true,priority=100,assetType='css');
				addAsset(asset="/botfly/github/jquery-ui/themes/base/jquery.ui.theme.css",sendToHeader=true,priority=99,assetType='css');
				for(var i=1;i<=files.recordCount;i++){
					if(!listFind('jquery.ui.all.css,jquery.ui.base.css,jquery.ui.core.css,jquery.ui.theme.css',files.name[i])){
						addAsset(asset="/botfly/github/jquery-ui/themes/base/#files.name[i]#",sendToHeader=true,priority=evaluate(10+i),assetType='css');
					}
				}
				break;
			case "jqueryValidate":
				addAsset(asset="/botfly/github/jQuery-Validation-Engine/css/validationEngine.jquery.css",sendToHeader=true,priority=arguments.priority,assetType='css');
				addAsset(asset="/botfly/github/jQuery-Validation-Engine/js/jquery.validationEngine.js",sendToHeader=true,priority=arguments.priority);
				addAsset(asset="/botfly/github/jQuery-Validation-Engine/js/languages/jquery.validationEngine-en.js",sendToHeader=true,priority=arguments.priority);
				break;
			case "pusher":
				addAsset(asset="http://js.pusher.com/1.11/pusher.min.js",sendToHeader=true,priority=100);
				break;
			case "jQuerySimplePager":
				addAsset(asset="/botfly/github/simplepager/scripts/quickpager.jquery.js",sendToHeader=arguments.sendToHeader,priority=arguments.priority,assetType='js');
				break;
			case "jQuerySlideJS":
				addAsset(asset="/botfly/github/Slides/source/slides.js",sendToHeader=arguments.sendToHeader,priority=arguments.priority,assetType='js');
				break;
			case "geoLocation":
				addAsset(asset="http://code.google.com/apis/gears/gears_init.js",sendToHeader=true,assetType='js');
				addAsset(asset="/botfly/googleCode/geoLocationJavascript/geo.js",sendToHeader=arguments.sendToHeader,priority=arguments.priority,assetType='js');
				break;
			case "jqueryMouseWheel":
				addAsset(asset="/botfly/github/jquery-mousewheel/jquery.mousewheel.js",sendToHeader=arguments.sendToHeader,priority=arguments.priority,assetType='js');
				break;
			case "jqueryCloudCarousel":
				addAsset(asset="/botfly/jquery/CloudCarousel/cloud-carousel.1.0.5.js",sendToHeader=arguments.sendToHeader,priority=arguments.priority,assetType='js');
				break;
			default:
				throw('Unknown Asset Library','addAssetLibrary.UDF');
		}

	}

	public void function addAsset(required string asset,required boolean sendToHeader=false,required boolean async=false,required numeric priority=0,required string assetType='js',required string filter='any'){
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
			querySetCell(prc.assets,'filter',arguments.filter,prc.assets.recordCount);
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

	private any function getJQueryUIFiles(required string type){
		var files = "";
		if(arguments.type eq 'js'){
			directory name="files" action="list" filter="*.js" directory="#getDirectoryFromPath(expandPath('./'))#/botfly/github/jquery-ui/ui";
		}else{
			directory name="files" action="list" filter="*.css" directory="#getDirectoryFromPath(expandPath('./'))#/botfly/github/jquery-ui/themes/base/";
		}
		return files;
	}
}
