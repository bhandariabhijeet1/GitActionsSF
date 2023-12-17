({
	fetchFormInitData : function(component) {
         var fetchAllTypes = component.get("c.fetchAllSupportedCategories");
         fetchAllTypes.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {              
               var categoryList = JSON.parse(response.getReturnValue()); 
               component.set('v.allCategories',categoryList);
               var mode = component.get('v.mode');
               if(mode == 'edit') {
                   var selectComponent = component.find('selectCategory');
                   var selectedValue = component.get('v.ruleCategory');
                   selectComponent.set('v.value', selectedValue);
                }               
             }
        });
        $A.enqueueAction(fetchAllTypes);        
    },
    
    saveCategoryToDB : function(component) {
        var saveCat;
        var category = component.get('v.selectedCategory');
        var type = component.get('v.selectedType');
        if(component.get('v.mode') == 'edit'){
            saveCat = component.get("c.editCategory");
            saveCat.setParams({
               'ruleType' : type,
               'ruleCategory' : category,
               'ruleCategoryID' : component.get('v.ruleCategoryID')
            });
        }
        else {
        	saveCat = component.get("c.saveCategory");
               saveCat.setParams({
               'ruleType' : type,
               'ruleCategory' : category
            });
        }      
     
		saveCat.setCallback(this, function(response){
            var state = response.getState();
            var showGenericMessage = $A.get("e.c:ShowGenericMessage");
            if (state === "SUCCESS") {
              var result = response.getReturnValue(); 
               if(result == 'SUCCESS') {
                    if(component.get('v.mode') == 'edit')
                    {
                        console.log('Rule Category edited successfully.');
                    }
                    else {
                        console.log('Rule cat saved successfully');
                    }
                   var compEvent = component.getEvent("RuleCategoryActionEvent");
                    compEvent.setParams({"ACTION" : 'LIST' });
				    compEvent.fire();
                } 
                else if(result == 'DUPLICATE_RULE_CAT') {
                    var message = $A.get("$Label.c.RuleCategoryBuilder_CategorySaveDuplicate"); 
                    this.showGenericMessage(component, false, message, 'DUPLICATE');
                   
                }
                else {
                    var message = $A.get("$Label.c.RuleBuilder_RuleSaveError"); 
                    this.showGenericMessage(component, false, message, 'ERROR');
                }
            }
            else {
                console.log('error'+state );
            }
        });
        $A.enqueueAction(saveCat);
    },
    
    isValidForm : function(component) {
        var validForm=true;
        var category = component.get('v.selectedCategory');
        var type = component.get('v.selectedType');
        if(category == '') {
            var catComp = component.find('selectCategory');
            catComp.set("v.errors", [{message:"Select Suitable Category!"}]);
            validForm = false;
        }
        else {
           // console.log('cat'+category);
            }
        if(!type || type == '') {
            var selectType = component.find('selectTypeText');
            selectType.set("v.errors", [{message:"Select Suitable Category Type!"}]);
            validForm = false;
        }
        else {
            //console.log('type'+type);
        }
        return validForm;
    },
    
    showGenericMessage : function(component,isConfirmation, message, action) {
    	   component.set('v.isConfirmation', isConfirmation);
           component.set('v.genericMessage', message);
           component.set('v.isShowGenericMessage', true);
           component.set('v.genericMessageAction', action);
    }
})