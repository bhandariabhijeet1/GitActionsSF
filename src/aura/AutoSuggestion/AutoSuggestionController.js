({
	ClickFunc : function(component, event, helper) {
		var handle = event.currentTarget;
        var ISymtom = handle.dataset.symptom;
     	var cmpEvent = component.getEvent("AutosuggestionEvent");
       console.log('Auto ISymtom: '+ISymtom);
        console.log('index'+component.get('v.listIndex'));
        cmpEvent.setParams({'ISymtom' : ISymtom, 'listIndex': component.get('v.listIndex')}).fire();
	},
    
})