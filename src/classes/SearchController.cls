public with sharing class SearchController {
    
    public static List<Node> icdCodeCache = null; 
    
    @AuraEnabled
    public static void addICDCodeToCache(String icdCode, String icdDescription, String hccCode, String hccDescription){
        System.debug('Inside addICDCodeToCache: '+icdCode+' '+icdDescription);
        icdCodeCache = (List<Node>)Cache.Session.get('icdCodeCache');
        if(icdCodeCache==null){
            System.debug('Cache is null');
            icdCodeCache = new List<Node>();
        } 
        if(String.isNotEmpty(icdCode)){
            Node n1 = new Node();
            n1.code = icdCode;
            n1.description = icdDescription;
            n1.hccCode = hccCode;
            n1.hccDescription = hccDescription;
            icdCodeCache.add(n1);            
        }
        Map<String,Node> tempMap = new Map<String,Node>();
        for(Node tempNode:icdCodeCache){
            tempMap.put(tempNode.code, tempNode);
        }
        icdCodeCache = new List<Node>();
        icdCodeCache.addAll(tempMap.values());
        Cache.Session.put('icdCodeCache', icdCodeCache);
    }
    
    @AuraEnabled
    public static List<Node> getICDCodeCache(){
        icdCodeCache = (List<Node>)Cache.Session.get('icdCodeCache');
        if(icdCodeCache==null){
            System.debug('Cache is null');
            icdCodeCache = new List<Node>();
        } 
        return icdCodeCache;
    }
    
    @AuraEnabled
    public static Boolean isICDCodePresentInCache(String icdCode){
        System.debug('isICDCodePresentInCache');
        icdCodeCache = (List<Node>)Cache.Session.get('icdCodeCache');
        Boolean icdCodePresent=false;
        if(icdCodeCache!=null){
            for(Node n : icdCodeCache){
                if(String.isNotEmpty(icdCode) && icdCode.equalsIgnoreCase(n.code)){
                    icdCodePresent=true;
                    break;
                }
            }
        }
        return icdCodePresent;
    }
    
    @AuraEnabled
    public static void removeICDCodeFromCache(String icdCodeToRemove){     
        icdCodeCache = (List<Node>)Cache.Session.get('icdCodeCache');
        if(icdCodeCache !=null){
            if(String.isNotEmpty(icdCodeToRemove) && icdCodeToRemove.equalsIgnoreCase('remove-all')){
                icdCodeCache = new List<Node>();
            }else{
                Integer index = 0;
                for(Node n : icdCodeCache){
                    if(String.isNotEmpty(icdCodeToRemove) && icdCodeToRemove.equalsIgnoreCase(n.code)){
                        System.debug('Found Icd Code to be removed...');
                        icdCodeCache.remove(index);
                        break;
                    } 
                    index++;
                }
            }
            Cache.Session.remove('icdCodeCache');
            Cache.Session.put('icdCodeCache', icdCodeCache);
        }
    }
    
    @AuraEnabled
    public static String getUserName() {
        return userinfo.getName();
    }
    
    @AuraEnabled
    public static SearchAPI.SearchResult getAPIResponse(String searchString, Boolean isMapRequired){
        SearchAPI searchAPI = new SearchAPI();
        List<Node> nodes = new List<Node>();
        //Replace Search String with matching acronym 
        String  sReplacementSearchString = SearchUtil.fetchReplacementAcronym(searchString);
        String sSearchType = SearchUtil.verifySearchType(sReplacementSearchString);
        
        System.debug(sReplacementSearchString+' sSearchType: '+sSearchType);
        
        if(sSearchType.equalsIgnoreCase('ICD10Code'))
        {
            sReplacementSearchString = sReplacementSearchString.toUpperCase();
            nodes = searchAPI.getICD10SearchResults(sReplacementSearchString);  
        }
        else if(isICD9SearchEnabled() && sSearchType.equalsIgnoreCase('ICD9Code'))
        {
            //below code will execute if ICD9 based search is allowed and SearchType is ICD09 code
            nodes = searchAPI.getICD9SearchResults(sReplacementSearchString);  
        }
        else
        {
            nodes = searchAPI.getSearchResults(sReplacementSearchString);   
        }
        //nodes = SearchUtil.checkForChildrenWithHCC(nodes);
        if(isMapRequired) {
            if(nodes!=null){
             	SearchAPI.SearchResult result = new SearchAPI.SearchResult(searchString, SearchUtil.getICD10Hierarchy(nodes,false)) ;
             	return result; 
            }
        }
        SearchAPI.SearchResult result = new SearchAPI.SearchResult(searchString, nodes) ;
        return result;
    }
    
     @AuraEnabled
    public static SearchAPI.SearchResult getAPIResponseForFav(String searchList, Boolean isMapRequired){        
        SearchAPI searchAPI = new SearchAPI();
        List<Node> nodes = new List<Node>();
        for(String searchString : searchList.split(',')) {
     
        //Replace Search String with matching acronym 
        String  sReplacementSearchString = SearchUtil.fetchReplacementAcronym(searchString);
        String sSearchType = SearchUtil.verifySearchType(sReplacementSearchString);
        
        System.debug(sReplacementSearchString+' sSearchType: '+sSearchType);
        
        if(sSearchType.equalsIgnoreCase('ICD10Code'))
        {
            sReplacementSearchString = sReplacementSearchString.toUpperCase();
            nodes.addAll(searchAPI.getICD10Range(sReplacementSearchString));  
        }
        else if(isICD9SearchEnabled() && sSearchType.equalsIgnoreCase('ICD9Code'))
        {
            //below code will execute if ICD9 based search is allowed and SearchType is ICD09 code
            nodes.addAll(searchAPI.getICD9SearchResults(sReplacementSearchString));  
        }
        else
        {
            nodes.addAll(searchAPI.getSearchResults(sReplacementSearchString));   
        }        
        
        //nodes = SearchUtil.checkForChildrenWithHCC(nodes);
        } 
         if(isMapRequired) {
             SearchAPI.SearchResult result = new SearchAPI.SearchResult(searchList, SearchUtil.getICD10Hierarchy(nodes, false)) ;
             return result;   
         }
        SearchAPI.SearchResult result = new SearchAPI.SearchResult(searchList, nodes) ;
        return result; 
     }   
    
    @AuraEnabled
    public static List<SearchAPI.SearchReport> getReportingData(String sICD10Codes, String sICDDescription, String sHccCode, String sHccDesc){
        System.debug('getReportingData: '+sHccCode+' '+sHccDesc);        
        SearchAPI searchAPI = new SearchAPI();
        SearchAPI.SearchReport oSearchReport = new SearchAPI.SearchReport();
        List<SearchAPI.SearchReport> lstSearchReport = new List<SearchAPI.SearchReport>();
        if(sHccCode==null){
            sHccCode='';
        }
        if(sHccDesc==null){
            sHccDesc='';
        }
        oSearchReport.sICD10Codes = sICD10Codes;
        oSearchReport.sICDDescription = sICDDescription;
        oSearchReport.hccDescription = sHccDesc;
        oSearchReport.hccCode = sHccCode;
        oSearchReport.sICD9Code = searchAPI.getICD9Codes(sICD10Codes);            
        lstSearchReport.add(oSearchReport);
        return lstSearchReport;  
    }
    
    @AuraEnabled
    public static String getICD10InstructionalNotes(String sICD10Codes, String sICD9Codes){
        string returnvariable;
        SearchAPI searchAPI = new SearchAPI();
        SearchAPI.Notes oNotes = new SearchAPI.Notes();
        List<SearchAPI.Notes> lstNotes = new List<SearchAPI.Notes>();

        lstNotes = searchAPI.getICD10InstructionalNotes(sICD10Codes);
        returnvariable = JSON.serialize(lstNotes);    
        return returnvariable;
    }
    
    @AuraEnabled
    public static String getICD9InstructionalNotes(String sICD10Codes, String sICD9Codes){
        string returnvariable;
        SearchAPI searchAPI = new SearchAPI();
        SearchAPI.Notes oNotes = new SearchAPI.Notes();
        List<SearchAPI.Notes> lstNotes = new List<SearchAPI.Notes>();

        if(String.isNotBlank(sICD9Codes) && !sICD9Codes.equalsIgnoreCase('NA'))
        {
            sICD9Codes = sICD9Codes.containsIgnoreCase(',') ? sICD9Codes.split(',')[0] : sICD9Codes;
            lstNotes = searchAPI.getICD9InstructionalNotes(sICD9Codes);
        }        
        returnvariable = JSON.serialize(lstNotes);        
        return returnvariable;  
    }
    
    @AuraEnabled
    public static String getICD10IncludeExcludeNotes(String sICD10Codes, String sICD9Codes){
        string returnvariable;
        SearchAPI searchAPI = new SearchAPI();
        SearchAPI.Notes oNotes = new SearchAPI.Notes();
        List<SearchAPI.Notes> lstNotes = new List<SearchAPI.Notes>();
        
        lstNotes = searchAPI.getICD10IncludeExcludeNotes(sICD10Codes);
        system.debug('lstNotes=='+lstNotes);
        returnvariable = JSON.serialize(lstNotes);    
        return returnvariable;
    }
    
    @AuraEnabled
    public static String getICD9IncludeExcludeNotes(String sICD10Codes, String sICD9Codes){
        string returnvariable;
        SearchAPI searchAPI = new SearchAPI();
        SearchAPI.Notes oNotes = new SearchAPI.Notes();
        List<SearchAPI.Notes> lstNotes = new List<SearchAPI.Notes>();   
        
        if(String.isNotBlank(sICD9Codes) && !sICD9Codes.equalsIgnoreCase('NA'))
        {
            sICD9Codes = sICD9Codes.containsIgnoreCase(',') ? sICD9Codes.split(',')[0] : sICD9Codes;
            lstNotes = searchAPI.getICD9IncludeExcludeNotes(sICD9Codes);
        }        
        returnvariable = JSON.serialize(lstNotes);    
        return returnvariable;
    }
    
    @AuraEnabled
    public static String getICD10Range(String sICD10Codes, Boolean isMapRequired ){
        string returnvariable;
        SearchAPI searchAPI = new SearchAPI();
        List<Node> lstNodes = new List<Node>();   
        
        if(String.isNotBlank(sICD10Codes) && !sICD10Codes.equalsIgnoreCase('NA'))
        {
            lstNodes = searchAPI.getICD10Range(sICD10Codes);
            System.debug('Calling from getICDrange');
            //lstNodes = SearchUtil.checkForChildrenWithHCC(lstNodes);
        }  
        if(isMapRequired) {
           return SearchUtil.getICD10Hierarchy(lstNodes,false);
        }
        returnvariable = JSON.serialize(lstNodes);     
        return returnvariable; 
    }
    
    @AuraEnabled
    public static String getCode(String code){ 
        return 'Test' + code;
    }   
     
    @AuraEnabled
    public static Boolean isICD9SearchEnabled(){
        System.debug('isICD9SearchEnabled called');
        String confValue = SearchUtil.getConfigValue('Enable_ICD09_Search');
        return (confValue!=null && confValue.equalsIgnoreCase('true'));
    }
    
    @AuraEnabled
    public static String addToMyFavorites(String ICDCode, String searchString) {
        System.debug('Add to my fav');
        String searchStr = (String)JSON.deserializeUntyped(searchString);
        return MyFavoritesController.addToMyFavorites(ICDCode, searchStr);
     }
 }