public with sharing class SearchAPI { 
    
    //Class to hold the data for the IncludeExcluide Notes
    public class ICDIncludeExcludeNote {
        public String sNote {get;set;}
        public Integer iIndentation {get;set;}
        
        public ICDIncludeExcludeNote(String sNote, Integer iIndentation){
            this.sNote = sNote;
            this.iIndentation = iIndentation;
        }
    }
    
    //Class to hold the Search Result so that Search Ahead works properly
    public class SearchResult {
        @AuraEnabled
        public String searchKey;
        @AuraEnabled
        public List<Node> results = new List<Node>() ;
        @AuraEnabled
        public String mapResults = '' ;
      
        public SearchResult(String searchKey, List<Node> results){
            this.searchKey = searchKey ;
            this.results = results ;
        }
     
        public SearchResult(String searchKey, String mapResults){
            this.searchKey = searchKey ;
            this.mapResults = mapResults;
        }
    }
        
    //Class to create collection that would hold the search data to be displayed on the Search Report Page
    public class SearchReport {
        @AuraEnabled
        public String sICD9Code {get;set;}
        @AuraEnabled
        public String sICD10Codes {get;set;}
        @AuraEnabled
        public String sICDDescription {get;set;}
        @AuraEnabled
        public String hccCode {get;set;}
        @AuraEnabled
        public String hccDescription {get;set;}
    }
    
    //Class to to create collection that would hold the Datat to be data to vbe displayed for the Include-Exclude/Instructional Notes
    public class Notes {
        @AuraEnabled
        public String sNoteType {get;set;}
        @AuraEnabled
        public String sHeaderNote {get;set;}
        @AuraEnabled
        public String sHeaderType {get;set;}
        @AuraEnabled
        public List<String> lstNote {get;set;}
        @AuraEnabled
        public List<ICDIncludeExcludeNote> lstNoteWithIndentation {get;set;}
    }
    
    //Class to
    public class ICD10Hierarchy {
        @AuraEnabled
        public Map<Node, ICD10SubCategory> data {get;set;}
        @AuraEnabled
        public Set<Node> keys {get;set;}
        public ICD10Hierarchy() {
           data = new Map<Node, ICD10SubCategory> ();
           keys = data.keySet();
        }
    }
    
    //Class to 
    public class ICD10SubCategory {
      @AuraEnabled
      public Map<Node, ICD10SubCategoryNodes> data {get;set;}
      @AuraEnabled
      public Set<Node> keys {get;set;}
      public ICD10SubCategory( ) {
        data = new  Map<Node, ICD10SubCategoryNodes>();
        keys = data.keySet();
      }
    }
    
    //Class to
    public class ICD10SubCategoryNodes {
      public List<Node> data {get;set;}
      public ICD10SubCategoryNodes() {
        data = new List<Node>();
     }
    }
        
    //Method to perform a callout and return an httpResponse
    public List<Node> getSearchResults(String searchString){
        try
        {
            String endpoint = 'callout:Optum_360_Term_Search/'+searchString.trim().replaceAll('\\s+', '%20')+'?'+SearchConstants.SEARCH_PARAMS;
            System.debug(' Endpoint  ' + endpoint);
            HttpUtil util = new HttpUtil();
            httpResponse res = util.callout(endpoint);

            Dom.Document doc = res.getBodyDocument();
            SearchParseUtil.TermSearchResults tsgSearchResults = SearchParseUtil.parseSearchResults(doc);
            System.debug((tsgSearchResults.termSearchNodeList.size())+'<<--------->>'+tsgSearchResults.termSearchNodeList);
            return tsgSearchResults.termSearchNodeList;
        }
        catch(Exception e)
        {
            System.debug('Caught '+e.getMessage()+' '+e.getStackTraceString());  
            return null;
        }
    }
    
     //Method to perform a callout and return an httpResponse
    public void getJSONSearchResults(String searchString){
        try
        {
            String endpoint = 'callout:Optum_360_Term_Search/'+searchString.trim().replaceAll('\\s+', '%20')+'?'+SearchConstants.SEARCH_PARAMS;
            System.debug(' Endpoint  ' + endpoint);
            HttpUtil util = new HttpUtil();
            httpResponse res = util.jsonCallout(endpoint);
            
            String sModifiedJSONString = res.getBody();
            sModifiedJSONString = sModifiedJSONString.replaceAll('term-search-group', 'TermSearchGroup');
            sModifiedJSONString = sModifiedJSONString.replaceAll('desc', 'description');
            sModifiedJSONString = sModifiedJSONString.replaceAll('@href-beg', 'href');
            sModifiedJSONString = sModifiedJSONString.replaceAll('node', 'Node');
            sModifiedJSONString = sModifiedJSONString.substring(19, sModifiedJSONString.length()-1);
            System.debug('===Response==='+sModifiedJSONString);
            List<TermSearchGroup> lstTermSearchGroup = (List<TermSearchGroup>)JSON.deserialize(res.getBody(), List<TermSearchGroup>.class);
            System.debug('===Response==='+lstTermSearchGroup);
        }
        catch(Exception e)
        {
            System.debug('Caught '+e.getMessage()+' '+e.getStackTraceString());  
        }
    }
    
    //Method to perform a callout and return an httpResponse
    public List<Node> getICD10SearchResults(String sICD10Code){
        try
        {
            String endpoint = 'callout:Optum_360_ICD10/'+EncodingUtil.urlEncode(sICD10Code.trim(),'UTF-8')+SearchConstants.ICD10_SEARCH_PARAMS;
            HttpUtil util = new HttpUtil();            
            httpResponse res = util.callout(endpoint);
            
            Dom.Document doc = res.getBodyDocument();            
            SearchParseUtil.TermSearchResults tsgSearchResults = SearchParseUtil.parseICD10SearchResults(doc, sICD10Code);            
            return tsgSearchResults.termSearchNodeList;
        }
        catch(Exception e){
            System.debug('Caught '+e.getMessage()+' '+e.getStackTraceString());      
            return null;
        }
    }
    
    //Method to perform a callout and return an httpResponse
    public List<Node> getICD9SearchResults(String sICD9Code){
        try
        {
            String endpoint = 'callout:Optum_360_ICD9_V1/'+EncodingUtil.urlEncode(sICD9Code.trim(),'UTF-8')+SearchConstants.ICD9_SEARCH_PARAMS;
            HttpUtil util = new HttpUtil();            
            httpResponse res = util.callout(endpoint); 
            
            Dom.Document doc = res.getBodyDocument();
            SearchParseUtil.TermSearchResults tsgSearchResults = SearchParseUtil.parseSearchResults(doc);
            return tsgSearchResults.termSearchNodeList;
        }
        catch(Exception e)
        {
           System.debug('Caught '+e.getMessage()+' '+e.getStackTraceString()); 
           return null;
        }
    }
    
    //Method to perform a callout and return an httpResponse containing the ICD 9 Code
    public String getICD9Codes(String sICD10Code){
        String sICD9Codes = '';
        try
        {
            String endpoint = 'callout:Optum_360_ICD10/'+sICD10Code+SearchConstants.ICD9_Code_FETCH_PARAMS;
            HttpUtil util = new HttpUtil();
            List<Node> lstNode = new List<Node>();
            httpResponse res = util.callout(endpoint);
            
            Dom.Document doc = res.getBodyDocument();
            sICD9Codes = SearchParseUtil.parseICD9Mapping(doc);
        }
        catch(Exception e)
        {
           System.debug('Caught '+e.getMessage()+' '+e.getStackTraceString()); 
        }
        return sICD9Codes;
    }
    
    //Method to perform a callout and return an httpResponse containing the ICD 10 Instructional Notes
    public List<Notes> getICD10InstructionalNotes(String sICD10Code){
        List<Notes> lstNotes = new List<Notes>();
        try
        {
            String endpoint = 'callout:Optum_360_ICD10/'+sICD10Code+'/'+SearchConstants.ICD_INSTRUCTIONAL_NOTES_PARAMS;
            HttpUtil util = new HttpUtil();            
            httpResponse res = util.callout(endpoint);
            
            Dom.Document doc = res.getBodyDocument();            
            lstNotes = SearchParseUtil.parseICDInstructionalNotes(doc,SearchConstants.ICD10_INSTRUCTIONAL_NOTES_ROOTNODE);
        }
        catch(Exception e)
        {
            System.debug('Caught '+e.getMessage()+' '+e.getStackTraceString());
        }
        return lstNotes;
    }
    
    //Method to perform a callout and return an httpResponse containing the ICD 9 Instructional Notes
    public List<Notes> getICD9InstructionalNotes(String sICD9Code){
        List<Notes> lstNotes = new List<Notes>();
        try
        {
            String endpoint = 'callout:Optum_360_ICD9_V1/'+sICD9Code+'/'+SearchConstants.ICD_INSTRUCTIONAL_NOTES_PARAMS;
            HttpUtil util = new HttpUtil();            
            httpResponse res = util.callout(endpoint);
            
            Dom.Document doc = res.getBodyDocument();            
            lstNotes = SearchParseUtil.parseICDInstructionalNotes(doc, SearchConstants.ICD_INSTRUCTIONAL_NOTES_PARAMS);
        }
        catch(Exception e)
        {
            System.debug('Caught '+e.getMessage()+' '+e.getStackTraceString()); 
        }
        return lstNotes;
    }
    
    //Method to perform a callout and return an httpResponse containing the ICD 10 Include Exclude Notes
    public List<Notes> getICD10IncludeExcludeNotes(String sICD10Code){
        List<Notes> lstNotes = new List<Notes>();
        try
        {
            String endpoint = 'callout:Optum_360_ICD10/'+sICD10Code+SearchConstants.ICD_INCLUDE_EXCLUDE_PARAMS;
            HttpUtil util = new HttpUtil();
            httpResponse res = util.callout(endpoint);
            
            Dom.Document doc = res.getBodyDocument();
            lstNotes = SearchParseUtil.parseICDIncludeExcludeNotes(doc);
        }
        catch(Exception e)
        {
            System.debug('Caught '+e.getMessage()+' '+e.getStackTraceString()); 
        }
        return lstNotes;
    }
    
    //Method to perform a callout and return an httpResponse containing the ICD 9 Include Exclude Notes
    public List<Notes> getICD9IncludeExcludeNotes(String sICD9Code){
        List<Notes> lstNotes = new List<Notes>();
        try
        {
            System.debug('=====sICD9Code====='+sICD9Code);
            String endpoint = 'callout:Optum_360_ICD9_V1/'+sICD9Code+SearchConstants.ICD_INCLUDE_EXCLUDE_PARAMS;
            HttpUtil util = new HttpUtil();
            httpResponse res = util.callout(endpoint);
            
            Dom.Document doc = res.getBodyDocument();
            lstNotes = SearchParseUtil.parseICDIncludeExcludeNotes(doc);
        }
        catch(Exception e)
        {
            System.debug('Caught '+e.getMessage()+' '+e.getStackTraceString()); 
        }
        return lstNotes;
    }
    
    public List<Node> getICD10Range(String sICD10Codes){
        List<Node> lstICD10Range = new List<Node>();        
        try
        {
            String endpoint = 'callout:Optum_360_ICD10/'+EncodingUtil.urlEncode(sICD10Codes.trim(),'UTF-8')+SearchConstants.ICD10_RANGE_PARAMS;
			System.debug('endpoint: '+endpoint);            
            HttpUtil util = new HttpUtil();            
            httpResponse res = util.callout(endpoint);  
            
            Dom.Document doc = res.getBodyDocument();
            lstICD10Range = SearchParseUtil.parseICD10RangeResults(doc);            
            return lstICD10Range;
        }
        catch(Exception e)
        {
            System.debug('Caught '+e.getMessage()+' '+e.getStackTraceString()); 
            return null;
        }        
    }
}