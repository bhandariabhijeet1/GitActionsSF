public class RulesEngine {

	public static SmartLogicAggregateResponse  evaluatePatientCondition(SmartLogicRequest request) {        
		String categoryQuery ='';
		String gender;
		Boolean bAllowCalloutsToOptum360 = false;
		Integer iRecordsFromOptum360 = 0;

		List<String> categories = null;
		List<SmartLogicAggregateResponse.SmartDiagnosisResult> smartLogicResponses;
		SmartLogicAggregateResponse smartLogicResponseObj= new SmartLogicAggregateResponse();
		Map<String,String> diagnosisList = new Map<String,String> ();
		Map<String,boolean> rulesEvaluated = new Map<String,boolean>();
		Map<String,String> symptoms = new Map<String, String>();
		List<String> allGenders = new List<String>();
		Set<String> setExclusionRulesandCombinations = new Set<String>(); 

		List<String> ruleTypes = request.ruleTypes;
		setExclusionRulesandCombinations.addAll(request.excludeRuleList);
		for(String sSymptom : request.symptoms.keySet())
		{
			String sLowerCaseSymptom = sSymptom.toLowerCase();            
			symptoms.put(sLowerCaseSymptom, request.symptoms.get(sSymptom));
		}
		Set<String> allInputFields = symptoms.keySet();           
		allGenders.add('U');
		if(symptoms.containsKey('gender'))  {
			gender = symptoms.get('gender');
			if(gender.containsIgnoreCase('U')){
				allGenders.add('M');
				allGenders.add('F');
			}
			else {
				allGenders.add(gender);
			}
		}
		else {
			allGenders.add('M');
			allGenders.add('F');           
		}
		system.debug(LoggingLevel.INFO, 'genders'+allGenders);        
		smartLogicResponses = smartLogicResponseObj.diagnosisResults;

		//Fetch the configurations for callout to Optum 360
		for(smartlogic_configuration__mdt oConfiguration : [SELECT DeveloperName, value__c FROM smartlogic_configuration__mdt])
		{
			if(oConfiguration.DeveloperName.equalsIgnoreCase('Allow_callouts_to_Optum_360'))
			{
				bAllowCalloutsToOptum360 = Boolean.valueOf(oConfiguration.value__c);				
			}
			if(oConfiguration.DeveloperName.equalsIgnoreCase('Records_from_Optum_360_for_Smart_Logic'))
			{
				iRecordsFromOptum360 = Integer.valueOf(oConfiguration.value__c);
			}
		}

		if(String.isNotBlank(request.category)) {
			categories = new List<String> ();
			categories.add(request.category);
			categories.add('Global');
			if(ruleTypes.size() == 0) {
				categoryQuery = ' and  Rule_Category__c in (Select id from Rule_Category__c where Rule_Category__c in :categories)';
			}
			else {
				ruleTypes.add('Global');
				categoryQuery = ' and  Rule_Category__c in (Select id from Rule_Category__c where  Rule_Type__c in :ruleTypes AND  Rule_Category__c in :categories)';
			}   
		}

		String query = 'SELECT Rule_Library__r.Name,Rule_Library__r.Multiple_Value_Count__c, Rule_Library__r.Works_with_Rule_Combinations_Only__c, Rule_Library__r.Rule_Library_Ext_Id__c, Rule_Library__r.Rule_Field__c,Rule_Library__r.Rule_Gender__c, Rule_Library__r.Rule_Operator__c,Rule_Library__r.Rule_Value__c, Rule_Library__r.Rule_Diagnosis__c, Rule_Library__r.Rule_ICD__c, Rule_Library__r.Rule_Description__c ';
		query += ' FROM Rule_Category_Library_Mapping__c ';
		query += ' WHERE Rule_Library__r.is_Active__c = true and Rule_Library__r.Rule_Gender__c in :allGenders AND Rule_Library__r.Rule_Library_Ext_Id__c NOT IN :setExclusionRulesandCombinations AND Rule_Library__r.Rule_Field__c in  :allInputFields'+ categoryQuery;
		for(Rule_Category_Library_Mapping__c ruleObj : Database.query(query) )
		{
			Rule_Library__c ruleObjTemp = ruleobj.Rule_Library__r;
			system.debug(LoggingLevel.INFO, 'ruleObj Found----'+ruleObjTemp);
			if(!symptoms.containsKey(ruleObjTemp.Rule_Field__c.toLowerCase()))
			{
				continue;
			}
			String fieldValue = symptoms.get(ruleObjTemp.Rule_Field__c.toLowerCase());
			boolean ruleResult = RuleEngineUtil.evaluateRule(ruleObjTemp, fieldValue.trim());
			//if rule evaluates to true
			if(ruleResult) 
			{	

				system.debug(LoggingLevel.INFO, 'bAllowCalloutsToOptum360-'+bAllowCalloutsToOptum360);
				system.debug(LoggingLevel.INFO, 'Test.isRunningTest()-'+Test.isRunningTest());
				if(String.isNotBlank(ruleObj.Rule_Library__r.Rule_ICD__c)) 	//if rule has diagnosis
				{
					smartLogicResponses.add(new SmartLogicAggregateResponse.SmartDiagnosisResult(ruleObj.Rule_Library__r.Rule_Gender__c, ruleObj.Rule_Library__r.Rule_ICD__c,ruleObj.Rule_Library__r.Rule_Diagnosis__c,ruleObj.Rule_Library__r.Rule_Description__c, RulesEngineConstants.SOURCE_RULE, ruleObj.Rule_Library__r.Rule_Library_Ext_Id__c));
				}				
				else if(!ruleObj.Rule_Library__r.Works_with_Rule_Combinations_Only__c && (bAllowCalloutsToOptum360 || Test.isRunningTest())) //Else if Rule ICD and description is blank and Rule is not bound to a single rule combination only
				{
					List<Node> lstNodes = new List<Node>();	
					String sInput = ruleObjTemp.Rule_Field__c+ ' ' + ruleObjTemp.Rule_Value__c;		
					lstNodes = SearchController.getAPIResponse(sInput.trim(), false).results;
					if(lstNodes != null && lstNodes.size() > 0)
					{
						Integer iCount = 0;
						for(Node oNode : lstNodes)
						{
							if(iCount >= iRecordsFromOptum360)
							{
								break;
							}
							smartLogicResponses.add(new SmartLogicAggregateResponse.SmartDiagnosisResult(ruleObj.Rule_Library__r.Rule_Gender__c, oNode.code, oNode.description,ruleObj.Rule_Library__r.Rule_Description__c, RulesEngineConstants.SOURCE_RULE, ruleObj.Rule_Library__r.Rule_Library_Ext_Id__c));
							iCount++;
						}
					}
				}
				RuleEvaluated rEval1 = new RuleEvaluated(ruleObj.Rule_Library__r.Rule_Library_Ext_Id__c,ruleObj.Rule_Library__r.Rule_Description__c,true);
				smartLogicResponseObj.rulesEvaluated.add(rEval1);
			}
			else{
				RuleEvaluated rEval2 = new RuleEvaluated(ruleObj.Rule_Library__r.Rule_Library_Ext_Id__c,ruleObj.Rule_Library__r.Rule_Description__c,false);
				smartLogicResponseObj.rulesEvaluated.add(rEval2);
			}
			rulesEvaluated.put(ruleObj.Rule_Library__r.Rule_Library_Ext_Id__c,ruleResult);

		}
		RuleEngineUtil.evaluateCombinations(rulesEvaluated,smartLogicResponses, smartLogicResponseObj, allGenders, setExclusionRulesandCombinations);
		SmartLogicICDProcessingUtil icdProcessingUtil = new SmartLogicICDProcessingUtil();
        icdProcessingUtil.fetchAndStoreICDCodes(smartLogicResponseObj.diagnosisResults);
		return  smartLogicResponseObj;
	}	  

}