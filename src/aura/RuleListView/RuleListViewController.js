({
    doInit : function(component, event, helper) {
        component.set('v.symptomSearch','');
        helper.fetchTypesFromDB(component);
        if(component.get("v.combinationBuilderPage") || component.get("v.combinationBuilderPageANY"))
        {
            var RuleListTable = component.find("RuleListTableId");
            $A.util.addClass(RuleListTable, "ReducePadding");
        }
    },
    
    handleListEvents : function(component, event, helper) {
        console.log('--in handleListEvents ---');
        var eventParams = event.getParams();
        var eventType = eventParams.eventType;
        var preAction = eventParams.preAction;
        var message ='';
        if(preAction)
        {
            var message = $A.getReference("$Label.c."+preAction); 
        }    
        component.set('v.isShowGenericMessage',false);        
        component.set('v.genericMessageString', message);
        if(eventType == 'Refresh') {
            component.set('v.symptomSearch','');
            component.set('v.selectedFilter', 'All');
            var filterBy = 'All';//component.get('v.selectedFilter');
            var isAsc = component.get('v.isAsc');
        	var sortFieldName = component.get('v.selectedTabsoft');
            if(filterBy == 'All') {
                helper.fetchRulesFromDB(component,'');
            }
            else {
                helper.fetchRulesByCategory(component,filterBy, '', isAsc, sortFieldName);
            }   
            var map = component.get("v.selectedRules");
            var overlayRules = component.get("v.overlayRules");
            
            var combinationConstructed = helper.parseCombinationMap(map,component);
            var cmpEvent = component.getEvent("ConstructCombination");
            console.log('Combination Created: '+ combinationConstructed);        
            cmpEvent.setParams({"ICombinationString" : combinationConstructed, "ICombinationMap":map, "ICombinationANYMap":new Object(), "IOverlayRules":overlayRules, "IShowANYOFTable" : false, "IShowRuleListTable": true, "IShowRuleCombListTable": false}).fire();
        }        
    },
    
    handleValueTextKeyUp : function(component, event, helper) {
        component.set('v.isShowGenericMessage',false);
        component.set('v.genericMessageString', '');
        var searchKey = component.get('v.symptomSearch');  
        var filterBy = component.get('v.selectedFilter');
        var isAsc = component.get('v.isAsc');
        var sortFieldName = component.get('v.selectedTabsoft');            
        helper.fetchRulesByCategory(component,filterBy, searchKey, isAsc, sortFieldName);
    },
    
    handleFilterBy : function(component, event, helper) {
        component.set('v.isShowGenericMessage',false);
        component.set('v.genericMessageString', '');
        var searchKey = component.get('v.symptomSearch');  
        var filterBy = component.get('v.selectedFilter');
        var isAsc = component.get('v.isAsc');
        var sortFieldName = component.get('v.selectedTabsoft');  
        helper.fetchRulesByCategory(component,filterBy, searchKey, isAsc, sortFieldName);
    },
    
    clear : function(component, event, helper) {
        component.set('v.symptomSearch','');  
        var filterBy = component.get('v.selectedFilter');
        var isAsc = component.get('v.isAsc');
        var sortFieldName = component.get('v.selectedTabsoft');          
        helper.fetchRulesByCategory(component,filterBy, '', isAsc, sortFieldName);
    },
    
    viewRule : function(component, event, helper) {
        var ruleClicked = event.currentTarget;
        var ruleId = ruleClicked.dataset.ruleid;
        component.set('v.symptomSearch','');
        var compEvent = component.getEvent("RuleActionEvent");
        compEvent.setParams({"ACTION" : 'View' });
        compEvent.setParams({"RULEID" : ruleId });
        compEvent.setParams({"ISRULE" : true });
        compEvent.fire();  
    },
    
    showSpinner : function(component, event, helper) {
        var el = component.find('Spinner');
        $A.util.removeClass(el.getElement(), 'slds-hide');
    },
    
    hideSpinner : function(component, event, helper) {
        var el = component.find('Spinner');
        $A.util.addClass(el.getElement(), 'slds-hide');
    },
    
    onCheck : function(component, event, helper) {
        helper.populateSelectedRuleMap(component, event, helper);
        var anySelected = component.get("v.anySelected");
        if(!anySelected){
            component.set('v.disableOperatorField',false);
        }
    },
    
    handleOperator : function(component, event, helper){
        helper.populateOperatorInRulesMap(component, event, helper);        
    },
    
    getValue : function(){
        return true;
    },
    
    removeRule : function(component, event, helper){
        var ruleId = event.getParam("IRuleId");        
        helper.removeSelectedRuleById(component, helper, ruleId);		
    },
    
    completeAnyOfExpression : function(component, event, helper){
        component.set('v.anySelected',false);
        component.set('v.disableOperatorField',false);
        component.set('v.disableCheckBoxes',true);
        helper.completeAnyOfCombination(component, event, helper);
    },
    
    handleANYOperator : function(component, event, helper){
        console.log('handleANy called');
        component.set("v.combinationBuilderPage",false);
        component.set("v.combinationBuilderPageANY",true);
        component.set('v.anySelected',true);        
        var map = component.get("v.selectedRules");
        component.set('v.selectedRulesforANYMap',new Array());
        component.set('v.anyOfSelectedRules', new Object());
        var mapANY = component.get('v.selectedRulesforANYMap');
        var overlayRules = component.get('v.overlayRules');
        var cmpEvent = component.getEvent("ConstructANYList");
        cmpEvent.setParams({"ICombinationMap": map, "ICombinationANYList": mapANY, "IOverlayRules": overlayRules, "IShowANYOFTable" : true, "IShowRuleListTable": false, "IShowRuleCombListTable": false}).fire();		
        helper.populateSelectedRuleANYMapOnButton(component, event, helper);
    },
    
    populateReOrderCombinationString : function(component, event, helper){
        var map = event.getParam("IReOrderCombinationMap");
        console.log('populateReOrderCombinationString');
        var overlayRules = event.getParam("IReOrderOverlayRules");
        var showANYOFTable = event.getParam("IShowANYOFTable");
        var currentSessionSelectedRules = event.getParam("ICurrentSessionSelectedRules");
        console.log('OverlayRules: ');
        console.log(JSON.stringify(overlayRules));
        if(!map){
            map = component.get("v.selectedRules");
        }
        console.log('populatereoder '+JSON.stringify(map));
        if(overlayRules){
            for(var i=0;i<overlayRules.length;i++){
                var arrObj = overlayRules[i];
                console.log(arrObj);
                if(arrObj){
                    var mapObj = map[arrObj.ruleId];
                    if(mapObj){
                        mapObj.operator=arrObj.operator;
                        mapObj.operatorSelected=arrObj.operatorSelected;
                    }
                    if(map && arrObj.isAnyRule){
                        console.log('Found Any Combination');
                        map[arrObj.ruleId] = arrObj;
                    }
                }            
            }
            component.set("v.selectedRules",map);
            component.set("v.overlayRules",overlayRules);
        }
        
        //To uncheck the rules after remove..
        var ruleList = component.get('v.ruleList');
        if(map){
            for(var i in ruleList){
                var rule = ruleList[i];
                var tempRule = map[rule.Rule_Library_Ext_Id__c];
                if(tempRule){
                    rule.checked=tempRule.checked; 
                    rule.operator=tempRule.operator;
                }else{
                    rule.checked=false;             
                    rule.operator='';
                }
            }
        }
        component.set('v.ruleList',ruleList);
        component.set('v.currentSessionSelectedRules',currentSessionSelectedRules);
             
        
        var showRuleListTable = true;
        if(showANYOFTable){
            showRuleListTable = false;
        }  
        var combinationString = helper.parseCombinationMap(map, component);
        var cmpEvent = component.getEvent("ConstructCombination");
        cmpEvent.setParams({"ICombinationString" : combinationString, "ICombinationMap":map,"ICombinationANYMap":new Object(), "IOverlayRules":overlayRules,"IShowANYOFTable" : showANYOFTable, "IShowRuleListTable": showRuleListTable, "IShowRuleCombListTable": false}).fire();        
    },
    
    onANYCheck : function(component, event, helper) {
        helper.populateSelectedRuleANYMap(component, event, helper);        
    },
    
    refreshRuleList : function(component, event, helper) {
        console.log('Refresh Rule List Controller method..');
        helper.refreshRuleListHelper(component, helper, true);
    },
    
    sortRuleName: function(component, event, helper) {
       // set current selected header field on selectedTabsoft attribute.     
       component.set("v.selectedTabsoft", 'RuleName');
       // call the helper function with pass sortField Name   
       helper.sortHelper(component, event, 'RuleName');
    },
    
    sortICDCode: function(component, event, helper) {
       // set current selected header field on selectedTabsoft attribute.     
       component.set("v.selectedTabsoft", 'ICDCode');
       // call the helper function with pass sortField Name   
       helper.sortHelper(component, event, 'ICDCode');
    },
    
    sortICDDescription: function(component, event, helper) {
       // set current selected header field on selectedTabsoft attribute.     
       component.set("v.selectedTabsoft", 'ICDDescription');
       // call the helper function with pass sortField Name   
       helper.sortHelper(component, event, 'ICDDescription');
    },
    
    handleSwitchTabs : function(component, event, helper){
        var map = event.getParam("ICombinationMap");
        console.log('handleSwitchTabs');
        var overlayRules = event.getParam("IOverlayRules");
        var currentSessionSelectedRules = event.getParam("ICurrentSessionSelectedRules");
        console.log('OverlayRules: ');
        console.log(JSON.stringify(overlayRules));
        if(!map){
            map = component.get("v.selectedRules");
        }
        console.log('populatereoder '+JSON.stringify(map));        
        //component.set('v.selectedRules',map);
        component.set('v.currentSessionSelectedRules',currentSessionSelectedRules);
    },
})