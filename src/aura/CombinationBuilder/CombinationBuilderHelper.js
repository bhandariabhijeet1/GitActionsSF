({
    validateForm : function(component){
        var ruleTest = component.get('v.newRuleCombination');
        var CombinationText = component.find("CombinationText");
        var valueCombination = CombinationText.get("v.value");
        var CombinationDesc = component.find("CombinationDesc");
        var valueCombinationDesc = CombinationDesc.get("v.value");
        var ICDText = component.find("ICDText");
        var valueICD = ICDText.get("v.value");
        var ICDDescText = component.find("ICDDescText");
        var valueICDDesc = ICDDescText.get("v.value");
        var validForm = true;
        var validRuleCombination = true;
        CombinationText.set("v.errors", null);
        ICDText.set("v.errors", null);
        ICDDescText.set("v.errors", null);
        validRuleCombination = this.validateRuleCombination(valueCombination);
        if (valueCombination == '' || valueCombination == null) {
            CombinationText.set("v.errors", [{message:"Enter valid Rule Combination!"}]);
            validForm = false;
        }
        if (valueCombinationDesc == '' || valueCombinationDesc == null) {                
            validForm = false;
        }
        if (valueICD == '' || valueICD == null) {
            ICDText.set("v.errors", [{message:"Enter valid ICD!"}]);
            validForm = false;
        }
        if (valueICDDesc == '' || valueICDDesc == null) {
            ICDDescText.set("v.errors", [{message:"Enter valid ICD Description!"}]);
            validForm = false;
        }
        if(!validRuleCombination){
            CombinationText.set("v.errors", [{message:"Please check for right parenthesis in Rule Combination!"}]);
            validForm = false;
        }
        var validateAnyEx = this.validateAnyOfExpression(valueCombination);
        if(!validateAnyEx){
            CombinationText.set("v.errors", [{message:"Any Of Expression should end with operator and integer value {R1,R2}>=3 "}]);
            validForm = false;
        }
        console.log('validForm: '+ validForm);
        return validForm;
    },
    
    saveRuleCombinationtoDB : function(component,ruleCombination) {  
        console.log('Helper Method Save Rule Combination to DB');
        var saveAction;
        var mode = component.get('v.mode');        
        ruleCombination.Rule_Combination__c = ruleCombination.Rule_Combination__c.replace('IF ', '');
        ruleCombination.Rule_Combination_With_Exp__c = ruleCombination.Rule_Combination_With_Exp__c.replace('IF ', '');
        ruleCombination.Rule_Combination_Description__c = ruleCombination.Rule_Combination_Description__c.replace('IF ', '');
        if(mode == 'Edit') {
            saveAction = component.get("c.editRuleCombination");
        }
        else if(mode == 'Clone') {
            saveAction = component.get("c.cloneRuleCombination");
        }
            else {
                saveAction = component.get("c.saveRuleCombinationtoDB");
            }
        saveAction.setParams({
            'ruleCombination': JSON.stringify(ruleCombination)
        });
        saveAction.setCallback(this, function(response){
            var state = response.getState();            
            console.log(response.getReturnValue());
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                console.log(returnValue);  
                if(returnValue == 'SUCCESS') {
                    var action;// = 'CombinationBuilder_Saved'; 
                    if(mode == 'Edit') {
                        action = 'CombinationBuilder_Edited';
                    }else if(mode == 'Clone') {
                        action = 'CombinationBuilder_Cloned';
                    }
                    this.resetFields(component);
                    var compEvent = component.getEvent("RuleActionEvent");                   
                    compEvent.setParams({"ACTION" : 'RefreshCombinationList','preAction' : action });
                    compEvent.fire();
                }                
                else if(returnValue == 'COMBINATION_TOO_LONG'){
                    var message = $A.get("$Label.c.CombinationBuilder_CombTooLong"); 
                    this.showGenericMessage(component, false, message, 'TOOLONG');
                }
                else if(returnValue == 'DUPLICATE_RULE_COMBINATION'){
                    var message = $A.get("$Label.c.CombinationBuilder_CombSaveDuplicate"); 
                    this.showGenericMessage(component, false, message, 'DUPLICATE');
                }
                    else {
                        var message = $A.get("$Label.c.CombinationBuilder_CombSaveError"); 
                        this.showGenericMessage(component, false, message, 'ERROR');
                    }            
            }           
        });
        $A.enqueueAction(saveAction);
    },
    
    populateCombinationString : function(component,ruleCombination) { 
        console.log('Helper method to get Combination String');
        console.log('$$Rule Combi:' + ruleCombination);
        var CombinationText = component.find("CombinationText");        	
        CombinationText.set("v.errors", [{message:""}]);
        if(ruleCombination.indexOf('IF')>-1){
            ruleCombination = ruleCombination.replace('IF ', '');
        }
        if(ruleCombination){
            var getDescAction = component.get("c.getCombinationString");
            getDescAction.setParams({
                'ruleCombination': ruleCombination
            });
            getDescAction.setCallback(this, function(response){
                var state = response.getState();
                console.log('$$State:' + state);
                if (state === "SUCCESS") {
                    
                    var returnValue = JSON.parse(response.getReturnValue());
                    console.log(returnValue);
                    var ruleIdList = [];
                    var ruleDescList = [];
                    for(var key in returnValue) {
                        ruleIdList.push(key);
                        ruleDescList.push(returnValue[key]);                        
                    }
                    console.log('Rule Desc List@@@ :' + ruleDescList);
                    console.log('Rule Id :' + ruleIdList);  
                    if(ruleDescList != "" || ruleDescList != null){
                        ruleDescList[0] = "IF " + ruleDescList[0];
                        CombinationText.set("v.value", ruleDescList[0]);
                        component.set("v.ruleIdList", ruleIdList);
                        component.set("v.ruleDescList", ruleDescList);
                    }
                    else{
                        CombinationText.set("v.errors", [{message:"Please check all the Rules entered are valid and Rule Combination is in proper format!"}]);
                        CombinationDesc.set("v.value", '');
                    }
                } 
                else{
                    CombinationText.set("v.errors", [{message:"Please check all the Rules entered are valid and Rule Combination is in proper format!"}]);                   
                }
            });
            $A.enqueueAction(getDescAction);
        }
    },
    
    populateCombinationDescription : function(component,ruleCombination) {  
        component.set("v.srcIndex","-1");
        component.set("v.desIndex","-1");
        
        console.log('Helper method to get Combination Description');
        console.log('$$Rule Combi:' + ruleCombination);
        var CombinationText = component.find("CombinationText");        	
        CombinationText.set("v.errors", [{message:""}]);
        var CombinationDesc = component.find("CombinationDesc");
        
        if(ruleCombination.indexOf('IF')>-1){
            ruleCombination = ruleCombination.replace('IF ', '');
        }
        if(ruleCombination){
            var getDescAction = component.get("c.getCombinationDescription");
            getDescAction.setParams({
                'ruleCombination': ruleCombination
            });
            getDescAction.setCallback(this, function(response){
                var state = response.getState();
                var CombinationDesc = component.find("CombinationDesc");  
                console.log('$$State:' + state);
                if (state === "SUCCESS") {
                    var returnValue = JSON.parse(response.getReturnValue());
                    var combDesc = [];
                    var descList = [];
                    for(var key in returnValue) {
                        var ruleId = key;
                        if(key.indexOf('_DUP') > -1){
                            ruleId = key.substring(0, key.indexOf('_DUP'));
                        }
                        combDesc.push(ruleId);
                        descList.push(returnValue[key]);
                        console.log('Combination List@@@ :' + descList);
                    }
                    console.log('Combination :' + combDesc);  
                    if(descList != "" || descList != null){
                        descList[0] = "IF " + descList[0];
                        CombinationDesc.set("v.value", descList[0]);
                        if(descList.length > 1){
                            descList.splice(0,1);                            
                        }
                        component.set("v.selectedRuleDesc", descList.reverse());
                        console.log('Combination List*** :' + descList);
                        //if(!component.get("v.selectedRules")){
                        this.populateSelectedRuleList(component);
                        //}
                    }
                    else{
                        CombinationText.set("v.errors", [{message:"Please check all the Rules entered are valid and Rule Combination is in proper format!"}]);
                        CombinationDesc.set("v.value", '');
                    }
                } 
                else{
                    CombinationText.set("v.errors", [{message:"Please check all the Rules entered are valid and Rule Combination is in proper format!"}]);
                    CombinationDesc.set("v.value", '');
                }
            });
            $A.enqueueAction(getDescAction);
        }
    },
    
    validateRuleCombination : function(ruleCombination) {
        var depthR = 0;
        var depthS = 0;
        var depthC = 0;
        console.log('------------------------------');
        for(var i in ruleCombination){   
            if(ruleCombination[i] == '('){
                depthR ++;
            } 
            else if(ruleCombination[i] == ')') {
                depthR --;
            }
            if(ruleCombination[i] == '['){
                depthS ++;
            } 
            else if(ruleCombination[i] == ']') {
                depthS --;
            }
            if(ruleCombination[i] == '{'){
                depthC ++;
            } 
            else if(ruleCombination[i] == '}') {
                depthC --;
            } 
            if (depthR < 0 || depthS < 0 || depthC < 0) return false;
        }
        if(depthR > 0 || depthS > 0 || depthC > 0) return false;
        // OK !
        return true;
    },
    
    refreshFormFields : function(component){
        console.log('Inside Refresh form fields');
        component.set('v.newRuleCombination', {'sobjectType': 'Rule_Combination__c'});
        component.set('v.newRuleCombination.Is_Active__c', false);
        component.set('v.newRuleCombination.Gender__c', 'U');
        component.set('v.ruleCombinationWithExp', '');
        component.set('v.selectedRules', new Array());
        component.set('v.selectedRulesforANY', new Array());
        component.set('v.selectedRulesforANYMap', new Array());
        this.hideAuraElement(component, 'SelectedRuleList');
        var CombinationText = component.find("CombinationText");
        var cachedRule = component.get('v.cachedRuleCombination');
        CombinationText.set("v.value", "IF ");
        console.log('cachedRule: '+cachedRule);
        CombinationText.set("v.errors", [{message:""}]);
        var CombinationDesc = component.find("CombinationDesc");
        CombinationDesc.set("v.value", "");
        CombinationDesc.set("v.errors", [{message:""}]);
        var ICDText = component.find("ICDText");
        ICDText.set("v.value", "");
        ICDText.set("v.errors", [{message:""}]);
        var ICDDescText = component.find("ICDDescText");
        ICDDescText.set("v.value", "");
        ICDDescText.set("v.errors", [{message:""}]); 
        var mode = component.get('v.mode');
        console.log('Mode ' + mode);
        if(mode == 'Edit'|| mode == 'Clone') {                
            var ruleId = component.get('v.ruleId'); 
            console.log('In edit mode ' + ruleId);
            this.fetchRuleCombinationFromDB(component,ruleId); 
        }  
        this.fetchOperatorsForANY(component);
    },
    
    hideAuraElement : function(component, auraId) {
        var elementToHide = component.find(auraId);
        $A.util.removeClass(elementToHide, 'slds-show');
        $A.util.addClass(elementToHide, 'slds-hide');
        console.log('In hide'+auraId);
    },
    
    showAuraElement : function(component,auraId) {
        var elementToShow = component.find(auraId);
        $A.util.removeClass(elementToShow, 'slds-hide');
        $A.util.addClass(elementToShow, 'slds-show');
        console.log('In show '+auraId);
    },
    
    removeRule : function(component,index) {
        var ruleList = component.get("v.selectedRules");
        var combinationMap = component.get('v.combinationMap');   
        //Create Rule List with Description & Operator
        for(var i = 0; i < ruleList.length; i++){ 
            var rule = ruleList[i];
            rule.operator = '';
            rule.checked = false;            
            combinationMap[rule.ruleId] = rule;
            console.log('Uncheck Rule ' + rule.ruleId + ',' + rule.ruledesc + ',' + rule.operator);
        } 
        component.set("v.combinationMap", combinationMap);
        ruleList.splice(index, 1);
        component.set("v.selectedRules", ruleList);
        console.log(ruleList);
        var overlayRules = component.get("v.overlayRules");
        overlayRules.splice(index, 1);
        component.set("v.overlayRules", overlayRules);
        
        if(ruleList.length == 0){
            component.set("v.selectedRules",new Array());
            component.set('v.selectedRulesforANY', new Array());	
            component.set('v.selectedRulesforANYMap', new Array());
            component.set('v.newRuleCombination.Rule_Combination__c','');
            component.set('v.ruleCombinationWithExp', '');
            component.set('v.newRuleCombination.Rule_Combination_Description__c','');
            component.set('v.combinationMap', new Object());
            component.set("v.overlayRules", new Array());
            
            var CombinationText = component.find("CombinationText");        
            CombinationText.set("v.value", "IF ");
        }
    },
    
    updateRuleCombination : function(component,index) {
        var ruleList = component.get("v.selectedRules");
        console.log(ruleList);
        var ruleDetails = ruleList[index];
        var ruleId = ruleDetails.ruleId;
        var operator = ruleDetails.operator;
        var prevOperator = ruleDetails.operator;
        var nextOperator = ruleDetails.operator;
        var nextIndex = parseInt(index);
        nextIndex++;
        if(index > 0){
            prevOperator = ruleList[index - 1].operator;
        }
        else{
            if(nextIndex <= ruleList.length - 1){
                nextOperator = ruleList[nextIndex].operator;
            }
        }
        console.log('Operator in delete row ' + operator);
        var removeString = operator + ' ' + ruleId;
        var ruleCombination = component.get('v.ruleCombinationWithExp'); //component.get("v.newRuleCombination.Rule_Combination__c");
        ruleCombination = ruleCombination + ' ';
        var endWithCurly = ruleId + '}';
        var endWithRound = ruleId + ')';
        var endWithSquare = ruleId + ']';
        console.log('Index ' + parseInt(index + 1) + '/' + nextIndex);
        console.log('Length ' + ruleList.length);
        if(operator.indexOf('IF')>-1){
            console.log('Nextoperator before' + nextOperator);
            if(nextOperator.indexOf('ANY')>-1){
                nextOperator = nextOperator.substring(0, nextOperator.indexOf('ANY') - 1);
                console.log('Nextoperator' + nextOperator);
            }
            if(ruleList.length > 1){            
                if(operator.indexOf('ANY')>-1){
                    removeString = "{" + ruleId + "}" + operator.substring(operator.indexOf('OF') + 2, operator.length) + ' ' + nextOperator;
                }
                else{
                    removeString = ruleId + ' ' + nextOperator;
                }
            }
            else{
                if(operator.indexOf('ANY')>-1){
                    removeString = "{" + ruleId + "}" + operator.substring(operator.indexOf('OF') + 2, operator.length);
                }
                else{
                    removeString = ruleId;
                }
            }
        }
        else if(operator.indexOf('ANY')>-1){
            prevOperator = operator.substring(0, operator.indexOf('ANY') - 1);
            removeString = prevOperator + " {" + ruleId + "}" + operator.substring(operator.indexOf('OF') + 2, operator.length);
        }
            else if(ruleCombination.indexOf(endWithRound)>-1 || ruleCombination.indexOf(endWithSquare) >-1){ // || (nextIndex == ruleList.length)){
                console.log(prevOperator + ' ' + ruleId);
                if(ruleCombination.indexOf(prevOperator + ' ' + ruleId) >-1) {
                    removeString = prevOperator + ' ' + ruleId;
                }
                else { removeString = ruleId; }
            } 
                else if(operator == 'none' || operator == undefined){
                    removeString = ruleId;
                }        		 
        
        removeString = removeString + ' ';
        ruleCombination = ruleCombination.replace(removeString, '');
        console.log('Remove String: ' + removeString);
        console.log('Rule Combination: ' + ruleCombination);
        component.set("v.ruleCombinationWithExp", ruleCombination.trim());
        component.set("v.newRuleCombination.Rule_Combination__c", ruleCombination.trim());
        component.set("v.newRuleCombination.Rule_Combination_With_Exp__c", ruleCombination.trim());
        this.populateCombinationString(component, ruleCombination);
        this.populateCombinationDescription(component, ruleCombination);
    },
    
    fetchRuleCombinationFromDB : function(component, ruleId) {        
        var fetchAction = component.get("c.fetchRuleCombinationById");
        fetchAction.setParams({
            'ruleId': ruleId
        });
        fetchAction.setCallback(this, function(response){
            var state = response.getState();
            if (state == "SUCCESS") {
                var returnValue = JSON.parse(response.getReturnValue());
                if(returnValue != null){
                    console.log(returnValue);
                    component.set('v.newRuleCombination', returnValue);
                    var ruleCombination = component.get('v.newRuleCombination.Rule_Combination__c');
                    ruleCombination = "IF " + ruleCombination;
                    var CombinationText = component.find("CombinationText");
                    CombinationText.set('v.value', ruleCombination);   
                    var ruleCombinationWithExp = component.get('v.newRuleCombination.Rule_Combination_With_Exp__c');
                    ruleCombinationWithExp = "IF " + ruleCombinationWithExp;
                    component.set('v.ruleCombinationWithExp', ruleCombinationWithExp);
                    this.populateCombinationDescription(component, ruleCombinationWithExp);
                    this.populateSelectedRuleList(component);
                }
            }
        });
        $A.enqueueAction(fetchAction);                                 
    },
    
    populateSelectedRuleList : function(component){
        var CombinationText = component.find("CombinationText"); 
        var CombinationDesc = component.find("CombinationDesc"); 
        var temp = new Object();
        var tempRule = new Object();
        var map = new Array();       
        var ruleList = new Array();
        var ruleDescList = new Array();
        var operatorList = new Array();
        var overlayRules = new Array();
        var combinationMap = component.get('v.combinationMap');
        var delIndex = new Array();
        var brackets = ["(", ")", "[", "]"];
        var logicalOperators = ["AND", "OR", "and", "or"];
        
        var ruleCombinationText = component.get("v.ruleCombinationWithExp"); //CombinationText.get("v.value");
       
        if(ruleCombinationText != null || ruleCombinationText !=''){ 
            for(var s = 0; s < ruleCombinationText.length; s++){
                ruleCombinationText = ruleCombinationText.replace(' ',',');
                
                for(var i = 0; i < brackets.length; i++){                
                    ruleCombinationText = ruleCombinationText.replace(brackets[i],'');    
                }        
            }
            
            ruleList = ruleCombinationText.split(",");
            console.log('Rules List with operator ' + ruleList);
            var anyOperator = false;
            ruleList.forEach(function(value, index) {
                console.log('Rule Value [' + value + ']');
                if(value == '' || value.trim().length == 0 || value == null || value == undefined || value == ' '){
                    console.log('Delete blank value @ ' + index);                
                    delIndex.push(index);                
                }
                else if(value == 'IF' || value == 'AND' || value == 'and' || value == 'OR' || value == 'or'){
                    operatorList.push(value);
                    delIndex.push(index);                
                }    
                    else if(value.indexOf("{")>-1){
                        value = value.replace('{',''); 
                        var anyOperatorText = operatorList[operatorList.length-1];
                        anyOperatorText = anyOperatorText + " ANY OF ";
                        operatorList[operatorList.length-1] = anyOperatorText;
                        anyOperator = true;
                    }           	           
                        else if(value.indexOf("}") >-1)
                        {
                            value = value.replace('}','');
                            anyOperator = false;
                        }
                            else if(value == '=' || value == '!=' || value == '>' || value == '>=' || value == '<' || value == '<='){                
                                var anyOperatorText = operatorList[operatorList.length-1];
                                anyOperatorText = anyOperatorText + value;
                                operatorList[operatorList.length-1] = anyOperatorText;
                                delIndex.push(index);                
                            }
                                else if(! isNaN(value)){ 
                                    var anyOperatorText = operatorList[operatorList.length-1];
                                    anyOperatorText = anyOperatorText + ' ' + value;
                                    operatorList[operatorList.length-1] = anyOperatorText;
                                    delIndex.push(index);                
                                } 
                ruleList[index] = value.trim();
            });
            
            //Delete operators from Rule List
            delIndex.forEach(function(value, index){
                ruleList.splice(value-index, 1);            
            });                                                 
        }
        console.log('Rule List after del ' + ruleList);
        var distinctRuleList = [];
    	for(var i = 0; i < ruleList.length; i++) {
        	if(distinctRuleList.indexOf(ruleList[i]) == -1) {
            	distinctRuleList.push(ruleList[i]);
        	}
    	}    	
        console.log('Rule List after unique ' + distinctRuleList);
        //Fetch Rule Descriptions
        ruleDescList = component.get('v.selectedRuleDesc');  
        console.log('ruleDescList: ' + ruleDescList);
        var distinctRuleDescList = [];
    	for(var i = 0; i < ruleDescList.length; i++) {
        	if(distinctRuleDescList.indexOf(ruleDescList[i]) == -1) {
            	distinctRuleDescList.push(ruleDescList[i]);
        	}
    	}    	
        console.log('Rule Desc List after unique ' + distinctRuleDescList);
        var ruleDescMap = component.get('v.ruleDescMap');
        if(ruleDescMap){
            
        }else{
            console.log('map is null');
            var t = new Object();
            t.ruleId='temp';
            t.ruledesc='temp';            
            ruleDescMap={"key":t};            
            component.set('v.ruleDescMap',ruleDescMap); 
        }
        for(var i = 0; i < distinctRuleList.length; i++){    
            var tempRuleDesc = new Object();
            tempRuleDesc.ruleId = distinctRuleList[i];
            tempRuleDesc.ruledesc = distinctRuleDescList[i];
            if(ruleDescList[i] && !ruleDescMap[tempRuleDesc.ruleId]){
            	ruleDescMap[tempRuleDesc.ruleId] = tempRuleDesc;
                console.log('Temp Rule Desc' + tempRuleDesc.ruleId + ',' + tempRuleDesc.ruledesc);                
            }
        }
        
        //Fetch rules with ANY
        var ruleCombinationTextANY = component.get("v.ruleCombinationWithExp"); //CombinationText.get("v.value");
        console.log('**' + ruleCombinationTextANY);
        ruleCombinationTextANY = ruleCombinationTextANY.replace('),(', '|');
        ruleCombinationTextANY = ruleCombinationTextANY.replace('), (', '|');
        for(var s = 0; s < ruleCombinationTextANY.length; s++){
            for(var l = 0; l < logicalOperators.length; l++){                
                ruleCombinationTextANY = ruleCombinationTextANY.replace(logicalOperators[l],'|');    
            }
            for(var i = 0; i < brackets.length; i++){                
                ruleCombinationTextANY = ruleCombinationTextANY.replace(brackets[i],'');    
            }        
        }
        
        var ruleANYList = ruleCombinationTextANY.split("|");
        var ruleDescANYList = new Array();
        console.log('Rules List with ANY operator ' + ruleANYList);
        ruleANYList.forEach(function(value, index) {
            console.log('Rule Value [' + value + ']');
            if(value){            
                if(value.indexOf('IF')>-1){
                    value = value.replace('IF ',''); 
                }
                if(value.indexOf('{')>-1){
                    value = value.replace('{',''); 
                    value = value.substring(0, value.indexOf('}'));
                    var ruleIdList = value.split(",");
                    console.log(ruleIdList);
                    var allRuleDesc = '';
                    for(var i = 0; i < ruleIdList.length; i++){
                        console.log(ruleIdList[i]);
                        var tempR = ruleDescMap[ruleIdList[i].trim()];
                        console.log(tempR);
                        if(!tempR){
                            continue;
                        }
                        if(i == ruleIdList.length-1){
                            allRuleDesc += tempR.ruledesc;  
                        }
                        else{
                            allRuleDesc += tempR.ruledesc + ', ';  
                        }
                    }
                    ruleDescANYList.push(allRuleDesc);            	
                }
                else
                {
                    if(value != '' || value.trim().length != 0 || value != null || value != undefined || value != ' '){
                        var ruleDesc = ruleDescMap[value.trim()];
                        if(ruleDesc){
                            ruleDescANYList.push(ruleDesc.ruledesc);
                        }
                    }
                }
            }
            console.log('Rule Value [' + value + ']');
            ruleANYList[index] = value.trim();
        });
        //Fetch rules with ANY
        
        console.log('Rules List ' + ruleList);
        console.log('Rule Desc List ' + ruleDescList);
        console.log('Operator List ' + operatorList);
        console.log('Del List ' + delIndex);
        console.log('Rule Desc with ANY ' + ruleDescANYList);
        
        if(combinationMap){
            
        }else{
            console.log('map is null');
            var t = new Object();
            t.ruledesc='temp';
            t.checked= false;
            combinationMap={"key":t};            
            component.set('v.combinationMap',combinationMap); 
        }
        combinationMap = component.get('v.combinationMap');        
        
        //Create Rule List with Description & Operator
        for(var i = 0; i < ruleANYList.length; i++){ 
            temp = new Object();
            temp.ruleId = ruleANYList[i];
            temp.ruledesc = ruleDescANYList[i];
            temp.operator = operatorList[i];

            temp.checked = true;            
            map.push(temp); 
            overlayRules.push(temp);
            
            tempRule = new Object();
            tempRule.ruleId = ruleANYList[i];
            tempRule.ruledesc = ruleDescANYList[i];
            tempRule.operator = operatorList[i];
            tempRule.checked = true;            
            combinationMap[tempRule.ruleId] = tempRule;
            console.log('Temp ' + tempRule.ruleId + ',' + tempRule.ruledesc + ',' + tempRule.operator);
        }       
        
        console.log('Map ' + map);   
        component.set('v.selectedRules', map);
        component.set('v.overlayRules', overlayRules);
        component.set('v.combinationMap', combinationMap);
        this.showAuraElement(component, 'SelectedRuleList');        
    },
    
    removeOverlayRule : function(component,index) {
        var ruleList = component.get("v.selectedRules");
        var ruleObj = ruleList[index];
        ruleList.splice(index, 1);               
        component.set("v.selectedRules", ruleList);
        var overlayRules = component.get("v.overlayRules");
        overlayRules.splice(index, 1);
        component.set("v.overlayRules", overlayRules); 
        var cmpEvent = $A.get("e.c:RemoveSelectedRule");
        console.log('IRuleId: '+ruleObj.ruleId);
        cmpEvent.setParams({"IRuleId" : ruleObj.ruleId}).fire();
        console.log('Event fired');        
    },
    
    swipeElements : function(component, srcIndex, desIndex){
        var selectedRules = component.get("v.selectedRules");
        if(srcIndex!=desIndex && desIndex>=0 && desIndex<selectedRules.length){
            var currentSrc = selectedRules[srcIndex];
            var currentDes = selectedRules[desIndex];
            if(srcIndex==0){
                currentSrc.operator =  currentDes.operator;
                currentDes.operator = 'IF';
            }
            if(desIndex==0){
                currentDes.operator = currentSrc.operator;
                currentSrc.operator =  'IF';
            }
            selectedRules[srcIndex] = currentDes;
            selectedRules[desIndex] = currentSrc;
        }
        console.log('Show ANY OF table ' + component.get("v.showANYOFTable"));
        console.log('Show Rule List table ' + component.get("v.showRuleListTable"));
        component.set("v.selectedRules", selectedRules);
        var combinationMap = component.get("v.combinationMap");
        var cmpEvent = $A.get("e.c:ReOrderCombination");        
        console.log('Firing eventt ');
        console.log(JSON.stringify(selectedRules));
        var showANYOFTable = component.get("v.showANYOFTable");
        cmpEvent.setParams({"IReOrderOverlayRules" : selectedRules, "IShowANYOFTable" : showANYOFTable}).fire();        
    },
    
    showGenericMessage : function(component,isConfirmation, message, action) {
        component.set('v.isConfirmation', isConfirmation);
        component.set('v.genericMessage', message);
        component.set('v.isShowGenericMessage', true);
        component.set('v.genericMessageAction', action);
    }, 
    
    fetchOperatorsForANY : function(component){
        var fetchAllOperators = component.get("c.fetchAllOperators");
        fetchAllOperators.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                console.debug('Fetched data fetchAllOperators');
                var dataTypeOperatorMap = JSON.parse(response.getReturnValue()); 
                var operators = dataTypeOperatorMap['INTEGER'].split(',');
                component.set('v.allOperators', operators);                
            }
        });
        $A.enqueueAction(fetchAllOperators);
    },
    
    addAnyOfCombination : function(component, event, helper){
        console.log('Inside addAnyOfCombination');
        component.set("v.anyError", "");
        var map = component.get('v.selectedRules');
        var mapANY = component.get('v.selectedRulesforANYMap');
        var ruleANY = component.get('v.selectedRulesforANY');  
        var overlayRules = component.get('v.overlayRules');
        var combinationOperator = component.get("v.combinationOperator");
        var anyOperator = component.get("v.anyOperator");
        var anyValue = component.get("v.anyValue");
        var combOprFlag = true;
        if(map.length > 0 && combinationOperator == 'None'){
            combOprFlag = false;
        }
        if(mapANY.length > 0 && anyOperator != 'None' && anyValue && combOprFlag){              
            var strRule = '';
            var strRuleDesc = '';
            for(var i = 0;i < mapANY.length;i++)
            {
                if(i == mapANY.length-1){
                    strRule += mapANY[i].ruleId;
                    strRuleDesc += mapANY[i].ruledesc;  
                }
                else{
                    strRule += mapANY[i].ruleId + ', ';
                    strRuleDesc += mapANY[i].ruledesc + ', ';  
                }
            }
            
            console.log('All Rules Description ' + strRuleDesc);
            var prevOperator = '';
            var temp = new Object();
            temp.ruleId = strRule;
            temp.ruledesc = strRuleDesc;
            temp.checked = true;
            temp.operator = combinationOperator;    
            if(combinationOperator == 'None'){
                temp.operator = 'IF';
            }
            temp.anyOperator = ' ANY OF ' + anyOperator + ' ' + anyValue;
            temp.checkedANY = true;
            temp.isAnyRule = true;
            temp.anyRuleOperator = anyOperator;
            temp.anyRuleValue = anyValue;
            temp.operatorSelected = 'X1~none';
            
            map.push(temp);
            overlayRules.push(temp);
            console.log(ruleANY);
            component.set("v.selectedRules", map);            
            component.set('v.selectedRulesforANYMap', null);
            component.set('v.selectedRulesforANY', ruleANY);  
            component.set('v.overlayRules', overlayRules);  
            component.set("v.combinationOperator", 'None');
            component.set("v.anyOperator", 'None');            
            component.set("v.anyValue", null);
            component.set("v.isCombinationBuilderPage",true);
            component.set("v.showANYOFTable",false);
            var combinationMap = component.get("v.combinationMap");
            var cmpEvent = $A.get("e.c:ReOrderCombination");
            console.log('Firing eventt for any');
            cmpEvent.setParams({"IReOrderCombinationMap" :combinationMap, "IReOrderOverlayRules" : map}).fire();            
        }
        else{
            component.set("v.isCombinationBuilderPage",false);
            component.set("v.showANYOFTable",true);
            console.log('No input');
            console.log('Values: ' + mapANY.length + anyOperator + anyValue)
            if(mapANY.length == 0){        
                component.set("v.anyError", "Rules are not selected!!");
            }
            else if(combinationOperator == 'None' && !combOprFlag){
                component.set("v.anyError", "Operator is not selected!!");
            }
                else if(anyOperator == 'None'){
                    component.set("v.anyError", "Operator is not selected!!");
                }
                    else if(!anyValue){
                        component.set("v.anyError", "Value is not entered!!");
                    }            
        }
    },
    
    validateRulesSelection : function(component) {
        var ruleList = component.get("v.selectedRules");
        var invalidRules='';
        for(var i=0;i<ruleList.length;i++){
            var tempRule = ruleList[i];
            if(!tempRule.operator || tempRule.operator==''){
                if(invalidRules==''){
                    invalidRules=tempRule.ruleId;
                }else{
                    invalidRules=invalidRules+','+tempRule.ruleId;
                }
            }
        }
        console.log('invalidRules: '+invalidRules);
        component.set('v.invalidRules',invalidRules);
        if(invalidRules==''){
            return true;
        }else{
            return false;            
        }
    },
    
    highlightRules : function(component) {
        var ruleList = component.get("v.selectedRules");        
        for(var i=0;i<ruleList.length;i++){
            var rule = ruleList[i];
            var tRow = component.find('trRule');
            console.log('Highlight row');
            console.log(tRow);
            if(rule.operator == ''){
                $A.util.addClass(tRow[i], 'highLightRow');            	
            }
        }

    },
    
    resetFields: function(component){
        component.set('v.showRuleSelectionOverlay',false);
        component.set("v.combinationConstructed","");
        component.set("v.selectedRules",new Array());
        component.set('v.selectedRulesforANY', new Array());
        component.set('v.selectedRulesforANYMap', new Array());
        component.set('v.newRuleCombination.Rule_Combination__c','');
        component.set('v.ruleCombinationWithExp','');
        component.set('v.newRuleCombination.Rule_Combination_Description__c','');
        component.set('v.combinationMap', new Object());
        component.set("v.overlayRules", new Array());
        component.set("v.srcIndex","-1");
        component.set("v.desIndex","-1");
        
        var CombinationText = component.find("CombinationText");        
        CombinationText.set("v.value", "IF ");
    },
    
    getInactiveRulesFromDB : function(component,ruleList) {
        var fetchInactiveRuleList = component.get("c.fetchInactiveRuleList");
        fetchInactiveRuleList.setParams({
            'ruleExtIdList': JSON.stringify(ruleList),
        });
        fetchInactiveRuleList.setCallback(this, function(response){
            var state = response.getState();            
            console.log('-----------------------');
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                var inActiveRules = JSON.parse(response.getReturnValue());
                console.log(inActiveRules);
                var message = $A.get("$Label.c.CombinationBuilder_CombSaveConfirmation"); 
                var activeField = component.get('v.newRuleCombination.Is_Active__c');  
                if(activeField == true) {
                    message = $A.get("$Label.c.CombinationBuilder_CombSaveActiveConfirmation");
                }
                if(Object.keys(inActiveRules).length > 0 && activeField == true) {
                    message = $A.get("$Label.c.CombinationBuilder_CombSaveInactiveRules"); 
                    var ruleList = '';
                    for (var key in inActiveRules) {
                        if (inActiveRules.hasOwnProperty(key)) {
                            ruleList = ruleList + key + " - " + inActiveRules[key] + ', ';
                        }
                    }
                    ruleList = ruleList.substring(0, ruleList.length - 2);
                    ruleList = ruleList + '\n';
                    message = message.replace('#RULE#',ruleList);
                }
                var mode = component.get('v.mode');
                if(mode == '' ) {
                    mode = 'Save';
                }
                component.set('v.positiveResponse',"Save");
                component.set('v.negativeResponse',"Cancel");
                this.showGenericMessage(component, true, message,mode);                 
            }            
        });
        $A.enqueueAction(fetchInactiveRuleList);
    },
    
    validateAnyOfExpression : function(ruleCombination) {
        var sIx = -1;
        var eIx = -1;
        var isValidEx = true;
        console.log('validateAnyOfExpression.ruleCombination' + ruleCombination);
        for(var i in ruleCombination){   
            if(ruleCombination[i] == '}') {
                var tempStr = '';
                sIx = i;
                console.log('sIx='+i);                 
            }
            if(ruleCombination[i]=='A' || ruleCombination[i]=='a' || ruleCombination[i]=='o' || ruleCombination[i]=='O' || i==ruleCombination.length-1 || ruleCombination[i]==')'){
                
                if(sIx!=-1){
                    console.log('eIx='+i);
                    if(i==ruleCombination.length-1){
                        eIx = ruleCombination.length;  
                    }else{
                        eIx = i;                        
                    }                    
                }
            }
            if(sIx>-1 && eIx>-1){
                tempStr = ruleCombination.slice(sIx, eIx);
                console.log('tempStr: '+tempStr);
                sIx = -1;
                eIx = -1;
                if(tempStr){
                    tempStr = tempStr.replace(")","").trim();
                    var last = tempStr[tempStr.length-1];
                    var secondLast = tempStr[tempStr.length-2];
                    if(last == ')'){
                        last =secondLast;
                        secondLast = tempStr[tempStr.length-3];
                    }
                    console.log('Last: '+last);
                    console.log('secondLast: '+secondLast);
                    if(secondLast && !isNaN(secondLast)){
                        if(last){
                            if(isNaN(last)){
                                isValidEx = false; 
                                break;
                            }
                        }else{
                            isValidEx = false;      
                            break;
                        }
                    }else{
                        console.log('secondLast aa:'+secondLast);
                        if(secondLast=='>'||secondLast=='<'||secondLast=='='){
                            isValidEx = true;
                        }else{
                            if(isNaN(secondLast)){
                                isValidEx = false;
                                break;
                            }
                        }
                    }
                    if(last){
                        if(isNaN(last))
                            isValidEx = false;
                    }else{
                        isValidEx = false;
                        break;
                    }
                    var isOperatorPresent = this.conditionalOperatorFound(tempStr);
                    if(!isOperatorPresent){
                        isValidEx = false;
                        break;
                    }                    
                }
            }            
        }
        return isValidEx;
    },
    
    conditionalOperatorFound : function(tempStr){
        var opFound = false;
        if(tempStr.indexOf('>')>0 || tempStr.indexOf('<')>0 || tempStr.indexOf('=')>0 || tempStr.indexOf('!=')>0 || tempStr.indexOf('>=')>0 || tempStr.indexOf('<=')>0){
            var strOpr = tempStr;
            console.log('Operator string ' + strOpr);
            if(strOpr.indexOf('}') > -1){
                strOpr = strOpr.replace('}', '');
            }
            //To remove value from operator string
            strOpr = strOpr.replace(/[0-9]/g, '');
            strOpr = strOpr.trim();
            console.log('Operator in Comb: ' + strOpr);
            if(strOpr == '>' || strOpr == '<' || strOpr == '=' || strOpr == '!=' || strOpr == '>=' || strOpr == '<='){
            	opFound = true;      
            }
            else{
                opFound = false;
            }                
        }else{
            opFound = false;  
        }
        return opFound;
    },
    
    openLookup : function (component, event, helper, objType, ElementIds, DataColumns, isStandalone, isRuleBuilderSelection, SFIDField, searchFilterText, DateOfService){
        var lightningURL = window.location.protocol+"//"+window.location.hostname;
        var codeSearchLink = component.get('v.CodeSearchLink');
        codeSearchLink = codeSearchLink.replace('#1', objType);
        codeSearchLink = codeSearchLink.replace('#2', ElementIds);
        codeSearchLink = codeSearchLink.replace('#3', DataColumns);
        codeSearchLink = codeSearchLink.replace('#4', isStandalone);
        codeSearchLink = codeSearchLink.replace('#5', SFIDField);
        codeSearchLink = codeSearchLink.replace('#6', DateOfService);
        codeSearchLink = codeSearchLink.replace('#7', isRuleBuilderSelection);
        codeSearchLink = codeSearchLink.replace('#8', searchFilterText);
        codeSearchLink = codeSearchLink.replace('#9', lightningURL);
        var url = encodeURI(codeSearchLink);
        childWindow =  window.open(url,'CTSearchLookup','width=1200,toolbar=1,resizable=1,scrollbars=yes,height=550,top=50,left=50');
    },
    
    handleLookupSelections : function(event, component) {
        try{
            Object.keys(event.data).forEach(function (elementId) {
                if(elementId && elementId != 'Type')
                {
                    component.set(elementId,event.data[elementId]);
                }
            });
        }
        catch(e)
        {
           console.log(e.message);
        }
    }
})