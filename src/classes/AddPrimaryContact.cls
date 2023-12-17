public class AddPrimaryContact implements Queueable {
    private Contact oContactBase;
    private String sBaseStateAbbr;
    public AddPrimaryContact(Contact oContact, String sStateAbbr) {
        this.oContactBase = oContact;
        this.sBaseStateAbbr = sStateAbbr;
    }
    public void execute(QueueableContext context) {
        List<Contact> lstContact = new List<Contact>();
        System.debug('======oContactBase======'+oContactBase);
        for (Account oAccount : [SELECT ID,Name FROM Account WHERE BillingState=:sBaseStateAbbr LIMIT 200]) {
            
            Contact oNewContact = oContactBase.clone(false, false, true, true);
            oNewContact.LastName = oAccount.Name;
            oNewContact.AccountId = oAccount.Id;
            lstContact.add(oNewContact);
        }
        insert lstContact;
    }
}