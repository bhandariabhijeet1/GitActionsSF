public class MyFavoritesController {
    
    @AuraEnabled
    public static String getMyFavorites() {
        List<User_Favorites__c> favList = new List<User_Favorites__c>();
        Map<String,Boolean> userFavoritesCache = (Map<String,Boolean>)Cache.Session.get('userFavoritesCache');
        if(userFavoritesCache==null){
            System.debug('Fav cahce is null');
            userFavoritesCache = new Map<String,Boolean>();
        }
        if(favList.size()==0){
            User_Favorites__c[] myFavs = [select Search_String__c, ICD_Code__c from User_Favorites__c]; //where Owner = :userinfo.getName()];
            for(User_Favorites__c fav : myFavs){
                favList.add(fav);
                userFavoritesCache.put(fav.ICD_Code__c,true);
            }
        }
        System.debug('Storing userFavoritesCache : '+userFavoritesCache);
		Cache.Session.put('userFavoritesCache', userFavoritesCache);		        
        return JSON.serialize(favList);
    }
    
    @AuraEnabled
    public static String addToMyFavorites(String ICDCode, String searchString) {
        User_Favorites__c newFav  = new User_Favorites__c();
        newFav.ICD_Code__c = ICDCode; 
        newFav.Search_String__c = searchString;
        
        Boolean isPresent = isPresentMyFavorites(ICDCode, searchString);
        if(!isPresent){
            //Insert ICD Codes in Cache
            if(String.isNotBlank(ICDCode)){
                Map<String,Boolean> userFavoritesCache = (Map<String,Boolean>)Cache.Session.get('userFavoritesCache');
                if(userFavoritesCache!=null){
                    userFavoritesCache.put(ICDCode,true);
                }
                Cache.Session.put('userFavoritesCache', userFavoritesCache);
            }
            	
            Database.SaveResult sr = Database.insert(newFav, false);
            if (!sr.isSuccess()) {
                // Insertion failed due to duplicate detected
                for(Database.Error duplicateError : sr.getErrors()){
                    system.debug(LoggingLevel.ERROR,duplicateError);
                    return 'DUPLICATE_MYFAVORITES';
                }
                return 'ERROR';
            }
            else {
                return 'SUCCESS';	
            }
        }
        else{
        	return 'SUCCESS';	
        }
    }
    
    @AuraEnabled
    public static Boolean isPresentMyFavorites(String ICDCode, String searchString) {
        /*List<User_Favorites__c> favRec = [SELECT Id FROM User_Favorites__c 
                                     	  WHERE Search_String__c = :searchString
                                     	  AND ICD_Code__c = :ICDCode 
                                     	  LIMIT 1];
        System.debug('Rec Count ' + favRec);
        if(favRec.size() > 0)
            return true;
        else
            return false;*/
        if(String.isNotBlank(ICDCode)){
            Map<String,Boolean> userFavoritesCache = (Map<String,Boolean>)Cache.Session.get('userFavoritesCache');
            if(userFavoritesCache!=null){
                 return userFavoritesCache.containsKey(ICDCode) && ((Boolean)userFavoritesCache.get(ICDCode));
            }else{
                return false;
            }
        }else{
            return false;
        }
    }
    
    @AuraEnabled
    public static String removeFromMyFavorites(String ICDCode, String searchString) {
        User_Favorites__c  favRec = [SELECT Id FROM User_Favorites__c 
                                     WHERE Search_String__c = :searchString
                                     AND ICD_Code__c = :ICDCode 
                                     LIMIT 1];
        if(favRec != null){
            Database.delete(favRec, false);
            //Remove ICD Codes from Cache
            if(String.isNotBlank(ICDCode)){
                Map<String,Boolean> userFavoritesCache = (Map<String,Boolean>)Cache.Session.get('userFavoritesCache');
                if(userFavoritesCache!=null){
                    userFavoritesCache.remove(ICDCode);
                }
                Cache.Session.put('userFavoritesCache', userFavoritesCache);
            }
            return 'SUCCESS';
        }
        else
            return 'ERROR';
    }
}