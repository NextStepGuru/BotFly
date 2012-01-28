component
{
	property name="javaLoader" inject="coldbox:plugin:JavaLoader";

	qrGenerator function init(){

		// Plugin Properties
		setPluginName("qrCodeGenerator");
		setPluginVersion("1.1");
		setPluginDescription("A Service Wrapper for multiple QR Code Generator APIs");
		setPluginAuthor("Jeremy R DeYoung");
		setPluginAuthorURL("http://www.lunarfly.com");

		return this;
	}

//******************************************* PUBLIC EVENTS *******************************************//


	public any function generateBarcode(required string service='local',required string encodeValue="Hello World",required boolean returnAsImage=false,required string imagePath=getDirectoryFromPath(ExpandPath('./')),required string imageName=createUUID() & '.png',required numeric size=8,required string errorCorrectionLevel="L",required string format="png",required numeric padding=4,required string version=1){

		if(!ListFindNoCase("H,M,Q,L",arguments.errorCorrectionLevel)){
			throw("The provided Error Correcting Level is invalid. Acceptable Error Correction Levels: L, Q, M, & H.","qrGenerator.errorCorrectionLevel","",500);
		}

		switch(arguments.service){
			case "goodSurvey":
				return goodSurvey(argumentCollection=arguments);
			case "googleChart":
				return googleChart(argumentCollection=arguments);
			case "local":
				return local(argumentCollection=arguments);
			default:
				throw("Please choose a Service Type","qrGenerator.Service","Invalid Service Type",500);
		}
	}


//******************************************* PRIVATE EVENTS *******************************************//

	private any function local(){
		javaLoader.appendPaths( expandPath('./plugins/') );

		var errorCorrectionLevel 	= javaLoader.create('com.google.zxing.qrcode.decoder.ErrorCorrectionLevel');
		var mode 					= javaLoader.create('com.google.zxing.qrcode.decoder.Mode');
		var encoder					= javaLoader.create('com.google.zxing.qrcode.encoder.Encoder');
		var qrCode					= javaLoader.create('com.google.zxing.qrcode.encoder.QRCode');

		qrCode.setVersion(arguments.version);
		if(isValid('URL',arguments.encodeValue) && len(arguments.encodeValue) lte 25){
			encoder.chooseMode(mode['ALPHANUMERIC']);
			encoder.encode(UCASE(arguments.encodeValue), errorCorrectionLevel[arguments.errorCorrectionLevel], qrCode);
		}else{
			encoder.encode(arguments.encodeValue, errorCorrectionLevel[arguments.errorCorrectionLevel], qrCode);
		}

		var matrix = listToArray(qrCode.getMatrix().toString(),chr(10));

		var offset = arguments.padding*arguments.size;
		var size = offset*2 + arguments.size*qrCode.getMatrixWidth();
		var img = ImageNew(source="",width=size, height=size,imageType='rgb',canvasColor='##FFFFFF');
		ImageSetDrawingColor(img,'black');

		for(var x=1;x<=arrayLen(matrix);x++){
			matrix[x]=listToArray(matrix[x],' ');
			for(var y=1;y<=arrayLen(matrix);y++){
				if(matrix[x][y] eq 1){
					ImageDrawRect(img, (y-1)*arguments.size+offset, (x-1)*arguments.size+offset, arguments.size-1, arguments.size-1, true);
				}
			}
		}

		if(arguments.returnAsImage){
			return img;
		}else{
			ImageWrite(img, arguments.imagePath & arguments.imageName);
			return arguments.imagePath & arguments.imageName;
		}
	}

	private any function goodSurvey(){
		var urlString = "http://qrcode.good-survey.com/api/v2/generate?";

		// encoding method
		if(isValid('URL' ,arguments.encodeValue) && hash(arguments.encodeValue) eq hash(lcase(arguments.encodeValue))){
			//set the encoded method as alphanumeric that ignores case - this is best for urls
			var encodedMethod = 'alphanumeric';
		}else{
			var encodedMethod = 'byte';
		}
		urlString = urlString & 'em=' & encodedMethod;

		// encode the URL
		urlString = urlString & '&content=' & urlEncodedFormat(arguments.encodeValue);

		// append the available format
		if(!listFindNoCase('png,jpg,bmp,tif,xaml,svg,eps,txt,html,zip',arguments.format)){
			throw('The provided format is invalid for this service : ' & arguments.format);
		}
		urlString = urlString & '&format=' & arguments.format;

		// append the available padding
		if(arguments.padding gt 4){
			throw('The provided padding is invalid for this service');
		}
		urlString = urlString & '&padding=' & arguments.padding;

		// append the available size
		if(arguments.size gt 20){
			throw('The provided size is invalid for this service');
		}
		urlString = urlString & '&size=' & arguments.size;

		urlString = urlString & '&ec=' & arguments.errorCorrectionLevel;

		// append the available version
		if((!isNumeric(arguments.version) && arguments.version neq 'auto') || (isNumeric(arguments.version) && arguments.version gt 40)){
			throw('The provided version is invalid for this service');
		}
		urlString = urlString & '&version=' & arguments.version;

		if(arguments.returnAsImage){
			var httpService = new http();
			httpService.setURL(urlString);
			httpService.setMethod('GET');
			httpService.send();

			return httpService.send().getPrefix()['filecontent'];
		}else{
			return urlString;
		}

	}

	private any function googleChart(){
		var urlString = "https://chart.googleapis.com/chart?cht=qr";

		// encode the URL
		urlString = urlString & '&chl=' & urlEncodedFormat(arguments.encodeValue);

		// append the available format
		if(!listFindNoCase('png,jpg,bmp,tif,xaml,svg,eps,txt,html,zip',arguments.format)){
			throw('The provided format is invalid for this service : ' & arguments.format);
		}
		urlString = urlString & '&format=' & arguments.format;

		// append the available padding
		if(arguments.padding gt 4){
			throw('The provided padding is invalid for this service');
		}
		// combine error correcting level and padding
		urlString = urlString & '&chld=' & arguments.errorCorrectionLevel & "|" & arguments.padding;

		// append the available size
		if(arguments.size gt 40){
			throw('The provided size is invalid for this service');
		}
		urlString = urlString & '&chs=' & round(arguments.size*23) & 'x' & round(arguments.size*23);

		if(arguments.returnAsImage){
			var httpService = new http();
			httpService.setURL(urlString);
			httpService.setMethod('post');
			httpService.send();

			return httpService.send().getPrefix()['filecontent'];
		}else{
			return urlString;
		}

	}

}