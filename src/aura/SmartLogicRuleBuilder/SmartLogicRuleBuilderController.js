({
	 switchTab : function(component, event, helper) {
     var clickedTabName =   event.currentTarget.dataset.tab;
    
     component.set('v.isRuleCategoryViewPage',false);
     component.set('v.isShowNewCategoryPage',false);   
     component.set('v.isShowRuleTester',false);   
     component.set('v.isShowRulePage',false);
     component.set('v.isShowCombinationPage',false);
     component.set('v.ruleId','');
     
     for(var i=1;i <= 4; i++) {
         var tabName = component.find('tab-item-'+i);
         var tabContent = component.find('tab-content-'+i);
         if(clickedTabName == i) { //make active
              $A.util.addClass(tabName, 'slds-active');
              helper.showAuraElement(component,'tab-content-'+i);
              if(i==1) {
                 helper.showAuraElement(component,'ruleList');  
                 component.set('v.isShowRulePage',false);
                 component.set('v.isShowRuleTester',false);     
                 component.set('v.mode',''); 
                 component.set('v.isShowRuleViewPage',false); 
                 var compEvent = $A.get("e.c:RuleListEvents");
        		 compEvent.setParams({"eventType" : 'Refresh'});
            	 component.set('v.mode','');
                 compEvent.fire();          
                  
              }
              if(i==2) {
                  helper.showAuraElement(component,'ruleCombinationList');  
                  component.set('v.isShowCombinationPage',false);
              	  component.set('v.isShowRuleTester',false);    
                  component.set('v.mode',''); 
                  component.set('v.isShowRuleViewPage',false); 
                  var compEvent = $A.get("e.c:RuleListEvents");
        		  compEvent.setParams({"eventType" : 'RefreshCombinationList'});
                  compEvent.fire();          
              }
              if(i==3) {
                 component.set('v.isRuleCategoryViewPage',false);
                 component.set('v.isShowNewCategoryPage',false);   
                 component.set('v.isShowRuleTester',false);    
              }
             if(i==4) {
                 helper.showAuraElement(component,'tab-content-'+i);  
                 component.set('v.isShowRuleTester',true);    
                 
              }
         }
         else {
               helper.hideAuraElement(component,'tab-content-'+i);
               $A.util.removeClass(tabName, 'slds-active');  
         }
     }        
    },
    
    openNewRulePage : function(component, event, helper) {
        helper.hideAuraElement(component, 'ruleList');
        component.set('v.isShowRulePage',true);
        component.set('v.mode','');
        helper.showAuraElement(component, 'newRuleSection');
    },
    
    doInit : function(component, event, helper) {
     var action = component.get("c.getAllConfigurations");
         action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                 var allConfigs = response.getReturnValue(); 
                 component.set("v.userName", allConfigs.User_Name);
                 component.set("v.CodeSearchLink", allConfigs.Code_Search_URL);
                 component.set("v.homeURL", allConfigs.home_URL);
                 component.set("v.logoutURL", allConfigs.logout_URL);
               }
        });
        document.title = $A.get('$Label.c.Rule_Builder');
        $A.enqueueAction(action);
    },
    
    handleRuleEvents : function(component, event, helper) {
        console.log('------------handleRuleEvents---------------------------');
        var allParams = event.getParams();
        component.set('v.isShowRuleViewPage',false);
        component.set('v.isShowCombinationViewPage',false);
        component.set('v.isShowRulePage',false);
        component.set('v.mode',allParams.ACTION);
        console.log('ACTION--------------------'+allParams.ACTION);
        if(allParams.ACTION == 'Refresh') {
      		var preAction = allParams.preAction;
          
        	//fire listaction event to refresh list
            helper.showAuraElement(component,'ruleList');    
          	var compEvent = $A.get("e.c:RuleListEvents");
            compEvent.setParams({"eventType" : 'Refresh', 'preAction':allParams.preAction});
            component.set('v.mode','');
            compEvent.fire();            
        }
        else if(allParams.ACTION == 'Edit') {
            component.set('v.ruleId',allParams.RULEID);
            if(allParams.ISRULE) {
                component.set('v.isShowRulePage',true);
            	helper.showAuraElement(component,'newRuleSection');
            	helper.hideAuraElement(component,'ruleList');
            }
            else{                
        		component.set('v.isShowCombinationPage',true);
        		helper.showAuraElement(component, 'newCombinationSection');
        		helper.hideAuraElement(component, 'ruleCombinationList');
            }
        }
         else if(allParams.ACTION == 'Clone') {
            component.set('v.ruleId',allParams.RULEID);
            if(allParams.ISRULE){
            	component.set('v.isShowRulePage',true);
            	helper.showAuraElement(component,'newRuleSection');
            	helper.hideAuraElement(component,'ruleList');
            }
            else{                
        		component.set('v.isShowCombinationPage',true);
        		helper.showAuraElement(component, 'newCombinationSection');
        		helper.hideAuraElement(component, 'ruleCombinationList');
            }
        }
        else if(allParams.ACTION == 'View') {
            component.set('v.ruleId',allParams.RULEID);
            console.log('ISRULE ' + allParams.ISRULE);
            if(allParams.ISRULE){
           		helper.hideAuraElement(component,'ruleList');
            	helper.showAuraElement(component,'newRuleSection');
            	component.set('v.isShowRuleViewPage',true);
            }
            else{                
        		component.set('v.isShowCombinationPage',false);
                component.set('v.isShowCombinationViewPage',true);
        		helper.showAuraElement(component, 'newCombinationSection');
        		helper.hideAuraElement(component, 'ruleCombinationList');
            }
        }        
        else if(allParams.ACTION == 'RefreshCombinationList') {
          	//fire listaction event to refresh list    
          	console.log('hadling event refresh..');     	
            component.set('v.mode','');
            helper.showAuraElement(component,'ruleCombinationList');
            helper.hideAuraElement(component, 'newCombinationSection');             
            var compEvent = $A.get("e.c:RuleListEvents");
        	compEvent.setParams({"eventType" : 'RefreshCombinationList','preAction':allParams.preAction});
			compEvent.fire();
        }
        else if(allParams.ACTION == 'Test') {
         	component.set('v.ruleId',allParams.RULEID);
            component.set('v.isRule',allParams.ISRULE);
            component.set('v.isShowRuleTester',true);
        	helper.showAuraElement(component, 'ruleTesterSection');
            var tabName = component.find('tab-item-'+4);
            helper.showAuraElement(component,'tab-content-4');
            $A.util.addClass(tabName, 'slds-active');  
            for(var i=1;i<4;i++){
       	       var tabName = component.find('tab-item-'+i);
               $A.util.removeClass(tabName, 'slds-active');  
            }
            if(allParams.ISRULE){
           		helper.hideAuraElement(component,'ruleList');            	
            }
            else{ 
        		helper.hideAuraElement(component, 'ruleCombinationList');
            }
        }
        else if(allParams.ACTION == 'LIST'){
            component.set('v.isRuleCategoryViewPage', false);  
           	component.set('v.isShowNewCategoryPage', false);
            component.set('v.isShowEditCategoryPage', false);  
            component.set('v.mode','view'); 
        }
     },
    
    handleCategoryEvents : function(component, event, helper) {
      var allParams = event.getParams();
      console.log('Caught category event---------------');    
      component.set('v.ruleCategory', '');  
      component.set('v.mode','');
      console.log(allParams);
      if(allParams.ACTION == 'View'){
        component.set('v.ruleCategory', allParams.CATEGORY);
      	component.set('v.isRuleCategoryViewPage', true);  
      }
     else if(allParams.ACTION == 'LIST'){
       	component.set('v.isRuleCategoryViewPage', false);  
       	component.set('v.isShowNewCategoryPage', false);
        component.set('v.isShowEditCategoryPage', false);  
        component.set('v.mode','view'); 
         
      }  
      else if(allParams.ACTION == 'Edit'){
        component.set('v.mode','edit');
        component.set('v.ruleCategory', allParams.CATEGORY);
      	component.set('v.isShowNewCategoryPage', false); 
        component.set('v.isShowEditCategoryPage', true); 
        component.set('v.isRuleCategoryViewPage', false);  
         
      }  
    },
    
    openNewCombinationPage : function(component, event, helper) {
        component.set('v.mode','');
        helper.hideAuraElement(component, 'ruleCombinationList');
        component.set('v.isShowCombinationPage',true);
        component.set('v.isShowCombinationViewPage',false);
        helper.showAuraElement(component, 'newCombinationSection');
        var compEvent = $A.get("e.c:RuleListEvents");
       	compEvent.setParams({"eventType" : 'Refresh'});
		compEvent.fire();
    },
    
    openNewCategoryPage : function(component, event, helper) {
        component.set('v.isShowNewCategoryPage',true);
        component.set('v.isShowEditCategoryPage',false);
        component.set('v.isRuleCategoryViewPage', false);  
        helper.hideAuraElement(component, 'ruleCombinationList');
        helper.showAuraElement(component, 'newCategorySection');        
    },
})