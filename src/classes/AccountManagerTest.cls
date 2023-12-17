@IsTest
private class AccountManagerTest {
	@isTest static void testGetAccountById() {
        Id recordId = createTestRecord();
        System.debug('======recordId====='+recordId);
        // Set up a test request
        RestRequest request = new RestRequest();
        request.requestUri =
            'https://development2-dev-ed.lightning.force.com/services/apexrest/Accounts/'+recordId+'/contacts';
        request.httpMethod = 'GET';
        RestContext.request = request;
        // Call the method to test
        Account thisAccount = AccountManager.getAccount();
        // Verify results
        System.assert(thisAccount != null);
        System.assert(thisAccount.Cases != null);
    }
    
    // Helper method
    static Id createTestRecord() {
        // Create test record
        Account AccountTest = new Account(
            Name='Test Account');
        insert AccountTest;
        Case caseTest = new Case(
            Subject='Test record',
            Status='New',
            Origin='Phone',
            AccountId = AccountTest.Id,
            Priority='Medium'); 
        return AccountTest.Id;
    } 
}