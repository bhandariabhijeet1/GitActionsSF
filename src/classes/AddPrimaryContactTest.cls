@isTest
public class AddPrimaryContactTest {
    @testSetup
    static void setup() {
        List<Account> accounts = new List<Account>();
        Contact oContact = new Contact(firstName='Test',LastName='Name',email='test@email.com');
        for (Integer i = 0; i < 50; i++) {
            accounts.add(new Account(name='Test Account'+i,BillingState='New York',BillingCountry='United States'));
        }
        for (Integer i =50; i < 100; i++) {
            accounts.add(new Account(name='Test Account'+i,BillingState='California',BillingCountry='United States'));
        }
        insert accounts;
        insert oContact;
    }
    static testmethod void testQueueable() {
        // query for test data to pass to queueable class
        Contact oContact = [select id,firstName,LastName,Email from Contact where email = 'test@email.com' LIMIT 1];
        // Create our Queueable instance
        AddPrimaryContact oAddPrimaryContact = new AddPrimaryContact(oContact, 'California');
        // startTest/stopTest block to force async processes to run
        Test.startTest();
        System.enqueueJob(oAddPrimaryContact);
        Test.stopTest();
        // Validate the job ran. Check if record have correct parentId now
        System.assertEquals(50, [select count() from Contact where Account.BillingState = 'California']);
    }
}