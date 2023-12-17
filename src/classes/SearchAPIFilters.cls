public class SearchAPIFilters {
    
    public boolean blockNode(Node oNode, Map<String,String> mapConfigurations)
    {
        Boolean bDiscardNode = false;
        System.debug(oNode.Code+'=====oNode.isParent==='+oNode.isParent);
        if(
            mapConfigurations.containsKey('Enable_Data_filters') && mapConfigurations.get('Enable_Data_filters').equalsIgnoreCase('true') && 
            ((mapConfigurations.containsKey('Exclude_Code_Prefix') && String.isNotBlank(mapConfigurations.get('Exclude_Code_Prefix')) && hasDiscardPrefix(SearchConstants.CODE, SearchConstants.PREFIX, oNode.code, mapConfigurations)) || 
            (mapConfigurations.containsKey('Exclude_Description_Prefix') && String.isNotBlank(mapConfigurations.get('Exclude_Description_Prefix')) && hasDiscardPrefix(SearchConstants.DESCRIPTION, SearchConstants.PREFIX, oNode.description, mapConfigurations)) ||
            (mapConfigurations.containsKey('Exclude_Code_Contains') && String.isNotBlank(mapConfigurations.get('Exclude_Code_Contains')) && hasDiscardPrefix(SearchConstants.CODE, SearchConstants.CONTAINS, oNode.code, mapConfigurations)) || 
            (mapConfigurations.containsKey('Exclude_Description_Contains') && String.isNotBlank(mapConfigurations.get('Exclude_Description_Contains')) && hasDiscardPrefix(SearchConstants.DESCRIPTION, SearchConstants.CONTAINS, oNode.description, mapConfigurations)) ||
            (mapConfigurations.containsKey('Exclude_Code_Equals') && String.isNotBlank(mapConfigurations.get('Exclude_Code_Equals')) && hasDiscardPrefix(SearchConstants.CODE, SearchConstants.EQUALS, oNode.code, mapConfigurations)) || 
            (mapConfigurations.containsKey('Exclude_Description_Equals') && String.isNotBlank(mapConfigurations.get('Exclude_Description_Equals')) && hasDiscardPrefix(SearchConstants.DESCRIPTION, SearchConstants.EQUALS, oNode.description, mapConfigurations)))
        )
        {
            bDiscardNode = true;
        }
        
        return bDiscardNode;
    }
    
    //Function to identify if given text contains the code which has to be discarded.
   private boolean hasDiscardPrefix(String sSearchTerm , String sSearchType, String verificationText, map<String, String> mapConfigurations){        
        List<String> lstString = new List<String>();
        Boolean bHasDiscardText = false;
        String sTextToDiscard = '';
                
        if(sSearchTerm.equalsIgnoreCase(SearchConstants.CODE) && sSearchType.equalsIgnoreCase(SearchConstants.PREFIX))
        {
            sTextToDiscard = mapConfigurations.containsKey('Exclude_Code_Prefix') ? mapConfigurations.get('Exclude_Code_Prefix') : null;
        }
        else if(sSearchTerm.equalsIgnoreCase(SearchConstants.DESCRIPTION) && sSearchType.equalsIgnoreCase(SearchConstants.PREFIX))
        {
            sTextToDiscard = mapConfigurations.containsKey('Exclude_Description_Prefix') ? mapConfigurations.get('Exclude_Description_Prefix') : null;
        }
        else if(sSearchTerm.equalsIgnoreCase(SearchConstants.CODE) && sSearchType.equalsIgnoreCase(SearchConstants.CONTAINS))
        {
            sTextToDiscard = mapConfigurations.containsKey('Exclude_Code_Contains') ? mapConfigurations.get('Exclude_Code_Contains') : null;
        }
        else if(sSearchTerm.equalsIgnoreCase(SearchConstants.DESCRIPTION) && sSearchType.equalsIgnoreCase(SearchConstants.CONTAINS))
        {
            sTextToDiscard = mapConfigurations.containsKey('Exclude_Description_Contains') ? mapConfigurations.get('Exclude_Description_Contains') : null;
        }
        else if(sSearchTerm.equalsIgnoreCase(SearchConstants.CODE) && sSearchType.equalsIgnoreCase(SearchConstants.EQUALS))
        {
            sTextToDiscard = mapConfigurations.containsKey('Exclude_Code_Equals') ? mapConfigurations.get('Exclude_Code_Equals') : null;
        }
        else if(sSearchTerm.equalsIgnoreCase(SearchConstants.DESCRIPTION) && sSearchType.equalsIgnoreCase(SearchConstants.EQUALS))
        {
            sTextToDiscard = mapConfigurations.containsKey('Exclude_Description_Equals') ? mapConfigurations.get('Exclude_Description_Equals') : null;
        }
        
        if(String.isNotBlank(sTextToDiscard))
        {
            lstString = sTextToDiscard.split(',');
        }    
        
        for(String sMatchToDiscard : lstString)
        {
            if(sSearchType.equalsIgnoreCase(SearchConstants.PREFIX) && verificationText.toLowerCase().startsWith(sMatchToDiscard.toLowerCase()))
            {
                bHasDiscardText = true;
                break;
            }
            else if(sSearchType.equalsIgnoreCase(SearchConstants.CONTAINS) && verificationText.containsIgnoreCase(sMatchToDiscard))
            {
                bHasDiscardText = true;
                break;
            }
            else if(sSearchType.equalsIgnoreCase(SearchConstants.EQUALS) && verificationText.equalsIgnoreCase(sMatchToDiscard))
            {
                bHasDiscardText = true;
                break;
            }
        }   
        
        return bHasDiscardText;
   }

}