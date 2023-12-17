<aura:application controller='RuleBuilderController' extends="force:slds">

    <aura:attribute name="userName" type='String'/> 
    <aura:attribute name="homeURL" type='String'/> 
    <aura:attribute name="logoutURL" type='String'/> 
    <aura:attribute name="CodeSearchLink" type='String'/> 
    <aura:attribute name='ruleId' type='String'/>
    <aura:attribute name='isShowRulePage' type='boolean'/>
    <aura:attribute name='isShowRuleViewPage' type='boolean'/>
    <aura:attribute name='isShowCombinationPage' type='boolean'/>
    <aura:attribute name='isShowCombinationViewPage' type='boolean'/>
    <aura:attribute name='isRuleCategoryViewPage' type='boolean'/>
    <aura:attribute name='isShowNewCategoryPage' type='boolean'/>
    <aura:attribute name='isShowEditCategoryPage' type='boolean'/>
    <aura:attribute name='isShowRuleTester' type='boolean'/>
    <aura:attribute name='isRule' type='boolean'/>
    
    <aura:attribute name='ruleCategory' type='Object'/>
    
    <aura:attribute name='mode' type='String'/>
    
    <aura:handler name="init" value="{!this}" action="{!c.doInit}"/>    
    <aura:handler name="RuleActionEvent" event="c:RuleActions" action="{!c.handleRuleEvents}" includeFacets="true" />
    <aura:handler name="RuleCategoryActionEvent" event="c:RuleCategoryActions" action="{!c.handleCategoryEvents}" includeFacets="true" />
    <script>      
        var linkHref = document.createElement("link");
        linkHref.rel = "icon";
        linkHref.type="image/x-icon";
        linkHref.href = "{!join(',',$Resource.CodeSearchResources + '/images/favicon.ico')}";
        document.head.appendChild(linkHref);
    </script>
    
    <div class="slds" style='slds'>
        <div class="slds-page-header">           
            <div class="slds-grid">
                <div class="slds-col slds-has-flexi-truncate">
                    <img src="{!join(',',$Resource.RuleBuilderResources + '/RuleBuilderResources/Images/PathwayLogo.png')}" width="150" height="39.1" title='Pathway Logo' alt='Pathway Logo'/>
                    <div class="slds-grid">
                        <div class="slds-col--padded slds-size--1-of-2 slds-medium-size--5-of-6 slds-large-size--8-of-12">
                            <h1 class="slds-col--padded slds-text-heading--small slds-truncate " title="Select">
                                Rule Builder - Engine
                            </h1>
                        </div>                      
                        <div class="slds-col--padded slds-size--1-of-2 slds-medium-size--1-of-6 slds-large-size--4-of-12 slds-text-align--right">
                            {!v.userName}
                            <a href="{!v.homeURL}" target='_self' class="UserNavigatoionLinks">Home</a>
                            <a href="{!v.logoutURL}" target='_self' class="UserNavigatoionLinks">Logout</a>
                        </div>  
                    </div>                   
                </div>
            </div>
        </div>  
        <div class="slds-tabs--scoped tab-container">
            <ul class="slds-tabs--scoped__nav " role="tablist">        
                <li class="slds-tabs--scoped__item slds-text-heading--label slds-active custom-tab-item " title="Rule Library"
                    role="presentation" aura:id='tab-item-1'>
                    <a  class="slds-tabs--scoped__link"  onclick = "{!c.switchTab}" data-tab='1' role="tab" tabindex="0" aria-selected="true" aria-controls="tab-scoped-1" id="tab-scoped-1__item">Library of Rules</a>
                </li>                        
                <li class="slds-tabs--scoped__item slds-text-heading--label custom-tab-item " title="Combination Library"
                    role="presentation"  aura:id='tab-item-2'>
                    <a  class="slds-tabs--scoped__link" data-tab='2'  onclick = "{!c.switchTab}"  role="tab" tabindex="-1" aria-selected="false" aria-controls="tab-scoped-2" id="tab-scoped-2__item">Library of Combinations</a>
                </li>
                <li class="slds-tabs--scoped__item slds-text-heading--label custom-tab-item " title="Rule Categories"
                    role="presentation"  aura:id='tab-item-3'>
                    <a  class="slds-tabs--scoped__link" data-tab='3'  onclick = "{!c.switchTab}"  role="tab" tabindex="-1" aria-selected="false" aria-controls="tab-scoped-3" id="tab-scoped-3__item">Rule Categories</a>
                </li>
                <li class="slds-tabs--scoped__item slds-text-heading--label custom-tab-item " title="Rule Tester"
                    role="presentation"  aura:id='tab-item-4'>
                    <a  class="slds-tabs--scoped__link" data-tab='4'  onclick = "{!c.switchTab}"  role="tab" tabindex="-1" aria-selected="false" aria-controls="tab-scoped-4" id="tab-scoped-4__item">Test Rules</a>
                </li>
            </ul>
            <div class='tab-content-section'>
                <div id="tab-scoped-1" aura:id='tab-content-1'  class='fav-list-container'  role="tabpanel" aria-labelledby="tab-scoped-1--item">   			
                    <div aura:id = 'ruleList' class='slds-show'> 
                        <div class='newRuleButtonContainer'>
                            <button class="slds-button slds-button--neutral" onclick = '{!c.openNewRulePage}'> New Rule </button> 
                        </div>                        
                        <div aura:id='ruleListContainer' class='ruleListContainer'>                  
                            <c:RuleListView />
                        </div>                  
                    </div>
                    <div aura:id='newRuleSection' class='slds-hide'>
                        <aura:if isTrue='{!v.isShowRulePage}'>
                            <c:RuleBuilder ruleId='{!v.ruleId}' CodeSearchLink='{!v.CodeSearchLink}' mode='{!v.mode}'/>
                        </aura:if>    
                        <aura:if isTrue='{!v.isShowRuleViewPage}'>
                            <c:DisplayRule ruleId='{!v.ruleId}'/>
                        </aura:if>                   
                    </div>
                </div>
                <div id="tab-scoped-2" aura:id='tab-content-2' class='fav-list-container slds-hide' role="tabpanel" aria-labelledby="tab-scoped-2--item">			 
                    <div aura:id = 'ruleCombinationList' class='slds-show'> 
                        <div class='newRuleButtonContainer'>
                            <button class="slds-button slds-button--neutral" onclick = '{!c.openNewCombinationPage}'> New Rule Combination</button> 
                        </div>
                        <div aura:id='ruleCombListContainer' class='ruleListContainer'>                 
                            <c:RuleCombinationListView />
                        </div>                  
                    </div> 
                    <div aura:id='newCombinationSection'>
                        <aura:if isTrue='{!v.isShowCombinationPage}'>
                            <c:CombinationBuilder ruleId='{!v.ruleId}' CodeSearchLink='{!v.CodeSearchLink}' mode='{!v.mode}'/>
                        </aura:if>
                        <aura:if isTrue='{!v.isShowCombinationViewPage}'>
                            <c:DisplayRuleCombination ruleId='{!v.ruleId}'/>
                        </aura:if>
                    </div>
                </div>
                <div id="tab-scoped-3" aura:id='tab-content-3' class='fav-list-container slds-hide' role="tabpanel" aria-labelledby="tab-scoped-3--item">                    
                    <div aura:id = 'categoryList'> 
                        <aura:if isTrue='{! !v.isRuleCategoryViewPage &amp;&amp; !v.isShowNewCategoryPage&amp;&amp; !v.isShowEditCategoryPage}'>
                            <div class='newRuleButtonContainer'>
                                <button class="slds-button slds-button--neutral" onclick = '{!c.openNewCategoryPage}'> New Category </button> 
                            </div>                            
                            <div aura:id='categoryList' class='ruleListContainer'>                  
                                <c:RuleCategoryListView />
                            </div>                            
                        </aura:if>
                    </div>                    
                    <aura:if isTrue='{!v.isRuleCategoryViewPage}'>
                        <c:DisplayRuleCategory ruleCategory='{!v.ruleCategory}' />
                    </aura:if>   
                    <div aura:id='newCategorySection'>
                        <aura:if isTrue='{!v.isShowEditCategoryPage}'>
                            <c:CreateRuleCategory mode='{!v.mode}' ruleCategoryID='{!v.ruleCategory.Id}' selectedType='{!v.ruleCategory.Rule_Type__c}' ruleCategory='{!v.ruleCategory.Rule_Category__c}'/>                        
                        </aura:if>
                        <aura:if isTrue='{!v.isShowNewCategoryPage}'>
                            <c:CreateRuleCategory mode='{!v.mode}' />                        
                        </aura:if>
                    </div>                     
                </div>       
                <div id="tab-scoped-4" aura:id='tab-content-4' class='fav-list-container slds-hide' role="tabpanel" aria-labelledby="tab-scoped-4--item">
                    <div aura:id='ruleTesterSection'>
                        <aura:if isTrue='{!v.isShowRuleTester}'>
                            <c:RuleEngineTester ruleId='{!v.ruleId}' isRule='{!v.isRule}' />
                        </aura:if>  
                    </div>                    
                </div>           
            </div>
        </div>
    </div>    
    <c:GenericMessage />
</aura:application>