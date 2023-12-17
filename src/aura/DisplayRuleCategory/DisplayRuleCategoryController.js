({
	doInit : function(component, event, helper) {
		console.log('In display rule init');
        var cat=component.get('v.ruleCategory'); 
        console.log(cat);
	},
    
    backLink : function(component, event, helper) {
		var compEvent = component.getEvent("RuleCategoryActionEvent");
        compEvent.setParams({"ACTION" : 'LIST' });
		compEvent.fire();
    
    },
    
    editCat : function(component, event, helper) {
		var compEvent = component.getEvent("RuleCategoryActionEvent");
        compEvent.setParams({"ACTION" : 'Edit', 'CATEGORY' : component.get('v.ruleCategory') });
     	compEvent.fire();
    
    }
    
})