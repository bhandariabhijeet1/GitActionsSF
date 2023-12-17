({
	doInit : function(component, event, helper) {
        var ruleId = component.get('v.ruleId');
        component.set('v.newRule.is_Active__c',false);
        helper.hideAuraElement(component, 'multiOptions');
        helper.fetchFormInitData(component);
        window.addEventListener("message", function(lookupEvent){
            helper.handleLookupSelections(lookupEvent, component);
        }, false);
   },
    
    openICDLookup : function (component, event, helper){
        var objType = 'CodeSearch';
        var ElementIds = 'v.newRule.Rule_ICD__c,v.newRule.Rule_Diagnosis__c';
        var DataColumns = 'ICD Code,ICD Description';
        var isStandalone = 'false';
        var isRuleBuilderSelection = 'true';
        var SFIDField = '';
        var searchFilterText = '';
        if(component.get('v.newRule.Rule_ICD__c'))
        {
            searchFilterText = component.get('v.newRule.Rule_ICD__c');
        }
        var DateOfService = '2015';
        helper.openLookup(component, event, helper, objType, ElementIds, DataColumns, isStandalone, isRuleBuilderSelection, SFIDField, searchFilterText, DateOfService);
    },
    
    openICDLookupForSymptom : function (component, event, helper){
        var objType = 'CodeSearch';
        var ElementIds = 'v.newRule.Rule_Field__c';
        var DataColumns = 'ICD Code,ICD Description';
        var isStandalone = 'false';
        var isRuleBuilderSelection = 'true';
        var SFIDField = '';
        var searchFilterText = '';
        var DateOfService = '2015';
        helper.openLookup(component, event, helper, objType, ElementIds, DataColumns, isStandalone, isRuleBuilderSelection, SFIDField, searchFilterText, DateOfService);       
    },
    
    openMedicationLookupForSymptom : function (component, event, helper){
        var objType = 'Medication';
        var ElementIds = 'v.newRule.Rule_Field__c';
        var DataColumns = 'Name~~ Route~~ Form~~ Strength~~ UOM,Class';
        var isStandalone = 'false';
        var isRuleBuilderSelection = 'true';
        var SFIDField = '';
        var searchFilterText = '';
        var DateOfService = '2015';
        helper.openLookup(component, event, helper, objType, ElementIds, DataColumns, isStandalone, isRuleBuilderSelection, SFIDField, searchFilterText, DateOfService);        
    },

    //Method called on keyup on input field
    search : function(component, event, helper) {
        var keyCode=event.getParams().keyCode;
        var ruleField = component.get('v.newRule.Rule_Field__c');        
        var inputSymptom = component.find("selectField");
        inputSymptom.set("v.errors", null);
        //Hide text in Rule to be created
        helper.hideAuraElement(component, 'pickListOptions');
        helper.hideAuraElement(component, 'multiOptions');
        if(ruleField.trim().length >= 1) {
            if(keyCode != 13 && keyCode != 38 && keyCode != 40) {
               helper.filterSymptoms(component);
            }
        }
        else {
            component.set("v.showautosuggestedlist",false);

       }
    },
    
    populateSymtom : function(component, event, helper) {
        var symtom = event.getParam("ISymtom");
        component.set("v.newRule.Rule_Field__c",symtom);
        var ruleField = component.get('v.newRule.Rule_Field__c');
        if(ruleField == 'Select Diagnosis'){
            component.set("v.lookupType", "CodeSearch");
        }
        else if(ruleField == 'Select Medication'){
            component.set("v.lookupType", "Medication");
        }
        else{
            component.set("v.lookupType", "");    
        }
        component.set("v.showautosuggestedlist",false);
        component.set('v.newRule.Rule_Value__c','');
        helper.getOperatorsByFieldName(component, symtom);
        var selectedField = component.find('selectField');
        selectedField.set("v.errors", null);
        var inputOperator = component.find("selectOperator");
        inputOperator.set("v.value",'None');
        var inputCount = component.find("multipleValueCount");
        inputCount.set("v.errors", null);
       
    },
    handleTypeChange : function(component, event, helper) {
        var selectType = component.find("selectType");
        selectType.set("v.errors", null);
        var selectedType = selectType.get('v.value');
        component.set("v.showautosuggestedlist",false);
        component.set('v.newRule.Rule_Field__c','');
        component.set('v.newRule.Rule_Operator__c', '') ;
        component.set("v.ruleValue", ''); 
        component.set("v.newRule.Rule_Value__c", ''); 
        helper.getFieldsByType(component, selectedType);
    },
    
    handleFieldChange : function(component, event, helper) {
       var selectedField = component.get('v.newRule.Rule_Field__c');
       selectedField.set("v.errors", null);
       var inputOperator = component.find("selectOperator");
       inputOperator.set("v.value",'None');
      
       helper.getOperatorsByFieldName(component, selectedField);
       //component.set('v.newRule.Rule_Operator__c', '') ;
     },
   
    handleValueTextKeyUp :  function(component, event, helper) {
        var inputField = component.find('ruleTextValue');  
        inputField.set("v.errors", null);
        var ruleValue = inputField.get("v.value"); 
        component.set("v.ruleValue", ruleValue); 
        component.set("v.newRule.Rule_Value__c", ruleValue); 
    },
    
    handleMultiCountKeyup  :  function(component, event, helper) {
         var inputField = component.find('multipleValueCount');  
        inputField.set("v.errors", null);
        var inputValue = inputField.get("v.value"); 
        component.set("v.newRule.Multiple_Value_Count__c", inputValue); 
    },
  
    handleBoolValueChange : function (component, event, helper) {
        var inputValue = component.get('v.selectedBoolVal');  
        component.set("v.ruleValue", inputValue); 
        component.set("v.newRule.Rule_Value__c", inputValue); 
    },
  
    saveRule : function(component, event, helper) {
     var invalidRule =  component.get('v.isInvalidRule');
        if(!invalidRule ) {
        var validForm = true;
        validForm = helper.validateForm(component);
        if(validForm){
          
           var mode = component.get('v.mode');
           if(mode == '' ||  mode =='Save') {
              component.set('v.isConfirmation', true);
              mode ='Save';
              var rule = component.get('v.newRule');
           	  var message = $A.get("$Label.c.RuleBuilder_RuleSaveConfirmation"); 
              if(rule.is_Active__c) {
                message = $A.get("$Label.c.RuleBuilder_RuleSaveActiveConfirmation");
              }
              helper.showGenericMessage(component, true, message,mode); 
           }
            else {
                  helper.saveRuletoDB(component);
            }
          
         }
        }
     },     
 
    onCheck : function(component, event, helper) {
        var picklist = component.find('picklistCheckbox');
        picklist[picklist.length-1].set("v.errors", null);
                   
        var checkbox = event.getSource();
        var checkboxState = checkbox.get("v.value");
        var checkboxValue = checkbox.get("v.text");
        var selectedField = component.get('v.newRule.Rule_Field__c');
        var fieldDefinitionList = component.get('v.fieldDefinitionList'); 
        var fieldDataType = '';
        for(var i=0;i<fieldDefinitionList.length;i++) {
            if(fieldDefinitionList[i].fieldName == selectedField ) {
                fieldDataType = fieldDefinitionList[i].fieldDataType;
                break;
            }
        }
        var seperator = ',';
        if( fieldDataType == 'MULTIPICKLIST') {
             seperator = ';';
         }    
        
        var array = [];
        var mode = component.get('v.mode');
        if(mode == 'Edit' || mode == 'Clone')
        {
            var tempStr = component.get('v.newRule.Rule_Value__c');
            if(tempStr.trim()){
            	array = tempStr.split(seperator);
            }
        }
        else {
          	array = component.get('v.selectedPicklistValues');
         }
       if(checkboxState == true) {
             array.push(checkboxValue);
            component.set('v.selectedPicklistValues', array); 
        }
        else {
             var index = array.indexOf(checkboxValue);
             if (index > -1) {
                array.splice(index, 1);              
             }
            if(array.length == 1 && array[0] == '')
            {
                component.set('v.selectedPicklistValues', new Array()); 
            }  
            else {
                component.set('v.selectedPicklistValues', array); 
            }
        }       
        
        //Start - Added for fixing defect 90
        if(array.length == 0){
            component.set('v.showRuleValue', true);
            component.set('v.showSelectedValues', false);
        }
        else{
            component.set('v.showRuleValue', false);
            component.set('v.showSelectedValues', true);
        }
        if(component.get('v.newRule.Rule_Operator__c') != ':'){
            helper.showAuraElement(component, 'pickListOptions');
            helper.hideAuraElement(component, 'multiOptions');
        }
        else if(component.get('v.newRule.Rule_Operator__c') == ':'){
            helper.hideAuraElement(component, 'pickListOptions');
            helper.showAuraElement(component, 'multiOptions');
        }
        //Added for fixing defect 90 - End
        helper.getValueForField(component,component.get('v.newRule'));
    },
    
    cancel  : function(component, event, helper) {
        var compEvent = component.getEvent("RuleActionEvent");
        compEvent.setParams({"ACTION" : 'Refresh' });
		compEvent.fire();
    },
    
    handleOperatorChange : function(component, event, helper) {
       var selectOperator = component.find("selectOperator");    
       selectOperator.set("v.errors", null);
       component.set('v.newRule.Rule_Operator__c',selectOperator.get('v.value'));
    },

    arrowClicked : function(component, event, helper) {
       var isAUtoSuggestShown = component.get('v.showautosuggestedlist');
        if(isAUtoSuggestShown == true) {
            component.set("v.showautosuggestedlist",false);
        }
        else {
            helper.filterSymptoms(component,'');
        }
    },
    
    handleActionConfirmation : function(component, event, helper) {
    
      component.set('v.isShowGenericMessage', false);
      var allParams = event.getParams();
      var isConfirm = allParams.isConfirm;
      var action = allParams.ACTION;  
      if(isConfirm) { 
          if(action == 'DUPLICATE') {
              console.log('Duplicate rule msg displayed');
          }
          else if(action == 'ERROR') {
              console.log('Error in saving rule');
          }
          else {
            helper.saveRuletoDB(component);
          }    
      }
      else {
            console.log('Closed');
      }
        
    }
})