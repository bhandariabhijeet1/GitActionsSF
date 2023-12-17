@IsTest
public class AccountProcessorTest {
    @testSetup
    private static void dataSetup(){
        Account oAccount = new Account(name='TestAccount');
        insert oAccount;
    }
    
    @IsTest
    private static void testSendSms() {
        List<Id> lstAccountIds = new List<Id>(); 
        for(Account oAccount : [SELECT ID FROM Account]){
            lstAccountIds.add(oAccount.Id);
        }
        Test.startTest();
        	AccountProcessor.countContacts(lstAccountIds);
        Test.stopTest();
    }
}