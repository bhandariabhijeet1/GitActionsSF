public class RuleEngineUtil {

	public static Map<String,String> allLogicalOperators = null;
	public static Map<String,boolean> allYesNoValues = null;
	public static Map<String,String> combinationOperators = null;

	static {
		fetchLogicalOperators();
		fetchYesNoValues();
		fetchCombinationOperators();
	}

	/**
	 * This method creates a map out of all the logical operators.
	 */  
	static  void fetchLogicalOperators() {
		allLogicalOperators = new Map<String,String> ();  
		String allOperators = RulesEngineConstants.LOGICAL_OPERATORS;

		for(String operator: allOperators.split(',')) {
			allLogicalOperators.put(operator,operator);
		}
	}

	/**
	 * This method creates a map out of all the logical operators.
	 */  
	static  void fetchYesNoValues() {
		allYesNoValues = new Map<String,boolean> ();  
		String allValues = RulesEngineConstants.Yes_No_Values;

		for(String yesNo: allValues.split(',')) {
			if(yesNo.equalsIgnoreCase('yes')|| yesNo.equalsIgnoreCase('true') || yesNo.equalsIgnoreCase('1') || yesNo.equalsIgnoreCase('y')) {
				allYesNoValues.put(yesNo,true);
			}    
			else  {
				allYesNoValues.put(yesNo,false);
			}
		}
	}


	/**
	 * This method creates a map out of all the combination operators.
	 */  
	static void fetchCombinationOperators() {
		combinationOperators = new Map<String,String>();  
		String allOperators = RulesEngineConstants.COMBINATION_OPERATORS;

		for(String operator: allOperators.split(',')) {
			combinationOperators.put(operator,operator);
		}
	}

	/**
	 * This method splits combination into rules using logical operators and seperator.
	 */
	public static List<String> splitCombinationIntoRules(string combination) {
		List<String> ruleList = new List<String> ();
		//to create regular expression
		String allOperators = RulesEngineConstants.LOGICAL_OPERATORS.replace(',','|');
		allOperators = allOperators + ',';
		ruleList.addAll(combination.split(allOperators));
		return ruleList;
	}

	/**
	 * This method evaluates logical expressions. 
	 * Expressions with round brackets are evaluated recursively.
	 * Combinations which contain conditions like any x number if rules should be true
	 * are also evaluated seperately. 
	 */
	public static boolean evaluateLogicalExpression(List<String> tokens) {
		List<String> allTokens = new List<String>();
		List<String>  subCombination = new List<String>();

		for(integer k=0; k<tokens.size(); k++) {
			String token = tokens.get(k).trim();
			if(token.equals(')')) {
				integer i =  allTokens.size()-1;
				String token1 = allTokens.get(i);
				while(i>=0 && !token1.equalsIgnoreCase('('))  {
					subCombination.add(token1);
					allTokens.remove(i);
					i--;
					token1 = allTokens.get(i);
				}
				if(token1.equalsIgnoreCase('(')) {
					allTokens.remove(i);
				}
				boolean result = evaluateLogicalExpression(subCombination);
				subCombination = new List<String>();
				allTokens.add(''+result);

			}
			else if(token.equals('}')) {
				integer i =  allTokens.size()-1;
				String token1 = allTokens.get(i);
				integer j = k+1;
				while(String.isBlank(tokens.get(j))) {
					j++;
				}

				String expectedCount = tokens.get(j).replaceAll('[^-?0-9]+', ' ').trim();
				String operator = tokens.get(j).removeEnd(expectedCount).trim();
				while(!expectedCount.isNumeric()) {
					operator = tokens.get(j).trim();
					expectedCount = tokens.get(++j).replaceAll('[^-?0-9]+', ' ').trim();
				}
				while(i>=0 && !token1.equalsIgnoreCase('{'))  {
					subCombination.add(token1);
					allTokens.remove(i);
					i--;
					token1 = allTokens.get(i);
				}
				if(token1.equalsIgnoreCase('{')) {
					allTokens.remove(i);
				}
				boolean result = evaluateLogicalExpForAny(subCombination,Integer.valueOf(expectedCount), operator);
				subCombination = new List<String>();
				allTokens.add(''+result);
			}
			else { 
				if((allLogicalOperators.containsKey(token)|| allYesNoValues.containsKey(token) || combinationOperators.containsKey(token)) && !(String.isBlank(token)|| String.isEmpty(token) || token.isNumeric())) {
					allTokens.add(token);
				}
			} 

		}
		system.debug(allTokens[0]);
		Boolean left = getBooleanValue(allTokens[0]);
		integer i = 0;

		while(i< allTokens.size()-1) {
			String operator = allTokens[i+1];
			String right = allTokens[i+2];
			if(allLogicalOperators.containsKey(operator)) {

				if(operator.equalsIgnoreCase('AND')) {
					left = left && getBooleanValue(right) ;      
				}
				else if (operator.equalsIgnoreCase('OR')){
					left = left || getBooleanValue(right);      
				}
				else {
					return false;
				}
			}
			i=i+2;
		}
		return left;
	}

	/**
	 * This method is used to evaluate complex combination like any
	 * x number of rules should be true.
	 */
	public static boolean evaluateLogicalExpForAny(List<String> tokens, integer requiredCount,String operator) {
		integer actualCount = 0;
		Rule_Library__c rule = new Rule_Library__c();
		rule.Rule_Operator__c = operator.trim();
		rule.Rule_Value__c = requiredCount + '';

		for(String token : tokens) {
			actualCount = (Boolean.valueOf(token))? actualCount+1 : actualCount;
		}


		if(evaluateRule(rule, actualCount+'')) {
			return true;
		}   

		return false;
	}

	/* This method evalutes a rule in the library with the value in the input.
	 * 
	 */
	public static boolean evaluateRule(Rule_Library__c rule, String realTimeFieldValue) {
		system.debug(LoggingLevel.INFO, 'real time value--- ' + realTimeFieldValue);
		system.debug(LoggingLevel.INFO, 'rule--- ' + rule);
		//handle multiselect picklist
		if(rule.Rule_Operator__c.equalsIgnoreCase(':')){
			return evaluateRuleForMultiselectPicklist(rule, realTimeFieldValue);
		}
		realTimeFieldValue = realTimeFieldValue.trim();

		if(rule.Rule_Operator__c.equalsIgnoreCase('STARTS WITH') )
		{		
			return (realTimeFieldValue.startsWithIgnoreCase(rule.Rule_Value__c));
		}
		else if(rule.Rule_Operator__c.equalsIgnoreCase('CONTAINS') )
		{
			return (realTimeFieldValue.containsIgnoreCase(rule.Rule_Value__c));
		}

		//handle boolean values
		if(rule.Rule_Operator__c == '=' && (allYesNoValues.containsKey(realTimeFieldValue.toUpperCase())) ) {
			String[] allBooleanValues = rule.Rule_Value__c.split(',');
			system.debug(allBooleanValues);
			for(String ruleValue : allBooleanValues ) {
				if(ruleValue.containsIgnoreCase(realTimeFieldValue)) {
					return true;
				}
			}
			return false;
		}	
		//handle numeric values   	    
		else if((realTimeFieldValue.isNumeric() || isDouble(realTimeFieldValue)) && (rule.Rule_Value__c.isNumeric() || isDouble(rule.Rule_Value__c))) {
			Decimal realTimeValue = Decimal.valueOf(realTimeFieldValue);            
			if(rule.Rule_Operator__c == '>') {
				return realTimeValue > Decimal.valueOf(rule.Rule_Value__c);

			}else if(rule.Rule_Operator__c == '<') {
				return realTimeValue < Decimal.valueOf(rule.Rule_Value__c);
			}
			else if(rule.Rule_Operator__c == '=') {
				if(rule.Rule_Value__c.contains(',')) {
					boolean ruleResult = false;
					for(String ruleValue : rule.Rule_Value__c.split(',') ) {
						ruleResult = (realTimeValue == Decimal.valueOf(ruleValue));
						if(ruleResult) {
							return ruleResult;
						}
					}
					return ruleResult;
				}
				else {
					return realTimeValue == Decimal.valueOf(rule.Rule_Value__c);
				}    

			}
			else if(rule.Rule_Operator__c == '>=') {
				return realTimeValue >= Decimal.valueOf(rule.Rule_Value__c);

			}
			else if(rule.Rule_Operator__c == '<=') {
				return realTimeValue <= Decimal.valueOf(rule.Rule_Value__c);

			}
			else if(rule.Rule_Operator__c == '!=') {
				return realTimeValue != Decimal.valueOf(rule.Rule_Value__c);

			}

			else {
				system.debug(LoggingLevel.ERROR,'Unknown Operator');
				return false;
			}

		}
		else {
			//handle picklist
			if(rule.Rule_Operator__c == '=' ) {
				if(rule.Rule_Value__c.contains(',')) {
					boolean ruleResult = false;
					for(String ruleValue : rule.Rule_Value__c.split(',') ) {
						ruleResult = (realTimeFieldValue.equalsIgnoreCase(ruleValue.trim()));
						if(ruleResult){
							return ruleResult;
						}
					}
					return ruleResult;
				}
				else {
					return (realTimeFieldValue.equalsIgnoreCase(rule.Rule_Value__c));
				}    
			}
			else if(rule.Rule_Operator__c.equalsIgnoreCase('STARTS WITH') )
			{
				return (realTimeFieldValue.startsWithIgnoreCase(rule.Rule_Value__c));
			}
			else if(rule.Rule_Operator__c.equalsIgnoreCase('CONTAINS') )
			{
				return (realTimeFieldValue.containsIgnoreCase(rule.Rule_Value__c));
			}
			else if(rule.Rule_Operator__c == '!=' && (allYesNoValues.containsKey(realTimeFieldValue)) ) {
				return !allYesNoValues.get(realTimeFieldValue);
			}else if(rule.Rule_Operator__c == '!='){
				if(realTimeFieldValue!=null){
					return !realTimeFieldValue.equalsIgnoreCase(rule.Rule_Value__c);
				}else{
					return false;
				}
			}

			// handle other string operations
		}
		return false;
	}

	// SN-ROS-1 and SN-ROS-2 or SN-ROS-3
	public static void evaluateCombinations(Map<String, boolean>evaluatedRuleMap,  List<SmartLogicAggregateResponse.SmartDiagnosisResult> lstSmartLogicResponse, SmartLogicAggregateResponse smrtLogicResponseObj, List<String> allGenders, Set<String> setExclusionRulesandCombinations) 
	{
		set<String> allRuleNames= evaluatedRuleMap.keySet();

		//TO DO: fetch only combinations related to rules evaluated
		for(Rule_Combination__c combinationObj : [SELECT Rule_Combination__c, Rule_Diagnosis__c,Rule_ICD__c, Rule_Combination_Description__c, Gender__c, Rule_combination_Ext_Id__c	 
		                                          FROM Rule_Combination__c 
		                                          WHERE is_Active__c =True AND Gender__c IN :allGenders AND Rule_combination_Ext_Id__c NOT IN :setExclusionRulesandCombinations]) {
			String combination = combinationObj.Rule_Combination__c;
			List<String> ruleList = RuleEngineUtil.splitCombinationIntoRules(combination);
			for(String rule : ruleList) {
				rule = rule.remove(')');
				rule = rule.remove('(');
				rule = rule.remove('{');
				String tempString = rule.substringAfter('}');
				rule = rule.removeEnd(tempString);
				rule = rule.remove('}');
				rule = rule.trim();
				if(evaluatedRuleMap.containsKey(rule)){
					boolean ruleResult = evaluatedRuleMap.get(rule);
					String ruleResultStr = '~'+ ruleResult + '~';
					combination = combination.replace(rule, ruleResultStr);
				} 
				else {
					combination = combination.replace(rule, '~false~');
				}
			}

			//combination= true and true or false 
			boolean combinationResult = RuleEngineUtil.evaluateCombination(combination);  

			if(combinationResult) {
				lstSmartLogicResponse.add(new SmartLogicAggregateResponse.SmartDiagnosisResult(combinationObj.Gender__c, combinationObj.Rule_ICD__c, combinationObj.Rule_Diagnosis__c, combinationObj.Rule_combination_Ext_Id__c));
				RuleEvaluated comEval = new RuleEvaluated(combinationObj.Rule_combination_Ext_Id__c, combinationObj.Rule_Combination_Description__c, true);
				comEval.ruleCombination = combinationObj.Rule_Combination__c; 
				smrtLogicResponseObj.rulesEvaluated.add(comEval);
			}
		}
	} 

	/**
	 * This method works same as Boolean.valueOf(String) method.
	 * Additionally handles ! operator.
	 */
	public static boolean getBooleanValue(String expression){
		if(expression.startsWith('!')) {
			return ! Boolean.valueOf(expression.remove('!'));
		}
		else {
			return Boolean.valueOf(expression);
		}
		return false;
	}

	/**
	 *   This method evaluates the rules which are associated with  
	 *   multiselect picklist field Type
	 */
	public static boolean evaluateRuleForMultiselectPicklist(Rule_Library__c rule, String realTimeFieldValue) {
		Set<String> inputOptions = new Set<String>(realTimeFieldValue.split(';'));
		Set<String> ruleOptions = new Set<String>(rule.Rule_Value__c.split(';'));
		integer inputOptionCount = 0;
		if(inputOptions.size() < rule.Multiple_Value_Count__c) {
			// system.debug('Input size less');
			return false;
		}
		for(String ruleOption : ruleOptions)
		{
			if(inputOptionCount < rule.Multiple_Value_Count__c) {
				for(String inputOption : inputOptions) {
					if(ruleOption.equalsIgnoreCase(inputOption.trim())) {
						inputOptionCount++;
					}
				}
			}
			else {
				return true;
			}
		}
		if(inputOptionCount >= rule.Multiple_Value_Count__c) {
			return true;
		}
		return false;
	}

	/**
	 * This method evaluates rule Combination.
	 */
	public static boolean  evaluateCombination(String combination) {
		combination = combination.replace('(','~(~');
		combination = combination.replace(')','~)~');
		combination = combination.replace('{','~{~');
		combination = combination.replace('}','~}~');
		String[] tokens = combination.split('~|,|\\s'); 
		return evaluateLogicalExpression(tokens);
	}

	/*
	 *Function to test if given string is a double/Decimal    
	 */
	private static boolean isDouble(String sInputValue)
	{
		boolean isDouble = false;
		sInputValue = sInputValue.trim();
		List<String> lstDecimalValues = new list<String>();

		if(String.isNotBlank(sInputValue) && sInputValue.contains('.'))
		{
			lstDecimalValues = sInputValue.split('\\.');
			if(lstDecimalValues.size() == 2)
			{
				if(lstDecimalValues[0].isNumeric() && lstDecimalValues[1].isNumeric())
				{
					isDouble = true;
				}
			}
		}

		return isDouble;
	}

	/*
	 *Function to build formatted Rule Combination Description   
	 */
	public static string formatRuleCombinationDescription(String combination)
	{ 
		String strANDOperator = ' AND ';
		String strOROperator = ' OR ';
		String strboldAND = ' <font color="orange"><b>AND</b></font> ';
		String strboldOR = ' <font color="orange"><b>OR</b></font> ';
		if(String.isNotBlank(combination)){
			combination = combination.replaceAll(strANDOperator, strboldAND);
			combination = combination.replaceAll(strOROperator, strboldOR);
		}
		return combination;
	}
}