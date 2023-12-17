public class HTTPUtil {
    
    public httpResponse callout(String endpoint){
        //String endpoint = 'https://rtecstg.optum.com/ws/codetype/icd10cm/termsearchgroups/'+searchString+'?data=desc,rank&maxresult=5';
        
        //Instantiate an httpRequest and set the required attributes
        httpRequest req = new httpRequest();
        req.setMethod('GET');
        req.setEndpoint(endpoint);

		//Optional attributes are often required to conform to the 3rd Party Web Service Requirements
        req.setHeader('Accept-Encoding','gzip, deflate');
        req.setHeader('Accept','application/xml');
        
        //You can adjust the timeout duration (in milliseconds) to deal with slow servers or large payloads
        req.setTimeout(120000);
        
		httpResponse res = new http().send(req);
        return res;
    }
    
    public httpResponse jsonCallout(String endpoint){
        //String endpoint = 'https://rtecstg.optum.com/ws/codetype/icd10cm/termsearchgroups/'+searchString+'?data=desc,rank&maxresult=5';
        
        //Instantiate an httpRequest and set the required attributes
        httpRequest req = new httpRequest();
        req.setMethod('GET');
        req.setEndpoint(endpoint);

		//Optional attributes are often required to conform to the 3rd Party Web Service Requirements
        req.setHeader('Accept-Encoding','gzip, deflate');
        req.setHeader('Accept','application/json');
        
        //You can adjust the timeout duration (in milliseconds) to deal with slow servers or large payloads
        req.setTimeout(120000);
        
		httpResponse res = new http().send(req);
        return res;
    }

}