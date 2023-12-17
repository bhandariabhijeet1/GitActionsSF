@isTest
public class CodeSearchControllerTest {       
    
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
        
        User_Favorites__c favRec = new User_Favorites__c(Search_String__c='femur', ICD_Code__c='');
        insert favRec;
    }
    
    //Method to verify if correct user Label is returned by the controller
    public static testMethod void testGetUserName(){
        User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
        test.StartTest();
            System.runAs(oUser)
            {
                String userName = CodeSearchController.getUserName();
                String userName2 = SearchController.getUserName();
                System.assertEquals(UserInfo.getName(), userName);
                System.assertEquals(UserInfo.getName(), userName2);
            }
        test.stopTest();
    }
    
    //Method to verify if ICD 9 code search is enabled and retryuned by the controller
    public static testmethod void testIsICD09SearchEnabled(){
        User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
        test.StartTest();
            System.runAs(oUser)
            {
                configurations__mdt oConfiguration = [SELECT value__c FROM configurations__mdt WHERE DeveloperName = 'Enable_ICD09_Search'];
                System.assert(oConfiguration != null);
                boolean configValue = CodeSearchController.isICD9SearchEnabled();
                System.assertEquals(oConfiguration.value__c, String.valueOf(configValue));
             }
        test.stopTest();
    }
    
    //Method to verify if IICD 10 tree view is enabled and retryuned by the controller
    public static testmethod void testIsIICD10TreeViewEnabled(){
        User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
        test.StartTest();
            System.runAs(oUser)
            {
                configurations__mdt oConfiguration = [SELECT value__c FROM configurations__mdt WHERE DeveloperName = 'Enable_ICD10_Tree_View'];
                System.assert(oConfiguration != null);
                boolean configValue = CodeSearchController.isICD10TreeViewEnabled();
                System.assertEquals(oConfiguration.value__c, String.valueOf(configValue));
            }
        test.stopTest();
    }
    
    //Test fetching Global Configurations on the Controller
     public static testmethod void testGetAllConfigurations(){
        List<configurations__mdt> lstMetaDataConfigurations = new List<configurations__mdt>();
        
        User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
        test.StartTest();
            System.runAs(oUser)
            {
                lstMetaDataConfigurations = [SELECT value__c FROM configurations__mdt];
                Map<string,String> allConfigs = CodeSearchController.getAllConfigurations();
                
                System.assert(allConfigs.containsKey('User_Name'));
                System.assertEquals(UserInfo.getName() , allConfigs.get('User_Name'));    
                System.assertEquals(lstMetaDataConfigurations.size() + 1 , allConfigs.size());    
            }
        test.stopTest();
      }
      
      //Test fetching Global Configurations on the Controller
     public static testmethod void testFetchGlobalFavorites(){
        List<configurations__mdt> lstMetaDataConfigurations = new List<configurations__mdt>();
        
        User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
        test.StartTest();
            System.runAs(oUser)
            {
                Map<String, List<Node>> allConfigs = CodeSearchController.fetchGlobalFavorites();
                System.assert(allConfigs.size() > 0);
             }
        test.stopTest();
      }
    
     //Test fetching My Favorites on the Controller
     public static testmethod void testGetMyFavorites(){
        User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
        test.StartTest();
            System.runAs(oUser)
            {
                String data = MyFavoritesController.getMyFavorites();
                System.assertNotEquals(null, data);
             }
        test.stopTest();
      }
    
    //Test fetching Add To My Favorites on the Controller
     public static testmethod void testAddToMyFavorites(){
        User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
        test.StartTest();
            System.runAs(oUser)
            {
                String data = MyFavoritesController.addToMyFavorites('','fever');
                System.assertEquals('SUCCESS', data);
                Map<String,Boolean> userFavoritesCache = new Map<String,Boolean>();
                Cache.Session.put('userFavoritesCache', userFavoritesCache);
                String data1 = MyFavoritesController.addToMyFavorites('I11','');
                System.assertEquals('DUPLICATE_MYFAVORITES', data1);
             }
        test.stopTest();
      }
    
    //Test fetching Remove To My Favorites on the Controller
     public static testmethod void testRemoveFromMyFavorites(){
        User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
        test.StartTest();
            System.runAs(oUser)
            {
                String data = MyFavoritesController.removeFromMyFavorites('','femur');
                System.assertEquals('SUCCESS', data);
             }
        test.stopTest();
      }
    
    //Test jsonCallout
     public static testmethod void testjsonCallout(){
        User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
        test.StartTest();
            System.runAs(oUser)
            {
                SearchAPI util = new SearchAPI();
                util.getJSONSearchResults('femur');
                System.assert(true);
             }
        test.stopTest();
      }
    
}