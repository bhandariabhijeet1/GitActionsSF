public class RuleBuilderController {


	public static String fetchCategoriesData(){
		Map<string,List<String>> allCategories = SmartLogicRuleBuilderUtil.getCategoriesData();
		return JSON.serialize(allCategories);
	}

	/*
	 *This method is used to fetch  type field of all category records in the Rule Category Table.
	 * 
	 */ 
	@AuraEnabled 
	public static String fetchTypesData(){
		Map<String,String> allTypes = SmartLogicRuleBuilderUtil.getTypesData();
		return JSON.serialize(allTypes);
	} 

	@AuraEnabled 
	public static String fetchAllOperators(){
		Map<String,String> allOperators = SmartLogicRuleBuilderUtil.getDataTypeOperatorsMap();
		return JSON.serialize(allOperators);
	}

	//ToDo: Handle Global category
	@AuraEnabled
	public static String fetchFieldsForCategory(String category) {
		//Map<String, String> fieldLabelTypeMap = new Map<String, String>();
		List<FieldDefinition> lstFieldDefinition = new List<FieldDefinition>();        
        lstFieldDefinition.add(new FieldDefinition('Select Diagnosis', 'PICKLIST', new List<String>{'Active', 'Inactive'}));
        lstFieldDefinition.add(new FieldDefinition('Select Medication', 'PICKLIST', new List<String>{'Active', 'Inactive'}));
		if(!category.equalsIgnoreCase('global'))
		{
			String APINames = SmartLogicRuleBuilderUtil.getObjectAPINameForCategory(category);
			if(RulesEngineConstants.setSOAPNotesRelatedObjects.contains(APINames))
			{
				for(String sAPIName : RulesEngineConstants.setSOAPNotesRelatedObjects)
				{
					lstFieldDefinition.addAll(fetchFieldDefinitions(sAPIName));
				}
			}
			else
			{
				lstFieldDefinition.addAll(fetchFieldDefinitions(APINames));
			}
		}
		else
		{
			for(SmartLogic_Category_API_Name__c oMapping : [select API_Name__c from SmartLogic_Category_API_Name__c])
			{
				if(RulesEngineConstants.setSOAPNotesRelatedObjects.contains(oMapping.API_Name__c))
				{
					for(String sAPIName : RulesEngineConstants.setSOAPNotesRelatedObjects)
					{
						lstFieldDefinition.addAll(fetchFieldDefinitions(oMapping.API_Name__c));
					}
				}
				else
				{
					lstFieldDefinition.addAll(fetchFieldDefinitions(oMapping.API_Name__c));
				}
			}
		}
      system.debug('fieldValueis : '+lstFieldDefinition);
        
		return  JSON.serialize(lstFieldDefinition);
	}

	private static List<FieldDefinition>  fetchFieldDefinitions(String APINames)
	{
		List<FieldDefinition> lstFieldDefinition = new List<FieldDefinition>();       
		Map<String, String> fieldLabelTypeMap = new Map<String, String>(); 
		if(String.isNotBlank(APINames)) {

			SObjectType soapNoteType = Schema.getGlobalDescribe().get(APINames);
			Map<String,Schema.SObjectField> fieldMap = soapNoteType.getDescribe().fields.getMap();
			Map<String,String> allTypesOperatorMap = SmartLogicRuleBuilderUtil.getDataTypeOperatorsMap();

			for(String fieldName : fieldMap.keySet() ) {
				List<String> lstPicklistValues = new List<String>();
				Schema.DisplayType sfielddataType = fieldMap.get(fieldName).getDescribe().getType();
				if(sfielddataType == Schema.DisplayType.Picklist || sfielddataType == Schema.DisplayType.MultiPicklist)
				{
					list<Schema.PicklistEntry> lstPicklistValuesSchema = fieldMap.get(fieldName).getDescribe().getPickListValues();
					for (Schema.PicklistEntry sPicklistEntry : lstPicklistValuesSchema)
					{ 
						lstPicklistValues.add(sPicklistEntry.getLabel()); 
					}
				}
				else if(sfielddataType == Schema.DisplayType.Boolean)
				{
					lstPicklistValues.add('True'); 
					lstPicklistValues.add('False'); 
				}
				if(allTypesOperatorMap.containsKey(''+sfielddataType)) {
					lstFieldDefinition.add(new FieldDefinition(fieldMap.get(fieldName).getDescribe().getLabel(), sfielddataType+'', lstPicklistValues));
				}
			}
		}  

		return lstFieldDefinition; 
	}

	//ToDo: Handle Global category
	@AuraEnabled
	public static String fetchPickListValues(String fieldName, String category ) {

		List<String> allPicklistValues =  new List<String>();
		String APIName = SmartLogicRuleBuilderUtil.getObjectAPINameForCategory(category);
		Schema.SObjectType targetType = Schema.getGlobalDescribe().get(APIName);
		Sobject Object_name = targetType.newSObject();
		Schema.sObjectType sobject_type = Object_name.getSObjectType(); 
		Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
		Map<String, Schema.SObjectField> fieldMap = sobject_describe.fields.getMap(); 
		for(String key :  fieldMap.keySet()) {
			if(fieldMap.get(key).getDescribe().getLabel() == fieldName) {
				List<Schema.PicklistEntry> pick_list_values = fieldMap.get(key).getDescribe().getPickListValues();
				for (Schema.PicklistEntry a : pick_list_values) { 
					allPicklistValues.add(a.getValue());
				}
				return JSON.serialize(allPicklistValues);
			}
		}

		return JSON.serialize(allPicklistValues);
	}   

	@AuraEnabled
	public static String saveRuletoDB(String rule, String ruleType){
		system.debug(LoggingLevel.INFO,'Rule to be saved: '+ rule);
		Map<String, Object> obj = (Map<String, Object>) JSON.deserializeUntyped(rule);
		Rule_Library__c  newRule  = new Rule_Library__c();
		newRule.is_Active__c = (Boolean)obj.get('is_Active__c'); 
		newRule.Rule_Field__c = (String)obj.get('Rule_Field__c'); 
		newRule.Rule_Operator__c =(String)obj.get('Rule_Operator__c');
		newRule.Rule_Gender__c = (String)obj.get('Rule_Gender__c');
		newRule.Rule_ICD__c = (String)obj.get('Rule_ICD__c');
		newRule.Rule_Diagnosis__c = (String)obj.get('Rule_Diagnosis__c');
		newRule.Rule_Value__c = (String)obj.get('Rule_Value__c');
        newRule.Lookup_Type__c = (String)obj.get('Lookup_Type__c');
		String multiCount = (String) (obj.get('Multiple_Value_Count__c')+'');
		if(String.isNotBlank(multiCount)) {
			newRule.Multiple_Value_Count__c = Integer.valueOf(obj.get('Multiple_Value_Count__c'));	
		}

		return RuleOperationUtil.saveRule(newRule,ruleType);

	}

	@AuraEnabled
	public static String editRule(String rule, String ruleType){
		system.debug(LoggingLevel.INFO,'Rule to be edited: '+ rule);
		Map<String, Object> obj = (Map<String, Object>) JSON.deserializeUntyped(rule);
		Rule_Category_Library_Mapping__c oldMappingObj = RuleOperationUtil.fetchRuleById((String)obj.get('Id'));
		Rule_Library__c  oldRule  = oldMappingObj.Rule_Library__r;
		if(oldMappingObj != null) {
			Rule_Library__c  ruletoUpdate  = oldMappingObj.Rule_Library__r;
			ruletoUpdate.is_Active__c = (Boolean)obj.get('is_Active__c'); 
			ruletoUpdate.Rule_Field__c = (String)obj.get('Rule_Field__c'); 
			ruletoUpdate.Rule_Operator__c =(String)obj.get('Rule_Operator__c');
			ruletoUpdate.Rule_Gender__c = (String)obj.get('Rule_Gender__c');
			ruletoUpdate.Rule_ICD__c = (String)obj.get('Rule_ICD__c');
			ruletoUpdate.Rule_Diagnosis__c = (String)obj.get('Rule_Diagnosis__c');
			ruletoUpdate.Rule_Value__c = (String)obj.get('Rule_Value__c');
            ruletoUpdate.Lookup_Type__c = (String)obj.get('Lookup_Type__c');
			String multiCount = (String) (obj.get('Multiple_Value_Count__c')+'');
			if(String.isNotBlank(multiCount)) {
				ruletoUpdate.Multiple_Value_Count__c = Integer.valueOf(obj.get('Multiple_Value_Count__c'));	
			}
			String updateResult = RuleOperationUtil.updateRule(ruletoUpdate);
			//update mappping if required
			if(updateResult == 'SUCCESS'){
				if(ruleType.equals(oldMappingObj.Rule_Category__r.Rule_Type__c)) {
					system.debug(LoggingLevel.INFO,'updated rule has same category');
					return updateResult;
				}
				else {
					boolean updateMappingResult = RuleOperationUtil.updateMapping(oldMappingObj, ruleType);
					if(updateMappingResult) {

						return 'SUCCESS';
					}
					else {
						system.debug(LoggingLevel.Error, 'Mapping error in Edit');
						return 'MAPPING_ERROR';
					}
				}
			}
			else {
				return updateResult;
			}

		}
		else {
			system.debug(LoggingLevel.Error, 'Rule not found in Edit');
			return 'RULE_NOT_FOUND';
		}

	}

	@AuraEnabled
	public static String cloneRule(String rule, String ruleType){
		return saveRuletoDB(rule,ruleType);
	}


	@AuraEnabled
	public static String fetchAllRules(String searchKey, boolean isAsc, String sortFieldName) {
		String condition = '';
		String sortingCondition = '';
		if(searchKey != null) {
			condition = 'where Rule_Field__c like \'%'+ searchKey + '%\'';
			condition =  condition + ' or Rule_Description__c like \'%'+ searchKey + '%\'';
			condition =  condition + ' or Rule_Diagnosis__c like \'%'+ searchKey + '%\'';
			condition =  condition + ' or Rule_ICD__c like \'%'+ searchKey + '%\'';
		}
		if (sortFieldName != '') {
			if(sortFieldName == 'RuleName'){
				sortFieldName = 'Rule_Description__c';
			}else if(sortFieldName == 'ICDCode'){
				sortFieldName = 'Rule_ICD__c';
			} else if(sortFieldName == 'ICDDescription'){
				sortFieldName = 'Rule_Diagnosis__c';
			}
        	sortingCondition = ' order by ' + sortFieldName;
 		 	//if isAsc is equal tp ture then set 'asc' order otherwise set 'desc' order.
         	if (isAsc) {
         		sortingCondition += ' asc';
         	} else {
            	sortingCondition += ' desc';
         	}
         	sortingCondition += ' NULLS LAST';
      	}
      	      	
		String query = 'SELECT ID, is_Active__c,Rule_Field__c, 	Rule_Library_Ext_Id__c, Rule_Description__c, Rule_Gender__c, Rule_ICD__c, Rule_Operator__c, Rule_Diagnosis__c, Rule_Value__c,Multiple_Value_Count__c, Lookup_Type__c from  Rule_Library__c ' +condition+sortingCondition;
		List< Rule_Library__c> allRules = Database.query(query);
		return JSON.serialize(allRules);
	}

	@AuraEnabled
	public static Map<String, String> getAllConfigurations(){
		Map<string,String> allConfigs = SmartLogicRuleBuilderUtil.getAllConfigValues();
		allConfigs.put('User_Name', userinfo.getName());
		allConfigs.put('home_URL', System.Url.getSalesforceBaseURL().toExternalForm());
		allConfigs.put('logout_URL', System.Url.getSalesforceBaseURL().toExternalForm() + '/secur/logout.jsp');
		return allConfigs;
	}

	@AuraEnabled
	public static String fetchRulesByCategory(String categoryLabel, String searchKey, boolean isAsc, String sortFieldName) {
		String condition = 'where';
		String sortingCondition = '';
		String whereClause = '';
		boolean closeBracket = false;
		
		if(!categoryLabel.equalsIgnoreCase('All')) {
			if(categoryLabel.contains('Inactive')) {
				condition = condition + '  Rule_Library__r.is_Active__c != true';
			}
			else if(categoryLabel.contains('Active')) {
				condition = condition + '   Rule_Library__r.is_Active__c != false';
			}
			else {
				condition = condition +  '  Rule_Category__r.Rule_Type__c = \'' + categoryLabel + '\'';
			}
		}
		system.debug(LoggingLevel.INFO,'searchKey'+searchKey);
		if(searchKey != null) {
			if(condition != 'where') {
				condition = condition + ' and (';
				closeBracket = true;
			}
			condition = condition + ' Rule_Library__r.Rule_Field__c like \'%'+ searchKey + '%\'';
			condition =  condition + ' or Rule_Library__r.Rule_Description__c like \'%'+ searchKey + '%\'';
			condition =  condition + ' or Rule_Library__r.Rule_Diagnosis__c	 like \'%'+ searchKey + '%\'';
			condition =  condition + ' or Rule_Library__r.Rule_ICD__c like \'%'+ searchKey + '%\'';
			if(closeBracket){
				condition =  condition + ')';
			}
		}
		
		if (sortFieldName != '') {
			if(sortFieldName == 'RuleName'){
				sortFieldName = 'Rule_Library__r.Rule_Description__c';
			}else if(sortFieldName == 'ICDCode'){
				sortFieldName = 'Rule_Library__r.Rule_ICD__c';
			} else if(sortFieldName == 'ICDDescription'){
				sortFieldName = 'Rule_Library__r.Rule_Diagnosis__c';
			}
        	sortingCondition = ' order by ' + sortFieldName;
 		 	//if isAsc is equal tp ture then set 'asc' order otherwise set 'desc' order.
         	if (isAsc) {
         		sortingCondition += ' asc';
         	} else {
            	sortingCondition += ' desc';
         	}
         	sortingCondition += ' NULLS LAST';
      	}
      	
      	whereClause = ((condition == 'where') ? sortingCondition : (condition + sortingCondition));
      
		String query = 'select Rule_Library__r.Rule_Description__c, Rule_Library__r.Rule_Library_Ext_Id__c, Rule_Library__r.id,Rule_Library__r.Rule_Diagnosis__c,Rule_Library__r.Rule_ICD__c, Rule_Library__r.is_Active__c from Rule_Category_Library_Mapping__c '+ whereClause;
		system.debug(LoggingLevel.INFO,query);
		List< Rule_Library__c> allRules = new List<Rule_Library__c> ();
		for(Rule_Category_Library_Mapping__c ruleMapping :  Database.query(query)) {
			allRules.add(ruleMapping.Rule_Library__r);
		}
		return JSON.serialize(allRules);
	}

	@AuraEnabled 
	public static boolean changeRuleStatus(String rule) {
		Map<String, Object> obj = (Map<String, Object>) JSON.deserializeUntyped(rule);
		Rule_Library__c  newRule  = new Rule_Library__c();
		newRule.is_Active__c = (Boolean)obj.get('is_Active__c'); 
		newRule.Id = (String)obj.get('Id'); 
		return RuleOperationUtil.changeRuleStatus(newRule, newRule.is_Active__c);
	}


	@AuraEnabled
	public static String fetchRuleById(String ruleId) {
		return JSON.serialize(RuleOperationUtil.fetchRuleById(ruleId));
	}

	@AuraEnabled
	public static String fetchAllRuleCombinations(String searchKey, boolean isAsc, String sortFieldName, String isActive){
		String sortingCondition = '';
		List<Rule_Combination__c> allRules = new List<Rule_Combination__c>();
		Map<String, Rule_Combination__c> mapCombRules = new Map<String, Rule_Combination__c>();
		List<String> lstRuleCombinations = new List<String>();
		if (sortFieldName != '' && sortFieldName != 'RuleCombination') {
			if(sortFieldName == 'ICDCode'){
				sortFieldName = 'Rule_ICD__c';
			} else if(sortFieldName == 'ICDDescription'){
				sortFieldName = 'Rule_Diagnosis__c';
			}
        	sortingCondition = ' order by ' + sortFieldName;
 		 	//if isAsc is equal tp ture then set 'asc' order otherwise set 'desc' order.
         	if (isAsc) {
         		sortingCondition += ' asc';
         	} else {
            	sortingCondition += ' desc';
         	}
      	}      	
      	
      	String query = 'SELECT ID, Rule_combination_Ext_Id__c, Is_Active__c, Rule_Combination__c, Rule_Combination_Description__c, Gender__c, Rule_ICD__c, Rule_Diagnosis__c, Rule_Combination_Formatted__c from  Rule_Combination__c' + sortingCondition;
      	if('Active'.equalsIgnoreCase(isActive)){
      		query = 'SELECT ID, Rule_combination_Ext_Id__c, Is_Active__c, Rule_Combination__c, Rule_Combination_Description__c, Gender__c, Rule_ICD__c, Rule_Diagnosis__c, Rule_Combination_Formatted__c from  Rule_Combination__c where Is_Active__c=true' + sortingCondition;
      	}else if('Inactive'.equalsIgnoreCase(isActive)){
      		query = 'SELECT ID, Rule_combination_Ext_Id__c, Is_Active__c, Rule_Combination__c, Rule_Combination_Description__c, Gender__c, Rule_ICD__c, Rule_Diagnosis__c, Rule_Combination_Formatted__c from  Rule_Combination__c where Is_Active__c=false' + sortingCondition;
      	}	
      	system.debug(LoggingLevel.INFO,query);
      	for(Rule_Combination__c comb : Database.query(query)) {
			if(searchKey != null){
				if(comb.Rule_Combination_Description__c.toLowerCase().contains(searchKey.toLowerCase())
			  		|| (comb.Rule_ICD__c.toLowerCase().contains(searchKey.toLowerCase()))
			  		|| (comb.Rule_Diagnosis__c.toLowerCase().contains(searchKey.toLowerCase()))){
			   		if(sortFieldName == 'RuleCombination'){
			   			String key = comb.Rule_Combination_Description__c+'~~'+comb.Rule_Combination__c+'~~'+comb.Gender__c;
			   			lstRuleCombinations.add(key);	
			   			mapCombRules.put(key, comb);
			   		}
			   		else{
						allRules.add(comb);	
			   		}
				}
			}
			else{
				if(sortFieldName == 'RuleCombination'){
					String key = comb.Rule_Combination_Description__c+'~~'+comb.Rule_Combination__c+'~~'+comb.Gender__c;
			   		lstRuleCombinations.add(key);
			   		mapCombRules.put(key, comb);
			   	}
			   	else{
					allRules.add(comb);	
			   	}
			}			
		}
		if (sortFieldName == 'RuleCombination') {
			lstRuleCombinations.sort();
			for(String rule : lstRuleCombinations) {
				Rule_Combination__c combR =  mapCombRules.get(rule);
				if (isAsc) {
         			allRules.add(combR);
         		} else {	
         			if(allRules.size() == 0){
            			allRules.add(combR);
         			}
         			else{
         				allRules.add(0, combR);
         			}
         		}    			
			}				
		}
		return JSON.serialize(allRules);
	}

	@AuraEnabled 
	public static boolean changeRuleCombinationStatus(String rule) {
		Map<String, Object> obj = (Map<String, Object>) JSON.deserializeUntyped(rule);
		Rule_Combination__c  newRule  = new Rule_Combination__c();
		newRule.Is_Active__c = (Boolean)obj.get('Is_Active__c'); 
		newRule.Id = (String)obj.get('Id'); 
		return RuleOperationUtil.changeRuleCombinationStatus(newRule, newRule.is_Active__c);
	}

	@AuraEnabled
	public static String saveRuleCombinationtoDB(String ruleCombination){     
		system.debug(LoggingLevel.INFO,'saveRuleCombinationtoDB '+ruleCombination);  
		Map<String, Object> obj = (Map<String, Object>) JSON.deserializeUntyped(ruleCombination);
		Rule_Combination__c newRuleComb  = new Rule_Combination__c();
		newRuleComb.Is_Active__c = (Boolean)obj.get('Is_Active__c'); 
		newRuleComb.Rule_ICD__c = (String)obj.get('Rule_ICD__c');
		newRuleComb.Rule_Diagnosis__c = (String)obj.get('Rule_Diagnosis__c');
		newRuleComb.Rule_Combination__c = (String)obj.get('Rule_Combination__c');
		newRuleComb.Rule_Combination_With_Exp__c = (String)obj.get('Rule_Combination_With_Exp__c');
		newRuleComb.Rule_Combination_Key__c = RuleOperationUtil.generateRuleCombinationHashCode( (String)obj.get('Rule_Combination__c'));
		newRuleComb.Gender__c = (String)obj.get('Gender__c');
		newRuleComb.Rule_Combination_Description__c = (String)obj.get('Rule_Combination_Description__c');
		newRuleComb.Rule_Combination_Formatted__c = RuleEngineUtil.formatRuleCombinationDescription((String)obj.get('Rule_Combination_Description__c'));
		return RuleOperationUtil.saveRuleCombination(newRuleComb);         
	}

	@AuraEnabled
	public static String getCombinationDescription(String ruleCombination){     
		Map<string,String> allData = SmartLogicRuleBuilderUtil.getDescriptionByRules(ruleCombination);
		return JSON.serialize(allData);       
	}    

	@AuraEnabled
	public static String fetchRuleCombinationById(String ruleId) {
		return JSON.serialize(RuleOperationUtil.fetchRuleCombinationById(ruleId));
	}

	@AuraEnabled
	public static String editRuleCombination(String ruleCombination){       
		Map<String, Object> obj = (Map<String, Object>) JSON.deserializeUntyped(ruleCombination);
		system.debug(LoggingLevel.INFO,'editRuleCombinationtoDB '+ruleCombination); 
		Rule_Combination__c oldRuleCombination = RuleOperationUtil.fetchRuleCombinationById((String)obj.get('Id'));       
		if(oldRuleCombination != null) {
			Rule_Combination__c  ruleCombtoUpdate = oldRuleCombination;
			ruleCombtoUpdate.Is_Active__c = (Boolean)obj.get('Is_Active__c'); 
			ruleCombtoUpdate.Gender__c = (String)obj.get('Gender__c');
			ruleCombtoUpdate.Rule_ICD__c = (String)obj.get('Rule_ICD__c');
			ruleCombtoUpdate.Rule_Diagnosis__c = (String)obj.get('Rule_Diagnosis__c');
			ruleCombtoUpdate.Rule_Combination__c = (String)obj.get('Rule_Combination__c');
			ruleCombtoUpdate.Rule_Combination_With_Exp__c = (String)obj.get('Rule_Combination_With_Exp__c');
			ruleCombtoUpdate.Rule_Combination_Key__c = RuleOperationUtil.generateRuleCombinationHashCode( (String)obj.get('Rule_Combination__c'));
			ruleCombtoUpdate.Rule_Combination_Description__c = (String)obj.get('Rule_Combination_Description__c');
			ruleCombtoUpdate.Rule_Combination_Formatted__c = RuleEngineUtil.formatRuleCombinationDescription((String)obj.get('Rule_Combination_Description__c'));

			String updateResult = RuleOperationUtil.updateRuleCombination(ruleCombtoUpdate);

			if(updateResult == 'SUCCESS'){
				return 'SUCCESS';
			}
			else {
				return updateResult;
			}       
		}
		else {
			system.debug(LoggingLevel.ERROR,'Rule combination not found in edit'); 
			return 'RULE_COMBINATION_NOT_FOUND';
		}         
	}

	@AuraEnabled
	public static String cloneRuleCombination(String ruleCombination){
		return saveRuleCombinationtoDB(ruleCombination);    	 
	}

	@AuraEnabled 
	public static String fetchInactiveRuleList(String ruleExtIdList) {
		List<String> ruleExtIds = (List<String>) JSON.deserialize(ruleExtIdList, List<String>.class);
		Map<String,String> ruleMap = new Map<String,String>();
		for(Rule_Library__c ruleLib : [select Rule_Library_Ext_Id__c, Rule_Description__c from Rule_Library__c where Rule_Library_Ext_Id__c in :ruleExtIds and is_Active__c != true])
		{
			ruleMap.put(ruleLib.Rule_Library_Ext_Id__c, ruleLib.Rule_Description__c);
		}
		return JSON.serialize(ruleMap);
	}
    
    @AuraEnabled
	public static String getCombinationString(String ruleCombination){     
		Map<String, String> allData = SmartLogicRuleBuilderUtil.replaceExpIdByRules(ruleCombination);
		return JSON.serialize(allData);              
	}

	public Class FieldDefinition
	{
		public String fieldName{get;set;}
		public String fieldDataType{get;set;}
		public List<String> lstfieldValue{get;set;}

		public FieldDefinition(String fieldName, String fieldDataType, List<String> lstfieldValue)
		{
			this.fieldName = fieldName;
			this.fieldDataType = fieldDataType;
			this.lstfieldValue = lstfieldValue;
		}
	}
}