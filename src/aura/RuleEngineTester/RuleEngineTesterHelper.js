({
	filterSymptoms : function(component,ruleField){
        var filteredList=new Array();
        var allFields=new Array();
        allFields=component.get("v.allFields");
        var j = 0;
       
     for(var i=0;i<allFields.length;i++){
         var searchResult=-1;
         var obj = allFields[i];
         if(obj['fieldName']){
            var lowerField = obj.fieldName.toLowerCase();
            var lowerSearchString = ruleField.toLowerCase();
         	searchResult = lowerField.indexOf(lowerSearchString);
         }
         if(searchResult!=-1 || ruleField == '' ){
             filteredList[j]=allFields[i].fieldName;
             j++;
         }
      }
       component.set("v.filteredList",filteredList);
    },
    
     getFieldsByType: function(component, category) {
         console.log('Inside getFieldsByType');
       var action = component.get("c.fetchFieldsAgainstRuleType");
       action.setParams({
               'sRuleTypeSelection' : category
        });
         action.setCallback(this, function(response){
             var state = response.getState();
            if (state === "SUCCESS") {
                var fieldDefList = JSON.parse(response.getReturnValue());
                component.set('v.fieldDefList', fieldDefList);
                var allFields = [];
                for(var key in fieldDefList) {
                    allFields.push(key);
                 }
                component.set('v.allFields',fieldDefList);
                var ruleId = component.get('v.ruleId');
                console.log(ruleId);
                 if(ruleId != null && ruleId != '') {
          		       this.setFieldTypes(component,component.get('v.allTestSymptomsList'));
                 }    
            }
           
        });
        $A.enqueueAction(action);
    }, 
    
    getSmartDiagnosis : function(component, category, allSymptoms) {
        var symptoms = [];
        for(var i=0;i< allSymptoms.length; i++) {
            var symp = new Object();
            symp.fieldName = allSymptoms[i].fieldName;
            symp.fieldValue = allSymptoms[i].fieldValue;
            symptoms.push(symp);
        }
        var gender = new Object();
        gender.fieldName = 'Gender';
        gender.fieldValue = component.find('GenderSelection').get('v.value');
        symptoms.push(gender);
      
        var action = component.get("c.executeRulesEngine");
        action.setParams({
               'sRuleCategoriesSelected' : category,
                'sSymptomsList' : JSON.stringify(symptoms)
        });
         action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
               var smartResponse = JSON.parse(response.getReturnValue());
               component.set('v.smartResponse',smartResponse);
               component.set('v.isShowResults',true);
            }
         });
        $A.enqueueAction(action);
    },
    
    setFieldTypes : function(component,allTestSymptomsList) {
        var allSymptomsList = new Array();
        var fieldDefList = component.get('v.fieldDefList');
        var ruleLookupType = component.get('v.ruleLookupType');
        var lstLookupFieldValues = [];        
        lstLookupFieldValues.push('Active');
        lstLookupFieldValues.push('Inactive');
        
        for(var i=0;i<allTestSymptomsList.length;i++) {
           
          for(var j=0;j<fieldDefList.length;j++) {
            var obj = fieldDefList[j];
            if(obj.fieldName ==  allTestSymptomsList[i].fieldName) {
                var symptom = new Object();
            	symptom.fieldDataType = obj.fieldDataType;
           		symptom.fieldName = obj.fieldName;
                symptom.lstfieldValue =  obj.lstfieldValue;
                symptom.fieldValue = allTestSymptomsList[i].fieldValue;
                symptom.showSuggestion = false;
                allSymptomsList.push(symptom);
                break;
            }
            else if(ruleLookupType == 'Medication' || ruleLookupType == 'CodeSearch'){
                var symptom = new Object();
            	symptom.fieldDataType = 'PICKLIST';
           		symptom.fieldName = allTestSymptomsList[i].fieldName;
                symptom.lstfieldValue =  lstLookupFieldValues;
                symptom.fieldValue = allTestSymptomsList[i].fieldValue;
                symptom.showSuggestion = false;
                allSymptomsList.push(symptom);
                break;
            }
          }
            
        }
       component.set('v.allSymptomsList', allSymptomsList);
       console.log('allSymptomsList' + allSymptomsList);
    }
    
})