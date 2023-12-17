({
	doInit : function(component, event, helper) {
        helper.fetchFormInitData(component);
   },
    
    handleTypeChange : function(component, event, helper) {
		  var catComp = component.find('selectCategory');
          catComp.set("v.errors", null);
    },
    
    saveRule : function(component, event, helper) {
        var mode = component.get('v.mode');
        if(helper.isValidForm(component)) {
             component.set('v.isConfirmation', true);
             var message = $A.get("$Label.c.RuleCategoryBuilder_SaveConfirmation"); 
              helper.showGenericMessage(component, true, message,mode); 
			
        }		
	},
    
    cancel : function(component, event, helper) {
		var compEvent = component.getEvent("RuleCategoryActionEvent");
        compEvent.setParams({"ACTION" : 'LIST' });
		compEvent.fire();
	},
    
    handleTypeInput : function (component, event, helper) {
        var selectType = component.find('selectTypeText');
        selectType.set("v.errors", null);
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
           helper.saveCategoryToDB(component);    	
          }    
      }
      else {
            console.log('Closed');
      }
        
    }
})