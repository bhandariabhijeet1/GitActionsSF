({
	doInit : function(component, event, helper){ 
        console.log('Combination Builder doInit Called');
        // Create the action
        var action = component.get("c.getItems");
    
        // Add callback behavior for when response is received
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.items", response.getReturnValue());
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
    
        // Send action off to be executed
        $A.enqueueAction(action);
    },
    
    handleAddItem : function(component, event, helper){
        console.log('Here 2');
        var newCampingItem = event.getParam("item");
        console.log("Create Camping Item: " + JSON.stringify(newCampingItem));
        //helper.saveItem(component,newCampingItem);
        var action = component.get("c.saveItem");
        action.setParams({
            "item": newCampingItem
        });
        action.setCallback(this, function(response){
            console.log('======Rsponse=======');
            console.log(response);
            var state = response.getState();
            if (state === "SUCCESS") {
                var items = component.get("v.items");
                items.push(response.getReturnValue());
                component.set("v.items", items);
            }
        });
        $A.enqueueAction(action);
    }
})