component extends="coldbox.system.Interceptor" output="false"{
	public void function preProcess(required any event,required any interceptData){

		var rc = arguments.event.getCollection();
		var ua = lcase(cgi.user_agent);
		var tmp = ua;

		rc.device 					= structNew();
		rc.device.isMobileAgent 	= false;
		rc.device.isWAPAgent 		= false;
		rc.device.isTablet			= false;
		rc.device.isDesktop			= false;
		rc.device.isHTML5			= false;

		rc.device.os				= structNew();
		//desktop
		rc.device.os.isApple		= false;
		rc.device.os.isWindows		= false;
		rc.device.os.isLinux		= false;
		//mobile
		rc.device.os.isAndroid	 	= false;
		rc.device.os.isiOS		 	= false;
		rc.device.os.isBlackberry	= false;

		rc.device.browser 			= structNew();
		rc.device.browser.isIE		= false;
		rc.device.browser.isFirefox	= false;
		rc.device.browser.isChrome	= false;
		rc.device.browser.isSafari	= false;
		rc.device.browser.isOpera	= false;
		rc.device.browser.name		= "";
		rc.device.browser.version	= 0;

		//  browser detection
		if(find("chrome",ua)){
			rc.device.browser.isChrome = true;
			rc.device.browser.name = "Chrome";
			try{
				tmp = removeChars(ua,1,findNoCase(rc.device.browser.name,tmp)-1);
				tmp = listToArray(tmp,'/ ');
				rc.device.browser.version = tmp[2];
				if(listFirst(rc.device.browser.version,'.') gte 11){
					rc.device.isHTML5 = true;
				}
			}catch(any e){

			}
		}else if(find('firefox',ua)){
			rc.device.browser.isFirefox = true;
			rc.device.browser.name = "Firefox";
			try{
				tmp = removeChars(ua,1,findNoCase(rc.device.browser.name,tmp)-1);
				tmp = listToArray(tmp,'/ ');
				rc.device.browser.version = tmp[2];
				if(listFirst(rc.device.browser.version,'.') gte 5){
					rc.device.isHTML5 = true;
				}
			}catch(any e){

			}
		}else if(find('msie',ua)){
			rc.device.browser.isIE = true;
			rc.device.browser.name = "MSIE";
			try{
				tmp = removeChars(ua,1,findNoCase(rc.device.browser.name,tmp)-1);
				tmp = listToArray(tmp,'/ ;');
				rc.device.browser.version = tmp[2];
				if(listFirst(rc.device.browser.version,'.') gte 9){
					rc.device.isHTML5 = true;
				}
			}catch(any e){

			}
		}else if(find('safari',ua)){
			rc.device.browser.isSafari = true;
			rc.device.browser.name = "Safari";
			try{
				tmp = removeChars(ua,1,findNoCase(' version',tmp)-1);
				tmp = listToArray(tmp,'/ ');
				rc.device.browser.version = tmp[2];
				if(listFirst(rc.device.browser.version,'.') gte 5){
					rc.device.isHTML5 = true;
				}
			}catch(any e){

			}
		}else if(find('opera',ua)){
			rc.device.browser.isOpera = true;
			rc.device.browser.name = "Opera";
			try{
				tmp = removeChars(ua,1,findNoCase(' version',tmp)-1);
				tmp = listToArray(tmp,'/ ');
				rc.device.browser.version = tmp[2];
				if(listFirst(rc.device.browser.version,'.') gte 11){
					rc.device.isHTML5 = true;
				}
			}catch(any e){

			}
		}

		// operating system
		if(find('macintosh',ua)){
			rc.device.os.isApple = true;
			rc.device.isDesktop = true;
		}else if(find('windows',ua)){
			rc.device.os.isWindows = true;
			rc.device.isDesktop = true;
		}else if(find('android',ua)){
			rc.device.os.isAndroid = true;
			rc.device.isMobileAgent = true;
		}else if(find('linux',ua)){
			rc.device.os.isLinux = true;
			rc.device.isDesktop = true;
		}else if(find('like mac os x',ua)){
			rc.device.os.isiOS = true;
			rc.device.isMobileAgent = true;
		}else if(find('blackbery',ua)){
			rc.device.os.isBlackberry = true;
			rc.device.isMobileAgent = true;
		}

		if(find('ipad',ua)){
			rc.device.isTablet = true;
		}

		rc.device.results = ua;
	}

	public void function preLayout(required any event,required any interceptData){
		var rc = arguments.event.getCollection();

	}


	private struct function userAgentBreakdown(required string ua) {

	    var returnObj = structNew();
	    	returnObj.os = structNew();

	    var uaString = arguments.ua;

		// hack to make blackberry work on old devices
	    uaString = replaceNoCase(uaString,'BlackBerry','BlackBerry ','all');

	    var userAgent=listToArray(uaString,';()');

	    if(arraylen(userAgent) eq 1){
	    	var temp=listToArray(uaString,'/;()');
	    	userAgent = arrayNew(1);
	    	for(var i=1;i<=arrayLen(temp);i++){
	    		if(arrayLen(temp) gte (i+1)){
		    		arrayAppend(userAgent,temp[i] & " " & temp[i+1]);
		    		i++;
	    		}
	    	}
	    }


		for(var i=arrayLen(userAgent);i>0;i--){
			if(!structKeyExists(returnObj.os,'name')){
				switch(lcase(listFirst(userAgent[i]," /-:"))){
					case "android":
						returnObj.os.name = "Android";
						break;
					case "blackberry":
						returnObj.os.name = "BlackBerry";
						break;
					case "symbian":
						returnObj.os.name = "SymbianOS";
						break;
					case "windows":
						returnObj.os.name = "Windows";
						break;
					case "apple,macintosh":
						returnObj.os.name = "Apple";
						break;
					case "linux":
						returnObj.os.name = "Linux";
						break;
					case "unix":
						returnObj.os.name = "Unix";
						break;
				}
				if(structKeyExists(returnObj.os,'name')){
					returnObj.os.version = breakoutVersion(userAgent[i],returnObj.os.name);
					arrayDeleteAt(userAgent,i);
					break;
				}
			}
		}

		returnObj.ua = userAgent;

		return returnObj;
	}

	private string function breakoutVersion(required string str,required string osname){
		var data = listLast(arguments.str," /:\=_+");

		if(data eq arguments.osname){
			data = 0;
		}

		return data;
	}
}