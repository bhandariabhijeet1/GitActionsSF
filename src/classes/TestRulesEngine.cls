@isTest
public with sharing class TestRulesEngine {

	@testSetup  
	public static void setup() {
		List<Rule_Category__c> lstRuleCategory = new List<Rule_Category__c>();
		List<Rule_Library__c> lstRuleLibarry = new List<Rule_Library__c>();
		List<Rule_Category_Library_Mapping__c> lstRuleCategoryLibraryMapping = new List<Rule_Category_Library_Mapping__c>();
		List<Rule_Combination__c> lstRuleCombination = new list<Rule_Combination__c>();

		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
		User u = new User(Alias = 'standt', Email='Attestationuser@testorg.com', 
				EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
				LocaleSidKey='en_US', ProfileId = p.Id, 
				TimeZoneSidKey='America/Los_Angeles', UserName='Attestationuser1@testorg.com');
		insert u;

		lstRuleCategory.add(new Rule_Category__c(Rule_Category_Ext_ID__c='CAT1', Rule_Category__c='SOAP Notes', Rule_Type__c='Review of Systems'));
		lstRuleCategory.add(new Rule_Category__c(Rule_Category_Ext_ID__c='CAT2', Rule_Category__c='SOAP Notes', Rule_Type__c='Physical Exam'));
		lstRuleCategory.add(new Rule_Category__c(Rule_Category_Ext_ID__c='CAT3', Rule_Category__c='Global', Rule_Type__c='Global'));
		lstRuleCategory.add(new Rule_Category__c(Rule_Category_Ext_ID__c='CAT4', Rule_Category__c='SOAP Notes', Rule_Type__c='SocialHx'));
		lstRuleCategory.add(new Rule_Category__c(Rule_Category_Ext_ID__c='CAT5', Rule_Category__c='Engagement', Rule_Type__c='Medication'));
		upsert lstRuleCategory;

		lstRuleLibarry.add(new Rule_Library__c(Rule_Library_Ext_Id__c='R1', is_Active__c=true, Rule_Field__c='Hearing Loss', Rule_Operator__c='=', Rule_Value__c='Bilateral', Rule_ICD__c='H91.90', Rule_Diagnosis__c='Hearing Loss', Rule_Gender__c='U', Works_with_Rule_Combinations_Only__c=false));
		lstRuleLibarry.add(new Rule_Library__c(Rule_Library_Ext_Id__c='R2', is_Active__c=true, Rule_Field__c='Morning Stiffness', Rule_Operator__c='=', Rule_Value__c='Yes', Rule_ICD__c='', Rule_Diagnosis__c='', Rule_Gender__c='', Works_with_Rule_Combinations_Only__c=true));
		lstRuleLibarry.add(new Rule_Library__c(Rule_Library_Ext_Id__c='R3', is_Active__c=true, Rule_Field__c='Morning Stiffness How Long', Rule_Operator__c='=', Rule_Value__c='1', Rule_ICD__c='', Rule_Diagnosis__c='', Rule_Gender__c='', Works_with_Rule_Combinations_Only__c=true));
		lstRuleLibarry.add(new Rule_Library__c(Rule_Library_Ext_Id__c='R4', is_Active__c=true, Rule_Field__c='Joint Swelling', Rule_Operator__c='=', Rule_Value__c='True', Rule_ICD__c='', Rule_Diagnosis__c='', Rule_Gender__c='', Works_with_Rule_Combinations_Only__c=true));
		lstRuleLibarry.add(new Rule_Library__c(Rule_Library_Ext_Id__c='R5', is_Active__c=false, Rule_Field__c='Hearing Loss', Rule_Operator__c='=', Rule_Value__c='Test Symp', Rule_Gender__c='U', Works_with_Rule_Combinations_Only__c=false));

		upsert lstRuleLibarry;

		lstRuleCombination.add(new Rule_Combination__c(Is_Active__c=true, Gender__c='U', Rule_combination_Ext_Id__c='EXP1', Rule_Combination__c='(R2 AND R3) OR R4', Rule_Combination_Description__c='((Morning Stiffness = True,Yes,1) AND (Morning Stiffness How Long > 1) ) OR (Joint Swelling = True,Yes,1)', Rule_ICD__c='M06.9', Rule_Diagnosis__c='Arthritis-Rheumatoid'));
		lstRuleCombination.add(new Rule_Combination__c(Is_Active__c=true, Gender__c='U', Rule_combination_Ext_Id__c='EXP2', Rule_Combination__c='(R2 AND R3) AND R4', Rule_Combination_Description__c='((Morning Stiffness = True,Yes,1) AND (Morning Stiffness How Long > 1) ) AND (Joint Swelling = True,Yes,1)', Rule_ICD__c='M06.91', Rule_Diagnosis__c='Arthritis-Rheumatoid type 1'));
		
        lstRuleCombination.add(new Rule_Combination__c(Is_Active__c=false, Gender__c='U', Rule_combination_Ext_Id__c='EXP3', Rule_Combination__c='(R1 AND R2) OR R5', Rule_Combination_Description__c='((Hearing Loss = True,Yes,1) AND (Morning Stiffness = True,Yes,1) ) OR (Hearing Loss = True,Yes,1)', Rule_ICD__c='M06.9', Rule_Diagnosis__c='Arthritis-Rheumatoid'));
		lstRuleCombination.add(new Rule_Combination__c(Is_Active__c=false, Gender__c='U', Rule_combination_Ext_Id__c='EXP4', Rule_Combination__c='(R1 AND R2) AND R5', Rule_Combination_Description__c='((Hearing Loss = True,Yes,1) AND (Morning Stiffness = True,Yes,1) ) AND (Hearing Loss = True,Yes,1)', Rule_ICD__c='M06.91', Rule_Diagnosis__c='Arthritis-Rheumatoid type 1'));
		lstRuleCombination.add(new Rule_Combination__c(Is_Active__c=true, Gender__c='U', Rule_combination_Ext_Id__c='EXP5', Rule_Combination__c='(R1 AND EXP2)', Rule_Combination_Description__c='((Hearing Loss = True,Yes,1) AND (Morning Stiffness = True,Yes,1) ) AND (Hearing Loss = True,Yes,1)', Rule_ICD__c='M06.91', Rule_Diagnosis__c='Arthritis-Rheumatoid type 1'));
        upsert lstRuleCombination;

		String testRuleType = 'Physical Exam';
		List<Rule_Category__c>  categoryList = [Select id from Rule_Category__c where Rule_Type__c = :testRuleType];

		List<Rule_Category_Library_Mapping__c> lstCategoryMapping =  new   List<Rule_Category_Library_Mapping__c>();
		for(Rule_Library__c ruleObj : lstRuleLibarry) {
			Rule_Category_Library_Mapping__c mapping = new Rule_Category_Library_Mapping__c();
			mapping.Rule_Library__c = ruleObj.id;
			mapping.Rule_Category__c = categoryList.get(0).id;
			lstCategoryMapping.add(mapping);
		}
		upsert lstCategoryMapping;	
		List<SmartLogic_Category_API_Name__c> allSettings = new List<SmartLogic_Category_API_Name__c>();
		allSettings.add(new SmartLogic_Category_API_Name__c(API_Name__c = 'SOAP_Note__c',Name = 'SOAP Notes'));
		allSettings.add(new SmartLogic_Category_API_Name__c(API_Name__c = 'Engagement__c',Name = 'Engagement'));
		insert allSettings;
	}

}