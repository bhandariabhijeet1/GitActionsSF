({
    doInit : function(component, event, helper) {
        var ruleId = component.get('v.ruleId');
        if(ruleId) {
            helper.fetchRuleFromDB(component,ruleId);
        }
    },
    cancel  : function(component, event, helper) {
        var compEvent = component.getEvent("RuleActionEvent");
        compEvent.setParams({"ACTION" : 'Refresh' });
        compEvent.fire();
    },
    
    editRule  : function(component, event, helper) {
        var compEvent = component.getEvent("RuleActionEvent");
        var rule = component.get('v.rule');
        compEvent.setParams({"ACTION" : 'Edit','RULEID': rule.Id, 'ISRULE': true});
        compEvent.fire();
    }
})