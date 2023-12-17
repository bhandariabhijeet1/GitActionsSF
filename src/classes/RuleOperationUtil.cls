public class RuleOperationUtil {

	/**
	 * This method saves rule to DB and creates mapping with the 
	 * specified rule Category.
	 */
	public static string saveRule(Rule_Library__c newRule, String ruleType) {
		try {
			newRule.Rule_Library_Ext_Id__c = 'R' + getNextRuleId();
			system.debug(LoggingLevel.INFO,'Creating rule with external ID'+ newRule.Rule_Library_Ext_Id__c);
			Database.SaveResult sr = Database.insert(newRule, false);
			if (!sr.isSuccess()) {
				// Insertion failed due to duplicate detected
				for(Database.Error duplicateError : sr.getErrors()){
					system.debug(LoggingLevel.ERROR,duplicateError);
                    return 'DUPLICATE_RULE';
				}
				return 'ERROR';
			}
			else {
				if(createRuleCategoryMapping(sr.getId(), ruleType)) {
					return 'SUCCESS';	
				}
				else {
					Database.delete(newRule, false);
					system.debug(LoggingLevel.ERROR,'MAPPING_ERROR');
					return 'MAPPING_ERROR';	
				}
			}
		}
		catch(Exception e) {
			system.debug(LoggingLevel.ERROR,e.getMessage());
			return e.getMessage();
		}
	}

	/**
	 * This method saves rule to DB and creates mapping with the 
	 * specified rule Category.
	 */
	public static string updateRule(Rule_Library__c newRule) {
		try {
			Database.SaveResult sr = Database.update(newRule, false);
			if (!sr.isSuccess()) {
				// Insertion failed due to duplicate detected
				for(Database.Error duplicateError : sr.getErrors()){
					system.debug(LoggingLevel.ERROR,duplicateError);
					return 'DUPLICATE_RULE';
				}
				return 'ERROR';
			}
			else {
				return 'SUCCESS';	
			}
		}
		catch(Exception e) {
			system.debug(LoggingLevel.ERROR,e.getMessage());
			return e.getMessage();
		}
	}



	/**
	 * This method maps a rule to specific category.
	 */
	public static boolean createRuleCategoryMapping(String ruleId, String ruleType) {
		Rule_Category_Library_Mapping__c mapping = new Rule_Category_Library_Mapping__c();
		try {
			mapping.Rule_Library__c = ruleId;
			List<Rule_Category__c>  categoryList = [Select id from Rule_Category__c where Rule_Type__c = :ruleType];
			if(categoryList.size() > 0) {
				mapping.Rule_Category__c = categoryList.get(0).id;
				insert mapping;
				return true;
			}
			else {
				return false;
			}

		}
		catch(Exception e) {
			system.debug(LoggingLevel.ERROR,e.getMessage());
			return false;
		}	
	}


	/**
		This method updates the category maping for a rule.
	 */
	public static boolean updateMapping(Rule_Category_Library_Mapping__c oldMappingObj, String ruleType){
		List<Rule_Category__c> allCategories = [select Id, Rule_Type__c from Rule_Category__c where  Rule_Type__c = :ruleType ];
		if(allCategories.size() > 0) {
			oldMappingObj.Rule_Category__c = allCategories.get(0).Id;
			try {
				update oldMappingObj;
				return true;
			}
			catch(Exception e) {
				system.debug(LoggingLevel.ERROR,e.getMessage());
				return false;
			} 		
		}
		else {
			system.debug(LoggingLevel.ERROR,'No Category  found for the rule Type--'+ ruleType);
			return false;
		}

		return false;
	}


	/**
	 * This method activates/deactivates the rule.
	 */

	public static boolean  changeRuleStatus(Rule_Library__c rule, boolean shouldActivate) {
		try {
			List<Rule_Library__c> foundRules = [select id from Rule_Library__c where id = :rule.Id];
			Rule_Library__c foundRule = foundRules.get(0);
			foundRule.is_Active__c = shouldActivate;
			update foundRule;
			return true;
		}
		catch(Exception e ) {
			system.debug(LoggingLevel.ERROR,'Unable to change status'+ e.getMessage());
			return false;
		}

	}



	/**
	 * This method fetches rule with the specific id from DB.
	 */
	public static Rule_Category_Library_Mapping__c fetchRuleById (String ruleId){
		try {
			List<Rule_Category_Library_Mapping__c > foundRules = [select  Rule_Category__r.Rule_Type__c, Rule_Library__r.id, Rule_Library__r.is_Active__c,Rule_Library__r.Rule_Field__c, Rule_Library__r.Rule_Gender__c, Rule_Library__r.Rule_ICD__c, Rule_Library__r.Rule_Operator__c, Rule_Library__r.Rule_Diagnosis__c, Rule_Library__r.Rule_Value__c, Rule_Library__r.Multiple_Value_Count__c, Rule_Library__r.Lookup_Type__c    from Rule_Category_Library_Mapping__c where Rule_Library__r.id = :ruleId ];
			Rule_Category_Library_Mapping__c mappingObj = foundRules.get(0);

			return mappingObj;
		}
		catch(Exception e) {
			system.debug(LoggingLevel.ERROR,'Rule with Id not found'+e.getMessage());
			return null;
		}	

	}

	/*This method activates/deactivates the rule.*/     
	public static boolean changeRuleCombinationStatus(Rule_Combination__c rule, boolean shouldActivate) {
		try {
			List<Rule_Combination__c> foundRules = [select id from Rule_Combination__c where id = :rule.Id];
			Rule_Combination__c foundRule = foundRules.get(0);
			foundRule.is_Active__c = shouldActivate;
			update foundRule;
			return true;
		}
		catch(Exception e ) {
			system.debug(LoggingLevel.ERROR,'Unable to change status'+ e.getMessage());
			return false;
		}

	}

	/*This method saves rule combination to DB*/
	public static string saveRuleCombination(Rule_Combination__c newRuleComb) {
		try {
			newRuleComb.Rule_combination_Ext_Id__c = 'EXP'+getNextRuleCombinationId();
			Database.SaveResult sr = Database.insert(newRuleComb, false);
			if (!sr.isSuccess()) {
				system.debug('Errors ' + sr.getErrors());
				// Insertion failed due to duplicate detected
				for(Database.Error duplicateError : sr.getErrors()){
					system.debug(LoggingLevel.ERROR,duplicateError);
					if(duplicateError.getMessage().contains('data value too large')){
                        return 'COMBINATION_TOO_LONG';
                    }
                    else{
						return 'DUPLICATE_RULE_COMBINATION';
                    }
				}
				return 'ERROR';
			}
			else {
				return 'SUCCESS';           	 	
			}
		}
		catch(Exception e) {
			system.debug(LoggingLevel.ERROR,e.getMessage());
			return e.getMessage();
		}
	}



	public static integer getNextRuleId() {
		integer maxRuleId = 0;

		List<Rule_Library__c> allRules = [select Rule_Library_Ext_Id__c from Rule_Library__c];

		for(Rule_Library__c rule : allRules) {
			String ruleExt = rule.Rule_Library_Ext_Id__c;
			if(String.isNotBlank(ruleExt)) {
				ruleExt = ruleExt.removeStart('R');  
				if(ruleExt.isNumeric()) {
					integer ruleId = Integer.valueOf(ruleExt);
					if(maxRuleId < ruleId) {
						maxRuleId = ruleId ;
					}
				} 
			}  
		}
		return ++maxRuleId;
	}

	public static integer getNextRuleCombinationId() {
		integer maxRuleId = 0;

		List<Rule_Combination__c> allRulesComb = [select Rule_combination_Ext_Id__c from Rule_Combination__c];

		for(Rule_Combination__c rule : allRulesComb) {
			String ruleExt = rule.Rule_combination_Ext_Id__c;
			if(String.isNotBlank(ruleExt)) {
				ruleExt = ruleExt.removeStart('EXP');  
				if(ruleExt.isNumeric()) {
					integer ruleId = Integer.valueOf(ruleExt);
					if(maxRuleId < ruleId) {
						maxRuleId = ruleId ;
					}
				} 
			}  
		}
		return ++maxRuleId;
	}

	/* This method fetches rule combination with the specific id from DB.*/
	public static Rule_Combination__c fetchRuleCombinationById (String ruleId){
		try {
			Rule_Combination__c ruleCombination = [select id, Is_Active__c, Gender__c, Rule_ICD__c, Rule_Diagnosis__c, 
			                                       Rule_Combination__c, Rule_Combination_With_Exp__c, Rule_Combination_Description__c, Rule_Combination_Formatted__c
			                                       from Rule_Combination__c where id = :ruleId ];

			return ruleCombination;
		}
		catch(Exception e) {
			system.debug(LoggingLevel.ERROR,'Rule Combination with Id not found');
			return null;
		}	

	}

	/*This method updates rule combination in DB.*/
	public static string updateRuleCombination(Rule_Combination__c newRuleComb) {
		try {
			Database.SaveResult sr = Database.update(newRuleComb, false);
			if (!sr.isSuccess()) {
				// Insertion failed due to duplicate detected
				for(Database.Error duplicateError : sr.getErrors()){
					system.debug(LoggingLevel.ERROR,duplicateError);
					return 'DUPLICATE_RULE_COMBINATION';
				}
				return 'ERROR';
			}
			else {
				return 'SUCCESS';	
			}
		}
		catch(Exception e) {
			system.debug(LoggingLevel.ERROR,e.getMessage());
			return e.getMessage();
		}
	}
	
	/*This method creates hash code for Rule combination in DB.*/
	public static string generateRuleCombinationHashCode(String ruleComb) {
		try {
			ruleComb = ruleComb.toUpperCase().trim();
			Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(ruleComb));
			String uniqueString = EncodingUtil.convertToHex(hash);
			System.debug('**RuleOperationUtil.generateRuleCombinationHashCode ' + ruleComb + ' ' + uniqueString);
			return uniqueString;
		}
		catch(Exception e) {
			system.debug(LoggingLevel.ERROR,e.getMessage());
			return e.getMessage();
		}
	}
}