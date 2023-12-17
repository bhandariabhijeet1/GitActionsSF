({
	 hideAuraElement : function(component, auraId) {
          var elementToHide = component.find(auraId);
          $A.util.removeClass(elementToHide, 'slds-show');
          $A.util.addClass(elementToHide, 'slds-hide');
 	},
    
    showAuraElement : function(component,auraId) {
          var elementToShow = component.find(auraId);
          $A.util.removeClass(elementToShow, 'slds-hide');
          $A.util.addClass(elementToShow, 'slds-show');
    },
    
    updateRuleStatus : function(component, rule) {
        var updateAction = component.get("c.changeRuleStatus");
        var action = 'RuleBuilder_Status_';
        updateAction.setParams({
            'rule': JSON.stringify(rule),
        });
        updateAction.setCallback(this, function(response){
           var returnValue = response.getReturnValue();
           if(returnValue) {
              action = (rule.is_Active__c)? action +'Activated' : action +'Deactivated';
           }
           else {
             action = action + 'Error';
           }
           var compEvent = $A.get("e.c:RuleListEvents");
           compEvent.setParams({"eventType" : 'Refresh', preAction: action});
		   compEvent.fire();
        });
       $A.enqueueAction(updateAction);
    },
    
    updateRuleCombinationStatus : function(component, rule) {
        var updateAction = component.get("c.changeRuleCombinationStatus");
        updateAction.setParams({
            'rule': JSON.stringify(rule),
        });
        var action = 'CombinationBuilder_Status_';
        updateAction.setCallback(this, function(response){
           var returnValue = response.getReturnValue();
           var showGenericMessage = $A.get("e.c:ShowGenericMessage");
          
          if(returnValue) {
              action = (rule.Is_Active__c)? action +'Activated' : action +'Deactivated';
           }
           else {
             action = action + 'error';
           }
         var compEvent = $A.get("e.c:RuleListEvents"); //component.getEvent("RuleActionEvent");
         compEvent.setParams({"eventType" : 'RefreshCombinationList', preAction: action});
		 compEvent.fire();              
            
        });
       $A.enqueueAction(updateAction);
    },    
    
  
})