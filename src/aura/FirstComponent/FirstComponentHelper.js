({
	fetchAccounts : function(component, functionName, callBackFunctionName) {
		var action = component.get(functionName);
	    action.setCallback(this, response => this.handleFetchAccount(action, component, response));
	    $A.enqueueAction(action);
	},
	
	handleFetchAccount: function(action, component, response) {
    	var state = response.getState();
    	var resultsToast = $A.get("e.force:showToast");
    	if (state === "SUCCESS")
    	{
    		component.set('v.lstAccounts', response.getReturnValue());
    		//component.set('v.Message', 'Data Fetched Successfully');
    		resultsToast.setParams({
	            "title": "Accounts Fetched",
	            "message": "Accounts Fetched Successfully"
	        });
	        resultsToast.fire();
    	}
    	else if(state === "ERROR")
    	{
    		var errors = action.getError();
    		if(errors && errors[0] && errors[0].message)
    		{
    			resultsToast.setParams({
		            "title": "Accounts Fetch failed",
		            "message": "Account fetching failed due to unknown error"
		        });
		        resultsToast.fire();
    			//component.set('v.Message', errors[0].message);
    		}
    	}
    	console.log(component.get('v.Message'));
    }
})