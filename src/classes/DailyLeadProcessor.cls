global class DailyLeadProcessor implements Schedulable {
    global void execute(SchedulableContext ctx) {
        List<Lead> lstLead = new List<Lead>();
        for(Lead oLead : [SELECT Id FROM Lead WHERE LeadSource='' LIMIT 200]){
            oLead.LeadSource = 'Dreamforce';
            lstLead.add(oLead);
        }
        update lstLead;
    }
}