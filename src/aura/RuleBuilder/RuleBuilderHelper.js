({
    fetchFormInitData : function(component) {
        var fetchAllTypes = component.get("c.fetchTypesData");
        fetchAllTypes.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                console.debug('Fetched init data');
                var typeCategoryMap = JSON.parse(response.getReturnValue()); 
                var allTypes = [];
                for(var key in typeCategoryMap) {
                    if(key != 'Global') {
                    	allTypes.push({"class": "optionClass", label: key, value: key});    
                    }
                }
               // var selectType = component.find("selectType"); 
                //selectType.set('v.options',allTypes);
                component.set('v.selectedType','Global');
                component.set('v.allTypes',allTypes);
                component.set('v.typeCategoryMap',typeCategoryMap);
                $A.enqueueAction(fetchAllOperators);
                var mode = component.get('v.mode');
                if(!(mode == 'Edit'|| mode == 'Clone')) {
             	   this.getFieldsByType(component,'Global');
               }
            }
        });
        
        var fetchAllOperators = component.get("c.fetchAllOperators");
        fetchAllOperators.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                console.debug('Fetched data fetchAllOperators');
                var dataTypeOperatorMap = JSON.parse(response.getReturnValue()); 
                component.set('v.dataTypeOperatorMap',dataTypeOperatorMap);
                var mode = component.get('v.mode');
                if(mode == 'Edit'|| mode == 'Clone') {
                    var ruleId = component.get('v.ruleId'); 
                    this.fetchRuleFromDB(component,ruleId); 
                }
                
            }
        });
         $A.enqueueAction(fetchAllTypes);
        
    },
    
    getFieldsByType: function(component, type) {
        console.log('-----getFieldsByType----');
        var typeCategoryMap = component.get('v.typeCategoryMap');
        console.log(typeCategoryMap);
        var category = typeCategoryMap[type];
        
        var action = component.get("c.fetchFieldsForCategory");
        action.setParams({
            'category' : category
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var fieldDefinitionList = JSON.parse(response.getReturnValue());
                component.set('v.fieldDefinitionList', fieldDefinitionList);
               
                var mode = component.get('v.mode');
                if(mode == 'Edit' || mode == 'Clone') {
                    var rule = component.get('v.newRule');
                    var selectedField = rule.Rule_Field__c;
      				var lookupType = rule.Lookup_Type__c;
                    component.set('v.lookupType', lookupType);
      				if(lookupType == 'CodeSearch'){
      					selectedField = 'Select Diagnosis';
      				}
      				else if(lookupType == 'Medication'){
        				selectedField = 'Select Medication';
      				}
                    if(selectedField != '') {
                        console.log(lookupType + ' ' + selectedField);
                    	this.getOperatorsByFieldName(component,selectedField);
                    }
                    else {
                         component.set('v.allOperators',[]);
                    }
                }
            }
            this.filterSymptoms(component);
            component.set("v.showautosuggestedlist",false);
            
        });
        $A.enqueueAction(action);
    }, 
    
    getOperatorsByFieldName: function(component, fieldName) {
        var dataTypeOperatorMap = component.get('v.dataTypeOperatorMap');
        var fieldDefinitionList = component.get('v.fieldDefinitionList');
        var fieldDataType  ='';
        var fieldPicklistValues = [];
        for(var i=0;i<fieldDefinitionList.length;i++) {
            if(fieldDefinitionList[i].fieldName == fieldName) {
           		fieldDataType = fieldDefinitionList[i].fieldDataType;  
                fieldPicklistValues = fieldDefinitionList[i].lstfieldValue;
                break;
            }
           
        }
        if(fieldDataType == '') {
            component.set('v.isInvalidRule',true);
        }
        else {
        	 component.set('v.isInvalidRule',false);
            this.showValueSectionByType(component, fieldDataType, fieldName,fieldPicklistValues);
        	var operators = dataTypeOperatorMap[fieldDataType].split(',');
        	component.set('v.allOperators', operators);
        	var mode = component.get('v.mode');
        	if(mode == 'Edit' || mode == 'Clone') {
            	var rule = component.get('v.newRule');
            	var selectOperator = component.find('selectOperator');
            	selectOperator.set('v.value', rule.Rule_Operator__c);
            }
        }
    }, 
    
    showValueSectionByType : function(component, fieldDataType, fieldName,fieldPicklistValues) {
        console.log('--------showValueSectionByType-----------------');
         component.set('v.isInvalidRule',false);
        this.hideAuraElement(component,'picklistValues');
        this.hideAuraElement(component,'boolValue');
        this.hideAuraElement(component,'textNumValue');
        this.hideAuraElement(component,'multipleValueCount-container');  
        this.hideAuraElement(component,'multipleValueCount');    
        component.set('v.ruleValue','');
        var mode = component.get('v.mode');
        if(mode != 'Edit' && mode != 'Clone') {
            component.set('v.newRule.Rule_Operator__c','');
            component.set('v.newRule.Multiple_Value_Count__c','');
            component.set('v.selectedPicklistValues',[]);
        }
        if(fieldDataType == 'PICKLIST' || fieldDataType == 'MULTIPICKLIST') {
            this.showAuraElement(component,'picklistValues');
            this.showAuraElement(component, 'pickListOptions');
            component.set('v.allPicklistValues',  fieldPicklistValues);
            var checkboxes = component.find('picklistCheckbox');
            for(var i=0;i<checkboxes.length;i++) {
            	checkboxes[i].set("v.value",false);
            }
            if( fieldDataType == 'MULTIPICKLIST') {
                this.showAuraElement(component,'multipleValueCount-container');    
                this.showAuraElement(component,'multipleValueCount');  
            }
            else {
                this.hideAuraElement(component,'multipleValueCount-container');  
                this.hideAuraElement(component,'multipleValueCount');    
             }
               var mode = component.get('v.mode');
               if(mode == 'Edit' || mode == 'Clone') {
                    var array = []; 
                    if(fieldDataType == 'MULTIPICKLIST') {
                        array = component.get('v.newRule.Rule_Value__c').split(';');
                    }
                    else {
                        array = component.get('v.newRule.Rule_Value__c').split(',');
                    }
                    component.set('v.selectedPicklistValues',component.get('v.newRule.Rule_Value__c'));
                    var allCheckboxes = component.find('picklistCheckbox');
                     for(var j=0; j<array.length ; j++) { 
                        for(var i=0;i<allCheckboxes.length;i++) {
                             if(allCheckboxes[i].get('v.text') == array[j]) {
                                allCheckboxes[i].set("v.value",true);
                            }
                        }       
                    }
              }
        }
        else if(fieldDataType == 'BOOLEAN') {
            this.showAuraElement(component,'boolValue');
         
            if(mode == 'Edit' || mode == 'Clone') {
                var ruleValue = component.get('v.newRule').Rule_Value__c;
                if(ruleValue == '') {
                  var booleanDropdown = component.find('allBoolVals');
                  booleanDropdown.set('v.value', 'True,Yes,1');
                  component.set('v.selectedBoolVal','True,Yes,1');
                  component.set('v.selectedPicklistValues', new Array());
                  component.set('v.newRule.Rule_Value__c','True,Yes,1');
                }
                else {
               		 component.set('v.selectedBoolVal', ruleValue);
                }    
            }
            else {
                var booleanDropdown = component.find('allBoolVals');
                booleanDropdown.set('v.value', 'True,Yes,1');
                component.set('v.selectedBoolVal','True,Yes,1');
                component.set('v.newRule.Rule_Value__c','True,Yes,1');
               
            }
        }
        else {
            this.showAuraElement(component,'textNumValue');  
            component.set('v.selectedPicklistValues', new Array());
            if(mode == 'Edit' || mode == 'Clone') {
                var ruleTextValue = component.find('ruleTextValue');
                var ruleValue = component.get('v.newRule').Rule_Value__c;
                ruleTextValue.set('v.value',ruleValue );
            }
        }
    },
 
    
    saveRuletoDB : function(component) {
        
        console.log('--------in saveRuletoDB-----------');
        var rule = component.get('v.newRule');
        this.getValueForField(component, rule);
        
        var ruleICDField = component.find('ICDText');  
        rule.Rule_ICD__c = ruleICDField.get("v.value"); 
        
        var ruleICDDesc = component.find('ICDDescText');  
        rule.Rule_Diagnosis__c = ruleICDDesc.get("v.value"); 
        
        var ruleSymptomField = component.find('selectField');  
        rule.Rule_Field__c = ruleSymptomField.get("v.value"); 
        
        var ruleOperator = component.find("selectOperator");
        rule.Rule_Operator__c = ruleOperator.get("v.value");
        
        rule.Lookup_Type__c = component.get("v.lookupType");
        
        component.set('v.newRule', rule);
        console.log('rule'+JSON.stringify(rule));
        
        var selectedType = component.get('v.selectedType');
        var saveAction1;
        
        var mode = component.get('v.mode');
        console.log('-----------------'+mode+'-----------------');
        if(mode == 'Edit') {
            saveAction1 = component.get("c.editRule");
        }
        else if(mode == 'Clone') {
            saveAction1 = component.get("c.cloneRule");
        }
        else if(mode == 'Save' || mode == '') {
            saveAction1 = component.get("c.saveRuletoDB");
        }        
        saveAction1.setParams({
            'rule': JSON.stringify(rule),
            'ruleType' : selectedType
        });
  
       saveAction1.setCallback(this, function(response){
            var state = response.getState();
            console.log('------------------------save state ------------'+state);
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                //console.log(returnValue);  
                if(returnValue == 'SUCCESS') {
                    var action;
                    if(mode == 'Edit') {
                        action = 'RuleBuilder_Edited';
                    } else if(mode == 'Clone') {
                        action = 'RuleBuilder_Cloned';
                    }
                    console.log('Rule'+ action +'successfully');
                    var compEvent = component.getEvent("RuleActionEvent");
                    compEvent.setParams({"ACTION" : 'Refresh','preAction' : action });
                    compEvent.fire();
                }
                else if(returnValue == 'DUPLICATE_RULE') {
                    var message = $A.get("$Label.c.RuleBuilder_RuleSaveDuplicate"); 
                  
                    this.showGenericMessage(component, false, message, 'DUPLICATE');
                   
                }
                else {
                    var message = $A.get("$Label.c.RuleBuilder_RuleSaveError"); 
                    this.showGenericMessage(component, false, message, 'ERROR');
                }
            }
           else {
                console.log('------------------------not success state ------------'+state);
           }
            
        });
        $A.enqueueAction(saveAction1);
    },
    
    getValueForField : function(component, rule) {
      var fieldDefinitionList = component.get('v.fieldDefinitionList'); 
      var fieldDataType = '';
      var selectedField = rule.Rule_Field__c;
      var lookupType = component.get("v.lookupType");
      if(lookupType == 'CodeSearch'){
      	selectedField = 'Select Diagnosis';
      }
      else if(lookupType == 'Medication'){
        selectedField = 'Select Medication';
      }
        
      for(var i=0;i<fieldDefinitionList.length;i++) {
            if(fieldDefinitionList[i].fieldName == selectedField) {
                fieldDataType = fieldDefinitionList[i].fieldDataType;
            }
      }
      if(fieldDataType == 'PICKLIST' || fieldDataType == 'MULTIPICKLIST') {
             var strValue = component.get('v.selectedPicklistValues').toString();
            if(fieldDataType == 'MULTIPICKLIST' && strValue!='')
            {
                var splittedValues = strValue.split(',');
                var allOptions = splittedValues[0];
                for(var i=1;i<splittedValues.length; i++ ) {
                    allOptions = allOptions + ';' +splittedValues[i];
                }
                // rule.multipleValueCount = component.get("v.multipleValueCount");
                rule.Rule_Operator__c = ':';
                strValue = allOptions;
                rule.Rule_Value__c = strValue;
            }
            else {
               rule.Rule_Value__c = strValue;
            }
            
        }
        else if(fieldDataType == 'BOOLEAN') {
            var inputField = component.find('allBoolVals');
            rule.Rule_Value__c = inputField.get("v.value"); 
        }
        else {
            var inputField = component.find('ruleTextValue');  
            rule.Rule_Value__c = inputField.get("v.value"); 
        }
        
    },
    
    fetchRuleFromDB : function(component, ruleId) {
        
        var fetchAction = component.get("c.fetchRuleById");
        fetchAction.setParams({
            'ruleId': ruleId
        });
        fetchAction.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnValue = JSON.parse(response.getReturnValue());
                component.set('v.newRule',returnValue.Rule_Library__r);  
                
                var selectOperator = component.find("selectOperator"); 
                selectOperator.set('v.value',returnValue.Rule_Operator__c); 
                
                var selectType = component.find("selectType"); 
                selectType.set('v.value',returnValue.Rule_Category__r.Rule_Type__c);
                
                this.getFieldsByType(component,returnValue.Rule_Category__r.Rule_Type__c);
            }
        });
        $A.enqueueAction(fetchAction);                                 
    },
    
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
    
    validateForm : function(component){
        console.log('------validateForm--------');
        var ruleTest = component.get('v.newRule');
        var inputSysmtom = component.find("selectField");
        var valueSymptom = inputSysmtom.get("v.value");
        var inputOperator = component.find("selectOperator");
        var valueOperator = inputOperator.get("v.value");
        var selectTypeField = component.find('selectType');
        var selectedField = component.get('v.newRule.Rule_Field__c');
        var fieldDefinitionList = component.get('v.fieldDefinitionList'); 
        var fieldDataType = '';
        console.log(fieldDefinitionList);
        console.log('selectedField' + selectedField);
        console.log(component.get("v.lookupType"));
        var lookupType = component.get("v.lookupType");
        if(lookupType == 'CodeSearch'){
            selectedField = 'Select Diagnosis';
        }
        else if(lookupType == 'Medication'){
            selectedField = 'Select Medication';
        }
        console.log('selectedField' + selectedField);
        for(var i=0;i<fieldDefinitionList.length;i++) {
            if(fieldDefinitionList[i].fieldName == selectedField ) {
                fieldDataType = fieldDefinitionList[i].fieldDataType;
            }
        }
       
        var validForm=true;
        console.log(valueSymptom);
        console.log('valueOperator::'+valueOperator);
        console.log('fieldDataType----'+fieldDataType);
        if (!valueSymptom || valueSymptom == 'Select Diagnosis' || valueSymptom == 'Select Medication') {
            console.log('valueSymptom error');
            inputSysmtom.set("v.errors", [{message:"Select desired Symptom"}]);
            validForm=false;
        }
        else {
            inputSysmtom.set("v.errors", null);
            component.set('v.newRule.Rule_Field__c',valueSymptom);
        }
        
        if (valueOperator=='None') {
            console.log('operrator error');
            inputOperator.set("v.errors", [{message:"Select suitable Operator"}]);
            validForm=false;
        }
        
        if(fieldDataType == 'PICKLIST' || fieldDataType == 'MULTIPICKLIST') {
            
            if( fieldDataType == 'MULTIPICKLIST') {
                var array = component.get('v.selectedPicklistValues').toString().split(',');
                var inputCount = component.find("multipleValueCount");
                var valueCount = inputCount.get("v.value");
              
                if(!valueCount){
                    inputCount.set("v.errors", [{message:"Please enter count"}]);
                    validForm=false;
                } 
                else if(array.length == 1 && array[0] == '') {
                    component.set('v.selectedPicklistValues',[]);
                    inputCount.set("v.errors", [{message:"Please select atleast "+valueCount+" value/s"}]);
                    validForm=false;
                }
                else if(array.length<valueCount){
                    inputCount.set("v.errors", [{message:"Please select atleast "+valueCount+" value/s"}]);
                    validForm=false;
                }
                else{
                    validForm=true;    
                }
            }
            else if(fieldDataType == 'PICKLIST') {
                 var array = component.get('v.selectedPicklistValues').toString();
                 if(array.length == 0) {
                    component.set('v.selectedPicklistValues',[]);
                    var picklist = component.find('picklistCheckbox');
                    picklist[picklist.length-1].set("v.errors", [{message:"Please select atleast 1 value"}]);
                    validForm=false;
                }
             
            }
            
        }
        else if(fieldDataType == 'BOOLEAN') {
            
        }
        else{
            var inputText = component.find("ruleTextValue");
            var valueText = inputText.get("v.value");
            if(!valueText){
                inputText.set("v.errors", [{message:"Please enter count"}]);
                validForm=false;
            }
            
        }
        return validForm;
    },
    
    filterSymptoms : function(component){
        var filteredList=new Array();
        var allFields=new Array();
        allFields=component.get("v.fieldDefinitionList");
        var i = 0;
        var ruleField = component.get("v.newRule.Rule_Field__c");
        for(var s=0;s<allFields.length;s++){
            var searchResult=-1;
            if(allFields[s].fieldName && ruleField){
                var lowerField = allFields[s].fieldName.toLowerCase();
                searchResult = lowerField.indexOf(ruleField.toLowerCase());
            }
            if(searchResult!=-1 || !ruleField){
                filteredList[i]=allFields[s].fieldName;
                i++;
            }
        }
        console.log('filteredList '+filteredList.length);
        component.set("v.showautosuggestedlist",true);
        component.set("v.filteredList",filteredList);
    },
    
    confirmAction : function(component) {
        console.log('--------------------confirmAction------------------');
        var mode = component.get('v.mode');
        if(mode == '') {
            mode ='Save';
        }
        var showGenericMessage = $A.get("e.c:ShowGenericMessage");
        var message = $A.get("$Label.c.RuleBuilder_RuleSaveConfirmation"); 
        message = message.replace('$mode$',mode);
        console.log(message);
        showGenericMessage.setParams({"Message" : message, "isConfirmation":true,'ACTION':mode});
        showGenericMessage.fire();
    },
    
    showGenericMessage : function(component,isConfirmation, message, action) {
    	   component.set('v.isConfirmation', isConfirmation);
           component.set('v.genericMessage', message);
           component.set('v.isShowGenericMessage', true);
           component.set('v.genericMessageAction', action);
    },
    
    openLookup : function (component, event, helper, objType, ElementIds, DataColumns, isStandalone, isRuleBuilderSelection, SFIDField, searchFilterText, DateOfService){
        var lightningURL = window.location.protocol+"//"+window.location.hostname;
        var codeSearchLink = component.get('v.CodeSearchLink');
        codeSearchLink = codeSearchLink.replace('#1', objType);
        codeSearchLink = codeSearchLink.replace('#2', ElementIds);
        codeSearchLink = codeSearchLink.replace('#3', DataColumns);
        codeSearchLink = codeSearchLink.replace('#4', isStandalone);
        codeSearchLink = codeSearchLink.replace('#5', SFIDField);
        codeSearchLink = codeSearchLink.replace('#6', DateOfService);
        codeSearchLink = codeSearchLink.replace('#7', isRuleBuilderSelection);
        codeSearchLink = codeSearchLink.replace('#8', searchFilterText);
        codeSearchLink = codeSearchLink.replace('#9', lightningURL);
        var url = encodeURI(codeSearchLink);
        childWindow =  window.open(url,'CTSearchLookup','width=1200,toolbar=1,resizable=1,scrollbars=yes,height=550,top=50,left=50');
    },
    
    handleLookupSelections : function(event, component) {
        try{
            var inputSysmtom = component.find("selectField");
        	inputSysmtom.set("v.errors", null);
            Object.keys(event.data).forEach(function (elementId) {
                if(elementId && elementId != 'Type')
                {
                    component.set(elementId,event.data[elementId]);
                }
            });
        }
        catch(e)
        {
           console.log(e.message);
        }
    }
    
})