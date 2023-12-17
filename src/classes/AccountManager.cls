@RestResource(urlMapping='/Accounts/<Account_ID>/contacts')
global with sharing class AccountManager {
    @HttpGet
    global static Account getAccount() {
        RestRequest request = RestContext.request;
        // grab the caseId from the end of the URL
        System.debug('====request.requestURI======'+request.requestURI);
        String AccountId = request.requestURI.substringBetween('Accounts/','/contacts');
        System.debug('============'+AccountId);
        Account result =  [SELECT Id, Name, (SELECT ID, Name FROM Contacts)
                        FROM Account
                        WHERE Id =:AccountId];
        return result;
    }
}