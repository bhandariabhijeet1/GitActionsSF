@isTest
public class TestUtilityCls{
	public static Rule_Library__c getRuleLibrary(String ruleField,String ruleOperator,String ruleValue,String ruleICD,String ruleDiagnosis,String ruleGender,String ruleLibraryExtId){
		Rule_Library__c rule = new Rule_Library__c();
		rule.is_Active__c = true;
		rule.Rule_Field__c = ruleField;
		rule.Rule_Operator__c = ruleOperator;
		rule.Rule_Value__c = ruleValue;
		rule.Rule_ICD__c = ruleICD;
		rule.Rule_Diagnosis__c = ruleDiagnosis;
		rule.Rule_Gender__c = ruleGender;
		rule.Rule_Library_Ext_Id__c = ruleLibraryExtId;
		return rule;
	} 

	public static Rule_Library__c getRuleLibrary(String ruleField,String ruleOperator,String ruleValue,String ruleICD,String ruleDiagnosis,String ruleGender,String ruleLibraryExtId, boolean WorksWithRuleCombinationsOnly){
		Rule_Library__c rule = new Rule_Library__c();
		rule.is_Active__c = true;
		rule.Rule_Field__c = ruleField;
		rule.Rule_Operator__c = ruleOperator;
		rule.Rule_Value__c = ruleValue;
		rule.Rule_ICD__c = ruleICD;
		rule.Rule_Diagnosis__c = ruleDiagnosis;
		rule.Rule_Gender__c = ruleGender;
		rule.Rule_Library_Ext_Id__c = ruleLibraryExtId;
		rule.Works_with_Rule_Combinations_Only__c = WorksWithRuleCombinationsOnly;
		return rule;
	} 

	public static Rule_Category__c getRuleCatagory(String ruleCategoryExtId,String ruleCategory,String ruleType){
		Rule_Category__c ruleCategoryRecord = new Rule_Category__c();
		ruleCategoryRecord.Rule_Category_Ext_ID__c = ruleCategoryExtId;
		ruleCategoryRecord.Rule_Category__c = ruleCategory;
		ruleCategoryRecord.Rule_Type__c = ruleType;
		return ruleCategoryRecord;
	}

	public static Rule_Category_Library_Mapping__c getRuleLibraryCategoryMapping(String ruleCategoryId,String ruleLibraryId){
		Rule_Category_Library_Mapping__c ruleMapping = new Rule_Category_Library_Mapping__c();
		ruleMapping.Rule_Category__c = ruleCategoryId;
		ruleMapping.Rule_Library__c = ruleLibraryId;
		return ruleMapping;
	}

	public static Rule_Combination__c getRuleCombination(String gender,String ruleCombinationValue,String ruleCombinationDescription,String ruleCombinationExtId,String ruleDiagnosis,String ruleICD){
		Rule_Combination__c  ruleCombination = new Rule_Combination__c();
		ruleCombination.Gender__c = gender;
		ruleCombination.Is_Active__c = true;
		ruleCombination.Rule_Combination__c = ruleCombinationValue;
		ruleCombination.Rule_Combination_Description__c = ruleCombinationDescription;
		ruleCombination.Rule_combination_Ext_Id__c = ruleCombinationExtId;
		ruleCombination.Rule_Diagnosis__c = ruleDiagnosis;
		ruleCombination.Rule_ICD__c = ruleICD;
		return ruleCombination;
	}
}