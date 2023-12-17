@isTest
public class SmartLogicICDProcessingUtilTest {
	@testSetup	
    public static void setup(){
	Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='Attestationuser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='Attestationuser@testorg.com');
        insert u;
         
        HCC_Codes__c hccCode = new HCC_Codes__c();
        hccCode.Name = 'HCC10';
        hccCode.HCC_Description__c = 'Lymphoma';
        hccCode.Effective_Date__c = System.today();
        insert hccCode;
        
        ICD_Codes__c icdCode = new ICD_Codes__c();
        icdCode.Name = 'C41.3';
        icdCode.ICD_Description__c = 'Malignant Neoplasms';
        icdCode.Effective_Date__c = System.today();
        icdCode.ICD_Version__c = '0';
        icdCode.HCC_Code__c = hccCode.id;
        insert icdCode;   
        
        ICD_Codes__c icdCode1 = new ICD_Codes__c();        
        icdCode1.Name = 'M84.4';
        icdCode1.ICD_Description__c = 'Pathological fracture';
        icdCode1.Effective_Date__c = System.today();
        icdCode1.ICD_Version__c = '0';
        //icdCode.HCC_Code__c = hccCode.id;
        insert icdCode1;        
        
        HCC_Codes__c hccCode1 = new HCC_Codes__c();
        hccCode1.Name = 'HCC173';
        hccCode1.HCC_Description__c = 'Traumatic Amputations';
        hccCode1.Effective_Date__c = System.today();
        insert hccCode1;  
        
		ICD_Codes__c icdCode2 = new ICD_Codes__c(); 
        icdCode2.Name = 'S78.929A';
        icdCode2.ICD_Description__c = 'Partial traumatic amputation';
        icdCode2.Effective_Date__c = System.today();
        icdCode2.ICD_Version__c = '0';
        icdCode2.HCC_Code__c = hccCode1.id;
        insert icdCode2;  

        Access_Token__c accessToken=new Access_Token__c();
        accessToken.value__c='test';
        insert accessToken;
        
        System.assert(true);
	}
	

	public static testMethod void testFetchAndStoreICDCodes(){
	    Test.startTest();
        SmartLogicAggregateResponse smResponse = new SmartLogicAggregateResponse();
        Test.setMock(HttpCalloutMock.class,new smartLogicICDAPIMock());
        List<SmartLogicAggregateResponse.SmartDiagnosisResult> smDigResult = new List<SmartLogicAggregateResponse.SmartDiagnosisResult>();
        SmartLogicAggregateResponse.SmartDiagnosisResult sd1 = new SmartLogicAggregateResponse.SmartDiagnosisResult('','A41.59','','');
        SmartLogicAggregateResponse.SmartDiagnosisResult sd2 = new SmartLogicAggregateResponse.SmartDiagnosisResult('','D89.40','','');
        SmartLogicAggregateResponse.SmartDiagnosisResult sd3 = new SmartLogicAggregateResponse.SmartDiagnosisResult('','I11.0','','');
        SmartLogicAggregateResponse.SmartDiagnosisResult sd4 = new SmartLogicAggregateResponse.SmartDiagnosisResult('','Z94.3','','');
        smDigResult.add(sd1);
        smDigResult.add(sd2);
        smDigResult.add(sd3);
        smDigResult.add(sd4);
        smResponse.diagnosisResults = smDigResult;
        List<ICD_Codes__c> icdCodeList = [select name from ICD_Codes__c];
		Integer countBefore = icdCodeList.size();
        SmartLogicICDProcessingUtil tempObj = new SmartLogicICDProcessingUtil();
   
        tempObj.fetchAndStoreICDCodes(smResponse.diagnosisResults);
        List<ICD_Codes__c> icdCodeList1 = [select name from ICD_Codes__c];
        Integer countAfter = icdCodeList1.size();
    	System.assert((countBefore+1)==countAfter);
        
        Test.stopTest();
	}
}