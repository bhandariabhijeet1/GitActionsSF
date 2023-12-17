public class CodeSearchController {
	//Use @AuraEnabled to enable client- and server-side access to the method
  	@AuraEnabled
  	public static String getUserName() {
    	return userinfo.getName();
  	}
    
    @AuraEnabled
    public static Boolean isICD9SearchEnabled(){
        System.debug('isICD9SearchEnabled called');
        String confValue = SearchUtil.getConfigValue('Enable_ICD09_Search');
        return (confValue!=null && confValue.equalsIgnoreCase('true'));
    }
     @AuraEnabled
    public static Boolean isICD10TreeViewEnabled(){
        System.debug('isICD10TreeViewEnabled called');
        String confValue = SearchUtil.getConfigValue('Enable_ICD10_Tree_View');
        return (confValue!=null && confValue.equalsIgnoreCase('true'));
    }
    
     @AuraEnabled
    public static Map<String, String> getAllConfigurations(){
        Map<string,String> allConfigs = SearchUtil.getAllConfigValues();
        allConfigs.put('User_Name', userinfo.getName());
        return allConfigs;
    }
   
    @AuraEnabled
    public static Map<String, List<Node>> fetchGlobalFavorites() {
        return SearchUtil.fetchGlobalFavorites();
     }
}