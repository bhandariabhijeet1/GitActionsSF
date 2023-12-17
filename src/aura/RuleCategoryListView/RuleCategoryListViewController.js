({
	
   doInit : function(component, event, helper) {
      	helper.fetchCategoriesFromDB(component);        
    },
    
    viewCategory : function(component, event, helper) {
		var catClicked = event.currentTarget;
        console.log(catClicked);
        var dataset = catClicked.dataset;
        var category={};
        category.Rule_Type__c = dataset.cattype;
        category.Rule_Category__c = dataset.category;
        category.Id = dataset.catid;
        var compEvent = component.getEvent("RuleCategoryActionEvent");
        compEvent.setParams({"ACTION" : 'View' });
        //compEvent.setParams({"CATEGORY-TYPE" : category.cattype});
        compEvent.setParams({"CATEGORY" : category });
		compEvent.fire();  
	},
 
})