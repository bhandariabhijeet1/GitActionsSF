/*
ClsFirstComponent 
Apr 4, 2018 : 3:46:00 PM  >> Created by abhijeet_bhandari
*/
public with sharing class ClsFirstComponent {
   	@AuraEnabled
   	public static List<Account> fetchAccounts()
   	{
   		return [SELECT Id, name, industry, Type, NumberOfEmployees, TickerSymbol, Phone FROM Account ORDER BY createdDate ASC];
   	}
   	
   	@AuraEnabled
   	public static Account fetAccountById(String AccountId)
   	{
   		Account oAccont = new Account();
   		if(String.isNotBlank(AccountId))
   		{
   			oAccont = [SELECT Id, name, industry, Type, NumberOfEmployees, TickerSymbol, Phone FROM Account WHERE Id=: AccountId ORDER BY createdDate ASC];
   		}
   		return oAccont;
   	}
}