public class RuleEvaluated {
	public String externalId{get;set;}
	public String ruleCombination{get;set;}
	public String ruleDescription{get;set;}
	public Boolean result{get;set;}

	public RuleEvaluated(){}

	public RuleEvaluated(String externalId, String ruleDescription, Boolean result){
		this.externalId=externalId;
		this.ruleDescription = ruleDescription;
		this.result = result;
		this.ruleCombination = '';
	}
}