({  
    fetchRuleCombinationFromDB : function(component, ruleId) {        
        var fetchAction = component.get("c.fetchRuleCombinationById");
        fetchAction.setParams({
            'ruleId': ruleId
         });
        fetchAction.setCallback(this, function(response){
            var state = response.getState();
            if (state == "SUCCESS") {
            	var returnValue = JSON.parse(response.getReturnValue());
              	if(returnValue != null){
              		component.set('v.newRuleCombination', returnValue);                  
              	}
            }
        });
        $A.enqueueAction(fetchAction);                                 
   },
})