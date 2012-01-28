component
{

	emailYak function init(){

		setPluginName("emailYak");
		setPluginVersion("1.0");
		setPluginDescription("A wrapper for emailYak");
		setPluginAuthor("Jeremy R DeYoung");
		setPluginAuthorURL("http://www.lunarfly.com");

		return this;
	}

	public any function registerAddress(required string emailAddress,required string callbackURL="",required boolean pushEmail=false){
		var sendJSON = {'CallbackURL'=arguments.callbackURL,'PushEmail'=arguments.pushEmail,'Address'=arguments.emailAddress};

		return sendAndReceive(httpURL='https://api.emailyak.com/v1/qui7efnusdq120k/json/register/address/',sendJSON=sendJSON);
	}

	private any function sendAndReceive(required string httpURL,required any sendJSON,required string httpMethod="POST"){
		var httpService = new http();
		var resultStruct = "";

		if(len(toString(SerializeJSON(arguments.sendJSON))) eq 0)
		{
			$throw('Invalid Body Data');
		}

		if(structKeyExists(arguments,'sendJSON'))
		{
			httpService.addParam(type="body",value=toString(SerializeJSON(arguments.sendJSON)));
		}

		httpService.addParam(type="header",name="Accept",value="application/json");
		httpService.addParam(type="header",name="Content-Type",value="application/json");

		httpService.setMethod(arguments.httpMethod);
	    httpService.setCharset("utf-8");
	    httpService.setUrl(arguments.httpURL);


		var result = httpService.send().getPrefix();
		var resultStruct      = structNew();
		resultStruct.code     = ListFirst(result.statuscode," ");
		resultStruct.status   = RemoveChars(result.statuscode,1,4);
		if(IsJSON(result.fileContent))
		{
			resultStruct.response = DeserializeJSON(result.fileContent);
		}
		else
		{
			resultStruct.response = toString(result.fileContent);
		}

		return resultStruct;
	}

}