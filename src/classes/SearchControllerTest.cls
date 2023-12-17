@isTest
public class SearchControllerTest {
    
    @testSetup  
    public static void setup() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='Attestationuser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='Attestationuser@testorg.com');
        insert u;
        
        Global_Favorites__c oGlobalFavoritesDiagnosis = new Global_Favorites__c(name='E21.1', ICD_Description__c='Secondary Hyperparathyroidism');
        insert oGlobalFavoritesDiagnosis;
        
        Global_Favorite_Searches__c oGlobalFavoritesSearches = new Global_Favorite_Searches__c(name='fract', Favorite_Search_Text__c='Fract');
        insert oGlobalFavoritesSearches;
        
        ICD_HCC_mapping__c oICDHCCMapping = new ICD_HCC_mapping__c(name='C41.3', HCC_code__c = '18', HCC_Description__c='Description');
        insert oICDHCCMapping;
        
        Acronym_mapping__c oAcronymMapping = new Acronym_mapping__c(name='dm2', Acronym_Replacement__c='DM 2');
        insert oAcronymMapping;
        
        
    }
     
    //Test method to verify if text search Output List is generated for given search
    public static testMethod void testTermSearch(){
        User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
        test.StartTest();
            System.runAs(oUser)
            {
                Test.setMock(HttpCalloutMock.class,new SearchAPIMock());
                SearchAPI searchApi = new SearchAPI();
               // List<Node> nodeList = searchApi.getSearchResults('fract');
               SearchAPI.SearchResult result =  SearchController.getAPIResponse('fract',true);       
               String sNodeHeirarchy = result.mapResults;
               System.assert(String.isNotBlank(sNodeHeirarchy));
               
               SearchAPI.SearchResult result1 =  SearchController.getAPIResponse('fract',false);       
               List<Node> nodeList = new List<Node>();
               nodeList = result1.results;
               for(Node node : nodeList){
                    for(Node node1 : nodeList){
                    Integer c = node1.compareTo(node);
                    System.assertEquals(true, (c==0||c==1||c==-1));
                    }
                }
              //  System.assertEquals('Success' , actualValue);
             }
        test.stopTest();
    }
    
    //Test method to verify if reporting data Output List is generated for given search
    public static testMethod void testReportSearch(){
        User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
        test.StartTest();
            System.runAs(oUser)
            {
                Test.setMock(HttpCalloutMock.class,new SearchAPIMock());
                SearchAPI searchApi = new SearchAPI();
               // List<Node> nodeList = searchApi.getSearchResults('fract');
             //  SearchAPI.SearchResult result =  SearchController.getAPIResponse('fract');
              LIST<SearchAPI.SearchReport> listReports =  SearchController.getReportingData('C41.3', 'sICDDescription','70','sHCCDescription');
              //  System.assertEquals('Success' , actualValue);
                if(listReports==null){
                    listReports = new List<SearchAPI.SearchReport>();
                }
                System.assertEquals(true, (listReports.size()>=1));
             }
        test.stopTest();
    }
    
    //Test method to verify if ICD 10 Search Output List is generated for given search
    public static testMethod void testICD10Search(){
        User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
        test.StartTest();
            System.runAs(oUser)
            {
                Test.setMock(HttpCalloutMock.class,new SearchAPIMock());
                SearchAPI searchApi = new SearchAPI();
                //List<Node> nodeList = searchApi.getICD10SearchResults('C41.3');
                SearchAPI.SearchResult result =  SearchController.getAPIResponse('C41.3',false);
                List<Node> nodeList = result.results;
              //  System.assertEquals('Success' , actualValue);
                if(nodeList==null){
                    nodeList = new List<Node>();
                }
                System.assertEquals(true, (nodeList.size()>=1));
            }
        test.stopTest();
    }
    
    //Test method to verify if ICD 10 Instructional Notes Output List is generated for given search
    public static testMethod void testICD10InstructionalNotes(){
        User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
        test.StartTest();
            System.runAs(oUser)
            {
                Test.setMock(HttpCalloutMock.class,new SearchAPIMock());
                SearchAPI searchApi = new SearchAPI();
                List<SearchAPI.Notes> nodeList = searchApi.getICD10InstructionalNotes('C41.3');
                String instNotes = SearchController.getICD10InstructionalNotes('C41.3', '');
              //  System.assertEquals('Success' , actualValue);
                if(nodeList==null){
                    nodeList = new List<SearchAPI.Notes>();
                }
                if(instNotes==null){
                    instNotes='';
                }

                System.assertEquals(true, (nodeList.size()>=1));
                System.assertEquals(true, (instNotes.length()>0));
             }
        test.stopTest();
    }
    
    //Test method to verify if ICD 10 Incldue Exclude Notes Output List is generated for given search
    public static testMethod void testICD10IncludeExcludeNotes(){
        User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
        test.StartTest();
            System.runAs(oUser)
            {
                Test.setMock(HttpCalloutMock.class,new SearchAPIMock());
                SearchAPI searchApi = new SearchAPI();
                List<SearchAPI.Notes> nodeList = searchApi.getICD10IncludeExcludeNotes('C41');
                String incExNotes = SearchController.getICD10IncludeExcludeNotes('C41', '');
              //  System.assertEquals('Success' , actualValue);
                if(nodeList==null){
                    nodeList = new List<SearchAPI.Notes>();
                }
                if(incExNotes==null){
                    incExNotes = '';
                }
                System.assertEquals(true, (nodeList.size()>=1));
                System.assertEquals(true, (incExNotes.length()>0));
            }
        test.stopTest();
    }
    
    //Test method to verify if ICD 10 Range Output List is generated for given search
    public static testMethod void testICD10Range(){
        User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
        test.StartTest();
            System.runAs(oUser)
            {
                Test.setMock(HttpCalloutMock.class,new SearchAPIMock());
                SearchAPI searchApi = new SearchAPI();
                List<Node> nodeList = searchApi.getICD10Range('C41');
                String range = SearchController.getICD10Range('C41',false);
              //  System.assertEquals('Success' , actualValue);
                if(nodeList==null){
                    nodeList = new List<Node>();
                }
                if(range==null){
                    range = '';
                }
                System.assertEquals(true, (nodeList.size()>=1));
                System.assertEquals(true, (range.length()>0));
            }
        test.stopTest();
    }
    
    //Test method to verify if ICD9 Searchs Output List is generated for given search
    public static testMethod void testICD9Search(){
        User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
        test.StartTest();
            System.runAs(oUser)
            {
                Test.setMock(HttpCalloutMock.class,new SearchAPIMock());
                SearchAPI searchApi = new SearchAPI();
               List<Node> nodeList = searchApi.getICD9SearchResults('171.3');
              //   SearchAPI.SearchResult result =  SearchController.getAPIResponse('171.3');
              //  List<Node> nodeList = result.results;
              //  System.assertEquals('Success' , actualValue);
                if(nodeList==null){
                    nodeList = new List<Node>();
                }
                System.assertEquals(true, (nodeList.size()>=1));
            }
        test.stopTest();
    }
    
   //Test method to verify if ICD9 code is generated for given search
    public static testMethod void testICD9CodeFetch(){
        User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
        test.StartTest();
            System.runAs(oUser)
            {
                Test.setMock(HttpCalloutMock.class,new SearchAPIMock());
                SearchAPI searchApi = new SearchAPI();
                String icdCodes = searchApi.getICD9Codes('C41.3');
              //  System.assertEquals('Success' , actualValue);
                if(icdCodes==null){
                   icdCodes='';
                }
                System.assertEquals(true, (icdCodes.length()>=1));
            }
        test.stopTest();
    }
    
     //Test method to verify if ICD9 Instructional Notes Output List is generated for given search
     public static testMethod void testICD9InstructionalNotes(){
        User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
        test.StartTest();
            System.runAs(oUser)
            {
                Test.setMock(HttpCalloutMock.class,new SearchAPIMock());
                SearchAPI searchApi = new SearchAPI();
                List<SearchAPI.Notes> nodeList = searchApi.getICD9InstructionalNotes('171.3');
                String instNotes = SearchController.getICD9InstructionalNotes('', '171.3');
              //  System.assertEquals('Success' , actualValue);
                if(nodeList==null){
                    nodeList = new List<SearchAPI.Notes>();
                }
                 if(instNotes==null){
                     instNotes = '';
                 }
                System.assertEquals(true, (nodeList.size()>=1));
                System.assertEquals(true, (instNotes.length()>=1));
            }
        test.stopTest();
    }
    
     //Test method to verify if ICD 9 Include Exclude Notes Output List is generated for given search      
     public static testMethod void testICD9IncludeExcludeNotes(){
        User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
        test.StartTest();
            System.runAs(oUser)
            {
                Test.setMock(HttpCalloutMock.class,new SearchAPIMock());
                SearchAPI searchApi = new SearchAPI();
                List<SearchAPI.Notes> nodeList = searchApi.getICD9IncludeExcludeNotes('171.3');
                String notes = SearchController.getICD9IncludeExcludeNotes('', '171.3');
              //  System.assertEquals('Success' , actualValue);
                if(nodeList==null){
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
        test.stopTest();
    }
    
    //Test method to verify if ICD 9 Include Exclude Notes Output List is generated for given search       
    public static testMethod void testICDCodeToCacheOperations(){
        List<Node> lstCachedNodes = new list<Node>();
        
        User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
        test.StartTest();
            System.runAs(oUser)
            {
                lstCachedNodes = (List<Node>)Cache.Session.get('icdCodeCache');
                System.assertEquals(null, lstCachedNodes);
                
                SearchController.addICDCodeToCache('M84.351A','Right hand Femur Fracture','18','Fractures');
                lstCachedNodes = (List<Node>)Cache.Session.get('icdCodeCache');
                System.assertEquals(1, lstCachedNodes.size());
                
                lstCachedNodes = SearchController.getICDCodeCache();
                System.assertEquals(1, lstCachedNodes.size());
                
                Boolean isICDCodePresentInCache = SearchController.isICDCodePresentInCache('M84.351A');
                System.assert(isICDCodePresentInCache);
                
                SearchController.removeICDCodeFromCache('M84.351A');
                lstCachedNodes = (List<Node>)Cache.Session.get('icdCodeCache');
                System.assertEquals(0, lstCachedNodes.size());
            }
        test.stopTest();        
    }
     
    //Test method to verify if ICD 9 Include Exclude Notes Output List is generated for given search       
    public static testMethod void testGetAPIResponseForFav(){
        List<Node> lstCachedNodes = new list<Node>();
        
        User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
        test.StartTest();
            System.runAs(oUser)
            {
                Test.setMock(HttpCalloutMock.class,new SearchAPIMock());
                SearchAPI searchApi = new SearchAPI();
                SearchAPI.SearchResult result =  SearchController.getAPIResponseForFav('C41.3,M84.3',false);
                List<Node> nodeList = result.results;
                System.assertNotEquals(null, nodeList);
                System.assert(nodeList.size()>=2);                
            }
        test.stopTest();        
     }
     
    //Test method to verify if a node is to be blocked by the filters       
    public static testMethod void testSearchAPIFiltersPassMode(){
        List<Node> lstCachedNodes = new list<Node>();
        Node oNode = new Node();oNode.code='M84';oNode.description='femur';oNode.rank=25;oNode.isParent = true;
        Map<String, String> mapConfigurations = new Map<String,String>{
            'Enable_Data_filters' => 'true',
            'Exclude_Code_Prefix' => 'O,P',
            'Exclude_Description_Prefix' => 'Unspecified',
            'Exclude_Code_Contains' => 'O,P',
            'Exclude_Description_Contains' => 'Unspecified',
            'Exclude_Code_Equals' => 'O,P',
            'Exclude_Description_Equals' => 'Unspecified'
        };
        
        User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
        test.StartTest();
            System.runAs(oUser)
            {
                Test.setMock(HttpCalloutMock.class,new SearchAPIMock());
                SearchAPIFilters oSearchAPIFilters = new SearchAPIFilters();                                
                System.assertEquals(false,oSearchAPIFilters.blockNode(oNode, mapConfigurations));                
            }
        test.stopTest();        
    }
     
    //Test method to verify if a node is to be blocked by the filters       
    public static testMethod void testSearchAPIFiltersBlockPrefixMode(){
        List<Node> lstCachedNodes = new list<Node>();
        Node oNode = new Node();oNode.code='O21';oNode.description='femur';oNode.rank=25;oNode.isParent = true;
        Map<String, String> mapConfigurations = new Map<String,String>{
            'Enable_Data_filters' => 'true',
            'Exclude_Code_Prefix' => 'O,P',
            'Exclude_Description_Prefix' => 'Unspecified',
            'Exclude_Code_Contains' => 'O,P',
            'Exclude_Description_Contains' => 'Unspecified',
            'Exclude_Code_Equals' => 'O,P',
            'Exclude_Description_Equals' => 'Unspecified'
        };
        
        User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
        test.StartTest();
            System.runAs(oUser)
            {
                Test.setMock(HttpCalloutMock.class,new SearchAPIMock());
                SearchAPIFilters oSearchAPIFilters = new SearchAPIFilters();                                
                System.assertEquals(true,oSearchAPIFilters.blockNode(oNode, mapConfigurations));                
            }
        test.stopTest();        
    }
     
    //Test method to verify if a node is to be blocked by the filters       
    public static testMethod void testSearchAPIFiltersBlockContainsMode(){
        List<Node> lstCachedNodes = new list<Node>();
        Node oNode = new Node();oNode.code='M84';oNode.description='femur Unspecified fracture';oNode.rank=25;oNode.isParent = true;
        Map<String, String> mapConfigurations = new Map<String,String>{
            'Enable_Data_filters' => 'true',
            'Exclude_Code_Prefix' => 'O,P',
            'Exclude_Description_Prefix' => 'Unspecified',
            'Exclude_Code_Contains' => 'O,P',
            'Exclude_Description_Contains' => 'Unspecified',
            'Exclude_Code_Equals' => 'O,P',
            'Exclude_Description_Equals' => 'Unspecified'
        };
        
        User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
        test.StartTest();
            System.runAs(oUser)
            {
                Test.setMock(HttpCalloutMock.class,new SearchAPIMock());
                SearchAPIFilters oSearchAPIFilters = new SearchAPIFilters();                                
                System.assertEquals(true,oSearchAPIFilters.blockNode(oNode, mapConfigurations));                
            }
        test.stopTest();        
    }
     
    //Test method to verify if a node is to be blocked by the filters       
    public static testMethod void testSearchAPIFiltersBlockEqualsMode(){
        List<Node> lstCachedNodes = new list<Node>();
        Node oNode = new Node();oNode.code='M84';oNode.description='Unspecified';oNode.rank=25;oNode.isParent = true;
        Map<String, String> mapConfigurations = new Map<String,String>{
            'Enable_Data_filters' => 'true',
            'Exclude_Code_Prefix' => 'O,P',
            'Exclude_Description_Prefix' => 'Unspecified',
            'Exclude_Code_Contains' => 'O,P',
            'Exclude_Description_Contains' => 'Unspecified',
            'Exclude_Code_Equals' => 'O,P',
            'Exclude_Description_Equals' => 'Unspecified'
        };
        
        User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
        test.StartTest();
            System.runAs(oUser)
            {
                Test.setMock(HttpCalloutMock.class,new SearchAPIMock());
                SearchAPIFilters oSearchAPIFilters = new SearchAPIFilters();                                
                System.assertEquals(true,oSearchAPIFilters.blockNode(oNode, mapConfigurations));                
            }
        test.stopTest();        
    }
    
    //Test method to verify if text search Output List is not generated for given search - Negative Test Method
    public static testMethod void testNegativeTermSearch(){
        User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
        test.StartTest();
            System.runAs(oUser)
            {
               Test.setMock(HttpCalloutMock.class,new SearchAPIMock());
               SearchAPI searchApi = new SearchAPI();
               SearchAPI.SearchResult result =  SearchController.getAPIResponse('acro',true);       
               String sNodeHeirarchy = result.mapResults;
               System.assert(String.isBlank(sNodeHeirarchy));
                System.assertEquals(false, (sNodeHeirarchy.equalsIgnoreCase('[]')));
               
               SearchAPI.SearchResult result1 =  SearchController.getAPIResponse('acro',false);       
               List<Node> nodeList = new List<Node>();
               nodeList = result1.results;
               System.assertEquals(null, nodeList);
             }
        test.stopTest();
    }
    
    //Test method to verify if reporting data Output List is not generated for given search - Negative Test Method
    public static testMethod void testNegativeReportSearch(){
        User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
        test.StartTest();
            System.runAs(oUser)
            {
                Test.setMock(HttpCalloutMock.class,new SearchAPIMock());
                SearchAPI searchApi = new SearchAPI();
              	LIST<SearchAPI.SearchReport> listReports =  SearchController.getReportingData('X12.3', 'sICDDescription','70','sHCCDescription');
                if(listReports==null){
                    listReports = new List<SearchAPI.SearchReport>();
                }
                System.assertEquals(false, (listReports.size()==0));
             }
        test.stopTest();
    }
    
    //Test method to verify if ICD 10 Search Output List is not generated for given search - Negative Test Method
    public static testMethod void testNegativeICD10Search(){
        User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
        test.StartTest();
            System.runAs(oUser)
            {
                Test.setMock(HttpCalloutMock.class,new SearchAPIMock());
                SearchAPI searchApi = new SearchAPI();
                //List<Node> nodeList = searchApi.getICD10SearchResults('X12.3');
                SearchAPI.SearchResult result =  SearchController.getAPIResponse('X2.3',false);
                List<Node> nodeList = result.results;
                System.debug('***Node List' + nodeList);
                if(nodeList!=null)
                {
                	System.assertEquals(true, (nodeList.size()==0));
                }
            }
        test.stopTest();
    }
    
    //Test method to verify if ICD 10 Instructional Notes Output List is not generated for given search - Negative Test Method
    public static testMethod void testNegativeICD10InstructionalNotes(){
        User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
        test.StartTest();
            System.runAs(oUser)
            {
                Test.setMock(HttpCalloutMock.class,new SearchAPIMock());
                SearchAPI searchApi = new SearchAPI();
                List<SearchAPI.Notes> nodeList = searchApi.getICD10InstructionalNotes('XZ2.3');
                String instNotes = SearchController.getICD10InstructionalNotes('XZ2.3', '');
                System.assertEquals(true, (nodeList.size()==0));
                //System.assertEquals(true, (instNotes.length()==0));
                System.assertEquals(true, (instNotes.equalsIgnoreCase('[]')));
             }
        test.stopTest();
    }
    
    //Test method to verify if ICD 10 Incldue Exclude Notes Output List is not generated for given search - Negative Test Method
    public static testMethod void testNegativeICD10IncludeExcludeNotes(){
        User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
        test.StartTest();
            System.runAs(oUser)
            {
                Test.setMock(HttpCalloutMock.class,new SearchAPIMock());
                SearchAPI searchApi = new SearchAPI();
                List<SearchAPI.Notes> nodeList = searchApi.getICD10IncludeExcludeNotes('X12');
                String incExNotes = SearchController.getICD10IncludeExcludeNotes('X12', '');
                System.assertEquals(true, (nodeList.size()==0));
                //System.assertEquals(true, (incExNotes.length()==0));
                System.assertEquals(true, (incExNotes.equalsIgnoreCase('[]')));
            }
        test.stopTest();
    }
    
    //Test method to verify if ICD 10 Range Output List is not generated for given search - Negative Test Method
    public static testMethod void testNegativeICD10Range(){
        User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
        test.StartTest();
            System.runAs(oUser)
            {
                Test.setMock(HttpCalloutMock.class,new SearchAPIMock());
                SearchAPI searchApi = new SearchAPI();
                List<Node> nodeList = searchApi.getICD10Range('XZ2');
                String range = SearchController.getICD10Range('XZ2',false);
                System.assertEquals(false, (nodeList.size()==0));
                //System.assertEquals(true, (range.length()==0));
                System.assertEquals(false, (range.equalsIgnoreCase('[]')));
            }
        test.stopTest();
    }
    
    //Test method to verify if ICD9 Searchs Output List is not generated for given search - Negative Test Method
    public static testMethod void testNegativeICD9Search(){
        User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
        test.StartTest();
            System.runAs(oUser)
            {
                Test.setMock(HttpCalloutMock.class,new SearchAPIMock());
                SearchAPI searchApi = new SearchAPI();
                List<Node> nodeList = searchApi.getICD9SearchResults('1X1.3');
                System.assertEquals(false, (nodeList.size()==0));
            }
        test.stopTest();
    }
    
    //Test method to verify if ICD9 code is not generated for given search - Negative Test Method
    public static testMethod void testNegativeICD9CodeFetch(){
        User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
        test.StartTest();
            System.runAs(oUser)
            {
                Test.setMock(HttpCalloutMock.class,new SearchAPIMock());
                SearchAPI searchApi = new SearchAPI();
                String icdCodes = searchApi.getICD9Codes('X12.3');
                //System.assertEquals(true, (icdCodes.length()==0));
                System.assertEquals(false, (icdCodes.equalsIgnoreCase('[]')));
            }
        test.stopTest();
    }
    
    //Test method to verify if ICD9 Instructional Notes Output List is not generated for given search - Negative Test Method
     public static testMethod void testNegativeICD9InstructionalNotes(){
        User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
        test.StartTest();
            System.runAs(oUser)
            {
                Test.setMock(HttpCalloutMock.class,new SearchAPIMock());
                SearchAPI searchApi = new SearchAPI();
                List<SearchAPI.Notes> nodeList = searchApi.getICD9InstructionalNotes('1X1.3');
                String instNotes = SearchController.getICD9InstructionalNotes('', '1X1.3');
                System.assertEquals(true, (nodeList.size()==0));
                //System.assertEquals(true, (instNotes.length()==0));
                System.assertEquals(true, (instNotes.equalsIgnoreCase('[]')));
            }
        test.stopTest();
    }
    
    //Test method to verify if ICD 9 Include Exclude Notes Output List is not generated for given search - Negative Test Method
     public static testMethod void testNegativeICD9IncludeExcludeNotes(){
        User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
        test.StartTest();
            System.runAs(oUser)
            {
                Test.setMock(HttpCalloutMock.class,new SearchAPIMock());
                SearchAPI searchApi = new SearchAPI();
                List<SearchAPI.Notes> nodeList = searchApi.getICD9IncludeExcludeNotes('1X1.3');
                String notes = SearchController.getICD9IncludeExcludeNotes('', '1X1.3');
                String testCode = SearchController.getCode('X12');
                //System.assertEquals('X12',testCode); 
                System.assertEquals(true, (nodeList.size()==0));
                System.assertEquals(true, (notes.equalsIgnoreCase('[]')));
             }
        test.stopTest();
     }    
}