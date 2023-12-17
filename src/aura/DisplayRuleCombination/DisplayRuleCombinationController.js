({
	doInit : function(component, event, helper){ 
        console.log('Display Rule Combination doInit Called');
        var ruleId = component.get('v.ruleId'); 
        console.log('In view mode ' + ruleId);
        helper.fetchRuleCombinationFromDB(component,ruleId);    	
    },
    
    editRuleCombination : function(component, event, helper) {
        var rule = component.get('v.newRuleCombination');
        var compEvent = component.getEvent("RuleActionEvent");
        compEvent.setParams({"ACTION" : 'Edit','RULEID': rule.Id, 'ISRULE': false});
		compEvent.fire();
    },
    
    cancel : function(component, event, helper) {
        var compEvent = component.getEvent("RuleActionEvent");
        compEvent.setParams({"ACTION" : 'RefreshCombinationList'});
		compEvent.fire();
    },
})