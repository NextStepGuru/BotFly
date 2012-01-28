component{

	public string function findRootDomain(required string urlstr=cgi.http_host){
		var domainArray = listToArray(arguments.urlstr,'.');

		return domainArray[arrayLen(domainArray)-1] & '.' & domainArray[arrayLen(domainArray)];
	}

}
