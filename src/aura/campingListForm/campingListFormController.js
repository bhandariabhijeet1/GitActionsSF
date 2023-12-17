({
	clickCreateItem : function(component, event, helper) {
		console.log('here 1...');
        var validExpense = component.find('campingItemForm').reduce(function (validSoFar, inputCmp) {
            // Displays error messages for invalid fields
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        // If we pass error checking, do some real work
        if(validExpense){
           helper.createItem(component, event);
        }
	}
})