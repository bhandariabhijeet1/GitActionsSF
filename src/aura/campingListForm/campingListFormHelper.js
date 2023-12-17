({
	createItem : function(component, event) {
		var item = component.get("v.newItem");
        var updateEvent = component.getEvent("addItem");
        updateEvent.setParams({ "item": item });
        updateEvent.fire(); 
        console.log('=====Fire======');
        component.set("v.newItem", {'sobjectType':'Camping_Item__c'});
	}
})