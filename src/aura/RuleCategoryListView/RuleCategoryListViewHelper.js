({
	fetchCategoriesFromDB : function(component) {
         var fetchCategoriesFromDB = component.get("c.fetchAllCategories");
		 fetchCategoriesFromDB.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var categoryList = JSON.parse(response.getReturnValue()); 
                component.set('v.categoryList',categoryList);
               //  this.showAuraElement(component,'catListTable');
                
             }
        });
        $A.enqueueAction(fetchCategoriesFromDB);
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
})