public class smartLogicRuleTesterController {

	@AuraEnabled
	public static String fetchFieldsAgainstRuleType(String sRuleTypeSelection) 
	{
		System.debug(LoggingLevel.INFO,'fetchFieldsAgainstRuleType======'+sRuleTypeSelection);
		List<FieldDefinition> lstFieldsDefinitionToDisplay = new list<FieldDefinition>();
		List<String> lstRuleTypesSelected = new List<String>();
		Set<String> setFieldsAddedForDisplay = new Set<String>();
		Map<String,String> mapCategoryandType = new Map<String,String>(); 

		mapCategoryandType = fetchTypesData();

		if(String.isNotBlank(sRuleTypeSelection))
		{
			lstRuleTypesSelected = sRuleTypeSelection.split(';');
			for(String sRuleType : lstRuleTypesSelected)
			{
				for(FieldDefinition oFieldDefinition : fetchFieldsForRuleType(mapCategoryandType.get(sRuleType), mapCategoryandType))
				{
					if(!setFieldsAddedForDisplay.contains(oFieldDefinition.fieldName))
					{
						setFieldsAddedForDisplay.add(oFieldDefinition.fieldName);
						lstFieldsDefinitionToDisplay.add(oFieldDefinition);
					}
				}    			
			}
			
			lstFieldsDefinitionToDisplay.addAll(populateLookupRules());
		}
		
		System.debug(LoggingLevel.INFO,'fetchFieldsAgainstRuleType======' + JSON.serialize(lstFieldsDefinitionToDisplay));
		return JSON.serialize(lstFieldsDefinitionToDisplay);
	}

	@AuraEnabled
	public static String populateSymptomsOnPageLoad(ID RecordID) 
	{
		SetupTester oSetupTester = new SetupTester();
		String sCustomObjectAPIName = findObjectNameFromRecordIdPrefix(RecordID);
		Rule_Combination__c oRuleCombination = new Rule_Combination__c();
		Rule_Library__c oRuleLibrary = new Rule_Library__c();
		list<Symptoms> lstSymptoms = new list<Symptoms>();

		if(sCustomObjectAPIName.equalsIgnoreCase('Rule_Combination__c'))
		{
			oRuleCombination = [SELECT Rule_Combination__c, Gender__c FROM Rule_Combination__c WHERE Id=:RecordID];
			if(oRuleCombination != null && oRuleCombination.Rule_Combination__c!=null)
			{
				oSetupTester.sCategoryType = 'Global';
				oSetupTester.sGender = oRuleCombination.Gender__c;
				lstSymptoms = fetchSymptomslistForCombination(oRuleCombination.Rule_Combination__c);
				oSetupTester.lstSymptoms = lstSymptoms;
			}
		}
		else if(sCustomObjectAPIName.equalsIgnoreCase('Rule_Library__c'))
		{
			oRuleLibrary = [SELECT Rule_Library_Ext_Id__c, Rule_Field__c, Rule_Value__c, Rule_Gender__c, Lookup_Type__c FROM Rule_Library__c WHERE ID=:RecordID];
			if(oRuleLibrary != null && oRuleLibrary.Rule_Library_Ext_Id__c != null)
			{
				oSetupTester.sCategoryType = 'Global';
				oSetupTester.sGender = oRuleLibrary.Rule_Gender__c;
				lstSymptoms.add(new Symptoms(oRuleLibrary.Rule_Field__c, oRuleLibrary.Rule_Value__c));
				oSetupTester.lstSymptoms = lstSymptoms;
                oSetupTester.sLookupType = oRuleLibrary.Lookup_Type__c;
			}
		}

		return JSON.serialize(oSetupTester);
	}

	@AuraEnabled
	public static String executeRulesEngine(String sRuleCategoriesSelected, String sSymptomsList) 
	{
		System.debug(LoggingLevel.INFO,sRuleCategoriesSelected+'Entering Rule Evaluation============'+sSymptomsList);

		SmartLogicRequest oRequest = new SmartLogicRequest();
		SmartLogicAggregateResponse oResponse = new SmartLogicAggregateResponse();
		RulesEngineResponse oRulesEngineResponse;
		List<String> lstRuleTypesSelected = new List<String>();
		Set<String> setUniqueDiagnosis = new Set<String>();
		List<SmartDiagnosisResult> lstPossibleDiagnosis = new List<SmartDiagnosisResult>();
		List<RuleEvaluated> lstRulesEvaluated = new List<RuleEvaluated>();
		List<RuleEvaluated> lstCombinationsEvaluated = new List<RuleEvaluated>();
		List<Symptoms> lstSymptoms = new List<Symptoms>();

		if(String.isNotBlank(sRuleCategoriesSelected))
		{
			lstRuleTypesSelected = sRuleCategoriesSelected.split(';');
			oRequest.ruleTypes = lstRuleTypesSelected;
		}
		lstSymptoms = String.isNotBlank(sSymptomsList) ? generateSymptomsList(sSymptomsList) : new List<Symptoms>();
		oRequest.symptoms = new Map<String,String> ();
		for(Symptoms oSymptom : lstSymptoms)
		{
			if(String.isNotBlank(oSymptom.fieldName))
			{
				if(oSymptom.fieldValue.equalsIgnoreCase('True,Yes,1')) {
					oRequest.symptoms.put(oSymptom.fieldName,'True');
				}
				else if (oSymptom.fieldValue.equalsIgnoreCase('False,No,0') ) {
					oRequest.symptoms.put(oSymptom.fieldName,'False');
				}
				else {
					oRequest.symptoms.put(oSymptom.fieldName,oSymptom.fieldValue);

				}
			}
		}

		oResponse = SmartLogicController.getAggregatedSmartDiagnosis(oRequest);    

		for(SmartLogicAggregateResponse.SmartDiagnosisResult oDiagnosis :  oResponse.diagnosisResults)
		{            
			if(setUniqueDiagnosis.add(oDiagnosis.ICD)){
				lstPossibleDiagnosis.add(new SmartDiagnosisResult(oDiagnosis.ICD, oDiagnosis.ICDDescription));
			}
		}  

		for(RuleEvaluated oRule :  oResponse.rulesEvaluated)
		{   
			if(String.isNotBlank(oRule.ruleCombination)){
				lstCombinationsEvaluated.add(oRule);
			}
			else{
				lstRulesEvaluated.add(oRule);
			}
		} 
		oRulesEngineResponse = new RulesEngineResponse(lstPossibleDiagnosis, lstRulesEvaluated, lstCombinationsEvaluated);

		System.debug(LoggingLevel.INFO,'Exiting Rule Evaluation============'+JSON.serialize(oRulesEngineResponse));
		return JSON.serialize(oRulesEngineResponse);
	}

	private static List<Symptoms> generateSymptomsList(String sSymptomsList)
	{
		List<Symptoms> lstSymptoms = new List<Symptoms>();

		lstSymptoms = (List<Symptoms>)JSON.deserialize(sSymptomsList, List<Symptoms>.class);

		return lstSymptoms;
	}

	private static List<FieldDefinition> fetchFieldsForRuleType(String sRuleCategory, Map<String,String> mapCategoryandType)
	{
		List<FieldDefinition> lstFieldDefinitionSingleCategory = new List<FieldDefinition>();    	

		if(String.isNotBlank(sRuleCategory))
		{
			if(!sRuleCategory.equalsIgnoreCase('global'))
			{
				for(String sSingleRuleCategory : mapCategoryandType.values())
				{
					lstFieldDefinitionSingleCategory.addAll(fetchFieldsForCategory(sSingleRuleCategory));
				}
			}
			else
			{
				lstFieldDefinitionSingleCategory.addAll(fetchFieldsForCategory(sRuleCategory));
			}
		}

		return lstFieldDefinitionSingleCategory;
	}

	private static Map<String,String> fetchTypesData() {
		Map<String,String> RuleCategoryMapping = new Map<String,String>();
		for(Rule_Category__c category : [select Rule_Category__c,  Rule_Type__c from Rule_Category__c ]) {
			RuleCategoryMapping.put(category.Rule_Type__c,category.Rule_Category__c);
		}
		return RuleCategoryMapping;
	}

	private static List<FieldDefinition> fetchFieldsForCategory(String category) {
		List<FieldDefinition> lstFieldDefinition = new List<FieldDefinition>();        
		Map<String, String> fieldLabelTypeMap = new Map<String, String>();

		String APIName = SmartLogicRuleBuilderUtil.getObjectAPINameForCategory(category);

		if(String.isBlank(APIName))
		{
			//return ( new List<FieldDefinition>());
			
			for(SmartLogic_Category_API_Name__c oMapping : [select API_Name__c from SmartLogic_Category_API_Name__c])
			{
				if(RulesEngineConstants.setSOAPNotesRelatedObjects.contains(oMapping.API_Name__c))
				{
					for(String sAPIName : RulesEngineConstants.setSOAPNotesRelatedObjects)
					{
						lstFieldDefinition.addAll(populateFieldDefinition(oMapping.API_Name__c));
					}
				}
				else
				{
					lstFieldDefinition.addAll(populateFieldDefinition(oMapping.API_Name__c));
				}
			}
		}

		if(String.isNotBlank(APIName)) {
			if(RulesEngineConstants.setSOAPNotesRelatedObjects.contains(APIName))
			{
				for(String sDependentObjectAPINames : RulesEngineConstants.setSOAPNotesRelatedObjects)
				{
					lstFieldDefinition.addAll(populateFieldDefinition(sDependentObjectAPINames));
				}
			}
			else
			{
				lstFieldDefinition.addAll(populateFieldDefinition(APIName));
			}
		}   
		//return fieldLabelTypeMap.keySet();
		return lstFieldDefinition;
	}

	private static List<FieldDefinition> populateFieldDefinition(String APIName)
	{
		List<FieldDefinition> lstFieldDefinition = new List<FieldDefinition>();
		SObjectType sObjectTypeDefinition = Schema.getGlobalDescribe().get(APIName);
		if(sObjectTypeDefinition!=null){
		Map<String,Schema.SObjectField> fieldMap = sObjectTypeDefinition.getDescribe().fields.getMap();
		Map<String,String> allTypesOperatorMap = SmartLogicRuleBuilderUtil.getDataTypeOperatorsMap();

		for(String fieldName : fieldMap.keySet() ) {
			List<String> lstPicklistValues = new List<String>();
			Schema.DisplayType sfielddataType = fieldMap.get(fieldName).getDescribe().getType();
			if(sfielddataType == Schema.DisplayType.Picklist || sfielddataType == Schema.DisplayType.MultiPicklist)
			{
				list<Schema.PicklistEntry> lstPicklistValuesSchema = fieldMap.get(fieldName).getDescribe().getPickListValues();
				for (Schema.PicklistEntry sPicklistEntry : lstPicklistValuesSchema)
				{ 
					lstPicklistValues.add(sPicklistEntry.getLabel()); 
				}
			}
			else if(sfielddataType == Schema.DisplayType.Boolean)
			{
				lstPicklistValues.add('Yes'); 
				lstPicklistValues.add('No'); 
			}
			if(allTypesOperatorMap.containsKey(''+sfielddataType)) {
				lstFieldDefinition.add(new FieldDefinition(fieldMap.get(fieldName).getDescribe().getLabel(), sfielddataType+'', lstPicklistValues));
			}
		}
		}

		return lstFieldDefinition;
	}

	private static String findObjectNameFromRecordIdPrefix(String recordIdOrPrefix){
		String objectName = '';
		try{
			//Get prefix from record ID
			//This assumes that you have passed at least 3 characters
			String myIdPrefix = String.valueOf(recordIdOrPrefix).substring(0,3);

			//Get schema information
			Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe(); 

			//Loop through all the sObject types returned by Schema
			for(Schema.SObjectType stype : gd.values()){
				Schema.DescribeSObjectResult r = stype.getDescribe();
				String prefix = r.getKeyPrefix();

				//Check if the prefix matches with requested prefix
				if(prefix!=null && prefix.equals(myIdPrefix)){
					objectName = r.getName();
					break;
				}
			}
		}
		catch(Exception e){
		System.debug(LoggingLevel.Error,e);
		}
		return objectName;
	}

	private static List<Symptoms> fetchSymptomslistForCombination(String sCombination)
	{
		List<Symptoms> lstSymptoms = new List<Symptoms>();
		Map<String, Rule_Library__c> mapRuleLibrary = new Map<String, Rule_Library__c>();

		for(Rule_Library__c oRule : [SELECT Rule_Library_Ext_Id__c, Rule_Field__c, Rule_Value__c FROM Rule_Library__c])
		{
			mapRuleLibrary.put(oRule.Rule_Library_Ext_Id__c, oRule);
		}
		String sActualString = sCombination+ ' ';		
		sActualString = sActualString.replaceAll(',',' ,');
		sActualString = sActualString.replaceAll('\\)',' \\)');
		sActualString = sActualString.replaceAll('\\}',' \\}');
		for(String sExternalId : mapRuleLibrary.keySet())
		{
			if(sActualString.contains(sExternalId+' '))
			{
				lstSymptoms.add(new Symptoms(mapRuleLibrary.get(sExternalId).Rule_Field__c, mapRuleLibrary.get(sExternalId).Rule_Value__c));
			}
		}

		return lstSymptoms;
	}

	@AuraEnabled
	public static String RuleCategoryOptions() 
	{
		List<RuleCategoryOptions> lstRuleCategoryOptions = new List<RuleCategoryOptions>();
		for(Rule_Category__c oRuleCategory : [SELECT Rule_Category__c, Rule_Type__c FROM Rule_Category__c])
		{
			if(!oRuleCategory.Rule_Type__c.equalsIgnoreCase('global'))
			{
				lstRuleCategoryOptions.add(new RuleCategoryOptions(oRuleCategory.Rule_Type__c,oRuleCategory.Rule_Type__c,false));
			}
		}
		return JSON.serialize(lstRuleCategoryOptions);
	}

	@AuraEnabled
	public static String RuleGenderOptions() 
	{
		List<RuleCategoryOptions> lstGenderOptions = new List<RuleCategoryOptions>();
		lstGenderOptions.add(new RuleCategoryOptions('Male','M',false));
		lstGenderOptions.add(new RuleCategoryOptions('Female','F',false));
		return JSON.serialize(lstGenderOptions);
	}

	private static List<FieldDefinition> populateLookupRules()
	{
		List<FieldDefinition> lstFieldDefinition = new List<FieldDefinition>();
		List<String> lookupTypes = new List<String>();
		lookupTypes.add('CodeSearch'); 
		lookupTypes.add('Medication'); 
		List<String> lstLookupPicklistValues = new List<String>();		
		lstLookupPicklistValues.add('Active'); 
		lstLookupPicklistValues.add('Inactive'); 
		
		for(Rule_Library__c oRule : [SELECT Rule_Library_Ext_Id__c, Rule_Field__c, Rule_Value__c FROM Rule_Library__c WHERE Lookup_Type__c IN :lookupTypes])
		{
			lstFieldDefinition.add(new FieldDefinition(oRule.Rule_Field__c, 'PICKLIST', lstLookupPicklistValues));
		}
		return lstFieldDefinition;
	}
	
	public Class RuleCategoryOptions
	{
		public String label{get;set;}
		public String value{get;set;}
		public String selected{get;set;}

		public RuleCategoryOptions(String label, String value, boolean selected)
		{
			this.label = label;
			this.value = value;
			this.selected = String.valueOf(selected);
		}
	}

	public Class FieldDefinition
	{
		public String fieldName{get;set;}
		public String fieldDataType{get;set;}
		public List<String> lstfieldValue{get;set;}

		public FieldDefinition(String fieldName, String fieldDataType, List<String> lstfieldValue)
		{
			this.fieldName = fieldName;
			this.fieldDataType = fieldDataType;
			this.lstfieldValue = lstfieldValue;
		}
	}

	public Class SmartDiagnosisResult 
	{
		public String ICD{get; set;}
		public String ICDDescription{get; set;} 

		public SmartDiagnosisResult(String ICD, String ICDDescription)
		{
			this.ICD = ICD;
			this.ICDDescription = ICDDescription;
		}                     
	}

	public Class RulesEngineResponse
	{
		public List<SmartDiagnosisResult> lstPossibleDiagnosis{get;set;}
		public List<RuleEvaluated> lstRulesEvaluated{get;set;}
		public List<RuleEvaluated> lstCombinationsEvaluated{get;set;}

		public RulesEngineResponse(List<SmartDiagnosisResult> lstPossibleDiagnosis, List<RuleEvaluated> lstRulesEvaluated, List<RuleEvaluated> lstCombinationsEvaluated)
		{
			this.lstPossibleDiagnosis = lstPossibleDiagnosis;
			this.lstRulesEvaluated = lstRulesEvaluated;
			this.lstCombinationsEvaluated = lstCombinationsEvaluated;
		}
	}

	public Class Symptoms
	{
		public String fieldName{get;set;}
		public String fieldValue{get;set;}

		public Symptoms(String fieldName, String fieldValue)
		{
			this.fieldName = fieldName;
			this.fieldValue = fieldValue;
		}
	}

	public class SetupTester
	{
		public list<Symptoms> lstSymptoms{get;set;}
		public String sCategoryType{get;set;}
		public String sGender{get;set;}
        public String sLookupType{get;set;}
	}
}