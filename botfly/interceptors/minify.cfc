component name="minify" output="false" extends="coldbox.system.interceptor"{
	property name="minifyHTML"	inject="coldbox:setting:minify_html";

	public void function configure(){

	}

	public void function preRender(){
		var rc = arguments.event.getCollection();
		var temp = arguments.interceptData['renderedContent'];

		if(rc.device.isHTML5 eq false || structKeyExists(rc,'noHTML5')){
			temp = reReplaceNoCase(temp,'<(section|article|nav|header|footer) ','<div ','all');
			temp = reReplaceNoCase(temp,'</(section|article|nav|header|footer)>','</div>','all');
		}

		if(minifyHTML){
			temp = replace(temp,chr(10),'','all');
			temp = replace(temp,'	','','all');

			arguments.interceptData['renderedContent'] = temp;
		}else{
			arguments.interceptData['renderedContent'] = trim(temp);
		}
	}

}
