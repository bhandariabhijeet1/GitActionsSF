@isTest
public class TestRuleOperationUtil {

	@testSetup 
	public static void setup() {
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
		User u = new User(Alias = 'standt', Email='Attestationuser@testorg.com', 
				EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
				LocaleSidKey='en_US', ProfileId = p.Id, 
				TimeZoneSidKey='America/Los_Angeles', UserName='Attestationuser@testorg.com');
		insert u;
        
        System.assert(true);
	}  

	public static testMethod void testSaveRuletoDBNegative(){
		User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
		test.StartTest();
		System.runAs(oUser)
		{       
			String saveResult = RuleOperationUtil.saveRule(null, 'Review of Systems');
			System.assertNotEquals(saveResult, 'SUCCESS');
		}
		test.stopTest(); 
	}

	public static testMethod void testUpdateRuleNegative(){
		User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
		test.StartTest();
		System.runAs(oUser)
		{       
			String saveResult = RuleOperationUtil.updateRule(null);
			System.assertNotEquals(saveResult, 'SUCCESS');
		}
		test.stopTest(); 
	}

	public static testMethod void testChangeRuleStatus() {
		User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
		test.StartTest();
		System.runAs(oUser)
		{       
			boolean operationResult = RuleOperationUtil.changeRuleStatus(null, true);
			System.assert(!operationResult);
			operationResult = RuleOperationUtil.changeRuleCombinationStatus(null, true);
			System.assert(!operationResult);

		}
		test.stopTest(); 
	}

	public static testMethod void testSaveRuleCombination() {
		User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
		test.StartTest();
		System.runAs(oUser)
		{       
			String saveResult = RuleOperationUtil.SaveRuleCombination(null);
			System.assertNotEquals(saveResult, 'SUCCESS');
		}
		test.stopTest(); 

	}
}