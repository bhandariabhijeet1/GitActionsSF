public class SmartLogicResponse {
	public boolean isError = false;
	public String message;
	public List<SmartDiagnosisResult> diagnosisResults{get;set;} 

	public SmartLogicResponse() {
		this.diagnosisResults = new List<SmartDiagnosisResult> ();
	}

	public class SmartDiagnosisResult{
		public String ICD{get;set;}
		public String ICDDescription{get;set;}
		public List<String> RuleIDs{get;set;}

		public SmartDiagnosisResult(String ICDCode, String ICDDesc, String sruleIds) {
			this.ICD = ICDCode;
			this.ICDDescription = ICDDesc;
			if(String.isNotBlank(sruleIds))
			{
				this.RuleIDs = sruleIds.split(',');
			}
		}
	}
}