({
	doInit : function(component, event, helper) {
		helper.fetchAccounts(component, 'c.fetchAccounts', 'handleFetchAccount');
	}
})