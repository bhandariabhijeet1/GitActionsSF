@isTest
public class SearchAPIsTest {

    @isTest
    public static void testTermSearch(){
        Test.setMock(HttpCalloutMock.class,new SearchAPIMock());
        SearchAPI searchApi = new SearchAPI();
       // List<Node> nodeList = searchApi.getSearchResults('fract');
       SearchAPI.SearchResult result =  SearchController.getAPIResponse('fract',true);       
        List<Node> nodeList = result.results;
        System.assertEquals(false, (nodeList.size()>1));
      //  System.assertEquals('Success' , actualValue);
        if(nodeList==null){
            nodeList = new List<Node>();
        }
        for(Node node : nodeList){
            for(Node node1 : nodeList){
            Integer c = node1.compareTo(node);
            System.assertEquals(true, (c==0||c==1||c==-1));
            }
        }
    }
    
    @isTest
    public static void testReportSearch(){
        Test.setMock(HttpCalloutMock.class,new SearchAPIMock());
        SearchAPI searchApi = new SearchAPI();
       // List<Node> nodeList = searchApi.getSearchResults('fract');
     //  SearchAPI.SearchResult result =  SearchController.getAPIResponse('fract');
      LIST<SearchAPI.SearchReport> listReports =  SearchController.getReportingData('C41.3', 'sICDDescription','70','sHCCDescription');
      //  System.assertEquals('Success' , actualValue);
        if(listReports==null){
            listReports = new List<SearchAPI.SearchReport>();
        }
      	System.debug('Node Size rep: '+listReports.size());
        System.debug('Node  : '+listReports);
        System.assertEquals(true, (listReports.size()>=1));
        
    }
    
    @isTest
    public static void testICD10Search(){
        
        Test.setMock(HttpCalloutMock.class,new SearchAPIMock());
        SearchAPI searchApi = new SearchAPI();
        //List<Node> nodeList = searchApi.getICD10SearchResults('C41.3');
        SearchAPI.SearchResult result =  SearchController.getAPIResponse('C41.3',false);
        List<Node> nodeList = result.results;
      //  System.assertEquals('Success' , actualValue);
        if(nodeList==null){
            nodeList = new List<Node>();
        }
      	System.debug('Node Size I10 : '+nodeList.size());
        System.debug('Node  I10: '+nodeList);
        System.assertEquals(true, (nodeList.size()>=1));
        
    }
    
    @isTest
    public static void testICD10InstructionalNotes(){
        Test.setMock(HttpCalloutMock.class,new SearchAPIMock());
        SearchAPI searchApi = new SearchAPI();
        List<SearchAPI.Notes> nodeList = searchApi.getICD10InstructionalNotes('C41.3');
        String instNotes = SearchController.getICD10InstructionalNotes('C41.3', '');
      //  System.assertEquals('Success' , actualValue);
        if(nodeList==null){
            System.debug('Notes are null');
            nodeList = new List<SearchAPI.Notes>();
        }
        if(instNotes==null){
            instNotes='';
        }
      	System.debug('Node Size note : '+nodeList.size());
        System.debug('Node  note: '+nodeList);
        System.assertEquals(true, (nodeList.size()>=1));
        System.assertEquals(true, (instNotes.length()>0));
    }
    
    @isTest
    public static void testICD10IncludeExcludeNotes(){
        Test.setMock(HttpCalloutMock.class,new SearchAPIMock());
        SearchAPI searchApi = new SearchAPI();
        List<SearchAPI.Notes> nodeList = searchApi.getICD10IncludeExcludeNotes('C41');
        String incExNotes = SearchController.getICD10IncludeExcludeNotes('C41', '');
      //  System.assertEquals('Success' , actualValue);
        if(nodeList==null){
            System.debug('Notes are null');
            nodeList = new List<SearchAPI.Notes>();
        }
        if(incExNotes==null){
            System.debug('Notes are null');
            incExNotes = '';
        }
      	System.debug('Node Size note : '+nodeList.size());
        System.debug('Node  note: '+nodeList);
        System.assertEquals(true, (nodeList.size()>=1));
        System.assertEquals(true, (incExNotes.length()>0));
    }
    
    @isTest
    public static void testICD10Range(){
        Test.setMock(HttpCalloutMock.class,new SearchAPIMock());
        SearchAPI searchApi = new SearchAPI();
        List<Node> nodeList = searchApi.getICD10Range('C41');
        String range = SearchController.getICD10Range('C41',false);
      //  System.assertEquals('Success' , actualValue);
        if(nodeList==null){
            System.debug('Notes are null');
            nodeList = new List<Node>();
        }
        if(range==null){
            range = '';
        }
      	System.debug('Node Size aaa : '+nodeList.size());
        System.debug('Node  aaa: '+nodeList);
        System.assertEquals(true, (nodeList.size()>=1));
        System.assertEquals(true, (range.length()>0));
    }
    
    @isTest
    public static void testICD9Search(){
        Test.setMock(HttpCalloutMock.class,new SearchAPIMock());
        SearchAPI searchApi = new SearchAPI();
       List<Node> nodeList = searchApi.getICD9SearchResults('171.3');
      //   SearchAPI.SearchResult result =  SearchController.getAPIResponse('171.3');
      //  List<Node> nodeList = result.results;
      //  System.assertEquals('Success' , actualValue);
        if(nodeList==null){
            System.debug('Notes are null');
            nodeList = new List<Node>();
        }
      	System.debug('Node Size note qqqq : '+nodeList.size());
        System.debug('Node  noteqqq: '+nodeList);
        System.assertEquals(true, (nodeList.size()>=1));
    }
    
    @isTest
    public static void testICD9CodeFetch(){
        Test.setMock(HttpCalloutMock.class,new SearchAPIMock());
        SearchAPI searchApi = new SearchAPI();
        String icdCodes = searchApi.getICD9Codes('C41.3');
        System.debug('icdCodes: '+icdCodes);
      //  System.assertEquals('Success' , actualValue);
        if(icdCodes==null){
           icdCodes='';
        }
        System.assertEquals(true, (icdCodes.length()>=1));
    }
    
     @isTest
     public static void testICD9InstructionalNotes(){
        Test.setMock(HttpCalloutMock.class,new SearchAPIMock());
        SearchAPI searchApi = new SearchAPI();
        List<SearchAPI.Notes> nodeList = searchApi.getICD9InstructionalNotes('171.3');
        String instNotes = SearchController.getICD9InstructionalNotes('', '171.3');
      //  System.assertEquals('Success' , actualValue);
        if(nodeList==null){
            System.debug('Notes are null');
            nodeList = new List<SearchAPI.Notes>();
        }
         if(instNotes==null){
             instNotes = '';
         }
      	System.debug('Node Size note : '+nodeList.size());
        System.debug('Node  note: '+nodeList);
        System.assertEquals(true, (nodeList.size()>=1));
        System.assertEquals(true, (instNotes.length()>=1));
    }
 	 @isTest	   
     public static void testICD9IncludeExcludeNotes(){
        Test.setMock(HttpCalloutMock.class,new SearchAPIMock());
        SearchAPI searchApi = new SearchAPI();
        List<SearchAPI.Notes> nodeList = searchApi.getICD9IncludeExcludeNotes('171.3');
        String notes = SearchController.getICD9IncludeExcludeNotes('', '171.3');
      //  System.assertEquals('Success' , actualValue);
        if(nodeList==null){
            System.debug('Notes are null');
            nodeList = new List<SearchAPI.Notes>();
        }
         if(notes==null){
             notes = '';
         }
         String testCode = SearchController.getCode('C41');
        System.assertEquals('TestC41',testCode); 
        System.assertEquals(true, (nodeList.size()==0));
        System.assertEquals(true, (notes.equalsIgnoreCase('[]')));
    }
 
}