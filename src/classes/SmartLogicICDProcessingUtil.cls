public class SmartLogicICDProcessingUtil {
    

    public void fetchAndStoreICDCodes(List<SmartLogicAggregateResponse.SmartDiagnosisResult> respList){
    	string icdList='';
    	FOR(SmartLogicAggregateResponse.SmartDiagnosisResult resultList : respList){
             icdList+=resultList.ICD+',';	
      	}
        icdList=icdList.removeEnd(',');
        System.debug('================'+icdList);
        ICDResponse icdResp = jsonCalloutMedispan(icdList);
        if(icdResp!=null){
        	storeICDCodes(icdResp.codeProperties);
        }
        
	}
    
    public ICDResponse parseICDResponse(String jsonResponse){
        ICDResponse icdResp = (ICDResponse)JSON.deserialize(jsonResponse, ICDResponse.class);
        System.debug(icdResp);
        return icdResp;
    } 
    
    
   
     public  ICDResponse jsonCalloutMedispan(String searchTerm){
    	HTTPResponse res = new HTTPResponse();
        ICDResponse icdResp;
    	try{
    	 	HTTP auth = new HTTP();
	     	HTTPRequest r = new HTTPRequest();
	     	System.debug('Heap Size in jsonCalloutMedispan---:2--- '+Limits.getHeapSize());
	     	String accessToken = getAccessToken();
	     	System.debug('accessToken: '+accessToken);
    	 	String authorizationHeader = 'Bearer ' + accessToken;
	    	String endPoint = constructEndPoint(searchTerm);
	    	r.setEndpoint(endPoint);
	    	r.setMethod('GET');
	    	r.setHeader('Accept-Encoding','gzip, deflate');
        	r.setHeader('Accept','application/json');
        	r.setHeader('Authorization', authorizationHeader);
        	System.debug('NDC Search: '+searchTerm);
            res = auth.send(r);
        	System.debug(res.getBody());
            icdResp=parseICDResponse(res.getBody());
    	}
		catch(Exception e ) {
			System.debug(logginglevel.ERROR,'\n===========Error in SmartLogicICDProcessingUtil.jsonCalloutMedispan===========\n'+e.getMessage()+'\n'+e.getStackTraceString());
			res.setStatus('NOTOK');
		}
        return icdResp;
    }
    public String getAccessToken(){
    	Access_Token__c a = [select value__c from Access_Token__c limit 1];
    	return a.value__c;
    }
    public  String constructEndPoint(String searchTerm){
    	String endPointUrl = '';
        String ICD_LIST_API = 'icd/list?icdlist=<icd-list>&data=desc-full,hcc';
        CTSearch_configurations__mdt oConfiguration = [SELECT value__c FROM CTSearch_configurations__mdt WHERE DeveloperName='API_endpoint' LIMIT 1];
    	endPointUrl = oConfiguration.value__c;
    	endPointUrl += ICD_LIST_API.replace('<icd-list>',searchTerm);
    	System.debug('======endPointUrl======'+endPointUrl);
    	return endPointUrl;
    }
    public void storeICDCodes(List<CodeProperties> lstIcds){
    	//SELECT Id,Name FROM HCC_Codes__c WHERE Name IN ('HCC11','HCC2','HCC114')
		//SELECT Id,Name FROM ICD_Codes__c WHERE Name IN ('J16.8','Q68','I11.0')
		
		List<String> hccList = new List<String>();
		List<String> icdList = new List<String>();
		for(CodeProperties codePropery : lstIcds){
			if(String.isNotBlank(codePropery.hcc)){
				hccList.add(codePropery.hcc);
			}
			if(String.isNotBlank(codePropery.code)){
				icdList.add(codePropery.code);
			}
		}
        List<ICD_Codes__c> icdCodeList = [select id,name from ICD_Codes__c where name in :icdList];
        List<HCC_Codes__c> hccCodeList = [select id,name from HCC_Codes__c where name in :hccList];
        
        Map<String,ID> hccIDMap = new Map<String,ID>();
        Map<String,ID> icdIDMap = new Map<String,ID>();
        
        for(ICD_Codes__c icdOb : icdCodeList){
        	icdIDMap.put(icdOb.name,icdOb.id);
        }
        for(HCC_Codes__c hccOb : hccCodeList){
        	hccIDMap.put(hccOb.name,hccOb.id);
        }
        
        for(CodeProperties codePropery : lstIcds){
        	HCC_Codes__c hccObject = null;
        	ICD_Codes__c icdObject = null;
            Savepoint sp = Database.setSavepoint();
        	try{
	        	if(String.isNotBlank(codePropery.hcc)){
	        		hccObject = new HCC_Codes__c();
	        		hccObject.Name = codePropery.hcc;
	        		hccObject.HCC_Description__c = codePropery.hccDesc;
	        		hccObject.Effective_Date__c = formatDate(codePropery.serviceDate);
	        		if(hccIDMap.containsKey(codePropery.hcc)){
	        			hccObject.id = hccIDMap.get(codePropery.hcc);
	        		}
	        		upsert hccObject;
	        	}
	        	
	        	if(String.isNotBlank(codePropery.code)){
	        		icdObject = new ICD_Codes__c();
	        		icdObject.Name = codePropery.code;
	        		icdObject.ICD_Description__c = codePropery.descFull;
	        		icdObject.Effective_Date__c = formatDate(codePropery.serviceDate);
                    icdObject.ICD_Version__c = '0';
	        		if(icdIDMap.containsKey(codePropery.code)){
	        			icdObject.id = icdIDMap.get(codePropery.code);
	        		}
	        		if(hccObject!=null){
	        			icdObject.HCC_Code__c = hccObject.id;
	        		}
	        		upsert icdObject;
        		}
        	}catch(Exception e){
                Database.rollback( sp );
        		System.debug(logginglevel.ERROR,'\n===========Error in SmartLogicICDProcessingUtil.storeICDCodes==========='+icdObject.Name+'\n'+e.getMessage()+'\n'+e.getStackTraceString());
        	}
        }
     }
    private static Date formatDate(String strDate){
        List<String> strComp = strDate.split('/');
		String formatedDate = strComp.get(2)+'-'+strComp.get(1)+'-'+strComp.get(0)+' 00:00:00';
        Date effectDate = Date.valueOf(formatedDate);
        return effectDate;
    }
     public class ICDResponse{
        public List<CodeProperties> codeProperties{get;set;}
        public Status status{get;set;}
    }
     public class CodeProperties{
        public String code{get;set;}
        public String descFull{get;set;}
        public String hcc{get;set;}
        public String hccDesc{get;set;}
        public String serviceDate{get;set;}
        public String status{get;set;}
    }
    public class Status{
        public List<Messages> messages{get;set;}
        
    }
    public class Messages{
        public String code{get;set;}
		public String name{get;set;}
		public String severity{get;set;}
		public String description{get;set;}
		public String transactionId{get;set;}
    }

}