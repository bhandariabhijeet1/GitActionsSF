({
	openDialogBox : function(component, event, helper) {
        console.log(event);
        var message = event.getParam("Message");
        component.set('v.message',message);
        console.log(message);
        var isConfirmation = event.getParam("isConfirmation");
        component.set('v.isConfirmation',isConfirmation);
        
        component.set('v.isShow',true);
        var ACTION = event.getParam("ACTION");
        console.log(ACTION);
        component.set('v.action',ACTION);
        
	},
    
    okClicked : function(component, event, helper) {
        component.set('v.isShow',false);
        var hideGenericMessage = component.getEvent("hideGenericMessage");
		hideGenericMessage.setParams({"isConfirm" : true, "ACTION" : component.get('v.action') });
        hideGenericMessage.fire();
    },
    
    yesClicked : function(component, event, helper) {
        component.set('v.isShow',false);
        var hideGenericMessage = component.getEvent("hideGenericMessage");
		hideGenericMessage.setParams({"isConfirm" : true, "ACTION" : component.get('v.action') });
        hideGenericMessage.fire();
    },
    
    noClicked : function(component, event, helper) {
        component.set('v.isShow',false);
        var hideGenericMessage = component.getEvent("hideGenericMessage");
		hideGenericMessage.setParams({"isConfirm" : false, "ACTION" : component.get('v.action') });
        hideGenericMessage.fire();
    },
    
    closeOverlay : function (component, event, helper) {
        component.set('v.isShow',false);
        var isConfirm = component.get('v.isConfirmation');
        var hideGenericMessage = component.getEvent("hideGenericMessage");
		hideGenericMessage.setParams({"isConfirm" : false, "ACTION" : component.get('v.action') });
        hideGenericMessage.fire();
    },
    
    
})