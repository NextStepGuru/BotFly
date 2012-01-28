component name="minify" output="false" extends="coldbox.system.interceptor"{
	property name="minifyHTML"	inject="coldbox:setting:minify_html";

	public void function configure(){

	}

	public void function preRender(){
		if(minifyHTML){
			var rc = arguments.event.getCollection();
			var temp = arguments.interceptData['renderedContent'];
			temp = replace(temp,chr(10),'','all');
			temp = replace(temp,'	','','all');
			if(rc.device.isHTML5 eq false || structKeyExists(rc,'noHTML5')){
				temp = reReplaceNoCase(temp,'<(section|article|nav|header|footer) ','<div ','all');
				temp = reReplaceNoCase(temp,'</(section|article|nav|header|footer)>','</div>','all');
			}

			arguments.interceptData['renderedContent'] = temp;
		}
	}

}
