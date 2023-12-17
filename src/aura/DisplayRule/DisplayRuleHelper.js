({
    
    fetchRuleFromDB : function(component, ruleId) {
        var fetchAction = component.get("c.fetchRuleById");
        fetchAction.setParams({
            'ruleId': ruleId
        });
        fetchAction.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnValue = JSON.parse(response.getReturnValue());
                component.set('v.rule',returnValue.Rule_Library__r);  
                component.set('v.ruleType',returnValue.Rule_Category__r.Rule_Type__c);  
            }
        });
        $A.enqueueAction(fetchAction);                                 
    },
    
})