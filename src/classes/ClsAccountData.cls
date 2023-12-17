public with sharing class ClsAccountData {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactData(){
        return ([SELECT ID, FirstName, LastName, Email, Phone,Title FROM Contact LIMIT 100]);
    }
}