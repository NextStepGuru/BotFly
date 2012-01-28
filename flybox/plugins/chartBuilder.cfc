/*
* builds a google chart based on the input
* Available chart types:
* 	Area, Bar, Candlestick, Column, Combo, Gauge, Geo, Line, Pie, Scatter, Table, Tree Map
**/

component {

	property name="s3Access"	inject="coldbox:setting:s3Access";
	property name="s3Secret"	inject="coldbox:setting:s3Secret";


	//init(): initialize the plugin
	public chartBuilder function init(){
		// Plugin Properties
		setPluginName("chartBuilder");
		setPluginVersion("1.0");
		setPluginDescription("A Service Wrapper for building data for various chart outputs");
		setPluginAuthor("Jeremy R DeYoung");
		setPluginAuthorURL("http://www.lunarfly.com");
		//return data
		return this;
	}

	public any function buildImageChart(required string chartType, required any chartDataLabels, required any chartData, required any chartDataTitles, required any chartColor, required any chartTitle, required any chartTitleSize,required any chartSize,required any cdnSave=true){
		//variables
		var chartCode = '';

		var	chartCode &= "http://chart.apis.google.com/chart?"; //chart image url

		//switch based on chart type
		switch(arguments.chartType){
			// stacked bar chart
			case "GroupVerticaBarChart":
				chartCode &= "cht=bvg";
				chartCode &= "&chtt=" & urlEncodedFormat(arguments.chartTitle);
				chartCode &= "&chco=" & arguments.chartColor;
				chartCode &= "&chd=t:";
				for(var i=1;i<=arrayLen(arguments.chartData);i++){
					chartCode &= arrayToList(arguments.chartData[i]);
					if(i neq arrayLen(chartData)){
						chartCode &= "|";
					}
				}
				chartCode &= "&chdl=" & chartDataLabels;
				chartCode &= "&chdlp=r,chdlp=r&chbh=r,0.5,1.5&chxt=x,y&chxp=1&chxl=0:|";
				for(var i=1;i<=arrayLen(arguments.chartDataTitles);i++){
					chartCode &= arrayToList(arguments.chartDataTitles[i],'|');
				}
				chartCode &= "&chs=" & arguments.chartSize;
				break;

			//default
			default:
				break;
		}
		if(cdnSave){
			var httpService = new http();
				httpService.setUrl(chartCode);
			var data = httpService.send().getPrefix()['fileContent'];
			var img = createImageNameAndPath();
			var src = "s3://" & s3Access & ":" & s3Secret & "@s3.amazonaws.com/qzassets/charts/" & img.name & ".png";
			file action="write" file=src output=data;

			//return data
			return "https://s3.amazonaws.com/qzassets/charts/" & img.name & ".png";
		}else{
			return chartCode;
		}
	}

	public struct function createImageNameAndPath(){
		var returnObj = structNew();
		var imageName = lcase(reReplace(createUUID(),'\W','','ALL'));
		var uploadPath = getDirectoryFromPath(expandPath('./images/uploads/'));

		returnObj.name = imageName;
		returnObj.path = uploadPath;

		return returnObj;
	}

}