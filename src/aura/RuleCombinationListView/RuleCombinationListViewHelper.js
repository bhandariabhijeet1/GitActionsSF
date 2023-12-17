({
	fetchRuleCombinationsFromDB : function(component, searchkey, isAsc, sortFieldName,filterStr) {
         component.set('v.ruleCombinationList',[]);        
           component.set('v.isLoading',true);
		 var fetchRuleCombinationsFromDB = component.get("c.fetchAllRuleCombinations");
         fetchRuleCombinationsFromDB.setParams({
               'searchKey' : searchkey,
               'isAsc' : isAsc,
               'sortFieldName' : sortFieldName,
             'isActive' : filterStr
         });
         fetchRuleCombinationsFromDB.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                 console.debug('Fetched data');
                 var ruleList = JSON.parse(response.getReturnValue());
                 if(ruleList.length == 0) {
                     component.set('v.isEmptyList',true);
                     component.set('v.ruleCombinationList',[]);
                 }
                 else {
                    component.set('v.isEmptyList',false);
                    component.set('v.ruleCombinationList',ruleList);
                     
                    console.log('Combination Builder Page:' + component.get('v.combinationBuilderPage'));
                    var combinationBuilderPage = component.get('v.combinationBuilderPage');
                    var currentSessionSelectedRules = component.get('v.currentSessionSelectedRules');
                    var currentTabSelectedRules = component.get('v.currentTabSelectedRules');
                     console.log('fetchRuleCombinationsFromDB currentTabSelectedRules' + JSON.stringify(currentTabSelectedRules));
                    console.log('fetchRuleCombinationsFromDB currentSessionSelectedRules' + JSON.stringify(currentSessionSelectedRules));
                    console.log('First Rule ' + component.get('v.firstRule'));
                    var map = component.get('v.selectedRules');
                    console.log('fetchRuleCombinationsFromDB selectedRules' + JSON.stringify(map));
                    if(map){
                        for(var i in ruleList){
                            var rule = ruleList[i];
                            var tempRule = map[rule.Rule_combination_Ext_Id__c];
                            var currentRuleIndex = -1;
                            if(currentSessionSelectedRules){
                                currentRuleIndex = currentSessionSelectedRules.indexOf(rule.Rule_combination_Ext_Id__c);
                            }
                            var currentTabRuleIndex = -1;
                            if(currentTabSelectedRules){
                                currentTabRuleIndex = currentTabSelectedRules.indexOf(rule.Rule_combination_Ext_Id__c);
                            }
                            console.log('cuurentRuleIndex ' + currentRuleIndex);
                            console.log(tempRule && (currentRuleIndex == -1 || currentTabRuleIndex > -1));
                            if(currentTabRuleIndex > -1){
                                currentRuleIndex = -1;
                            }
                            if(tempRule && currentRuleIndex == -1){
                                rule.ruledesc=tempRule.ruledesc; 
                                rule.checked=tempRule.checked;   
                                rule.operatorSelected=tempRule.operatorSelected;
                                rule.operator=tempRule.operator;
                                rule.isAnyRule=tempRule.isAnyRule;
                                rule.anyRuleOperator=tempRule.anyRuleOperator;
                                rule.anyRuleValue=tempRule.anyRuleValue;
                                
                            }else{
                                rule.ruledesc='';
                                rule.checked=false;
                                rule.operatorSelected=rule.Rule_combination_Ext_Id__c+'~none';
                                rule.operator='';
                                rule.isAnyRule='';
                                rule.anyRuleOperator='';
                                rule.anyRuleValue='';
                            }
                        }
                    }
                    component.set('v.isEmptyList',false);
                    component.set('v.ruleCombinationList',ruleList);
                    
                    var overlayRules = component.get('v.overlayRules');
                    if(overlayRules.length>0){
                		component.set("v.firstRule",overlayRules[0].ruleId);
                    }
                    else{
                		component.set("v.firstRule","");
            		}
                    
                    if(combinationBuilderPage){
                        //Highlight first rule of ANY            
                        this.highlightFirstANYRule(component, map, ruleList);
                        
                        for(var i=0;i<ruleList.length;i++){
                            var rule = ruleList[i];
                            //console.log('Rule Operator: ' + rule.operator + ' ANY Operator ' + rule.anyOperator);
                            
                            if(rule.operator=='AND'){
                                console.log('Change button color.......@@@@@@@');    
                                var btnAND = component.find("btnAND");
                                $A.util.addClass(btnAND[i], 'btnClicked');
                            }
                            if(rule.operator=='OR'){       
                                var btnOR = component.find("btnOR");
                                $A.util.addClass(btnOR[i], 'btnClicked');
                            }
                        }
                    }
                 }
                 component.set('v.isLoading',false);
               	 var hideSpinner = $A.get("e.c:HideSpinner");
            	 hideSpinner.fire();	
                 component.set('v.isShowGenericMessage',true);
             }
        });
        $A.enqueueAction(fetchRuleCombinationsFromDB);
	},
    
    sortHelper: function(component, event, sortFieldName) {
      var currentDir = component.get("v.arrowDirection");
 
      if (currentDir == 'arrowdown') {
         // set the arrowDirection attribute for conditionally rendred arrow sign  
         component.set("v.arrowDirection", 'arrowup');
         // set the isAsc flag to true for sort in Assending order.  
         component.set("v.isAsc", true);
      } else {
         component.set("v.arrowDirection", 'arrowdown');
         component.set("v.isAsc", false);
      }
      // call the onLoad function for call server side method with pass sortFieldName 
      var searchKey = component.get('v.symptomSearch');  
      var filterBy = component.get('v.selectedFilter');
	  var isAsc = component.get('v.isAsc');
         var filterStr=component.get('v.selectedFilter');
      this.fetchRuleCombinationsFromDB(component, searchKey, isAsc, sortFieldName,filterStr);
   },
   
    populateSelectedRuleMap : function(component,event,helper){
        var whichOne = event.getSource(); 
        var map = new Object();
        var temp = new Object();
        var overlayRules = new Array();
        var currentSessionSelectedRules = new Array();
        var currentTabSelectedRules = new Array();
        var ruleList = component.get('v.ruleCombinationList');
        var selectedRulesforANY = component.get('v.selectedRulesforANY');
        var previousOperator = component.get('v.previousOperator');
        map = component.get('v.selectedRules');
        overlayRules = component.get('v.overlayRules');
        currentSessionSelectedRules = component.get('v.currentSessionSelectedRules');
        currentTabSelectedRules = component.get('v.currentTabSelectedRules');
        console.log('@@OverlayRules: '+overlayRules);
        if(!overlayRules){
            overlayRules = new Array();
        }
        if(!currentSessionSelectedRules){
            currentSessionSelectedRules = new Array();
        }
        if(!currentTabSelectedRules){
            currentTabSelectedRules = new Array();
        }
        if(map){
            
        }else{
            console.log('map is null');
            var t = new Object();
            t.ruledesc='temp';
            t.checked= false;
            map={"key":t};
            component.set('v.selectedRules',map); 
        }
        map = component.get('v.selectedRules');
        var ruleText = whichOne.get('v.text');
        var ruleTextArr = ruleText.split('~'); 
        console.log('ruleText '+ ruleText);
        console.log('ruleTextArr');
        temp.ruleId =  ruleTextArr[0];
        temp.ruledesc = ruleTextArr[1];
        temp.isActive = ruleTextArr[3];
        temp.checked = whichOne.get('v.value');
        //temp.operator = previousOperator;
        var key = temp.ruledesc;
        map[temp.ruleId] = temp;
        console.log('Temp Checked ' + temp.checked);
        if(temp.checked){
            overlayRules.push(temp);
            currentSessionSelectedRules.push(ruleTextArr[0]);
            currentTabSelectedRules.push(ruleTextArr[0]);
        }
        else{
            var delIndex=-1;
            for(var i=0;i<overlayRules.length;i++){
                var temp = overlayRules[i];
                if(temp.ruleId == ruleTextArr[0] || temp.ruleId.indexOf(ruleTextArr[0]) > -1){
                    delIndex=i;
                    console.log('Del Index' + delIndex);
                }
            }
            if(delIndex!=-1){
                var lastRule = overlayRules[overlayRules.length-1];
                if(lastRule && lastRule.ruleId=='-'){
                    overlayRules.pop();                    
                }
                overlayRules.splice(delIndex,1);
                currentSessionSelectedRules.splice(delIndex,1);
                currentTabSelectedRules.splice(delIndex,1);
            }
            if(overlayRules.length>0){
                component.set("v.firstRule",overlayRules[0].ruleId);
                overlayRules[0].operator="IF";
            }else{
                component.set("v.firstRule","");
            }
        }
        console.log('Map and Temp');
        console.log(temp);
        console.log(map);       
        if(overlayRules && overlayRules.length>=1){
            var or = overlayRules[0];
            or.operator='IF';
            map[or.ruleId]=or;
            overlayRules[0]=or;
            component.set('v.firstRule',or.ruleId);
        }
        component.set('v.selectedRules',map); 
        component.set('v.overlayRules',overlayRules);
        component.set('v.currentSessionSelectedRules',currentSessionSelectedRules);
        component.set('v.currentTabSelectedRules',currentTabSelectedRules);
        console.log(whichOne.get('v.value')+' '+whichOne.get('v.text')); 
        console.log('overlayRules: '+ overlayRules);
        
        //For remove highlighting operator button 
        var index = ruleTextArr[2];
        var rule = ruleList[index];
        
        if(rule.operator=='AND'){
            var btnAND = component.find("btnAND");
            $A.util.removeClass(btnAND[index], 'btnClicked');
        }
        if(rule.operator=='OR'){
            var btnOR = component.find("btnOR");
            $A.util.removeClass(btnOR[index], 'btnClicked');
        }
        //if(rule.operator.indexOf('ANY') > -1){
        var btnANYOF = component.find("btnANYOF");
        $A.util.removeClass(btnANYOF[index], 'btnClicked');
        //}
        if(!whichOne.get('v.value')){
            rule.operator = '';   
        }
        
        var combinationConstructed = helper.parseCombinationMap(map,component);
        var cmpEvent = component.getEvent("ConstructCombination");
        console.log('Combination Created: '+ combinationConstructed);        
        cmpEvent.setParams({"ICombinationString" : combinationConstructed, "ICombinationMap":map, "ICombinationANYMap":selectedRulesforANY, "IOverlayRules":overlayRules, "IShowANYOFTable" : false, "IShowRuleListTable": true, "ICurrentSessionSelectedRules": currentSessionSelectedRules}).fire();
    },
    
    parseCombinationMap : function(map,component){
        var combinationStr = '';
        console.log('parseCombinationMap '+JSON.stringify(map));
        var anySelected = component.get("v.anySelected");
        var overlayRules = component.get("v.overlayRules");
        console.log('overlayRules pp');
        console.log(JSON.stringify(overlayRules));
        
        for(var i=0;i<overlayRules.length;i++){
            var rObj = overlayRules[i];
            var key = rObj.ruleId;
            console.log('Key: '+key);
            var ruleObj = map[key];            
            
            console.log('Rule Object to parse: ' + ruleObj);
            console.log(ruleObj);
            if(ruleObj && ruleObj.checked){
                console.log('Inside checked');
                if(i==0){
                    ruleObj.operator='IF';
                }
                console.log('ruleObj.operator: '+ruleObj.operator);
                console.log('ruleObj.endOfAny: '+ruleObj.endOfAny);
                if(ruleObj.operator!='none' && !ruleObj.endOfAny){
                    console.log('Inside one');
                    if(ruleObj.startOfAny){                        
                        combinationStr = combinationStr +' {'+ ruleObj.ruleId;
                    }else{
                        if(ruleObj.isAnyRule){
                            combinationStr = combinationStr +' '+ruleObj.operator+' {'+ruleObj.ruleId+'} '+ruleObj.anyRuleOperator+' '+ruleObj.anyRuleValue;
                        }else{
                            if(ruleObj.operator){
                                if(ruleObj.operator.indexOf('ANY') > -1){
                                    combinationStr = combinationStr +' '+ruleObj.operator.substring(0, ruleObj.operator.indexOf('ANY')) +'{'+ruleObj.ruleId+'}'+ruleObj.operator.substring(ruleObj.operator.indexOf('OF') + 2, ruleObj.operator.length);
                                }
                                else{
                                    combinationStr = combinationStr +' '+ruleObj.operator+' '+ruleObj.ruleId;
                                }
                            }
                            else{
                                combinationStr = combinationStr +' '+ruleObj.operator+' '+ruleObj.ruleId;
                            }
                        }
                    }
                }else{
                    console.log('Inside two');
                    if(ruleObj.endOfAny){
                        console.log('insdie end of any : '+ruleObj.forwardOperator);
                        if(ruleObj.forwardOperator){
                            combinationStr = combinationStr +', '+ruleObj.ruleId+'} '+ruleObj.anyOperator+' '+ruleObj.anyValue+' '+ruleObj.forwardOperator;
                        }else{
                            combinationStr = combinationStr +', '+ruleObj.ruleId+'} '+ruleObj.anyOperator+' '+ruleObj.anyValue;
                        }
                    }else{
                        if(ruleObj.anyOfMember){
                            combinationStr = combinationStr +', '+ ruleObj.ruleId;
                        }else{
                            combinationStr = combinationStr +' '+ ruleObj.ruleId;
                        }
                    }
                }
            }
        }
        /*var lastObj=map['-'];
        if(lastObj){
            overlayRules.push(lastObj);
        }*/
        component.set("v.overlayRules", overlayRules);
        return combinationStr;
    },
    
    populateOperatorInRulesMap : function(component, event, helper){
        var btnOperator = event.currentTarget;
        var txt = btnOperator.dataset.text;
        console.log('Selected Operator = '+ txt);
        var map = component.get('v.selectedRules');
        var ruleList = component.get('v.ruleCombinationList');
        var overlayRules = component.get('v.overlayRules');  
        var currentSessionSelectedRules = component.get('v.currentSessionSelectedRules');
        var currentTabSelectedRules = component.get('v.currentTabSelectedRules');
        // var previousOperator = component.get('v.previousOperator');
        if(!currentSessionSelectedRules){
            currentSessionSelectedRules = new Array();
        }
        if(!currentTabSelectedRules){
            currentTabSelectedRules = new Array();
        }
        var ruleTextArr = txt.split('~');
        var ruleId = ruleTextArr[0];
        var ruledesc = ruleTextArr[1];
        var opr = ruleTextArr[2];
        var index = ruleTextArr[3];
        if(map){
            var temp = map[ruleId];
            
            if(temp){
                temp.checked = true;
                temp.operator = opr;
                temp.operatorButton = opr;
                temp.operatorSelected = txt;
                var rulePresent = false;
                if(overlayRules){
                    for(var i=0; i<overlayRules.length; i++){
                        var tRule = overlayRules[i];
                        if(tRule && tRule.ruleId==temp.ruleId){
                            overlayRules[i] = temp;
                            rulePresent = true;
                        }
                    }
                    
                    if(!rulePresent){
    	                overlayRules.push(temp);
                        if(currentSessionSelectedRules){
        	            	currentSessionSelectedRules.push(temp.ruleId);
                        }
                        if(currentTabSelectedRules){
        	            	currentTabSelectedRules.push(temp.ruleId);
                        }
	                }
                } 
                
                if(temp.checked){                    
                    var ruleChecker = component.find("ruleChecker");
                    if(ruleChecker){
                        ruleChecker[index].set("v.value", true);
                    }
                }                 
            }
            else{
                console.log('Add unchecked Rule..');
                var tempRule = new Object();
                tempRule.ruleId =  ruleId;
                tempRule.ruledesc = ruledesc;
                tempRule.checked = true;
                tempRule.operator = opr;
                tempRule.operatorButton = opr;
                tempRule.operatorSelected = txt;
                map[tempRule.ruleId] = tempRule;
                overlayRules.push(tempRule);
                if(currentSessionSelectedRules){
                    currentSessionSelectedRules.push(ruleId);
                }
                if(currentTabSelectedRules){
                    currentTabSelectedRules.push(ruleId);
                }
                if(tempRule.checked){
                    var ruleChecker = component.find("ruleChecker");
                    if(ruleChecker){
                        ruleChecker[index].set("v.value", true);
                    }
                }
            }   
            console.log('Index ' + index);
            //For highlighting operator button 
            var rule = ruleList[index];
            if(rule){
                rule.operator = opr;   
            }
            else{
                rule.operator = '';
            }
            if(opr == 'AND'){
                var btnAND = component.find("btnAND");
                $A.util.addClass(btnAND[index], 'btnClicked');
            }
            else
            {
                var btnAND = component.find("btnAND");
                $A.util.removeClass(btnAND[index], 'btnClicked');
            }
            if(opr == 'OR'){
                var btnOR = component.find("btnOR");
                $A.util.addClass(btnOR[index], 'btnClicked');
            } 
            else{
                var btnOR = component.find("btnOR");
                $A.util.removeClass(btnOR[index], 'btnClicked');
            } 
            console.log('Rule Operator: '+ rule.operator);
            ruleList[index] = rule;
            component.set('v.ruleCombinationList', ruleList);
        }
        
        console.log('maop: '+ JSON.stringify(map));
        var selectedRulesforANY = component.get('v.selectedRulesforANY'); 
        component.set('v.overlayRules', overlayRules);
        component.set('v.currentSessionSelectedRules', currentSessionSelectedRules);
        component.set('v.currentTabSelectedRules', currentTabSelectedRules);
        var combinationConstructed = helper.parseCombinationMap(map,component);
        var cmpEvent = component.getEvent("ConstructCombination");
        console.log('Combination Created: '+ combinationConstructed);
        //component.set('v.overlayRules', overlayRules);
        cmpEvent.setParams({"ICombinationString" :combinationConstructed, "ICombinationMap":map, "ICombinationANYMap":selectedRulesforANY, "IOverlayRules":overlayRules, "IShowANYOFTable" : false, "IShowRuleListTable": true, "ICurrentSessionSelectedRules": currentSessionSelectedRules}).fire();
        component.set('v.disableCheckBoxes', false); 
    },
    
    highlightFirstANYRule : function(component, map, ruleList){        
        for(var mapRow in map){
            console.log('Map Value :');
            console.log(mapRow);
            var overlayRules = component.get('v.overlayRules');
            console.log(JSON.stringify(overlayRules));  
            var index = -1;
            for (var i = 0; i < overlayRules.length; i++) {
                console.log(overlayRules[i].ruleId);
                if (overlayRules[i].ruleId == mapRow) {
                    index = i;
                    break;
                }
            }
            var rules = mapRow.split(',');            
            console.log(rules.length);
            if(rules.length > 1){
                for(var i=0;i<ruleList.length;i++){
                    var rule = ruleList[i];
                    if(rule.Rule_combination_Ext_Id__c == rules[0]){
                        console.log(rules[0]);
                        console.log('Index of First Rule in ANY: ' + i);
                        console.log('Index of Overlay: ' + index);
                        //var tempRule = map[rule.Rule_Library_Ext_Id__c];
                        if(index > -1){
                            var ruleChecker = component.find("ruleChecker");
                            if(ruleChecker){
                                ruleChecker[i].set("v.value",true);
                            }
                            var btnANYOF = component.find("btnANYOF");
                            //console.log('ANY OF button: ' + btnANYOF);
                            if(btnANYOF){
                                $A.util.addClass(btnANYOF[i], 'btnClicked');                       
                            }
                            //break;
                        }
                        else{
                            var ruleChecker = component.find("ruleChecker");
                            if(ruleChecker){
                                ruleChecker[i].set("v.value",false);
                            }
                            var btnANYOF = component.find("btnANYOF");
                            //console.log('ANY OF button: ' + btnANYOF);
                            if(btnANYOF){
                                $A.util.removeClass(btnANYOF[i], 'btnClicked');                       
                            }
                        }
                    }
                }
            }
        }
    },
    
    populateSelectedRuleANYMapOnButton : function(component,event,helper){
        var btnOperator = event.currentTarget;
        var txt = btnOperator.dataset.text;
        var map = new Array();
        var temp = new Object();        
        map = component.get('v.selectedRulesforANYMap');
        var anyOfSelectedRules = component.get('v.anyOfSelectedRules');
        if(!anyOfSelectedRules){
            anyOfSelectedRules = new Object();
            component.set('v.anyOfSelectedRules',anyOfSelectedRules);
        }
        
        if(map){
            
        }else{
            console.log('map is null');
            var t = new Object();
            t.ruledesc='temp';
            t.checkedANY = false;
            map={"key":t};
            component.set('v.selectedRulesforANYMap', new Array()); 
        }
        map = component.get('v.selectedRulesforANYMap');        
        var ruleTextArr = txt.split('~'); 
        console.log('ruleText '+ txt);
        console.log('ruleTextArr');
        temp.ruleId =  ruleTextArr[0];
        temp.ruledesc = ruleTextArr[1];
        var index = ruleTextArr[2];
        temp.checkedANY = true;
        temp.operator = 'none';
        //temp.anyOperator = 'ANY';
        temp.operatorSelected = 'X1~none';
        if(temp.checkedANY){
            map.push(temp);
            var ruleANYChecker = component.find("ruleANYChecker");
            anyOfSelectedRules[temp.ruleId]=true;
            if(ruleANYChecker){
                ruleANYChecker[index].set("v.value", true);
            }
        }
        else{
            var delIndex=-1;
            anyOfSelectedRules[temp.ruleId]=false;
            for(var i=0;i<map.length;i++){
                var temp = map[i];
                if(temp.ruleId == ruleTextArr[0]){
                    delIndex=i;
                    console.log('Del Index' + delIndex);
                }
            }
            if(delIndex!=-1){                
                map.splice(delIndex,1);
            }
        }
        
        
        component.set('v.selectedRulesforANYMap',map);      
        component.set('v.anyOfSelectedRules',anyOfSelectedRules);
        
        var mapRules = component.get("v.selectedRules");
        
        var overlayRules = component.get('v.overlayRules');
        var cmpEvent = component.getEvent("ConstructANYList");
        console.log('aa combinationANYList$$$$$$$$$$');
        console.log(map);
        cmpEvent.setParams({"ICombinationMap": mapRules, "ICombinationANYList": map, "IOverlayRules": overlayRules, "IShowANYOFTable" : true, "IShowRuleListTable": false}).fire();		
    },
    
    populateSelectedRuleANYMap : function(component,event,helper){
        var whichOne = event.getSource(); 
        var map = new Array();
        var temp = new Object();        
        map = component.get('v.selectedRulesforANYMap');
        var anyOfSelectedRules = component.get('v.anyOfSelectedRules');
        if(!anyOfSelectedRules){
            component.set('v.anyOfSelectedRules',new Object());
        }
        if(map){
            
        }else{
            console.log('map is null');
            var t = new Object();
            t.ruledesc='temp';
            t.checkedANY = false;
            map={"key":t};
            component.set('v.selectedRulesforANYMap', new Array()); 
        }
        map = component.get('v.selectedRulesforANYMap');
        var ruleText = whichOne.get('v.text');
        var ruleTextArr = ruleText.split('~'); 
        console.log('ruleText '+ruleText);
        console.log('ruleTextArr');
        temp.ruleId =  ruleTextArr[0];
        temp.ruledesc = ruleTextArr[1];
        var index = ruleTextArr[2];
        temp.checkedANY = whichOne.get('v.value');        
        temp.operator = 'none';
        //temp.anyOperator = 'ANY';
        temp.operatorSelected = 'X1~none';
        if(temp.checkedANY){
            anyOfSelectedRules[temp.ruleId]=true;
            map.push(temp);
        }
        else{
            anyOfSelectedRules[temp.ruleId]=true;
            var delIndex=-1;
            for(var i=0;i<map.length;i++){
                var temp = map[i];
                if(temp.ruleId == ruleTextArr[0]){
                    delIndex=i;
                    console.log('Del Index' + delIndex);
                }
            }
            if(delIndex!=-1){                
                map.splice(delIndex,1);
            }
        }
        component.set('v.selectedRulesforANYMap',map); 
        component.set('v.anyOfSelectedRules',anyOfSelectedRules);
        
        console.log(whichOne.get('v.value')+' '+whichOne.get('v.text'));  
        
        var mapRules = component.get("v.selectedRules");
        var overlayRules = component.get('v.overlayRules');
        var cmpEvent = component.getEvent("ConstructANYList");
        console.log('bb combinationANYList$$$$$$$$$$');
        console.log(map);
        cmpEvent.setParams({"ICombinationMap": mapRules, "ICombinationANYList": map, "IOverlayRules": overlayRules, "IShowANYOFTable" : true, "IShowRuleListTable": false}).fire();		
    },
    
    removeSelectedRuleById : function(component, helper, ruleId){
        console.log('Rule COmb Id to be removed: '+ruleId);        
        var map = component.get("v.selectedRules");
        console.log(map);
        if(map){
            var tempObj = map[ruleId];
            var overlayRules = new Array();
            var isAnyRuleFlag = false;
            var delIndex = -1;
            if(tempObj){
                if(tempObj.startOfAny||tempObj.endOfAny||tempObj.anyOfMember){
                    console.log('tempObj: ');
                    console.log(JSON.stringify(tempObj));
                    console.log('Map Before: '+JSON.stringify(map));
                    helper.reconstuctAnyOfExpression(map,ruleId);
                    console.log('Map After: '+JSON.stringify(map));
                }
                tempObj.checked=false;
                tempObj.operatorSelected='X1~none';
                tempObj.operator='none';
                overlayRules = component.get('v.overlayRules');
                for(var i=0;i<overlayRules.length;i++){
                    var rTemp = overlayRules[i];
                    if(rTemp && rTemp.ruleId==ruleId){
                        if(i==0){
                            var rNext = overlayRules[1];
                            if(rNext){
                                rNext.operator='IF';
                                var mNext = map[rNext.ruleId];
                                if(mNext){
                                    mNext.operator='IF';
                                    map[rNext.ruleId] = mNext;
                                }
                            }
                        }
                        if(overlayRules.length>0){
                            component.set("v.firstRule",overlayRules[0].ruleId);
                            overlayRules[0].operator="IF";
                        }else{
                            component.set("v.firstRule","");
                        }
                        overlayRules.splice(i,1);
                        delIndex = i;
                    }
                }
                component.set('v.overlayRules',overlayRules);
            }
            for(var i=0;i<map.length;i++){
                var rTemp = map[i];
                console.log('ANY OF Rules :' + rTemp.ruleId );
                if(rTemp && rTemp.operator.indexOf('ANY')){   
                    rTemp.isAnyRule = true;
                    isAnyRuleFlag = true;
                }
            }
            component.set("v.selectedRules",map);
            var checkBox = component.find("ruleChecker");
            var dropDown = component.find("ruleSelector");
            for(var i in checkBox){
                var v1 = checkBox[i].get("v.text");
                var sr = v1.indexOf(ruleId);
                if(sr >= 0){
                    console.log('Selected V1 '+v1);
                    checkBox[i].set("v.value",false);
                }
            }
            for(var i in dropDown){
                var v1 = dropDown[i].get("v.value");
                var sr = v1.indexOf(ruleId);
                if(sr >= 0){
                    console.log('Selected V1 '+v1);
                    dropDown[i].set("v.value",'X1~none');
                }
            }
            console.log('Map after delete');
            console.log(map);
            var combinationConstructed = helper.parseCombinationMap(map,component);
            var cmpEvent = component.getEvent("ConstructCombination");
            console.log('Combination Created: '+combinationConstructed);
            var showAnyOverlay = component.get("v.combinationBuilderPageANY");
            if(!showAnyOverlay){
                showAnyOverlay=false;
            }
            helper.refreshRuleListHelper(component, helper, isAnyRuleFlag);
            cmpEvent.setParams({"ICombinationString" : combinationConstructed, "ICombinationMap":map, "IOverlayRules":overlayRules, "IShowANYOFTable" : showAnyOverlay, "IShowRuleListTable": true}).fire();
        }
    },
    
    refreshRuleListHelper : function(component, helper, isAnyRuleFlag){
        var ruleList = component.get("v.ruleCombinationList");
        console.log('Inside refreshreule list: '+ruleList.length);
        var map = component.get("v.selectedRules");
        var isRuleCheckedInOverlay = false;
        if(map){
            for(var i=0;i<ruleList.length;i++){
                //console.log('Refresh Index :' + i);
                var rule = ruleList[i];
                var tempObj = map[rule.Rule_combination_Ext_Id__c];
                //console.log('Rule Operator: ' + rule.operator + ' ANY Operator ' + rule.anyOperator);
                
                if(tempObj && tempObj.checked){
                    //console.log('Temp Obj Checked: ' + tempObj.checked + ' ANY Checked ' + tempObj.checkedANY);
                    isRuleCheckedInOverlay=true;
                }else{
                    isRuleCheckedInOverlay=false;
                }
                if(rule.operator=='AND'){
                    console.log('Change button color.......@@@@@@@');
                    var btnAND = component.find("btnAND");                    
                    //console.log('AND button: ' + btnAND);
                    if(btnAND){
                        if(isRuleCheckedInOverlay){
                            $A.util.addClass(btnAND[i], 'btnClicked');
                        }else{
                            $A.util.removeClass(btnAND[i], 'btnClicked');
                        }
                    }
                }
                if(rule.operator=='OR'){
                    var btnOR = component.find("btnOR");
                    //console.log('OR button: ' + btnOR);
                    if(btnOR){
                        if(isRuleCheckedInOverlay){
                            $A.util.addClass(btnOR[i], 'btnClicked');
                        }else{
                            $A.util.removeClass(btnOR[i], 'btnClicked');
                        }
                    }
                }
                
                if(!isRuleCheckedInOverlay){
                	var ruleChecker = component.find("ruleChecker");
                	if(ruleChecker){
	                    ruleChecker[i].set("v.value",false);
    	            }  
                }
                
                if(isAnyRuleFlag){
                	//To remove rules selection on Cancel
                	var ruleANYChecker = component.find("ruleANYChecker");
                	if(ruleANYChecker){
	                    ruleANYChecker[i].set("v.value",false);
    	            }                
                }
            }
            
            //Highlight first rule of ANY            
            this.highlightFirstANYRule(component, map, ruleList);
        }
        
        var combinationConstructed = helper.parseCombinationMap(map,component);
        var cmpEvent = component.getEvent("ConstructCombination");
        console.log('Combination Created: '+ combinationConstructed);
        var overlayRules = component.get('v.overlayRules');
        var currentSessionSelectedRules = component.get('v.currentSessionSelectedRules');
        cmpEvent.setParams({"ICombinationString" :combinationConstructed, "ICombinationMap":map, "IOverlayRules":overlayRules, "IShowANYOFTable" : false, "IShowRuleListTable": false, "IShowRuleCombListTable": true, "ICurrentSessionSelectedRules": currentSessionSelectedRules}).fire();        		
    },
})