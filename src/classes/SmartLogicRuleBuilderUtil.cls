public class SmartLogicRuleBuilderUtil {
	//Configurations Map
	public static Map<String,String> configs = null;

	public static Map<String,List<String>> getCategoriesData() {
		Map<String,List<String>> allData = new Map<String,List<String>>();
		for(Rule_Category__c category : [select Rule_Category__c , Rule_Type__c from Rule_Category__c ]) {
			if(!allData.containsKey(category.Rule_Category__c)) {
				alldata.put(category.Rule_Category__c, new List<String>());
			}
			allData.get(category.Rule_Category__c).add(category.Rule_Type__c);
		}
		return allData;
	}

	public static Map<String,String> getTypesData() {
		Map<String,String> allData = new Map<String,String>();
		for(Rule_Category__c category : [select Rule_Category__c,  Rule_Type__c from Rule_Category__c ]) {
			allData.put(category.Rule_Type__c,category.Rule_Category__c);
		}
		return allData;
	}

	//To Do: move this to custom settings
	public static Map<String,String> getDataTypeOperatorsMap() {
		Map<String,String> dataTypeOperatorMap = new Map<String,String>();
		dataTypeOperatorMap.put('STRING', '=,!=,STARTS WITH,CONTAINS');
		dataTypeOperatorMap.put('INTEGER', '=,!=,<,<=,>,>=');
		dataTypeOperatorMap.put('DOUBLE', '=,!=,<,<=,>,>=');
		dataTypeOperatorMap.put('BOOLEAN', '!=,=');
		dataTypeOperatorMap.put('PICKLIST', '=,!=');
		dataTypeOperatorMap.put('MULTIPICKLIST', ':');
		return dataTypeOperatorMap;
	}

	public static String  getObjectAPINameForCategory(String categoryName) {

		for(SmartLogic_Category_API_Name__c apiNameObj : [select API_Name__c from SmartLogic_Category_API_Name__c where Name = :categoryName]) {
			return apiNameObj.API_Name__c;
		}

		return '';
	}

	public static Map<String,String> getallConfigValues(){
		if(configs==null){
			configs = new Map<String,String>();
		}
		if(configs.size()==0){
			smartlogic_configuration__mdt[] tempConfigs = [select DeveloperName, value__c from smartlogic_configuration__mdt];
			for(smartlogic_configuration__mdt tConf : tempConfigs){
				configs.put(tConf.DeveloperName, tConf.value__c);
			}
		}
		return configs;
	}

	public static Map<String,String> getDescriptionByRules(String ruleCombination) {
		//TO DO: fetch only combinations related to rules
		Map<String,String> allData = new Map<String,String>();
		String ruleCombinationOri = ruleCombination;
		List<String> ruleList = RuleEngineUtil.splitCombinationIntoRules(ruleCombination);
		List<String> ruleDescriptionList = new List<String>();
		System.debug(LoggingLevel.INFO,'ruleList: '+ ruleList);
		for(String rule : ruleList) {
			rule = rule.remove(')');
			rule = rule.remove('(');
			rule = rule.remove('{');
			String tempString = rule.substringAfter('}');
			rule = rule.removeEnd(tempString);
			rule = rule.remove('}');
			rule = rule.trim();            
			if(rule.startsWith('EXP')){
				Rule_Combination__c ruleCombObj = [select Rule_Combination_Description__c from Rule_Combination__c where Rule_combination_Ext_Id__c = :rule];
				if(ruleCombObj != null){
					ruleCombination = ruleCombination.replaceFirst(rule, '(' + ruleCombObj.Rule_Combination_Description__c + ')');
					ruleDescriptionList.add(ruleCombObj.Rule_Combination_Description__c);	
					if(!allData.containsKey(rule)){				
						allData.put(rule, ruleCombObj.Rule_Combination_Description__c);
					}
					else{
						String dupRule = rule + '_DUP';
						allData.put(dupRule, ruleCombObj.Rule_Combination_Description__c);
					}
				}
				else{
					ruleCombination = '';
					break;
				}	
			}
			else if(rule.startsWith('R')){
				Rule_Library__c ruleObj = [select Rule_Description__c from Rule_Library__c where Rule_Library_Ext_Id__c = :rule];
				if(ruleObj != null){
					ruleCombination = ruleCombination.replaceFirst(rule, ruleObj.Rule_Description__c);
					ruleDescriptionList.add(ruleObj.Rule_Description__c);
					if(!allData.containsKey(rule)){
						allData.put(rule, ruleObj.Rule_Description__c);
					}
					else{
						String dupRule = rule + '_DUP';
						allData.put(dupRule, ruleObj.Rule_Description__c);
					}
				}
				else{
					ruleCombination = '';
					break;
				}	
				System.debug(LoggingLevel.INFO, 'Rule: '+ rule);
				System.debug(LoggingLevel.INFO, 'Desc: '+ ruleObj.Rule_Description__c);
				System.debug(LoggingLevel.INFO, 'Comb1: '+ ruleCombination);
			}
			
		}
		allData.put(ruleCombinationOri.trim(), ruleCombination.trim());
		system.debug('allData ***'+allData);
		return allData;
	}
    
    public static Map<String,String> replaceExpIdByRules(String ruleCombination) {
		//TO DO: fetch only combinations related to rules
		Map<String,String> allData = new Map<String,String>();
		String ruleCombinationOri = ruleCombination;
		List<String> ruleList = RuleEngineUtil.splitCombinationIntoRules(ruleCombination);
		List<String> ruleDescriptionList = new List<String>();
		System.debug(LoggingLevel.INFO,'ruleList: '+ ruleList);
		for(String rule : ruleList) {
			rule = rule.remove(')');
			rule = rule.remove('(');
			rule = rule.remove('{');
			String tempString = rule.substringAfter('}');
			rule = rule.removeEnd(tempString);
			rule = rule.remove('}');
			rule = rule.trim();            
			String ruleId = rule;
			if(rule.startsWith('EXP')){
				Rule_Combination__c ruleCombObj = [select Rule_Combination__c from Rule_Combination__c where Rule_combination_Ext_Id__c = :rule];
				if(ruleCombObj != null){
					ruleCombination = ruleCombination.replaceFirst(rule, '(' + ruleCombObj.Rule_Combination__c + ')');
					ruleId =  ruleCombObj.Rule_Combination__c;
				}	
			}			
			allData.put(rule, ruleId);
        }
        allData.put(ruleCombinationOri.trim(), ruleCombination.trim());
		system.debug('allData ***'+allData);
		return allData;
	}
}