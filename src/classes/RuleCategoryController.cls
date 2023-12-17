public  class RuleCategoryController {

	@AuraEnabled
	public static String fetchAllCategories(String searchKey){

		String query = 'SELECT ID,Rule_Category__c, Rule_Type__c from Rule_Category__c';
		List< Rule_Category__c> allCats = Database.query(query);
		return JSON.serialize(allCats);
	}

	@AuraEnabled
	public static String fetchAllSupportedCategories() {
		List<String> allCategories = new List<String>();	
		for(SmartLogic_Category_API_Name__c setting : SmartLogic_Category_API_Name__c.getAll().values()) { 
			allCategories.add(setting.Name);
		}

		return JSON.serialize(allCategories);
	}

	@AuraEnabled
	public static String fetchAllSupportedTypes() {
		List<String> allTypes = new List<String>();	
		allTypes.add('Physical Exam');
		allTypes.add('Review of Systems'); 
		return JSON.serialize(allTypes);

	}

	@AuraEnabled
	public static String saveCategory(String ruleType, String ruleCategory) {
		system.debug(LoggingLevel.INFO, 'ruleType:'+ruleType+ ' ruleCategory'+ruleCategory); 
		Rule_Category__c ruleCat = new Rule_Category__c();
		ruleCat.Rule_Category__c = ruleCategory;
		ruleCat.Rule_Category_Ext_ID__c = 'CAT'+ getNextCatId();
		ruleCat.Rule_Type__c = ruleType;
		try {
			Database.SaveResult sr = Database.insert(ruleCat, false);
			if (!sr.isSuccess()) {
				// Insertion failed due to duplicate detected
				for(Database.Error duplicateError : sr.getErrors()){
					system.debug(LoggingLevel.ERROR, duplicateError); 
					return 'DUPLICATE_RULE_CAT';
				}
				return 'ERROR';
			}
			return 'SUCCESS';
		}
		catch(Exception e) {
			return e.getMessage();
		}
	}

	@AuraEnabled
	public static String editCategory(String ruleType, String ruleCategory, String ruleCategoryID) {
		List<Rule_Category__c> ruleCatList = [select Id from Rule_Category__c where id= :ruleCategoryID];
		if(ruleCatList.size() > 0) {
			Rule_Category__c ruleCat = ruleCatList.get(0);
			ruleCat.Rule_Category__c = ruleCategory;
			ruleCat.Rule_Type__c = ruleType;
			system.debug(ruleCat);
			try {
				Database.SaveResult sr = Database.update(ruleCat, false);
				if (!sr.isSuccess()) {
					for(Database.Error duplicateError : sr.getErrors()){
						system.debug(LoggingLevel.ERROR, duplicateError); 
						return 'DUPLICATE_RULE_CAT';
					}
					return 'ERROR';
				}
				else {
					return 'SUCCESS';	
				}
			}
			catch(Exception e) {
				system.debug(LoggingLevel.ERROR,  e.getMessage()); 
				return e.getMessage();
			}
		}
		else {
			system.debug(LoggingLevel.ERROR, 'Rule Category not found');
			return 'ERROR';
		}

	}



	public static integer getNextCatId() {
		integer maxCatId = 0;

		for(Rule_Category__c cat :  [select Rule_Category_Ext_ID__c from Rule_Category__c]) {
			String catExt = cat.Rule_Category_Ext_ID__c;
			if(String.isNotBlank(catExt)) {
				catExt = catExt.removeStart('CAT');  
				if(catExt.isNumeric()) {
					integer catId = Integer.valueOf(catExt);
					if(maxCatId < catId) {
						maxCatId = catId ;
					}
				} 
			}  
		}
		return ++maxCatId;
	}
}