@isTest
private class LeadProcessorTest {
    @testSetup
    static void setup() {
        List<Lead> lstLeads = new List<Lead>();
        for (Integer i=0;i<200;i++) {
            lstLeads.add(new Lead(lastName='Company '+i,company='Test Company'));
        }
        insert lstLeads;
    }
    @isTest static void test() {
        Test.startTest();
        LeadProcessor oLeadProcessor = new LeadProcessor();
        Id batchId = Database.executeBatch(oLeadProcessor);
        Test.stopTest();
        // after the testing stops, assert records were updated properly
        System.assertEquals(200, [select count() from Lead where LeadSource='Dreamforce']);
    }
}