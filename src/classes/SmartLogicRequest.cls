public class SmartLogicRequest {

	@AuraEnabled
	public String category;

	@AuraEnabled
	public List<String> ruleTypes;

	@AuraEnabled
	public Map <String,String> symptoms;

	@AuraEnabled
	public List <String> excludeRuleList;

	public SmartLogicRequest() {
		category = '';
		ruleTypes = new List<String>();
		symptoms = new Map <String,String>();
		excludeRuleList = new List<String>();
	}
}