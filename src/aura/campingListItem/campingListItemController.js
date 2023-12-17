({
    doInit:function(component, event, helper){
        var item = new Object;
        item.Packed__c= false;
        item.Name = 'Test Account';
        item.Price__c = 243;
        item.Quantity__c = 20;
        component.set("v.item",item);
    },
    
    packItem : function(component, event, helper) {
        var item = new Object;
        item.Packed__c= true;
        item.Name = 'Test Account';
        item.Price__c = 243;
        item.Quantity__c = 20;
        component.set("v.item", item);
        var clickedButton = event.getSource();
        clickedButton.set("v.disabled",true);
	}
})