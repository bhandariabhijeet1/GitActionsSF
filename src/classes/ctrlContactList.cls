public with sharing class ctrlContactList {
    
    @AuraEnabled(cacheable=true)
    public static List<Contact> fetchContactList(){
        List<Contact> lstContact = new List<Contact>();
        lstContact = [SELECT ID, FirstName, LastName, Title, Email, Phone FROM Contact];
        System.debug('========'+lstContact.size());
        return lstContact;
    }
}