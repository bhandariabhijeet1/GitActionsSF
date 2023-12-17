public with sharing class TermSearchGroup {
	
	@AuraEnabled
	public String code {get;set;}
    @AuraEnabled
	public String description {get;set;}
    @AuraEnabled
	public String href {get;set;}
    @AuraEnabled
	public Integer rank {get;set;}
	@AuraEnabled
    public List<Node> Node{get;set;}
    
}