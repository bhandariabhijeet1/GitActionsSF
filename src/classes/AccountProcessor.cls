public class AccountProcessor {
	
    @future
    public static void countContacts(List<Id> lstAccountIds){
        List<Account> lstUpdateAccount = new List<Account>();
        Integer iContactCount = 0;
        for(Account oAccount: [SELECT ID,(SELECT ID FROM Contacts) FROM Account WHERE ID IN:lstAccountIds]){
            iContactCount = oAccount.Contacts != null && oAccount.Contacts.size() > 0 ? oAccount.Contacts.size() : 0;
            lstUpdateAccount.add(new Account(Id=oAccount.Id,Number_of_Contacts__c=iContactCount));
        }
        if(lstUpdateAccount != null && lstUpdateAccount.size() > 0){
            update lstUpdateAccount;
        }
    }
}