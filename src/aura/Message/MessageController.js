({
    InfoClose : function(component, event, helper) {
        component.set("v.ShowInfo",false);	
        component.set("v.MessageShowFlag",false);
    },
    ErrorClose:function(component, event, helper) {
        component.set("v.Showerror",false);	
        component.set("v.MessageShowFlag",false);
    },
    WarningClose:function(component, event, helper) {
        component.set("v.Showwarning",false);
        component.set("v.MessageShowFlag",false);
    },
})