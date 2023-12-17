@isTest
public class TestRuleCategoryController {
	@testSetup 
	public static void setup() {
		// TestRulesEngine.setup();
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
		User u = new User(Alias = 'standt', Email='Attestationuser@testorg.com', 
				EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
				LocaleSidKey='en_US', ProfileId = p.Id, 
				TimeZoneSidKey='America/Los_Angeles', UserName='Attestationuser1@testorg.com');
		insert u;

		List<Rule_Category__c> lstRuleCategory = new List<Rule_Category__c>();
		lstRuleCategory.add(new Rule_Category__c(Rule_Category_Ext_ID__c='CAT1', Rule_Category__c='SOAP Notes', Rule_Type__c='Review of Systems'));
		lstRuleCategory.add(new Rule_Category__c(Rule_Category_Ext_ID__c='CAT2', Rule_Category__c='SOAP Notes', Rule_Type__c='Physical Exam'));
		lstRuleCategory.add(new Rule_Category__c(Rule_Category_Ext_ID__c='CAT3', Rule_Category__c='Global', Rule_Type__c='Global'));
		lstRuleCategory.add(new Rule_Category__c(Rule_Category_Ext_ID__c='CAT4', Rule_Category__c='SOAP Notes', Rule_Type__c='SocialHx'));
		lstRuleCategory.add(new Rule_Category__c(Rule_Category_Ext_ID__c='CAT5', Rule_Category__c='Engagement', Rule_Type__c='Medication'));
		upsert lstRuleCategory;
		
        System.assert(true);
	}
	public static testMethod void testFetchAllCategories(){
		User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
		test.StartTest();
		System.runAs(oUser)
		{
			//Create custom settings record for category name
			SmartLogic_Category_API_Name__c categoryAPIName = new SmartLogic_Category_API_Name__c(Name='SOAP Notes',API_Name__c='SOAP_Note__c');
			insert categoryAPIName;
			String catStr = RuleCategoryController.fetchAllCategories('');
			System.assertNotEquals(null, catStr);
		}
		test.stopTest();
	}
	public static testMethod void testFetchAllSupportedTypes() {
		User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
		test.StartTest();
		System.runAs(oUser)
		{
			//Create custom settings record for category name
			SmartLogic_Category_API_Name__c categoryAPIName = new SmartLogic_Category_API_Name__c(Name='SOAP Notes',API_Name__c='SOAP_Note__c');
			insert categoryAPIName;
			String catStr = RuleCategoryController.fetchAllSupportedTypes();
			System.assertNotEquals(null, catStr);
		}
		test.stopTest();
	}
	public static testMethod void testFetchAllSupportedCategories(){
		User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
		test.StartTest();
		System.runAs(oUser)
		{
			//Create custom settings record for category name
			SmartLogic_Category_API_Name__c categoryAPIName = new SmartLogic_Category_API_Name__c(Name='SOAP Notes',API_Name__c='SOAP_Note__c');
			insert categoryAPIName;
			String catStr = RuleCategoryController.fetchAllSupportedCategories();
			System.assertNotEquals(null, catStr);
		}
		test.stopTest();
	}
	public static testMethod void testEditCategory(){
		User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
		test.StartTest();
		System.runAs(oUser)
		{
			String savRet = RuleCategoryController.saveCategory('TestType2','SoapNote');
			List<Rule_Category__c> ruleCatList = [select Id from Rule_Category__c];
			String catId = '';
			if(ruleCatList.size()>=1){
				catId = ruleCatList.get(0).Id;
			}
			String catStr = RuleCategoryController.editCategory('TestType1','SoapNote',catId);
			System.assertEquals('SUCCESS', catStr);
			System.assertEquals('SUCCESS', savRet);

		}
		test.stopTest();
	}
	public static testMethod void testMultupleSave(){
		User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
		test.StartTest();
		System.runAs(oUser)
		{
			String savRet1 = RuleCategoryController.saveCategory('TestType2','SoapNote');
			String savRet2 = RuleCategoryController.saveCategory('TestType2','SoapNote');

			System.assertEquals('SUCCESS', savRet1);
			System.assertEquals('DUPLICATE_RULE_CAT', savRet2);
		}
		test.stopTest();
	}

	public static testMethod void testEditNegative(){
		User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
		test.StartTest();
		System.runAs(oUser)
		{
			String savRet1 = RuleCategoryController.editCategory('TestType2','TestCat','');
			System.assertNotEquals('SUCCESS', savRet1);
		}
		test.stopTest();
	}
	public static testMethod void testEditCategoryDup(){
		User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
		test.StartTest();
		System.runAs(oUser)
		{
			String savRet = RuleCategoryController.saveCategory('TestType2','SoapNote');
			System.assertEquals('SUCCESS', savRet);
			List<Rule_Category__c> ruleCatList = [select Rule_Category__c,Rule_Type__c, Id from Rule_Category__c];
			String catId = '';
			if(ruleCatList.size()>=1){
				String ruleCat = ruleCatList.get(0).Rule_Category__c;
				String ruleType = ruleCatList.get(0).Rule_Type__c;
				catId = ruleCatList.get(1).Id;
			}
			String catStr = RuleCategoryController.editCategory('TestType2','SoapNote',catId);
			//System.assertEquals('DUPLICATE_RULE_CAT', catStr);
		}
		test.stopTest();
	}
}