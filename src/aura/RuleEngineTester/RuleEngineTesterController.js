({
    doInit : function(cmp,event,helper) {
        var RuleTypeOptions = [];
        var GenderOptions = [];
        var fetchRuleCategoryOptions = cmp.get("c.RuleCategoryOptions");
        var fetchGenderOptions = cmp.get("c.RuleGenderOptions");
        var fetchRuleDetailsForTesting = cmp.get("c.populateSymptomsOnPageLoad");
        var ruleId = cmp.get('v.ruleId');
        if(ruleId != null && ruleId != '') {
          fetchRuleDetailsForTesting.setParams({
            'RecordID': ruleId
          });
          cmp.set('v.allTestSymptomsList','');
        }
       
        fetchRuleCategoryOptions.setCallback(this, function(response){
            var state = response.getState();
            var symptom = new Object();
            symptom.fieldDataType = '';
            symptom.fieldName = '';
            symptom.lstfieldValue = [];
            symptom.fieldValue='';
            symptom.showSuggestion = false;
            var allSymptomsList = new Array();
			allSymptomsList.push(symptom);	
            cmp.set('v.allSymptomsList', allSymptomsList);
            if (state === "SUCCESS") {
                if(JSON.parse(response.getReturnValue()))
                {
                    RuleTypeOptions = JSON.parse(response.getReturnValue());
                    cmp.set("v.allCategories", RuleTypeOptions);
                    cmp.find("MultipleRuleTypeSelection").set("v.value", "Global"); 
                    if(ruleId != null && ruleId != '') {
                        $A.enqueueAction(fetchRuleDetailsForTesting);
                       
                    }   
                    else {
                         helper.getFieldsByType(cmp, 'Global');
                    }
                  }
            }
        });
        
        fetchGenderOptions.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                if(JSON.parse(response.getReturnValue()))
                {
                    GenderOptions = JSON.parse(response.getReturnValue());
                    cmp.set("v.allGenders", GenderOptions); 
                    if(ruleId == null && ruleId == '') {
                    	cmp.find("GenderSelection").set("v.value", "U"); 
                    }
                }
            }
        });
        
        fetchRuleDetailsForTesting.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = JSON.parse(response.getReturnValue());
                if(result)
                {
                    console.log(result);
                    cmp.set('v.allTestSymptomsList', result.lstSymptoms);
                    cmp.find("MultipleRuleTypeSelection").set("v.value", result.sCategoryType); 
                    cmp.find("GenderSelection").set("v.value", result.sGender);
                    cmp.set('v.ruleLookupType', result.sLookupType);
                    helper.getFieldsByType(cmp, result.sCategoryType);
                }
            }
        });
        
        $A.enqueueAction(fetchRuleCategoryOptions);
        $A.enqueueAction(fetchGenderOptions);
       
    },

	 ruleTypeSelectionChange: function(component,event,helper) {
         var selectCmp = component.find("MultipleRuleTypeSelection");
        var selectedTypes = selectCmp.get("v.value");
          
          var symptom = new Object();
          symptom.fieldDataType = '';
          symptom.fieldName = '';
          symptom.lstfieldValue = [];
          symptom.fieldValue='';
          symptom.showSuggestion = false;
          
        var allSymptomsList = new Array();
		allSymptomsList.push(symptom);	
        console.log('-----------------------------');
        console.log(allSymptomsList);
        component.set('v.allSymptomsList', allSymptomsList); 
        component.set('v.ruleId','');         
        component.set('v.allTestSymptomsList','');
        
        helper.getFieldsByType(component, selectedTypes);
       
	 },
    fieldSelectionChange :function(component,event,helper) {
    },
    
    genderSelectionChange: function(cmp) {
        
	 },
    
    //Method called on keyup on input field
    search : function(component, event, helper) {
        var keyCode=event.getParams().keyCode;
        var inputSymptom = event.getSource();
        var ruleField = inputSymptom.get('v.value');
        var allSymptomsList = component.get('v.allSymptomsList');
        var tempList = [];
        for(var i = 0; i<allSymptomsList.length;i++) {
            	  var obj = allSymptomsList[i];
            	  if(obj.fieldName == ruleField && obj.fieldName!= '') {
                		obj.showSuggestion = true;
            	   }   
            	  else {
                		obj.showSuggestion = false;
            	  }
                   tempList.push(obj);
        }
        if(ruleField.trim().length >= 1) {
            if(keyCode != 13 && keyCode != 38 && keyCode != 40) {
               helper.filterSymptoms(component,ruleField);
               
            }
        }
        component.set('v.allSymptomsList', tempList);
    },
    
    handleAutosuggestionEvent :  function(component, event, helper) {
        try{
        console.log('Indise handleAutosuggestionEvent' );
        var symptom = event.getParams().ISymtom;
        var listIndex = event.getParams().listIndex;
        var allSymptomsList = component.get('v.allSymptomsList');
        allSymptomsList[listIndex].fieldName = symptom;
        var fieldDefList = component.get('v.fieldDefList');
            
      
        for(var i=0;i<fieldDefList.length;i++) {
            var obj = fieldDefList[i];
            if(obj.fieldName == symptom) {
                allSymptomsList[listIndex].fieldDataType = obj.fieldDataType;
                allSymptomsList[listIndex].fieldValue = '';                    
                
                if(obj.fieldDataType == 'MULTIPICKLIST' || obj.fieldDataType == 'PICKLIST' || obj.fieldDataType == 'BOOLEAN')
                {
                    allSymptomsList[listIndex].lstfieldValue = obj.lstfieldValue; 
					allSymptomsList[listIndex].fieldValue = obj.lstfieldValue[0];                   
                }    
                
                allSymptomsList[listIndex].showSuggestion = false;
                break;
            }
        }
        console.log('obj.allSymptomsList: '+JSON.stringify(allSymptomsList));
        component.set('v.allSymptomsList', allSymptomsList);
        }
        catch(err){
            
        }
    },
    
    addClicked : function(component) {
        var symptom = new Object();
        symptom.fieldDataType = '';
        symptom.fieldName = '';
        symptom.lstfieldValue = [];
        symptom.fieldValue = '';
        symptom.showSuggestion = false;
        var allSymptomsList = component.get('v.allSymptomsList');
       	allSymptomsList.push(symptom);	
        component.set('v.allSymptomsList', allSymptomsList);
    },
    
    deleteClicked : function(component,event) {
      var allSymptomsList = component.get('v.allSymptomsList');
      if(allSymptomsList.length > 1) {
        var eventSrc = event.target || event.srcElement;
        var listIndex = eventSrc.dataset.listindex;
        allSymptomsList.splice(listIndex,1);
      	component.set('v.allSymptomsList', allSymptomsList);
      }
      
    },
    
    onBlur : function(component) {
        var allSymptomsList = component.get('v.allSymptomsList');
        var tempList = [];
        for(var i = 0; i<allSymptomsList.length;i++) {
              	allSymptomsList[i].showSuggestion = false;
                tempList.push(allSymptomsList[i]);
        }
        component.set('v.allSymptomsList',tempList);
    },
    
    arrowClicked : function(component, event, helper) {
        var eventSrc = event.target || event.srcElement;
        var listIndex = parseInt(eventSrc.attributes[1].value);
        if(isNaN(listIndex)) {
            listIndex = parseInt(eventSrc.attributes[4].value);
        }
        var allSymptomsList = component.get('v.allSymptomsList');
        var tempList = [];
        for(var i = 0; i<allSymptomsList.length;i++) {
          var obj = allSymptomsList[i];
          if(i == listIndex) {
              if(obj.showSuggestion == false) {
        			obj.showSuggestion = true;
              }
              else {
         		obj.showSuggestion = false;
              }
             
          }   
          else {
         		obj.showSuggestion = false;
          }
          tempList.push(obj);
        }
        helper.filterSymptoms(component,'');
        component.set('v.allSymptomsList', tempList);
   },
    
    handleReset : function(component) {
          component.find("MultipleRuleTypeSelection").set("v.value", "Global"); 
          component.find("GenderSelection").set("v.value", "U"); 
          
          var symptom = new Object();
          symptom.fieldDataType = '';
          symptom.fieldName = '';
          symptom.lstfieldValue = [];
          symptom.fieldValue='';
          symptom.showSuggestion = false;
          
          var allSymptomsList = new Array();
		  allSymptomsList.push(symptom);	
          component.set('v.allSymptomsList', allSymptomsList); 
         component.set('v.allTestSymptomsList','');
          component.set('v.isShowResults',false);
    },
    
    handleSubmit : function(component,event,helper){
        var category = component.find('MultipleRuleTypeSelection').get('v.value');
        var symptoms = component.get('v.allSymptomsList');
        helper.getSmartDiagnosis(component, category, symptoms);
    }
})