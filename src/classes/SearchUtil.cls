public class SearchUtil {
    //Configurations Map
    public static Map<String,String> configs = null;
    
    //ICD HCC Mapping
    public static Map<String, ICD_HCC_mapping__c> mapIcdHccMapping = null;
    
    public static boolean isValidICD9(String code){
        return Pattern.matches('^(V\\d{2}(\\.\\d{1,2})?|\\d{3}(\\.\\d{1,2})?|E\\d{3}(\\.\\d)?)$', code);
    }
    
    public static boolean isValidICD10(String code){
        code = code.toUpperCase();
            return Pattern.matches('^[A-TV-Z][0-9][A-Z0-9](\\.[A-Z0-9]{0,4})?$', code);
    }
    
    public static String verifySearchType(String sSearchString)
    {
        String sSearchType = '';        
        if(isValidICD10(sSearchString))
        {
            sSearchType = 'ICD10Code';
        }
        else if(isValidICD9(sSearchString))
        {
            sSearchType = 'ICD9Code';
        }        
        return sSearchType;
    }
    
    public static String getConfigValue(String key){
        if(configs==null){
            configs = new Map<String,String>();
        }
        if(configs.size()==0){
            configurations__mdt[] tempConfigs = [select DeveloperName, value__c from configurations__mdt];
            for(configurations__mdt tConf : tempConfigs){
               configs.put(tConf.DeveloperName, tConf.value__c);
            }
        }
        return configs.get(key);
   	}
    
    public static Map<String,String> getallConfigValues(){
        if(configs==null){
            configs = new Map<String,String>();
        }
        if(configs.size()==0){
            configurations__mdt[] tempConfigs = [select DeveloperName, value__c from configurations__mdt];
            for(configurations__mdt tConf : tempConfigs){
               configs.put(tConf.DeveloperName, tConf.value__c);
            }
        }
        return configs;
   	}
    
    //Populates HCC Code and HCC Description of given node
    public static Node mapHCCCode(Node oRangeNode){
        if(mapIcdHccMapping==null)
        {
            mapIcdHccMapping = new  Map<String, ICD_HCC_mapping__c>();
        }
        if(mapIcdHccMapping.size()==0)
        {
            mapIcdHccMapping = ICD_HCC_mapping__c.getAll();
        }
        if(String.isNotEmpty(oRangeNode.code) && mapIcdHccMapping.containsKey(oRangeNode.code)){
            oRangeNode.hccCode=mapIcdHccMapping.get(oRangeNode.code).HCC_code__c;
            oRangeNode.hccDescription=mapIcdHccMapping.get(oRangeNode.code).HCC_Description__c;
        }
        return oRangeNode;
    }
    
    //Fetch Acronym for given String
    public static String fetchReplacementAcronym(String sSearchTerm)
    {
        Map<String, Acronym_mapping__c> mapAcronymMapping = new Map<String, Acronym_mapping__c>();
        mapAcronymMapping = Acronym_mapping__c.getAll();
        String sMappedAcronym = ''; //return searchterm
        
        System.debug(' Acronym Mapping List @@@@@@@@@@@@@@  ' + mapAcronymMapping);
        if(String.isNotBlank(sSearchTerm) && mapAcronymMapping.containskey(sSearchTerm.toLowerCase()))
        {
            sMappedAcronym =  mapAcronymMapping.get(sSearchTerm.toLowerCase()).Acronym_Replacement__c;
        }
        System.debug(' Replaced Test @@@@@@@@@@@@@@  ' + sMappedAcronym);

        if(String.isNotBlank(sMappedAcronym)){
            return sMappedAcronym;
        }
        else{
            return sSearchTerm;
        }       
    }
    
    //Fetch global favorites for given String     
    public static  Map<String, List<Node>> fetchGlobalFavorites()
    {        
        Map<String, Global_Favorites__c> mapGlobalFavDiagnosis = new Map<String, Global_Favorites__c>();
        Map<String, Global_Favorite_Searches__c> mapGlobalFavSearch = new Map<String, Global_Favorite_Searches__c>();
        Map<String, Global_Favorites__c> sortedMapGlobalFavDiagnosis = new Map<String, Global_Favorites__c>();
        Map<String, List<Node>> mapGlobalFavs = new Map<String, List<Node>>();
        List<Node> favList = new List<Node> ();
        List<String> lstSortedGlobalFavDiagnosis =  new List<String>();
        
        //fetch global fav diagnosis
        mapGlobalFavDiagnosis = Global_Favorites__c.getAll();
         //fetch global fav diagnosis
        mapGlobalFavSearch = Global_Favorite_Searches__c.getAll();
   
        //sort global fav diagnosis
        for(Global_Favorites__c fav: mapGlobalFavDiagnosis.values()) {
            sortedMapGlobalFavDiagnosis.put(fav.ICD_Description__c, fav);
            lstSortedGlobalFavDiagnosis.add(fav.ICD_Description__c);
        } 
        lstSortedGlobalFavDiagnosis.sort();               
      
        //sort global fav Searches
        List<Global_Favorite_Searches__c> lstGlobalFavSearch = new List<Global_Favorite_Searches__c>();
        lstGlobalFavSearch.addAll(mapGlobalFavSearch.values());
        lstGlobalFavSearch.sort();                     
        
        for(String favDesc : lstSortedGlobalFavDiagnosis) {
           Global_Favorites__c fav = sortedMapGlobalFavDiagnosis.get(favDesc);
            List<String> lstICDDescriptions = new List<String>();
            if(String.isNotBlank(fav.ICD_Description__c))
            {
                lstICDDescriptions = favDesc.split('<~>');
                for(String sICDDescription : lstICDDescriptions)
                {
                    Node favoriteNode = new Node();
                    favoriteNode.code = fav.name;
                    favoriteNode.description = sICDDescription;
                    favList.add(favoriteNode);
                }
            }           
        }
        
         List<Node> searchList = new List<Node> ();
         for(Global_Favorite_Searches__c fav : lstGlobalFavSearch) {
                    Node favoriteNode = new Node();
                    favoriteNode.code = fav.name;
                    favoriteNode.description = fav.Favorite_Search_Text__c;
                    searchList.add(favoriteNode);
         }
         
        mapGlobalFavs.put('diagnosis', favList);
        mapGlobalFavs.put('searches', searchList);
        return mapGlobalFavs;
    }
    
    public static Boolean hasChildNodes(DOM.XMLNode xmlNode, Boolean bIsCategoryNode, Boolean bIsSubCategoryNode)
    {
        Boolean bHasChildElements = false;
        Boolean bHideDisplay = false;
        
        if(xmlNode != null)
        {
            for(Dom.XMLNode tsgNode : xmlNode.getChildElements()) 
            {
                System.debug('Code: '+tsgNode.getText());
                if(tsgNode.getName().equalsIgnoreCase(SearchConstants.NODE))
                {
                    System.debug('trueee');
                    bHasChildElements = true;
                    break;
                }
            }
            System.debug('bHasChildElements : '+bHasChildElements);
            
            if(bHasChildElements && (bIsCategoryNode || bIsSubCategoryNode))
            {
                bHideDisplay = true;
            }
        }        
        return bHideDisplay;
    }
    
        public static String  getICD10Hierarchy( List<Node> nodeList, boolean areAllOrphans) {
        system.debug('I will create map from nodeCount-----------------'+ nodeList.size());
        SearchAPI.ICD10Hierarchy hierarchyMapObj = new SearchAPI.ICD10Hierarchy ();
        Map<Node, SearchAPI.ICD10SubCategory> hierarchyMap = hierarchyMapObj.data;

        if(nodeList.size() == 1){
            system.debug('I am alone');
            if(nodeList.get(0).code!=null) {
                hierarchyMap.put(nodeList.get(0), new SearchAPI.ICD10SubCategory());
            } 
            return  JSON.serialize(hierarchyMapObj);
        }
       
       if(areAllOrphans) {
           for(Node nodeObj: nodeList) {
                if(nodeObj.code != null) {
                    hierarchyMap.put(nodeObj, new SearchAPI.ICD10SubCategory()); 
                }
           } 
            return  JSON.serialize(hierarchyMapObj);
       }
        
        for(Node nodeObj: nodeList) {
            if(nodeObj.code != null) {
                 String parent = nodeObj.getParent();
                 if(String.isBlank(parent)) {
                     if(!hierarchyMap.containsKey(nodeObj)) {
                        hierarchyMap.put(nodeObj, new SearchAPI.ICD10SubCategory());
                     }
                    else {
                        SearchAPI.ICD10SubCategory subCat = hierarchyMap.get(nodeObj);
                        hierarchyMap.put(nodeObj, subCat);
                     }
                 }
                 else {
                     if(parent.containsAny('.')) { //code-M84.356, parent- M84.3
                         String category = parent.split('\\.')[0]; //category - M84
                         Node nodeTemp = new Node ();
                         nodeTemp.code = category;
                         nodeTemp = SearchUtil.mapHCCCode(nodeTemp);

                        if(!hierarchyMap.containsKey(nodeTemp)) {
                             hierarchyMap.put(nodeTemp, new  SearchAPI.ICD10SubCategory()); 
                         }
                         SearchAPI.ICD10SubCategory subCategory = hierarchyMap.get(nodeTemp);
                         Node nodeTemp1 = new Node ();
                         nodeTemp1.code = parent;
                         nodeTemp1 = SearchUtil.mapHCCCode(nodeTemp1);
 
                         if(!subCategory.data.containsKey(nodeTemp1)) {
                            subCategory.data.put(nodeTemp1, new SearchAPI.ICD10SubCategoryNodes());
                         }
                        subCategory.data.get(nodeTemp1).data.add(nodeObj);
                    }
                    else { //sub code-M84.3, parent - M84
                       Node nodeTemp1 = new Node ();
                       nodeTemp1.code = parent;
                       nodeTemp1 = SearchUtil.mapHCCCode(nodeTemp1);

                       if(!hierarchyMap.containsKey(nodeTemp1)) {
                           hierarchyMap.put(nodeTemp1, new  SearchAPI.ICD10SubCategory());
                           hierarchyMap.get(nodeTemp1).data.put(nodeObj,new SearchAPI.ICD10SubCategoryNodes() );
                       }    
                       else {
                              SearchAPI.ICD10SubCategory subCategory = hierarchyMap.get(nodeTemp1);
                              if(!subCategory.data.containsKey(nodeObj)) {
                                  subCategory.data.put(nodeObj, new SearchAPI.ICD10SubCategoryNodes());
                              }
                              else {
                                 SearchAPI.ICD10SubCategoryNodes oldList = subCategory.data.get(nodeObj);
                                 subCategory.data.put(nodeObj, oldList);
                              }
                            }
                         
                    }
                }
            }      
        }
          return  JSON.serialize(checkForChildrenWithHCC(hierarchyMapObj));
    }
 
  	public static SearchAPI.ICD10Hierarchy checkForChildrenWithHCC(SearchAPI.ICD10Hierarchy ICD10HierarchyObj) {
         for(Node level1Node: ICD10HierarchyObj.data.keyset()) {       
             if(level1Node.hasChildWithHcc!=true){
                 SearchAPI.ICD10SubCategory ICD10SubCategoryObj = ICD10HierarchyObj.data.get(level1Node);
                 for(Node level2Node : ICD10SubCategoryObj.data.keyset()) {
                      if(String.isNotBlank(level2Node.hccCode)){
                              level1Node.hasChildWithHcc=true;                                    
                       }
                     if(level2Node.hasChildWithHcc!=true) {
                         SearchAPI.ICD10SubCategoryNodes ICD10SubCategoryNodesObj = ICD10SubCategoryObj.data.get(level2Node);
                         for(Node level3Node : ICD10SubCategoryNodesObj.data) {
                              if(String.isNotBlank(level3Node.hccCode)){
                                      level2Node.hasChildWithHcc=true;
                                      level1Node.hasChildWithHcc=true;
                                      break;
                              }                             
                         }                         
                     }
                 }
             } 
         }
         return ICD10HierarchyObj;
     }
}