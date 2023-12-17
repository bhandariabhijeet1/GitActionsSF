public class LeadProcessor implements Database.Batchable<sObject>, Database.Stateful {
	public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT ID FROM Lead'
        );
    }
    
    public void execute(Database.BatchableContext bc, List<Lead> scope){
        // process each batch of records
        List<Lead> lstUpdatedLeads = new List<Lead>();
        for (Lead oLead : scope) {
            lstUpdatedLeads.add(new Lead(Id=oLead.Id, LeadSource='Dreamforce'));
        }
        update lstUpdatedLeads;
    }
    
    public void finish(Database.BatchableContext bc){
    }
}