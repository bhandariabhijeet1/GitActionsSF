@isTest
public class TestRuleEngineUtil {

	public static testMethod void testEvaluateRuleForMultiselectPicklist() {
		Rule_Library__c testRule = new Rule_Library__c();
		testRule.Multiple_Value_Count__c = 3;
		testRule.Rule_Value__c = 'Medication;Heat;Cold;Activity;Rest';
		boolean result = false;
		test.StartTest();

		String testString = 'Heat';
		result = RuleEngineUtil.evaluateRuleForMultiselectPicklist(testRule, testString);
		System.assert(!result);


		testString = 'Heat;Cold;XYZ';
		result = RuleEngineUtil.evaluateRuleForMultiselectPicklist(testRule, testString);
		System.assert(!result);

		testString = 'Heat;Cold;Cold';
		result = RuleEngineUtil.evaluateRuleForMultiselectPicklist(testRule, testString);
		System.assert(!result);

		testString = 'Activity;Heat;Cold;Rest';
		result = RuleEngineUtil.evaluateRuleForMultiselectPicklist(testRule, testString);
		System.assert(result);


		testString = 'Rest;Activity;HEAT;Cold';

		result = RuleEngineUtil.evaluateRuleForMultiselectPicklist(testRule, testString);
		System.assert(result);

		testString = 'REST;Activity;Heat;Cold';
		result = RuleEngineUtil.evaluateRuleForMultiselectPicklist(testRule, testString);
		System.assert(result);

		testString = 'Rest;Activity;Heat;Cold;Rest';
		result = RuleEngineUtil.evaluateRuleForMultiselectPicklist(testRule, testString);
		System.assert(result);

		testString = 'HEAT;COLD;Rest';
		testRule.Rule_Value__c = 'Heat;Cold;Rest';
		result = RuleEngineUtil.evaluateRuleForMultiselectPicklist(testRule, testString);
		System.assert(result);

		testString = 'H;C;R';
		result = RuleEngineUtil.evaluateRuleForMultiselectPicklist(testRule, testString);
		System.assert(!result);

		test.stopTest();
	}

	public static testMethod void testEvaluateRuleNumber() {
		Rule_Library__c testRule = new Rule_Library__c();
		testRule.Rule_Value__c = '40';
		testRule.Rule_Operator__c = '>';

		test.StartTest();

		String testString = '41';
		boolean result = RuleEngineUtil.evaluateRule(testRule, testString);
		System.assert(result);

		testString = '41.45';
		result = RuleEngineUtil.evaluateRule(testRule, testString);
		System.assert(result);

		testString = '4';
		result = RuleEngineUtil.evaluateRule(testRule, testString);
		System.assert(!result);

		testRule.Rule_Operator__c = '>='; 
		testString = '41';
		result = RuleEngineUtil.evaluateRule(testRule, testString);
		System.assert(result);

		testRule.Rule_Operator__c = '<='; 
		testString = '32';
		result = RuleEngineUtil.evaluateRule(testRule, testString);
		System.assert(result);

		testRule.Rule_Operator__c = '!='; 
		testString = '32';
		result = RuleEngineUtil.evaluateRule(testRule, testString);
		System.assert(result);

		test.stopTest();

	}

	public static testMethod void testEvaluateRuleBoolean() {
		Rule_Library__c testRule = new Rule_Library__c();
		testRule.Rule_Value__c = 'True,Yes,1';
		testRule.Rule_Operator__c = '=';
		boolean result = false;
		test.StartTest();

		String testString = 'True';
		result = RuleEngineUtil.evaluateRule(testRule, testString);
		System.assert(result);

		testString = '1';
		result = RuleEngineUtil.evaluateRule(testRule, testString);
		System.assert(result);

		testString = 'Yes';
		result = RuleEngineUtil.evaluateRule(testRule, testString);
		System.assert(result);

		testString = 'No';
		testRule.Rule_Operator__c = '!=';
		result = RuleEngineUtil.evaluateRule(testRule, testString);
		System.assert(result);

		testString = 'False';
		testRule.Rule_Operator__c = '=';
		result = RuleEngineUtil.evaluateRule(testRule, testString);
		System.assert(!result);

		testString = 'No';
		result = RuleEngineUtil.evaluateRule(testRule, testString);
		System.assert(!result);

		testString = '0';
		result = RuleEngineUtil.evaluateRule(testRule, testString);
		System.assert(!result);

		testRule.Rule_Value__c = 'No,false,0';

		testString = 'False';
		result = RuleEngineUtil.evaluateRule(testRule, testString);
		System.assert(result);

		testString = 'No';
		result = RuleEngineUtil.evaluateRule(testRule, testString);
		System.assert(result);

		testString = '0';
		result = RuleEngineUtil.evaluateRule(testRule, testString);
		System.assert(result);


		testString = 'True';
		result = RuleEngineUtil.evaluateRule(testRule, testString);
		System.assert(!result);

		testString = 'Yes';
		result = RuleEngineUtil.evaluateRule(testRule, testString);
		System.assert(!result);

		testString = '1';
		result = RuleEngineUtil.evaluateRule(testRule, testString);
		System.assert(!result);


		testRule.Rule_Value__c = '1';
		testString = '1';
		result = RuleEngineUtil.evaluateRule(testRule, testString);
		System.assert(result);

		testRule.Rule_Value__c = '1';
		testString = '5';
		result = RuleEngineUtil.evaluateRule(testRule, testString);
		System.assert(!result);

		testRule.Rule_Value__c = 'XYZ';
		testString = '5';
		result = RuleEngineUtil.evaluateRule(testRule, testString);
		System.assert(!result);

		testRule.Rule_Value__c = 'XYZ';
		testString = 'XYZ';
		result = RuleEngineUtil.evaluateRule(testRule, testString);
		System.assert(result);


		test.stopTest();

	}

	public static testMethod void testEvaluateRuleText() {
		Rule_Library__c testRule = new Rule_Library__c();
		testRule.Rule_Value__c = 'Normal';
		testRule.Rule_Operator__c = '=';
		boolean result = false;

		test.StartTest();

		String testString = 'Normal';
		result = RuleEngineUtil.evaluateRule(testRule, testString);
		System.assert(result);

		testString = 'AbNormal';
		result = RuleEngineUtil.evaluateRule(testRule, testString);
		System.assert(!result);

		testString = 'Normality';
		testRule.Rule_Operator__c = 'STARTS WITH';
		result = RuleEngineUtil.evaluateRule(testRule, testString);
		System.assert(result);

		testString = 'abnormality';
		testRule.Rule_Operator__c = 'CONTAINS';
		result = RuleEngineUtil.evaluateRule(testRule, testString);
		System.assert(result);

		testString = 'abnormality';
		testRule.Rule_Operator__c = '!=';
		result = RuleEngineUtil.evaluateRule(testRule, testString);
		System.assert(result);

		test.stopTest();

	}


	public static testMethod void testEvaluateRulePicklist() {
		Rule_Library__c testRule = new Rule_Library__c();
		testRule.Rule_Value__c = 'Normal,Good';
		testRule.Rule_Operator__c = '=';
		boolean result = false;
		test.StartTest();

		String testString = 'Normal';
		result = RuleEngineUtil.evaluateRule(testRule, testString);
		System.assert(result);

		testString = 'AbNormal';
		result = RuleEngineUtil.evaluateRule(testRule, testString);
		System.assert(!result);

		test.stopTest();

	}

	public static testMethod void testSplitCombinationIntoRules(){
		test.StartTest(); 
		String testCombination = '{R1,R2,R3} = 2'; 
		List<String> ruleTokens = RuleEngineUtil.splitCombinationIntoRules(testCombination);
		System.assertEquals(3, ruleTokens.size());
		test.stopTest(); 
	}

	public static testMethod void testEvaluateCombination() {
		boolean result = false;
		test.StartTest();

		String testString = '{~true~,~true~,~false~} = 2';
		result = RuleEngineUtil.evaluateCombination(testString);
		System.assert(result);

		testString = '{~true~,~true~,~false~} > 2';
		result = RuleEngineUtil.evaluateCombination(testString);
		System.assert(!result);

		testString = '{~true~,~false~,~false~} > 2';
		result = RuleEngineUtil.evaluateCombination(testString);
		System.assert(!result);

		testString = '{~true~,~true~,~true~} = 2';
		result = RuleEngineUtil.evaluateCombination(testString);
		System.assert(!result);

		test.stopTest();   
	}

	public static testMethod void testEvaluateLogicalExpression() {
		boolean result = false;
		test.StartTest();

		List<String> tokens = new List<String>();
		tokens.add('true');
		tokens.add('and');
		tokens.add('(');
		tokens.add('true'); 
		tokens.add('or');
		tokens.add('false'); 
		tokens.add(')');
		result = RuleEngineUtil.evaluateLogicalExpression(tokens);
		System.assert(result);

		test.stopTest();

	}

	public static testMethod void testGetBooleanValue() {
		test.StartTest();

		boolean result = RuleEngineUtil.getBooleanValue('!false');
		System.assert(result);

		test.stopTest();
	}

}