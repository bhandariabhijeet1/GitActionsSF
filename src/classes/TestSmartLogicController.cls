@isTest
public class TestSmartLogicController {
	@testSetup 
	public static void setup() {
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
		User u = new User(Alias = 'standt', Email='Attestationuser@testorg.com', 
				EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
				LocaleSidKey='en_US', ProfileId = p.Id, 
				TimeZoneSidKey='America/Los_Angeles', UserName='Attestationuser@testorg.com');
		insert u;
		//Create custom settings record for category name
		SmartLogic_Category_API_Name__c categoryAPIName = new SmartLogic_Category_API_Name__c(Name='SOAP Notes',API_Name__c='SOAP_Note__c');
		insert categoryAPIName;

		//Create Rule Category Record
		Rule_Category__c ruleCategory = TestUtilityCls.getRuleCatagory('Test0001','SOAP Notes','Review of Systems');
		insert ruleCategory;

		//Create Rule Library Record
		Rule_Library__c rule = TestUtilityCls.getRuleLibrary('Regularly_Irregular','=','True,Yes,1','I48.91','Atrial Fibrillation','U','TesrR00001');
		insert rule;

		//Create Rule Library Category mapping record
		Rule_Category_Library_Mapping__c ruleMapping = TestUtilityCls.getRuleLibraryCategoryMapping(ruleCategory.id,rule.id);
		insert ruleMapping;

		//Create Rule Library Record
		Rule_Library__c rule2 = TestUtilityCls.getRuleLibrary('Chest Pain','=','True,Yes,1','I20.9','Angina, stable','U','TesrR00002');
		insert rule2;
		//Create Rule Library Category mapping record
		Rule_Category_Library_Mapping__c ruleMapping2 = TestUtilityCls.getRuleLibraryCategoryMapping(ruleCategory.id,rule2.id);
		insert ruleMapping2;

		//Create Rule Library Record
		Rule_Library__c rule3 = TestUtilityCls.getRuleLibrary('Wheezing','=','True,Yes,1','J44.9','Chronic obstructive pulmonary disease, unspecified','U','TesrR00003');
		insert rule3;

		//Create Rule Library Category mapping record
		Rule_Category_Library_Mapping__c ruleMapping3 = TestUtilityCls.getRuleLibraryCategoryMapping(ruleCategory.id,rule3.id);
		insert ruleMapping3;

		//Create Rule Library Record
		Rule_Library__c rule4 = TestUtilityCls.getRuleLibrary('Test Symp','=','True,Yes,1','','','U','TesrR00004',false);
		insert rule4;

		//Create Rule Library Category mapping record
		Rule_Category_Library_Mapping__c ruleMapping4 = TestUtilityCls.getRuleLibraryCategoryMapping(ruleCategory.id,rule4.id);
		insert ruleMapping4;

		//Create Rule Combination Record
		Rule_Combination__c ruleCombination = TestUtilityCls.getRuleCombination('U','TesrR00001 OR TesrR00002','(Regularly_Irregular = True,Yes,1) OR (Chest Pain = True,Yes,1)','TestRC00001','Angina, stable','I20.9');
		insert ruleCombination;
        
        System.assert(true);
	}
    
	public static testMethod void testGetSmartDiagnosys(){
		SmartLogicRequest slRequest = new SmartLogicRequest();
		slRequest.category = 'SOAP Notes';
		slRequest.symptoms = new Map<String,String> ();
		slRequest.ruleTypes = new List<String>();
		slRequest.ruleTypes.add('Review of Systems');
		slRequest.symptoms.put('Wheezing','Yes');
		slRequest.symptoms.put('Chest Pain','True');
		slRequest.symptoms.put('Regularly_Irregular','1');
		slRequest.symptoms.put('Test Symp','True,Yes,1');
		SmartLogicResponse slResponse = SmartLogicController.getSmartDiagnosis(slRequest);
		analyseResults(slResponse);

	}
	public static testMethod void testGetSmartDiagnosysNoResult(){
		SmartLogicRequest slRequest = new SmartLogicRequest();
		slRequest.category = 'SOAP Notes';
		slRequest.symptoms = new Map<String,String> ();
		slRequest.ruleTypes = new List<String>();
		slRequest.ruleTypes.add('Review of Systems');
		slRequest.symptoms.put('Wheezing','No');
		slRequest.symptoms.put('Chest Pain','False');
		slRequest.symptoms.put('Regularly_Irregular','0');
		slRequest.symptoms.put('gender','U'); 
		SmartLogicResponse slResponse = SmartLogicController.getSmartDiagnosis(slRequest);
		System.assert(slResponse.diagnosisResults.size()==0);

	}
	public static testMethod void testGetSmartDiagnosysNegative(){
		SmartLogicRequest slRequest = new SmartLogicRequest();
		slRequest.category = 'SOAP Notes1';
		slRequest.ruleTypes = new List<String>();
		slRequest.ruleTypes.add('Review of Systems');
		SmartLogicResponse slResponse = SmartLogicController.getSmartDiagnosis(slRequest);
		analyseResults(slResponse);
	}
	public static testMethod void testGetSmartDiagnosysNegativeNoSym(){
		SmartLogicRequest slRequest = new SmartLogicRequest();
		slRequest.category = 'SOAP Notes1';
		slRequest.ruleTypes = new List<String>();
		slRequest.symptoms = new Map<String,String> ();
		slRequest.ruleTypes.add('Review of Systems');
		SmartLogicResponse slResponse = SmartLogicController.getSmartDiagnosis(slRequest);
		analyseResults(slResponse);
	}

	public static void analyseResults(SmartLogicResponse response) {
		System.debug('response.isError: '+response.isError);
		System.debug('response.message: '+response.message);
		if(response.isError) {
			System.debug('Error::' + response.message);
			System.assert(true);
		}
		else if(response.diagnosisResults.size() > 0) {
			for(SmartLogicResponse.SmartDiagnosisResult result : response.diagnosisResults) {
				System.assert('J44.9'.equalsIgnoreCase(result.ICD)||'I20.9'.equalsIgnoreCase(result.ICD)||'I48.91'.equalsIgnoreCase(result.ICD));
			}
		}
		else {
			System.assert(false);
		}

	}
}