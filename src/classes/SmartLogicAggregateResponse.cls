public class SmartLogicAggregateResponse {
	public boolean isError = false;
	public String message;
	public List<SmartDiagnosisResult> diagnosisResults{get;set;} 
	public List<RuleEvaluated> rulesEvaluated{get;set;}

	public SmartLogicAggregateResponse() {
		this.diagnosisResults = new List<SmartDiagnosisResult> ();
		this.rulesEvaluated = new List<RuleEvaluated>();
	}

	public class SmartDiagnosisResult implements Comparable{
		public String Gender{get;set;}
		public String ICD{get;set;}
		public String ICDDescription{get;set;}
		public String ruleEvaluated{get;set;}
		public String ruleSource{get;set;}
		public String RuleID{get;set;}

		public SmartDiagnosisResult(String Gender, String ICDCode, String ICDDesc,String ruleEvaluated, String ruleSource, String RuleID) {
			this.Gender = Gender;
			this.ICD = ICDCode;
			this.ICDDescription = ICDDesc;
			this.ruleEvaluated = ruleEvaluated;
			this.ruleSource = ruleSource;
			this.RuleID = RuleID;
		}
		public SmartDiagnosisResult(String Gender, String ICDCode, String ICDDesc, String RuleID) {
			this.Gender = Gender;
			this.ICD = ICDCode;
			this.ICDDescription = ICDDesc;
			this.ruleEvaluated = '';
			this.ruleSource = '';
			this.RuleID = RuleID;
		}
		public Boolean equals(Object obj) {
			SmartDiagnosisResult smDignosis = (SmartDiagnosisResult) obj;
			if(smDignosis.ICD.compareTo(ICD)==0){
				return true;
			}else{
				return false;
			}
		}
		public Integer compareTo(Object obj) {
			SmartDiagnosisResult smDignosis = (SmartDiagnosisResult) obj;
			if(smDignosis.ICD.compareTo(ICD)==0){
				return 0;
			}else{
				return 1;
			}
		}
	}
}