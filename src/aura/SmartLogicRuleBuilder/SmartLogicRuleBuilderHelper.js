({
	hideAuraElement : function(component, auraId) {
          var elementToHide = component.find(auraId);
          $A.util.removeClass(elementToHide, 'slds-show');
          $A.util.addClass(elementToHide, 'slds-hide');
         console.log('In hide'+auraId);
	},
    
    showAuraElement : function(component,auraId) {
          var elementToShow = component.find(auraId);
          $A.util.removeClass(elementToShow, 'slds-hide');
          $A.util.addClass(elementToShow, 'slds-show');
        console.log('In show '+auraId);
    }
})