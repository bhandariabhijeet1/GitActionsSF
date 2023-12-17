({
	doInit : function(component, event, helper) {
		//var allActions = ['Activate','Edit','Copy'];        
        //component.set('v.allActions',allActions);
        console.log('RuleListAction doInit');
        var isRule = component.get('v.isRule');
        var btnStatusC = component.find('btnStatus');
        if(isRule){
        	if(rule.is_Active__c != true) {
        		$A.util.addClass(btnStatusC, 'ACTIVEBTN');
            }  
            else {
            	$A.util.addClass(btnStatusC, 'DEACTIVEBTN');
            }
        }
        else{
            if(rule.Is_Active__c != true) {
          		$A.util.addClass(btnStatusC, 'ACTIVEBTN');
           	}  
           	else {
           		$A.util.addClass(btnStatusC, 'DEACTIVEBTN');
            }
        }
	},
    
    handleAction : function(component, event, helper) {
        var action = component.get('v.selectedAction');
        console.log('handle '+ action);
        var rule = component.get('v.rule');
        var isRule = component.get('v.isRule');
        var fromOverlay = component.get('v.combinationBuilderPage');
        if(fromOverlay){
            action = 'Activate';
        }
        if(action == 'Activate') { 
            if(isRule) {
                if(rule.is_Active__c != true) {
            		rule.is_Active__c = true;
            	}  
            	else {
            		rule.is_Active__c = false;
                }
                helper.updateRuleStatus(component,rule);
            }
            else{
                 if(rule.Is_Active__c != true) {
            		rule.Is_Active__c = true;
            	}  
            	else {
            		rule.Is_Active__c = false;
                }
                helper.updateRuleCombinationStatus(component,rule);
            }
        }
        else  {
        	var compEvent = component.getEvent("RuleActionEvent");
            compEvent.setParams({"ACTION" : action,'RULEID': rule.Id, 'ISRULE': isRule});
			compEvent.fire();  
            helper.hideAuraElement(component,'action-list');
            //fire listaction event to refresh list
            var compEvent = $A.get("e.c:RuleListEvents");
            compEvent.setParams({"eventType" : 'Refresh','preAction' : action});
		    compEvent.fire();
        }
        
       
    },
    
    toggleActionList : function(component, event, helper) {
         helper.showAuraElement(component,'action-list');
    },
  
})