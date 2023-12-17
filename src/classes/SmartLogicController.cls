public class SmartLogicController {

	public static SmartLogicAggregateResponse getAggregatedSmartDiagnosis(SmartLogicRequest request) {
		SmartLogicAggregateResponse smartLogicResponseObj = null;
		try {
			if(request.symptoms.size() > 0) {
				displaySymptoms(request.symptoms);
				smartLogicResponseObj = RulesEngine.evaluatePatientCondition(request);  
				if(smartLogicResponseObj.diagnosisResults.size() == 0) {
					smartLogicResponseObj.isError = false;
					smartLogicResponseObj.message = 'No diagnosis';
				}
			}
			else {
				smartLogicResponseObj.isError = false;
				smartLogicResponseObj.message = 'No symptoms provided.';
			}
			// Remove Duplicate Diagnosis
			if(smartLogicResponseObj.diagnosisResults.size() > 0) {
				smartLogicResponseObj.diagnosisResults = updateDiagnosisRuleIdPriorToDeduplication(smartLogicResponseObj.diagnosisResults);
				smartLogicResponseObj.diagnosisResults = removeDuplicateDiagnosis(smartLogicResponseObj.diagnosisResults);
			}           
		}
		catch(Exception e) {
			smartLogicResponseObj = new SmartLogicAggregateResponse();
			smartLogicResponseObj.isError = true;
			smartLogicResponseObj.message = 'Something went wrong in the Rule Engine.'+e.getMessage();
			throw e;
		}
		System.debug(LoggingLevel.INFO,'**************OUTPUT******************'+smartLogicResponseObj);
		return smartLogicResponseObj;
	}

	public static SmartLogicResponse getSmartDiagnosis(SmartLogicRequest request) {
		SmartLogicResponse oSmartLogicResponseObj = new SmartLogicResponse();
		List<SmartLogicResponse.SmartDiagnosisResult> lstDiagnosisResult = new List<SmartLogicResponse.SmartDiagnosisResult>(); 
		try {
			SmartLogicAggregateResponse oSmartLogicAggregateResponseObj = getAggregatedSmartDiagnosis(request);
			if(oSmartLogicAggregateResponseObj != null && oSmartLogicAggregateResponseObj.diagnosisResults != null && oSmartLogicAggregateResponseObj.diagnosisResults.size() > 0)
			{
				for(SmartLogicAggregateResponse.SmartDiagnosisResult oDiagnosisResult : oSmartLogicAggregateResponseObj.diagnosisResults)
				{
					lstDiagnosisResult.add(new SmartLogicResponse.SmartDiagnosisResult(oDiagnosisResult.ICD, oDiagnosisResult.ICDDescription, oDiagnosisResult.RuleID));
				}
				oSmartLogicResponseObj.diagnosisResults = lstDiagnosisResult;
			}
		}
		catch(Exception e) {
			oSmartLogicResponseObj = new SmartLogicResponse();
			oSmartLogicResponseObj.isError = true;
			oSmartLogicResponseObj.message = 'Something went wrong in the Rule Engine.'+e.getMessage();
		}
		return oSmartLogicResponseObj;
	}

	private static List<SmartLogicAggregateResponse.SmartDiagnosisResult> updateDiagnosisRuleIdPriorToDeduplication(List<SmartLogicAggregateResponse.SmartDiagnosisResult> listDiagnosis){
		Map<String, String> mapICDCodenRuleId = new Map<String, String>();

		for(SmartLogicAggregateResponse.SmartDiagnosisResult oDiagnosis :  listDiagnosis)
		{ 
			if(String.isNotBlank(oDiagnosis.RuleID) && String.isNotBlank(oDiagnosis.ICD))
			{
				if(mapICDCodenRuleId.containsKey(oDiagnosis.ICD))
				{
					String sRuleIds = mapICDCodenRuleId.get(oDiagnosis.ICD);
					sRuleIds += ', ' +oDiagnosis.RuleID ;
					mapICDCodenRuleId.put(oDiagnosis.ICD, sRuleIds);
				}
				else
				{
					mapICDCodenRuleId.put(oDiagnosis.ICD, oDiagnosis.RuleID);
				}
			}
		}
		for(SmartLogicAggregateResponse.SmartDiagnosisResult oDiagnosis :  listDiagnosis)
		{ 
			if(mapICDCodenRuleId.containsKey(oDiagnosis.ICD))
			{
				oDiagnosis.RuleID = mapICDCodenRuleId.get(oDiagnosis.ICD);
			}
		}

		return listDiagnosis;
	}

	private static List<SmartLogicAggregateResponse.SmartDiagnosisResult> removeDuplicateDiagnosis(List<SmartLogicAggregateResponse.SmartDiagnosisResult> listDiagnosis){
		List<SmartLogicAggregateResponse.SmartDiagnosisResult> tempList = new List<SmartLogicAggregateResponse.SmartDiagnosisResult>();
		Set<String> uniqueICDList = new Set<String>();
		for(SmartLogicAggregateResponse.SmartDiagnosisResult diag :  listDiagnosis)
		{ 
			if(uniqueICDList.add(diag.ICD)){
				tempList.add(diag);
			}
		}
		return tempList;
	}

	public static void displaySymptoms( Map <String,String> symptoms) {
		System.debug(LoggingLevel.INFO,'**************INPUT******************');
		for(String field : symptoms.keySet() ) {
			String value = symptoms.get(field);
			System.debug(LoggingLevel.INFO,field + ' : ' + value );
		}
		System.debug(LoggingLevel.INFO,'*************************************'); 
	}
}