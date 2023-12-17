@isTest
public class TestRuleBuilderController {

	@testSetup 
	public static void setup() {
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
		User u = new User(Alias = 'standt', Email='Attestationuser@testorg.com', 
				EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
				LocaleSidKey='en_US', ProfileId = p.Id, 
				TimeZoneSidKey='America/Los_Angeles', UserName='Attestationuser@testorg.com');
		insert u;
        System.assert(true);
		TestRulesEngine.setup();
	}

	public static testMethod void testFetchCategoriesData(){
		User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
		test.StartTest();
		System.runAs(oUser)
		{
			List<Rule_Category__c> expectedList = [select Rule_Category__c , Rule_Type__c from Rule_Category__c ];

			String categories  = RuleBuilderController.fetchCategoriesData();
			Map<String, Object> actualMap =  (Map<String, Object>) JSON.deserializeUntyped(categories);
			integer actualCount = 0;
			for(String key : actualMap.keyset()){
				List<Object> listObj = (List<Object>)actualMap.get(key);
				actualCount = actualCount + listObj.size();
			}
			System.assertEquals(expectedList.size(),actualCount);
			for(Rule_Category__c rulCat : expectedList) {
				System.assert(actualMap.containsKey(rulCat.Rule_Category__c));
			}
		}
		test.stopTest();      
	}

	public static testMethod void testFetchTypesData(){
		User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
		test.StartTest();
		System.runAs(oUser)
		{
			List<Rule_Category__c> expectedList = [select Rule_Category__c,  Rule_Type__c from Rule_Category__c ];
			String resultString  = RuleBuilderController.fetchTypesData();
			Map<String, Object> actualMap =  (Map<String, Object>) JSON.deserializeUntyped(resultString);
			system.debug(actualMap);
			System.assertEquals(expectedList.size(),actualMap.keySet().size());
			for(Rule_Category__c rulCat : expectedList) {
				system.debug('--'+rulCat.Rule_Category__c);
				System.assert(actualMap.containsKey(rulCat.Rule_Type__c));
			}
		}
		test.stopTest();      
	}

	public static testMethod void testFetchAllOperators(){
		User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
		test.StartTest();
		System.runAs(oUser)
		{
			List<String> dataTypeList = new List<String>();
			dataTypeList.add('STRING');
			dataTypeList.add('INTEGER');
			dataTypeList.add('DOUBLE');
			dataTypeList.add('BOOLEAN');
			dataTypeList.add('PICKLIST');
			dataTypeList.add('MULTIPICKLIST');

			String resultString  = RuleBuilderController.fetchAllOperators();
			Map<String, Object> actualMap =  (Map<String, Object>) JSON.deserializeUntyped(resultString);
			System.assertEquals(dataTypeList.size(), actualMap.keyset().size());
			for(String operator : dataTypeList) {
				System.assert(actualMap.containsKey(operator));
			}

		}
		test.stopTest();      
	}

	public static testMethod void testFetchFieldsForCategory() {    	
		User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
		test.StartTest();
		System.runAs(oUser)
		{
			Map<String, String> dbFieldLabelTypeMap = new Map<String, String>();        	
			String categoryName = 'Engagement';
			String dbAPIName = '';

			for(SmartLogic_Category_API_Name__c apiNameObj : [select API_Name__c from SmartLogic_Category_API_Name__c where Name = :categoryName]) {
				dbAPIName = apiNameObj.API_Name__c;
			}
			if(String.isNotBlank(dbAPIName)) {
				SObjectType soapNoteType = Schema.getGlobalDescribe().get(dbAPIName);
				if(soapNoteType!=null){
					Map<String,Schema.SObjectField> fieldMap = soapNoteType.getDescribe().fields.getMap();
					Map<String,String> allTypesOperatorMap = SmartLogicRuleBuilderUtil.getDataTypeOperatorsMap();
					system.debug(allTypesOperatorMap);
					for(String fieldName : fieldMap.keySet() ) {
						Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
						if(allTypesOperatorMap.containsKey(''+fielddataType)) {
							dbFieldLabelTypeMap.put(fieldMap.get(fieldName).getDescribe().getLabel(), fielddataType+ '');
						}
					}
				}
			}

			String resultString  = RuleBuilderController.fetchFieldsForCategory(categoryName);
			List<Object> resultList = (List<Object>) Json.deserializeUntyped(resultString);

			System.assert(dbFieldLabelTypeMap.size()>=0);
		}
		test.stopTest(); 
	}

	public static testMethod void testFetchFieldsForCategoryforSoapNotes() {    	
		User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
		test.StartTest();
		System.runAs(oUser)
		{
			Map<String, String> dbFieldLabelTypeMap = new Map<String, String>();        	
			String categoryName = 'SOAP Notes';

			String resultString  = RuleBuilderController.fetchFieldsForCategory(categoryName);
			List<Object> resultList = (List<Object>) Json.deserializeUntyped(resultString);

			System.assert(resultList.size()>=0);
		}
		test.stopTest(); 
	}

	public static testMethod void testFetchFieldsForCategoryforGlobal() {    	
		User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
		test.StartTest();
		System.runAs(oUser)
		{
			Map<String, String> dbFieldLabelTypeMap = new Map<String, String>();        	
			String categoryName = 'Global';

			String resultString  = RuleBuilderController.fetchFieldsForCategory(categoryName);
			List<Object> resultList = (List<Object>) Json.deserializeUntyped(resultString);

			System.assert(resultList.size()>=0);
		}
		test.stopTest(); 
	}

	public static testMethod void testFetchPickListValues(){
		User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
		test.StartTest();
		System.runAs(oUser)
		{
			List<String> allPicklistValues =  new List<String>();
			String APIName = SmartLogicRuleBuilderUtil.getObjectAPINameForCategory('SOAP Notes');        
			Schema.SObjectType targetType = Schema.getGlobalDescribe().get(APIName);
			if(targetType!=null){
			Sobject Object_name = targetType.newSObject();
			Schema.sObjectType sobject_type = Object_name.getSObjectType(); 
			Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
			Map<String, Schema.SObjectField> fieldMap = sobject_describe.fields.getMap(); 
			for(String key :  fieldMap.keySet()) {
				if(fieldMap.get(key).getDescribe().getLabel() == 'Abnormal EOM') {
					List<Schema.PicklistEntry> pick_list_values = fieldMap.get(key).getDescribe().getPickListValues();
					for (Schema.PicklistEntry a : pick_list_values) { 
						allPicklistValues.add(a.getValue());
					}
				}
			}
			}

			String ctrlPickListValues  = RuleBuilderController.fetchPickListValues('Abnormal EOM', 'SOAP Notes');
			System.assertEquals(ctrlPickListValues, JSON.serialize(allPicklistValues));
		}
		test.stopTest();      
	}

	public static testMethod void testSaveRuletoDB(){
		User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
		test.StartTest();
		System.runAs(oUser)
		{       
			Rule_Library__c  newRule  = new Rule_Library__c();
			newRule.is_Active__c = true; 
			newRule.Rule_Field__c = 'Test Symptom'; 
			newRule.Rule_Operator__c = '=';
			newRule.Rule_Gender__c = 'U';
			newRule.Rule_ICD__c = 'S1.0';
			newRule.Rule_Diagnosis__c = 'Test Save Rule';
			newRule.Rule_Value__c = 'Yes';
			newRule.Multiple_Value_Count__c = 0;	

			String saveResult = RuleBuilderController.saveRuletoDB(JSON.serialize(newRule), 'Review of Systems');
			System.assertEquals(saveResult, 'SUCCESS');
		}
		test.stopTest(); 
	}


	public static testMethod void testEditRuletoDB() {
		User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
		test.StartTest();
		System.runAs(oUser)
		{       
			String condition = 'where  Rule_Library__r.Rule_Field__c= \'Hearing Loss\'';
			String query = 'select ID, Rule_Library__r.Rule_Description__c, Rule_Library__r.Rule_Library_Ext_Id__c,Rule_Library__r.Rule_Diagnosis__c,Rule_Library__r.Rule_ICD__c,Rule_Library__r.ID,Rule_Library__r.is_Active__c from Rule_Category_Library_Mapping__c '+ condition;
			List<Rule_Category_Library_Mapping__c> mappingFoundList = Database.query(query);
			System.assert(mappingFoundList.size()>0);
			Rule_Category_Library_Mapping__c  mappingFound = mappingFoundList.get(0);
			Rule_Library__c ruleObj = mappingFound.Rule_Library__r;
			ruleObj.Rule_ICD__c = 'E12.213';
			string actualResult = RuleBuilderController.editRule(JSON.serialize(ruleObj), 'Review of Systems');
			system.assertEquals('SUCCESS', actualResult);
		}
		test.stopTest(); 
	}

	public static testMethod void testCloneRule() {
		User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
		test.StartTest();
		System.runAs(oUser)
		{       
			String condition = 'where  Rule_Library__r.Rule_Field__c= \'Hearing Loss\'';
			String query = 'select ID, Rule_Library__r.Rule_Description__c, Rule_Library__r.Rule_Library_Ext_Id__c,Rule_Library__r.Rule_Diagnosis__c,Rule_Library__r.Rule_ICD__c,Rule_Library__r.ID,Rule_Library__r.is_Active__c from Rule_Category_Library_Mapping__c '+ condition;
			List<Rule_Category_Library_Mapping__c> mappingFoundList = Database.query(query);
			System.assert(mappingFoundList.size()>0);
			Rule_Category_Library_Mapping__c  mappingFound = mappingFoundList.get(0);
			Rule_Library__c ruleObj = mappingFound.Rule_Library__r;
			ruleObj.Rule_ICD__c = 'E12.213';
			ruleObj.Rule_Field__c ='Cloned Rule';
			string actualResult = RuleBuilderController.cloneRule(JSON.serialize(ruleObj), 'Review of Systems');
			system.assertEquals('SUCCESS', actualResult);
		}
		test.stopTest(); 
	}

	public static testMethod void testSaveDupRule() {
		User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
		test.StartTest();
		System.runAs(oUser)
		{       
			String condition = 'where  Rule_Library__r.Rule_Field__c= \'Hearing Loss\'';
			String query = 'select ID, Rule_Library__r.Rule_Gender__c,Rule_Library__r.Rule_Field__c, Rule_Library__r.Rule_Operator__c, Rule_Library__r.Rule_Description__c,Rule_Category__r.Rule_Type__c, Rule_Library__r.Rule_Library_Ext_Id__c,Rule_Library__r.Rule_Diagnosis__c,Rule_Library__r.Rule_ICD__c,Rule_Library__r.ID,Rule_Library__r.is_Active__c from Rule_Category_Library_Mapping__c '+ condition;
			List<Rule_Category_Library_Mapping__c> mappingFoundList = Database.query(query);
			System.assert(mappingFoundList.size()>0);
			Rule_Category_Library_Mapping__c  mappingFound = mappingFoundList.get(0);
			Rule_Library__c ruleObj = new Rule_Library__c();  
			ruleObj.Rule_Field__c = mappingFound.Rule_Library__r.Rule_Field__c;
			ruleObj.Rule_Operator__c = mappingFound.Rule_Library__r.Rule_Operator__c;
			ruleObj.Rule_Gender__c =  mappingFound.Rule_Library__r.Rule_Gender__c;
			string actualResult = RuleBuilderController.saveRuletoDB(JSON.serialize(ruleObj), mappingFound.Rule_Category__r.Rule_Type__c);
			system.assertEquals('DUPLICATE_RULE', actualResult);
			ruleObj.Rule_Field__c = 'Test Field';
			ruleObj.is_Active__c = true;
			actualResult = RuleBuilderController.saveRuletoDB(JSON.serialize(ruleObj), 'Test Review of Systems');
			system.assertEquals('MAPPING_ERROR', actualResult);
		}
		test.stopTest(); 
	}

	public static testMethod void testUpdateDupRule() {
		User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
		test.StartTest();
		System.runAs(oUser)
		{       

			String query = 'select ID, Rule_Library__r.Rule_Value__c, Rule_Library__r.Rule_Gender__c,Rule_Library__r.Rule_Field__c, Rule_Library__r.Rule_Operator__c, Rule_Library__r.Rule_Description__c,Rule_Category__r.Rule_Type__c, Rule_Library__r.Rule_Library_Ext_Id__c,Rule_Library__r.Rule_Diagnosis__c,Rule_Library__r.Rule_ICD__c,Rule_Library__r.ID,Rule_Library__r.is_Active__c from Rule_Category_Library_Mapping__c ';
			List<Rule_Category_Library_Mapping__c> mappingFoundList = Database.query(query);
			System.assert(mappingFoundList.size()>0);
			Rule_Category_Library_Mapping__c  mappingFound = mappingFoundList.get(0);
			Rule_Category_Library_Mapping__c  mappingFound2 = mappingFoundList.get(1);
			Rule_Library__c ruleObj = mappingFound2.Rule_Library__r; 
			ruleObj.Rule_Field__c = mappingFound.Rule_Library__r.Rule_Field__c;
			ruleObj.Rule_Operator__c = mappingFound.Rule_Library__r.Rule_Operator__c;
			ruleObj.Rule_Gender__c =  mappingFound.Rule_Library__r.Rule_Gender__c;
			ruleObj.Rule_Value__c = mappingFound.Rule_Library__r.Rule_Value__c;
			string actualResult = RuleBuilderController.editRule(JSON.serialize(ruleObj), mappingFound.Rule_Category__r.Rule_Type__c);
			system.assertEquals('DUPLICATE_RULE', actualResult);
			ruleObj = mappingFound2.Rule_Library__r; 
			ruleObj.Rule_Field__c = 'Test Field';
			actualResult = RuleBuilderController.editRule(JSON.serialize(ruleObj), 'Test Mapping');
			system.assertEquals('MAPPING_ERROR', actualResult);
		}
		test.stopTest(); 
	}


	public static testMethod void testFetchAllRules(){
		User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
		test.StartTest();
		System.runAs(oUser)
		{
			String searchKey = 'morning';
			String condition = '';
			if(searchKey != null) {
				condition = 'where Rule_Field__c like \'%'+ searchKey + '%\'';
			}
			String query = 'SELECT ID, is_Active__c,Rule_Field__c, 	Rule_Library_Ext_Id__c, Rule_Description__c, Rule_Gender__c, Rule_ICD__c, Rule_Operator__c, Rule_Diagnosis__c, Rule_Value__c,Multiple_Value_Count__c from  Rule_Library__c ' +condition;
			List< Rule_Library__c> allData = Database.query(query);

			String allRules  = RuleBuilderController.fetchAllRules(searchKey, true, 'RuleName');
			System.assertEquals(allRules, JSON.serialize(allData));
            
            String allICDRules = RuleBuilderController.fetchAllRules(searchKey, true, 'ICDCode');
            
            String allICDDescRules = RuleBuilderController.fetchAllRules(searchKey, true, 'ICDDescription');
		}
		test.stopTest(); 
	}

	public static testMethod void testGetAllConfigurations(){
		User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
		test.StartTest();
		System.runAs(oUser)
		{
			Map<String,String> dbConfigs = new Map<String,String>();

			smartlogic_configuration__mdt[] tempConfigs = [select DeveloperName, value__c from smartlogic_configuration__mdt];

			dbConfigs.put('User_Name', userinfo.getName());

			Map<string,String> allConfigs = RuleBuilderController.getAllConfigurations();
			allConfigs.put('User_Name', userinfo.getName());
			for(smartlogic_configuration__mdt testConf : tempConfigs) {
				System.assert(allConfigs.containsKey(testConf.DeveloperName));    
			}

		}
		test.stopTest();
	}

	public static testMethod void testFetchRulesByCategory() {
		User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
		test.StartTest();
		System.runAs(oUser)
		{
			String categoryLabel = 'All';
			String searchKey = 'morning';
			String condition = 'where';

			if(searchKey != null) {
				if(condition != 'where') {
					condition = condition + ' and ';
				}
				condition = condition + ' Rule_Library__r.Rule_Field__c like \'%'+ searchKey + '%\'';    		
			}
			String query = 'select Rule_Library__r.Rule_Description__c, Rule_Library__r.Rule_Library_Ext_Id__c, Rule_Library__r.id,Rule_Library__r.Rule_Diagnosis__c,Rule_Library__r.Rule_ICD__c, Rule_Library__r.is_Active__c from Rule_Category_Library_Mapping__c '+( (condition=='where')? '': condition);
			List< Rule_Category_Library_Mapping__c> dbRules = Database.query(query);


			String allRules = RuleBuilderController.fetchRulesByCategory(categoryLabel, searchKey, true, 'RuleName');
			system.debug(JSON.deserialize(allRules, List<Rule_Category_Library_Mapping__c>.class));
			List<Rule_Category_Library_Mapping__c> actualList = (List<Rule_Category_Library_Mapping__c>)JSON.deserialize(allRules, List<Rule_Category_Library_Mapping__c>.class);
			System.assertEquals(actualList.size(), dbRules.size());
            
            String allICDRules = RuleBuilderController.fetchRulesByCategory(categoryLabel, searchKey, true, 'ICDCode');
            
            String allICDDescRules = RuleBuilderController.fetchRulesByCategory(categoryLabel, searchKey, true, 'ICDDescription');
		}
		test.stopTest();
	}


	public static testMethod void testFetchRulesByCategoryInactiveRules() {
		User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
		test.StartTest();
		System.runAs(oUser)
		{
			String condition = 'where Rule_Library__r.is_active__c = false';
			String query = 'select id from Rule_Category_Library_Mapping__c '+( (condition=='where')? '': condition);
			List< Rule_Category_Library_Mapping__c> dbRules = Database.query(query);

			String allRules = RuleBuilderController.fetchRulesByCategory('Inactive', '', true, 'RuleName');
			system.debug(JSON.deserialize(allRules, List<Rule_Category_Library_Mapping__c>.class));
			List<Rule_Category_Library_Mapping__c> actualList = (List<Rule_Category_Library_Mapping__c>)JSON.deserialize(allRules, List<Rule_Category_Library_Mapping__c>.class);
			System.assertEquals(actualList.size(), dbRules.size());
		}
		test.stopTest();
	}

	public static testMethod void testFetchRulesByCategoryActiveRules() {
		User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
		test.StartTest();
		System.runAs(oUser)
		{
			String condition = 'where Rule_Library__r.is_active__c = true';
			String query = 'select id from Rule_Category_Library_Mapping__c '+( (condition=='where')? '': condition);
			List< Rule_Category_Library_Mapping__c> dbRules = Database.query(query);


			String allRules = RuleBuilderController.fetchRulesByCategory('Active', '', true, 'RuleName');
			system.debug(JSON.deserialize(allRules, List<Rule_Category_Library_Mapping__c>.class));
			List<Rule_Category_Library_Mapping__c> actualList = (List<Rule_Category_Library_Mapping__c>)JSON.deserialize(allRules, List<Rule_Category_Library_Mapping__c>.class);
			System.assertEquals(actualList.size(), dbRules.size());
		}
		test.stopTest();
	}

	public static testMethod void testChangeRuleStatus() {
		User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
		test.StartTest();
		System.runAs(oUser)
		{
			List<Rule_Library__c> ruleList = [select Id, is_Active__c from Rule_Library__c];            
			System.assert(ruleList.size()>0);
			Rule_Library__c ruleObj = ruleList.get(0);
			ruleObj.is_Active__c= ! ruleObj.is_Active__c;
			Boolean changeStatus = RuleBuilderController.changeRuleStatus(JSON.serialize(ruleObj));
			System.assertEquals(changeStatus, true);
		}
		test.stopTest();
	}

	public static testMethod void testFetchRuleById() {
		User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
		test.StartTest();
		System.runAs(oUser)
		{
			String ruleId = '';
			List<Rule_Library__c> ruleList = [select Id from Rule_Library__c];            
			if(ruleList.size() >= 1){
				ruleId = ruleList.get(0).Id;
			}
			List<Rule_Category_Library_Mapping__c > foundRules = [select  Rule_Category__r.Rule_Type__c, Rule_Library__r.id, Rule_Library__r.is_Active__c,Rule_Library__r.Rule_Field__c, Rule_Library__r.Rule_Gender__c, Rule_Library__r.Rule_ICD__c, Rule_Library__r.Rule_Operator__c, Rule_Library__r.Rule_Diagnosis__c, Rule_Library__r.Rule_Value__c, Rule_Library__r.Multiple_Value_Count__c   from Rule_Category_Library_Mapping__c where Rule_Library__r.id = :ruleId ];
			Rule_Category_Library_Mapping__c mappingObj = foundRules.get(0);

			String ruleObj = RuleBuilderController.fetchRuleById(ruleId);
			System.assertEquals(ruleObj, JSON.serialize(mappingObj));
		}
		test.stopTest();
	}
    public static testMethod void testFetchAllCombination(){
		User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
		test.StartTest();
		System.runAs(oUser)
		{
			String searchKey;
            String query = 'SELECT ID from Rule_Combination__c';
			List< Rule_Combination__c> allData = Database.query(query);
     		String allCombinationsString  = RuleBuilderController.fetchAllRuleCombinations(searchKey, true, 'RuleCombination','All');
			List< Rule_Combination__c> foundCombList = (List< Rule_Combination__c>)JSON.deserialize(allCombinationsString, List< Rule_Combination__c>.class);
			System.assertEquals(foundCombList.size(), allData.size());
		}
		test.stopTest(); 
	}

    public static testMethod void testFetchAllActiveCombinations(){
		User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
		test.StartTest();
		System.runAs(oUser)
		{
			String searchKey;
            String query = 'SELECT ID from Rule_Combination__c where is_Active__c = true';
			List< Rule_Combination__c> allData = Database.query(query);
     		String allCombinationsString  = RuleBuilderController.fetchAllRuleCombinations(searchKey, true, 'RuleCombination','Active');
			List< Rule_Combination__c> foundCombList = (List< Rule_Combination__c>)JSON.deserialize(allCombinationsString, List< Rule_Combination__c>.class);
			System.assertEquals(foundCombList.size(), allData.size());
		}
		test.stopTest(); 
	}
    public static testMethod void testFetchAllInactiveCombinations(){
		User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
		test.StartTest();
		System.runAs(oUser)
		{
			String searchKey;
			String query = 'SELECT ID from Rule_Combination__c where is_Active__c = false';
			List< Rule_Combination__c> allData = Database.query(query);
			String allCombinationsString  = RuleBuilderController.fetchAllRuleCombinations(searchKey, true, 'RuleCombination','Inactive');
			List< Rule_Combination__c> foundCombList = (List< Rule_Combination__c>)JSON.deserialize(allCombinationsString, List< Rule_Combination__c>.class);
			System.assertEquals(foundCombList.size(), allData.size());
		}
		test.stopTest(); 
	}

	public static testMethod void testchangeRuleCombinationStatus() {
		User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
		test.StartTest();
		System.runAs(oUser)
		{
			List<Rule_Combination__c> combList = [select Id, is_Active__c from Rule_Combination__c];            
			System.assert(combList.size()>0);
			Rule_Combination__c CombObj = combList.get(0);
			CombObj.is_Active__c= ! CombObj.is_Active__c;
			Boolean changeStatus = RuleBuilderController.changeRuleCombinationStatus(JSON.serialize(CombObj));
			System.assertEquals(changeStatus, true);
		}
		test.stopTest();
	}

	public static testMethod void testgetCombinationDescription() {
		User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
		test.StartTest();
		System.runAs(oUser)
		{
			List<Rule_Combination__c> combList = [select Id,Rule_Combination__c from Rule_Combination__c];            
			System.assert(combList.size()>0);
			Rule_Combination__c CombObj = combList.get(0);
			String combination = CombObj.Rule_Combination__c;
			String description = RuleBuilderController.getCombinationDescription(combination);
			System.assert(String.isNotBlank(description));
		}
	}
    
    public static testMethod void testgetRuleCombinationDescription() {
		User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
		test.StartTest();
		System.runAs(oUser)
		{
			List<Rule_Combination__c> combList = [select Id,Rule_Combination__c from Rule_Combination__c];            
			System.assert(combList.size()>0);
			Rule_Combination__c CombObj = combList.get(4);
			String combination = CombObj.Rule_Combination__c;
			String description = RuleBuilderController.getCombinationDescription(combination);
			System.assert(String.isNotBlank(description));
		}
	}
    
	public static testMethod void testSaveRuleCombination() {
		User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
		test.StartTest();
		System.runAs(oUser)
		{
			Rule_Combination__c ruleCombination = new Rule_Combination__c();
			ruleCombination.Rule_Combination__c = 'R1 AND R2';
			ruleCombination.Rule_Combination_Description__c = 'Hearing Loss = Left,Right,Bilateral AND Chest Pain = True,Yes,1';
			ruleCombination.Is_Active__c = true;
            ruleCombination.Gender__c = 'U';
			String result = RuleBuilderController.saveRuleCombinationtoDB(Json.serialize(ruleCombination));
			System.assertEquals(result,'SUCCESS');
			ruleCombination.Rule_Combination__c = 'R1 AND R2';
			ruleCombination.Is_Active__c = true;
			ruleCombination.Rule_Combination_Description__c = 'Hearing Loss = Left,Right,Bilateral AND Chest Pain = True,Yes,1';
            ruleCombination.Gender__c = 'U';
			result = RuleBuilderController.saveRuleCombinationtoDB(Json.serialize(ruleCombination));
			System.assertEquals(result,'DUPLICATE_RULE_COMBINATION');
		}
	}
	public static testMethod void testFetchRuleCombById() {
		User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
		test.StartTest();
		System.runAs(oUser)
		{
			List<Rule_Combination__c> combList = [select Id,Rule_Combination__c from Rule_Combination__c];            
			System.assert(combList.size()>0);
			Rule_Combination__c CombObj = combList.get(0);
			String combinationString =  RuleBuilderController.fetchRuleCombinationById(CombObj.id);
			System.assert(String.isNotBlank(combinationString));
			Rule_Combination__c actualCombination = (Rule_Combination__c)JSON.deserialize(combinationString, Rule_Combination__c.class);
            System.assertEquals(CombObj.id, actualCombination.id);
			System.assertEquals(CombObj.Rule_Combination__c, actualCombination.Rule_Combination__c);

		}
	}
	public static testMethod void testEditCombination() {
		User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
		test.StartTest();
		System.runAs(oUser)
		{
			List<Rule_Combination__c> combList = [select Id,Rule_Combination__c from Rule_Combination__c];            
			System.assert(combList.size()>0);
			Rule_Combination__c CombObj = combList.get(0);
			String combinationString =  RuleBuilderController.fetchRuleCombinationById(CombObj.id);
			System.assert(String.isNotBlank(combinationString));
			Rule_Combination__c actualCombination = (Rule_Combination__c)JSON.deserialize(combinationString, Rule_Combination__c.class);
			String oldCombination = actualCombination.Rule_Combination__c;
			actualCombination.Rule_Combination__c = 'R1 OR R4';
			String actualResult = RuleBuilderController.editRuleCombination(JSON.serialize(actualCombination));
			System.assertEquals('SUCCESS', actualResult);
			combinationString =  RuleBuilderController.fetchRuleCombinationById(CombObj.id);
			System.assert(String.isNotBlank(combinationString));
			Rule_Combination__c editedCombination = (Rule_Combination__c)JSON.deserialize(combinationString, Rule_Combination__c.class);
			System.assertNotEquals(oldCombination, editedCombination.Rule_Combination__c);

		}
	}
	public static testMethod void testEditCombinationDup() {
		User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
		test.StartTest();
		System.runAs(oUser)
		{
			List<Rule_Combination__c> combList = [select Id,Rule_Combination__c from Rule_Combination__c];            
			System.assert(combList.size()>0);
			Rule_Combination__c CombObj = combList.get(0);
			Rule_Combination__c CombObj1 = combList.get(1);
			String combinationString =  RuleBuilderController.fetchRuleCombinationById(CombObj.id);
			String combinationString1 =  RuleBuilderController.fetchRuleCombinationById(CombObj1.id);
			System.assert(String.isNotBlank(combinationString));
			Rule_Combination__c actualCombination = (Rule_Combination__c)JSON.deserialize(combinationString, Rule_Combination__c.class);
			Rule_Combination__c actualCombination1 = (Rule_Combination__c)JSON.deserialize(combinationString1, Rule_Combination__c.class);

			String oldCombination = actualCombination.Rule_Combination__c;
			actualCombination.Rule_Combination__c = actualCombination1.Rule_Combination__c;
			actualCombination.Gender__c = actualCombination1.Gender__c;
			String actualResult = RuleBuilderController.editRuleCombination(JSON.serialize(actualCombination));
			System.assertEquals(actualResult,'DUPLICATE_RULE_COMBINATION');

		}
	}
	public static testMethod void testCloneCombination() {
		User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
		test.StartTest();
		System.runAs(oUser)
		{
			List<Rule_Combination__c> combList = [select Id,Rule_Combination__c, Rule_Combination_Description__c from Rule_Combination__c];            
			System.assert(combList.size()>0);
			Rule_Combination__c CombObj = combList.get(0);
			String combinationString =  RuleBuilderController.fetchRuleCombinationById(CombObj.id);
			System.assert(String.isNotBlank(combinationString));
			Rule_Combination__c actualCombination = (Rule_Combination__c)JSON.deserialize(combinationString, Rule_Combination__c.class);
			String oldCombination = actualCombination.Rule_Combination__c;
			actualCombination.Rule_Combination__c = 'R1 OR R4';
			String actualResult = RuleBuilderController.cloneRuleCombination(JSON.serialize(actualCombination));
			System.assertEquals('SUCCESS', actualResult);
			combinationString =  RuleBuilderController.fetchRuleCombinationById(CombObj.id);
			System.assert(String.isNotBlank(combinationString));
			Rule_Combination__c clonedCombination = (Rule_Combination__c)JSON.deserialize(combinationString, Rule_Combination__c.class);
			System.assertEquals(oldCombination, clonedCombination.Rule_Combination__c);

		}
	}

	public static testmethod void testFetchInactiveRuleList() {
		List<String> ruleIdList = new List<String> ();
		ruleIdList.add('R1');
		ruleIdList.add('R2');

		String inActiveRules = RuleBuilderController.fetchInactiveRuleList(JSON.serialize(ruleIdList));
		Map<String,String> inActiveRuleMap = (Map<String,String>)JSON.deserialize(inActiveRules, Map<String,String>.class);
		System.assertEquals(0,inActiveRuleMap.size());

		ruleIdList.add('R5');
		inActiveRules = RuleBuilderController.fetchInactiveRuleList(JSON.serialize(ruleIdList));
		inActiveRuleMap = (Map<String,String>)JSON.deserialize(inActiveRules, Map<String,String>.class);
		System.assertEquals(1,inActiveRuleMap.size());

	}
    
    public static testMethod void testgetRuleCombinationString() {
		User oUser = [SELECT ID FROM User WHERE Email='Attestationuser@testorg.com' LIMIT 1];
		test.StartTest();
		System.runAs(oUser)
		{
			List<Rule_Combination__c> combList = [select Id,Rule_Combination__c from Rule_Combination__c];            
			System.assert(combList.size()>0);
			Rule_Combination__c CombObj = combList.get(4);
			String combination = CombObj.Rule_Combination__c;
			String description = RuleBuilderController.getCombinationString(combination);
			System.assert(String.isNotBlank(description));
		}
	}
}