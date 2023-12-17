@isTest
private class DailyLeadProcessorTest {
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    @testSetup static void setup() {
        List<Lead> lstLead = new List<Lead>();
        for (Integer i = 0; i < 200; i++) {
            lstLead.add(new Lead(lastName='Test Lead'+i,Company='TestCompany'));
        }
        insert lstLead;
    }
    static testmethod void testScheduledJob() {
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('ScheduledApexTest',
            CRON_EXP,
            new DailyLeadProcessor());
        System.assertNotEquals(200, [SELECT count() FROM Lead WHERE LeadSource = 'Dreamforce']);
        Test.stopTest();
        System.assertEquals(200, [SELECT count() FROM Lead WHERE LeadSource = 'Dreamforce']);
    }
}