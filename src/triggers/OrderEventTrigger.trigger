trigger OrderEventTrigger on Order_Event__e (after insert) {
   
    // List to hold all cases to be created.
    List<Task> tasks = new List<Task>();
       
    // Iterate through each notification.
    for (Order_Event__e event : Trigger.New) {
        if (event.Has_Shipped__c == true) {
           Task t = new Task();
            t.OwnerId = userInfo.getUserId();
            t.Subject = 'Follow up on shipped order ' + event.Order_Number__c;
            t.Status = 'New';
            t.Priority = 'Medium';
           
           tasks.add(t);
        }
   }
    
    // Insert all cases corresponding to events received.
    insert tasks;

}