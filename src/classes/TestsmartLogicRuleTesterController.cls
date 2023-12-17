@isTest(SeeAllData=false)
public class TestsmartLogicRuleTesterController{

	@testSetup
	public static void setupData(){
		//Create custom settings record for category name
		SmartLogic_Category_API_Name__c categoryAPIName = new SmartLogic_Category_API_Name__c(Name='SOAP Notes',API_Name__c='SOAP_Note__c');
		insert categoryAPIName;

		//Create Rule Category Record
		Rule_Category__c ruleCategory = TestUtilityCls.getRuleCatagory('Test0001','SOAP Notes','Review of Systems');
		insert ruleCategory;

		//Create Rule Library Record
		Rule_Library__c  rule = TestUtilityCls.getRuleLibrary('Regularly_Irregular','=','True,Yes,1',null,'Atrial Fibrillation','U','TesrR00001');
		insert rule;

		//Create Rule Library Category mapping record
		Rule_Category_Library_Mapping__c ruleMapping = TestUtilityCls.getRuleLibraryCategoryMapping(ruleCategory.id,rule.id);
		insert ruleMapping;

		//Create Rule Library Record
		Rule_Library__c rule2 = TestUtilityCls.getRuleLibrary('Chest Pain','=','True,Yes,1',null,'Angina, stable','U','TesrR00002');
		insert rule2;

		//Create Rule Library Category mapping record
		Rule_Category_Library_Mapping__c ruleMapping2 = TestUtilityCls.getRuleLibraryCategoryMapping(ruleCategory.id,rule2.id);
		insert ruleMapping2;

		//Create Rule Library Record
		Rule_Library__c rule3 = TestUtilityCls.getRuleLibrary('Wheezing','=','True,Yes,1','J44.9','Chronic obstructive pulmonary disease, unspecified','U','TesrR00003');
		insert rule3;

		//Create Rule Library Category mapping record
		Rule_Category_Library_Mapping__c ruleMapping3 = TestUtilityCls.getRuleLibraryCategoryMapping(ruleCategory.id,rule3.id);
		insert ruleMapping3;

		//Create Rule Combination Record
		Rule_Combination__c ruleCombination = TestUtilityCls.getRuleCombination('U','TesrR00001 OR TesrR00002','(Regularly_Irregular = True,Yes,1) OR (Chest Pain = True,Yes,1)','TestRC00001','Angina, stable','I20.9');
		insert ruleCombination;

        System.assert(true);
	}

	public static testmethod void testfetchFieldsAgainstRuleType() {

		Rule_Library__c ruleRecord = [select id from Rule_Library__c where Rule_Field__c = 'Regularly_Irregular']; 
		Rule_Combination__c ruleCombinationRecord = [select id from Rule_Combination__c];// where Rule_Combination__c = 'TesrR00001 OR TesrR00002'];

		//Get the Rule Category Options and Rule Gender Options
		String ruleCategoryOptions = smartLogicRuleTesterController.RuleCategoryOptions();
		system.assertNotEquals(ruleCategoryOptions,null);
		system.debug(ruleCategoryOptions);
		list<smartLogicRuleTesterController.RuleCategoryOptions> ruleCategoryOptionsJSON = (list<smartLogicRuleTesterController.RuleCategoryOptions>)JSON.deserialize(String.escapeSingleQuotes(ruleCategoryOptions),list<smartLogicRuleTesterController.RuleCategoryOptions>.class);
		system.assertEquals(ruleCategoryOptionsJSON[0].label,'Review of Systems');
		system.assertEquals(ruleCategoryOptionsJSON[0].value,'Review of Systems');
		system.assertEquals(ruleCategoryOptionsJSON[0].selected,'false');

		String ruleGenderOptions = smartLogicRuleTesterController.RuleGenderOptions();
		system.assertNotEquals(ruleGenderOptions,null);
		list<smartLogicRuleTesterController.RuleCategoryOptions> ruleGenderOptionsJSON = (list<smartLogicRuleTesterController.RuleCategoryOptions>)JSON.deserialize(String.escapeSingleQuotes(ruleCategoryOptions),list<smartLogicRuleTesterController.RuleCategoryOptions>.class);
		system.assertEquals(ruleGenderOptionsJSON.size(),1);

		//Fetch fields i.e. symptoms for selected rule type
		String fieldsAgainstRuleType = smartLogicRuleTesterController.fetchFieldsAgainstRuleType('Review of Systems');
		system.assertNotEquals(fieldsAgainstRuleType,null);

		//Pass id of Rule Library record to populate symptoms for rule selected for testing
		String symptomDetailsForRule = smartLogicRuleTesterController.populateSymptomsOnPageLoad(ruleRecord.id);
		system.assertNotEquals(symptomDetailsForRule,null);

		//Pass id of Rule Combination record to populate symptoms for rule combination selected for testing
		String symptomDetailsForRuleCombination = smartLogicRuleTesterController.populateSymptomsOnPageLoad(ruleCombinationRecord.id);
		system.assertNotEquals(symptomDetailsForRuleCombination,null);

		//Pass the symptom and rule category i.e. click on submit to get the ICDs and rules evaluated
		String ruleEngineResponse = smartLogicRuleTesterController.executeRulesEngine('Review of Systems','[{"fieldName":"Regularly_Irregular","fieldValue":"True"}]');
		system.assertNotEquals(ruleEngineResponse,null);
	}
    
    /*public static testmethod void testRuleTesterController() {
        //fetchSmartLogicRequest
		SmartLogicRequest slRequest;
        SmartLogicRequest compRequest = new SmartLogicRequest();
		compRequest.symptoms.put('','');
		SmartLogicRequest resultRequest  = RuleTesterController.fetchSmartLogicRequest(slRequest);
		System.assert(resultRequest != null);
        
		//fetchTypesData
		List<Rule_Category__c> expectedList = [select Rule_Category__c,  Rule_Type__c from Rule_Category__c ];
		String resultString  = RuleTesterController.fetchTypesData();
		Map<String, Object> actualMap =  (Map<String, Object>) JSON.deserializeUntyped(resultString);
		system.debug(actualMap);
		System.assertEquals(expectedList.size(),actualMap.keySet().size());
		for(Rule_Category__c rulCat : expectedList) {
			system.debug('--'+rulCat.Rule_Category__c);
			System.assert(actualMap.containsKey(rulCat.Rule_Type__c));
		}

		//fetchFieldsForCategory
		String categoryName = 'SOAP Notes';
		String resultString1  = RuleTesterController.fetchFieldsForCategory(categoryName);
		Map<String, Object> resultList = (Map<String, Object>) Json.deserializeUntyped(resultString1);
		System.assert(resultList.size()>0);
	}*/

}