({
    doInit : function(component, event, helper){ 
        console.log('Combination Builder doInit Called');
        helper.refreshFormFields(component);  
        window.addEventListener("message", function(lookupEvent){
            helper.handleLookupSelections(lookupEvent, component);
        }, false);
    },
    
    openICDLookup : function (component, event, helper){
        var objType = 'CodeSearch';
        var ElementIds = 'v.newRuleCombination.Rule_ICD__c,v.newRuleCombination.Rule_Diagnosis__c';
        var DataColumns = 'ICD Code,ICD Description';
        var isStandalone = 'false';
        var isRuleBuilderSelection = 'true';
        var SFIDField = '';
        var searchFilterText = '';
        if(component.get('v.newRuleCombination.Rule_ICD__c'))
        {
            searchFilterText = component.get('v.newRuleCombination.Rule_ICD__c');
        }
        var DateOfService = '2015';
        helper.openLookup(component, event, helper, objType, ElementIds, DataColumns, isStandalone, isRuleBuilderSelection, SFIDField, searchFilterText, DateOfService);
    },
    
    selectRules : function(component, event, helper) {
        component.set("v.invalidRules", '-');
        component.set("v.showRuleSelectionOverlay",true);
        component.set("v.isCombinationBuilderPage",true);
        component.set("v.showANYOFTable",false);
		component.set("v.showRuleListTable",true);        
        component.set("v.showRuleCombListTable",false);  
        component.set("v.currentTabSelectedRules", new Array());    
        var currentCombination = component.get('v.newRuleCombination.Rule_Combination__c');
        var currentCombinationWithExp = component.get('v.ruleCombinationWithExp');
        var currentCombinationDesc = component.get('v.newRuleCombination.Rule_Combination_Description__c');
        var currentSelectedRules = component.get('v.selectedRules');
        var currentSelectedRulesforANY = component.get('v.selectedRulesforANY');
        var currentCombinationMap = component.get('v.combinationMap');
        var currentShowANYOFTable = component.get('v.showANYOFTable');
        component.set('v.cachedRuleCombination', currentCombination);
        component.set('v.cachedRuleCombinationWithExp', currentCombinationWithExp);
        component.set('v.cachedRuleCombinationDesc', currentCombinationDesc);
        component.set('v.cachedRuleCombinationDesc', currentCombinationDesc);
        component.set('v.cachedSelectedRules',currentSelectedRules);
        component.set('v.cachedSelectedRulesforANY',currentSelectedRulesforANY);
        if(component.get('v.cachedCombinationMap')){
        	component.set('v.cachedCombinationMap',currentCombinationMap);
        }
        component.set('v.cachedShowANYOFTable',currentShowANYOFTable);     
        console.log('v.currentSessionSelectedRules'+ component.get('v.currentSessionSelectedRules'));
        var ruleCombination = component.get('v.ruleCombinationWithExp');
        if(!ruleCombination){
            ruleCombination = component.get('v.newRuleCombination.Rule_Combination__c');
        }        
        helper.populateCombinationDescription(component, ruleCombination);                    
    },
    
    closeOverlay : function(component, event, helper) {
        console.log('closeOverlay');
        var selectedRules = component.get('v.selectedRules');
        console.log('selectedRules '+JSON.stringify(selectedRules));
        component.set("v.isCombinationBuilderPage",true);
        component.set("v.showANYOFTable",false);
        component.set("v.combinationOperator", 'None');
        component.set("v.anyOperator", 'None');            
        component.set("v.anyValue", null);
        component.set("v.anyError", "");
        component.set("v.currentTabSelectedRules", new Array());
        if(selectedRules && selectedRules.length==0 ){
            component.set("v.showRuleSelectionOverlay",false);
        }
        else {
            var action = 'Creation Close';
            var message = $A.get("$Label.c.CombinationBuilder_Close"); 
            component.set('v.positiveResponse',"Yes");
            component.set('v.negativeResponse',"No");
            helper.showGenericMessage(component, true, message,action); 
        }
    },
    
    doneRulesSelection : function(component, event, helper) {
        //var ruleCombination = component.get('v.newRuleCombination.Rule_Combination__c'); 
        var ruleCombination = component.get('v.ruleCombinationWithExp');
        component.set("v.newRuleCombination.Rule_Combination_With_Exp__c",ruleCombination);
        console.log('Rule Combination: '+ ruleCombination);
        var submitDone = helper.validateRulesSelection(component);
        helper.highlightRules(component);
        console.log('submitDone: '+submitDone);
        if(submitDone){
            helper.populateCombinationDescription(component,ruleCombination);
            helper.showAuraElement(component, 'SelectedRuleList');
            component.set("v.showRuleSelectionOverlay",false);
            component.set("v.currentSessionSelectedRules", new Array());
            component.set("v.currentTabSelectedRules", new Array());
        }
        component.set("v.isCombinationBuilderPage",true);
        component.set("v.showANYOFTable",false);
        component.set("v.combinationOperator", 'None');
        component.set("v.anyOperator", 'None');            
        component.set("v.anyValue", null);
        component.set("v.anyError", "");
    },
    
    saveRuleCombination : function(component, event, helper) {
        var validForm = true;        
        validForm = helper.validateForm(component);
        console.log('In Controller validForm '+validForm);
        if(validForm){
            var ruleList = component.get('v.selectedRules');
            var ruleIdList= [];
            for(var i=0; i < ruleList.length; i++) {
                var ruleId = ruleList[i].ruleId;
                if(ruleId.indexOf(',')>-1) {
                    var anyRuleIdList = ruleId.split(',');
                    for(var j=0;j<anyRuleIdList.length;j++) {
                        ruleIdList.push(anyRuleIdList[j].trim());
                    }
                }
                else {
                    ruleIdList.push(ruleId.trim());
                }   
            }
            console.log(ruleIdList);
            
            helper.getInactiveRulesFromDB(component,ruleIdList);
        }
    },
    
    cancel  : function(component, event, helper) {
        var compEvent = component.getEvent("RuleActionEvent");
        compEvent.setParams({"ACTION" : 'RefreshCombinationList'});
        compEvent.fire();
    },
    
    populateCombinationString : function(component, event, helper){
        console.log('populateCombinationString-------');
        var comStr = event.getParam("ICombinationString");
        var combinationMap = event.getParam("ICombinationMap");
        var combinationANYMap = event.getParam("ICombinationANYMap");
        console.log('combinationANYMap-------'+combinationANYMap);
        var overlayRules = event.getParam("IOverlayRules");
        var showANYOFTable = event.getParam("IShowANYOFTable");
        console.log('showANYOFTable-------'+showANYOFTable);
        var showRuleListTable = event.getParam("IShowRuleListTable");
        console.log('showRuleListTable-------'+showRuleListTable);
        var showRuleCombListTable = event.getParam("IShowRuleCombListTable");
        console.log('showRuleCombListTable-------'+showRuleCombListTable);
        component.set('v.isCombinationBuilderPage',true);
        var currentSessionSelectedRules = event.getParam("ICurrentSessionSelectedRules");
        if(showANYOFTable){
            showRuleListTable=true;
            component.set('v.isCombinationBuilderPage', false);
            component.set('v.combinationANYMap', []);
        }
        var selectedRules = new Array();
        var selectedRulesforANY = new Array();
        console.log('Inside populateCombinationString: '+JSON.stringify(overlayRules));
        if(overlayRules){
            for(var i=0;i<overlayRules.length;i++){
                var key = overlayRules[i].ruleId;
                var temp = combinationMap[key];
                if(temp){
                    if(temp.checked){
                        if(i==0){
                            temp.operator='IF';
                        }
                        selectedRules.push(temp);
                    }
                }
            }
        }
        component.set("v.newRuleCombination.Rule_Combination__c",comStr);
        component.set("v.ruleCombinationWithExp",comStr);
        component.set("v.selectedRules",selectedRules);
        component.set("v.selectedRulesforANY",selectedRulesforANY);
        component.set("v.combinationMap", combinationMap);
        component.set("v.showANYOFTable", showANYOFTable);
        component.set("v.overlayRules", overlayRules);
        component.set("v.currentSessionSelectedRules", currentSessionSelectedRules);
        helper.populateCombinationString(component, comStr);
    },
    
    populateCombinationDescription : function(component, event, helper){ 
        //var ruleCombination = component.get('v.newRuleCombination.Rule_Combination__c');
        var ruleCombination = component.get('v.ruleCombinationWithExp');
        if(ruleCombination == null || ruleCombination == ''){
            ruleCombination = component.get('v.newRuleCombination.Rule_Combination__c');
        }
        console.log('Rule Combination: '+ ruleCombination);
        var CombinationText = component.find("CombinationText");        	
        CombinationText.set("v.errors", [{message:""}]);
        if(ruleCombination != null){
            if(ruleCombination.indexOf('IF') == 0){
                helper.populateCombinationDescription(component, ruleCombination);
                var ruleCombinationDesc = component.get('v.newRuleCombination.Rule_Combination_Description__c');            
            }
            else{
                //CombinationText.set("v.value", "IF ");
                CombinationText.set("v.errors", [{message:"Rule Combination must prefix with 'IF' operator."}]);
            }
        }
    },
    
    removeRuleFromList : function(component, event, helper){         
        console.log('In removeRuleFromList');
        var self = this;  // safe reference
        var index = event.target.dataset.index;
        console.log('Index' + index);
        helper.updateRuleCombination(component, index);
        helper.removeRule(component, index);
    },
    
    handleListEvents : function(component, event, helper) {
        console.log('In handleListEvents');
        var eventParams = event.getParams();
        var eventType = eventParams.eventType;
        if(eventType == 'Refresh') {
            helper.refreshFormFields(component);
        }        
    },
    
    clearMessage: function(component, event, helper){         
        var CombinationText = component.find("CombinationText");        	
        CombinationText.set("v.errors", [{message:""}]);       
    },
    
    removeRuleFromOverlay : function(component, event, helper){         
        console.log('In removeRuleFromList');
        var self = this;  // safe reference
        var index = event.target.dataset.index;
        console.log('Index' + index);
        helper.removeOverlayRule(component, index);
    },
    
    handleActionConfirmation : function(component, event, helper) {
        console.log('-------------------in handleActionConfirmation-----------------');
        component.set('v.isShowGenericMessage', false);
        var allParams = event.getParams();
        var isConfirm = allParams.isConfirm;
        var action = allParams.ACTION;  
        console.log('ACTION::::'+action+'::'+isConfirm);
        if(isConfirm) { 
            if(action == 'Creation Close') {
                helper.resetFields(component);
                var preCombination = component.get('v.cachedRuleCombination');
                var preCombinationWithExp = component.get('v.cachedRuleCombinationWithExp');
                var preCombinationDesc = component.get('v.cachedRuleCombinationDesc');
                var preSelectedRules = component.get('v.cachedSelectedRules');
                var preCachedSelectedRulesAny = component.get('v.cachedSelectedRulesforANY');
                var preCombinationMap = component.get('v.cachedCombinationMap');
                var preShowANYOFTable = component.get('v.cachedShowANYOFTable');
                console.log(preSelectedRules);
                console.log('preCombinationMap ++++' + preCombinationMap);
                console.log(preCombinationMap);
                //Remove rules without operator
                var delIndex = new Array();
                for(var i=0;i<preSelectedRules.length;i++){
                    var temp = preSelectedRules[i];
                    if(!temp.operator){
                        delIndex.push(i);
                        console.log('Del Index' + delIndex);
                    }
                }                
            	delIndex.forEach(function(value, index){
                	preSelectedRules.splice(value-index, 1);            
            	});
                
                component.set('v.newRuleCombination.Rule_Combination__c', preCombination)
                component.set('v.ruleCombinationWithExp', preCombinationWithExp);
                component.set('v.newRuleCombination.Rule_Combination_Description__c', preCombinationDesc);
                component.set('v.selectedRules', preSelectedRules);
                component.set('v.selectedRulesforANY', preCachedSelectedRulesAny);
                component.set('v.combinationMap', preCombinationMap);
                component.set('v.showANYOFTable', preShowANYOFTable);
                component.set('v.overlayRules', preSelectedRules);
            }    
            else if(action == 'Save' || action == 'Edit' || action == 'Clone') {                
                helper.saveRuleCombinationtoDB(component,component.get('v.newRuleCombination'));                
            }
            else if(action == 'TOOLONG') {
                    console.log('Combination too long msg displayed');
                }
                
                else if(action == 'DUPLICATE') {
                    console.log('Duplicate Combination msg displayed');
                }
                    else if(action == 'ERROR') {
                        console.log('Error in saving Combination');
                    }
            
        }
        else {
            console.log('Closed');
        }
        
    },
    
    handleReOrder : function(component, event, helper){
        console.log('Called handleReOrder');
        var textField = event.getSource();
        var val = textField.get("v.value");
        var lab = textField.get("v.label");
        var arr = lab.split(' ');
        var srcIndex = parseInt(arr[0])-1;
        var desIndex = parseInt(val)-1;
        component.set("v.srcIndex",srcIndex);
        component.set("v.desIndex",desIndex);
        console.log(srcIndex+'<------>'+desIndex);
        helper.swipeElements(component, srcIndex, desIndex);
    },
    
    addAnyOfExpression : function(component, event, helper){        
        helper.addAnyOfCombination(component, event, helper);        
        if(!component.get('v.showANYOFTable')){
            component.set("v.isCombinationBuilderPage",true);
            var cmpEvent = $A.get("e.c:RefreshRuleList");
            cmpEvent.setParams({"IShowANYOFTable" :false}).fire(); 
        }
        component.set("v.srcIndex","-1");
        component.set("v.desIndex","-1");
    },
    
    populateANYCombinationString : function(component, event, helper){
        console.log('populateANYCombinationString-------');
        var combinationMap = event.getParam("ICombinationMap");
        var combinationANYList = event.getParam("ICombinationANYList");
        var overlayRules = event.getParam("IOverlayRules");
        var showANYOFTable = event.getParam("IShowANYOFTable");
        var showRuleListTable = event.getParam("IShowRuleListTable");
        var showRuleCombListTable = event.getParam("IShowRuleCombListTable");
        component.set('v.isCombinationBuilderPage',true);
        if(showANYOFTable){
            showRuleListTable=true;
            showRuleCombListTable=true;
            component.set('v.isCombinationBuilderPage', false);
            component.set('v.combinationANYMap', []);
        }        
        
        var selectedRulesforANYMap = new Array();
        if(combinationANYList){
            console.log('combinationANYList----'+combinationANYList);
            for(var i=0;i<combinationANYList.length;i++){
                var temp = combinationANYList[i];
                console.log('ANY OF --> '+combinationANYList[i].checkedANY);
                if(temp.checkedANY){
                    selectedRulesforANYMap.push(temp);
                }
            }
        }
        console.log(showANYOFTable);
        component.set("v.selectedRulesforANYMap",selectedRulesforANYMap);
        component.set("v.showANYOFTable", showANYOFTable);             
    },
    
    cancelANYTable: function(component, event, helper){
        component.set("v.isCombinationBuilderPage",true);
        component.set("v.showANYOFTable",false);
        component.set("v.combinationOperator", 'None');
        component.set("v.anyOperator", 'None');            
        component.set("v.anyValue", null);
        component.set("v.anyError", "");
        component.set("v.srcIndex","-1");
        component.set("v.desIndex","-1");
        var cmpEvent = $A.get("e.c:RefreshRuleList");
        cmpEvent.setParams({"IShowANYOFTable" :false}).fire();            
    },
    
    checkOperator : function(component, event, helper){
        console.debug('Inside check operator');
        var trR = event.currentTarget;
        var txt = trR.dataset.text;
        console.log('Rule Selected: '+txt);
        return true;
    },
    
    clearErrors : function(component, event, helper){
        var textField = event.getSource();
        textField.set("v.errors","");
    },
    
    switchTab : function(component, event, helper) {
        var clickedTabName =   event.currentTarget.dataset.tab;   
        component.set("v.isCombinationBuilderPage",true);
        component.set("v.showANYOFTable", false);  
        component.set("v.combinationOperator", 'None');
        component.set("v.anyOperator", 'None');            
        component.set("v.anyValue", null);
        component.set("v.anyError", "");
        component.set("v.srcIndex","-1");
        component.set("v.desIndex","-1");
        for(var i=1;i <= 4; i++) {
            var tabName = component.find('tab-item-'+i);
            var tabContent = component.find('tab-content-'+i);
            if(clickedTabName == i) { //make active
                $A.util.addClass(tabName, 'slds-active');
                helper.showAuraElement(component,'tab-content-'+i);
                if(i==1) {
                    component.set("v.showRuleListTable",true);
                    component.set("v.showRuleCombListTable",false);
                }
                if(i==2) {
                    component.set("v.showRuleListTable",false);
                    component.set("v.showRuleCombListTable",true);
                    component.set("v.isCombinationBuilderPage",true);
                }
            }
            else {
                helper.hideAuraElement(component,'tab-content-'+i);
                $A.util.removeClass(tabName, 'slds-active');  
            }
        }
        var map = component.get('v.selectedRules');
        var combinationMap = component.get("v.combinationMap");
        var currentSessionSelectedRules = component.get('v.currentSessionSelectedRules');
        console.log('v.currentSessionSelectedRules'+ component.get('v.currentSessionSelectedRules'));
        var cmpEvent = $A.get("e.c:HandleSwitchTab");
        console.log('Firing event switch tabs');
        cmpEvent.setParams({"ICombinationMap" :combinationMap, "IOverlayRules" : map, "ICurrentSessionSelectedRules": currentSessionSelectedRules}).fire();            
    },
})