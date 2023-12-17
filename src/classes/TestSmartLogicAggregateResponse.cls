@isTest
public class TestSmartLogicAggregateResponse {

	public static testMethod void testEquals() {
		SmartLogicAggregateResponse.SmartDiagnosisResult smartDiagnosisResultObj = new SmartLogicAggregateResponse.SmartDiagnosisResult('Gender', 'ICDCode', 'ICDDesc', 'RuleID');
		SmartLogicAggregateResponse.SmartDiagnosisResult smartDiagnosisResultObj1 = new SmartLogicAggregateResponse.SmartDiagnosisResult('Gender', 'ICDCode', 'ICDDesc', 'RuleID');
		SmartLogicAggregateResponse.SmartDiagnosisResult smartDiagnosisResultObj2 = new SmartLogicAggregateResponse.SmartDiagnosisResult('Gender', 'ICDCode1', 'ICDDesc', 'RuleID');
		System.assert(smartDiagnosisResultObj.equals(smartDiagnosisResultObj1));
		System.assert(!smartDiagnosisResultObj1.equals(smartDiagnosisResultObj2));
	}

	public static testMethod void testCompareto() {
		SmartLogicAggregateResponse.SmartDiagnosisResult smartDiagnosisResultObj = new SmartLogicAggregateResponse.SmartDiagnosisResult('Gender', 'ICDCode', 'ICDDesc', 'RuleID');
		SmartLogicAggregateResponse.SmartDiagnosisResult smartDiagnosisResultObj1 = new SmartLogicAggregateResponse.SmartDiagnosisResult('Gender', 'ICDCode', 'ICDDesc', 'RuleID');
		SmartLogicAggregateResponse.SmartDiagnosisResult smartDiagnosisResultObj2 = new SmartLogicAggregateResponse.SmartDiagnosisResult('Gender', 'ICDCode1', 'ICDDesc', 'RuleID');
		System.assert(smartDiagnosisResultObj.compareTo(smartDiagnosisResultObj1)==0);
		System.assert(smartDiagnosisResultObj1.compareTo(smartDiagnosisResultObj2)==1);
	}
}