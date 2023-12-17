public with sharing class SearchParseUtil{ 

	//Class to represent Search Results
    public class TermSearchResults {
        public List<Node> termSearchNodeList {get;set;}
    }    
    
    //Class to represent Search Results
    /*public class TermSearchResultsJSON {
        public List<DummyNode> termSearchNodeListSON {get;set;}
    }*/    
    
    //Method to deserialize the response body
    public static TermSearchResults parseSearchResults(Dom.Document doc){
        TermSearchResults tsgResults = new TermSearchResults();
        SearchAPIFilters oSearchAPIFilters = new SearchAPIFilters();
        Map<String, String> mapConfigurations = new Map<String, String>();  
        tsgResults.termSearchNodeList = new List<Node>();
        
        try
        {            
            for(configurations__mdt oConfiguration : [SELECT DeveloperName, value__c FROM configurations__mdt])
            {
                mapConfigurations.put(oConfiguration.DeveloperName, oConfiguration.value__c);
            }
            Dom.XMLNode tsgs = doc.getRootElement();
            for(Dom.XMLNode tsg : tsgs.getChildren()) {
                parseTermSearchGroup(tsgResults.termSearchNodeList,tsg,mapConfigurations,true);
            }
            
            System.debug(' @@@ List ' + tsgResults.termSearchNodeList.size());
            System.debug(' @@@ List Data' + tsgResults);
            Integer i=1;
            for(Node n : tsgResults.termSearchNodeList){
                System.debug(' AAA@ '+i+' '+n.code+' '+n.description);
                i++;                
            }
        }
        catch(Exception e)
        {
            System.debug(e.getStackTraceString());
        }
        return tsgResults;
    }

	public static void parseTermSearchGroup(List<Node> termSearchNodeList,Dom.XMLNode tsg, Map<String, String> mapConfigurations, Boolean bIsCategoryNode){
        Node tsgData = new Node();   
        Node oTempNode = new Node();
        SearchAPIFilters oSearchAPIFilters = new SearchAPIFilters();        

        tsgData.href=tsg.getAttributeValue(SearchConstants.HREF_BEG, null); 
        tsgData.isParent = SearchUtil.hasChildNodes(tsg, bIsCategoryNode, false);       
        
        //Code block to populate Temp Node which would be a clone of the termSearchNodeList.add(tsgData); Node and test filtering
        oTempNode.code = tsg.getChildElement(SearchConstants.CODE, null).getText();
        oTempNode.description = tsg.getChildElement(SearchConstants.DESCRIBE, null).getText();    
        oTempNode.isParent = SearchUtil.hasChildNodes(tsg, bIsCategoryNode, false); 
        
        //Add at level 1- oTempNode         
        if(String.isNotBlank(oTempNode.code) && !oSearchAPIFilters.blockNode(oTempNode, mapConfigurations))
        {
            termSearchNodeList.add(tsgData);           
        }
                                
        for(Dom.XMLNode tsgNode : tsg.getChildren()) {
            System.debug('TTT: '+tsgNode.getNodeType()+' '+tsgNode.getName()+' '+tsgNode.getText());
            if(tsgNode.getNodeType() == Dom.XmlNodeType.ELEMENT){
                parseTSGNode(tsgNode,termSearchNodeList,mapConfigurations,true);
            }
            if(tsgNode.getName().equals(SearchConstants.CODE)){
                tsgData.code=tsgNode.getText();                
                tsgData = SearchUtil.mapHCCCode(tsgData);
            }
            if(tsgNode.getName().equals(SearchConstants.DESCRIBE)){
                tsgData.description=tsgNode.getText();
            }
            if(tsgNode.getName().equals(SearchConstants.RANK)){
                tsgData.rank=Integer.valueOf(tsgNode.getText());
            }
        }        
        //termSearchNodeList.sort();
    }
    
    public static void parseTSGNode(Dom.XMLNode tsgNode,List<Node> nodeList, Map<String, String> mapConfigurations, Boolean bIsSubCategoryNode){
        if(tsgNode!=null){
         
            Node dataNode = new Node();
            SearchAPIFilters oSearchAPIFilters = new SearchAPIFilters();            
            List<Dom.XMLNode> tsgNodeList = tsgNode.getChildren();
            
            dataNode.href = tsgNode.getAttributeValue(SearchConstants.HREF_BEG, null);
            dataNode.isParent = SearchUtil.hasChildNodes(tsgNode,false, bIsSubCategoryNode);       
            for(Dom.XMLNode tsgNodeData : tsgNodeList) {
                if(tsgNodeData.getName() != null){
                    if(tsgNodeData.getName().equals(SearchConstants.NODE)){
                        parseTSGNode(tsgNodeData,nodeList, mapConfigurations, false); 
                    }
                    if(tsgNodeData.getName().equals(SearchConstants.CODE)){
                        dataNode.code=tsgNodeData.getText();
                        dataNode = SearchUtil.mapHCCCode(dataNode);
                    }
                    if(tsgNodeData.getName().equals(SearchConstants.DESCRIBE)){
                        dataNode.description=tsgNodeData.getText();
                    }
                    if(tsgNodeData.getName().equals(SearchConstants.RANK)){
                        dataNode.rank=Integer.valueOf(tsgNodeData.getText());
                    }
                }
            }
            if(String.isNotBlank(dataNode.code) && !oSearchAPIFilters.blockNode(dataNode, mapConfigurations)){
                //If b is subcat(level 2) add to level 2 else add to level 3 list
                nodeList.add(dataNode);
            }
        }
    }
    
    //Method to deserialize the response body
    public static TermSearchResults parseICD10SearchResults(Dom.Document doc, String sICD10Code){
        System.debug('**parseICD10SearchResults');
        TermSearchResults tsgResults = new TermSearchResults();
        SearchAPIFilters oSearchAPIFilters = new SearchAPIFilters();   
        Map<String, String> mapConfigurations = new Map<String, String>();    
        tsgResults.termSearchNodeList = new List<Node>();   

        try
        {            
            Dom.XMLNode tsgs = doc.getRootElement();
            for(configurations__mdt oConfiguration : [SELECT DeveloperName, value__c FROM configurations__mdt])
            {
                mapConfigurations.put(oConfiguration.DeveloperName, oConfiguration.value__c);
            }
    
            if(tsgs.getName().equalsIgnoreCase(SearchConstants.CODE_PROPERTIES))
            { 
                Node oNode = new Node();
                oNode.code = sICD10Code;
                oNode.description = tsgs.getChildElement(SearchConstants.DESC_FULL, null).getText();
                oNode.isParent = SearchUtil.hasChildNodes(tsgs, false, false);
                oNode = SearchUtil.mapHCCCode(oNode);        
                if(String.isNotBlank(oNode.code) && !oSearchAPIFilters.blockNode(oNode, mapConfigurations))
                {
                     tsgResults.termSearchNodeList.add(oNode);
                }                       
            }
        }
        catch(Exception e)
        {
            System.debug(e.getStackTraceString());
        }
        return tsgResults;
    }
    
    //Method to parse the ICD9 mapping DOM and return the ICD 9 code
    public static String parseICD9Mapping(Dom.Document doc)
    {
        String sICD9Codes = '';
        List<Node> nodeList = new List<Node>();
        Map<String, String> mapConfigurations = new Map<String, String>();   
        
        Dom.XMLNode ICD9Nodes = doc.getRootElement();
        for(configurations__mdt oConfiguration : [SELECT DeveloperName, value__c FROM configurations__mdt])
        {
            mapConfigurations.put(oConfiguration.DeveloperName, oConfiguration.value__c);
        }
        
        if(ICD9Nodes.getName().equals(SearchConstants.ICD_9_MAPPING))
        {
            SearchParseUtil.parseTSGNode(ICD9Nodes,nodeList,mapConfigurations, false);
            if(nodeList != null && nodeList.size() > 0)
            {
                for(Node oNode : nodeList)
                {
                    sICD9Codes += oNode.code + ',';
                }
            }
            sICD9Codes = sICD9Codes.substring(0, sICD9Codes.length()-1);
        }
        else if(ICD9Nodes.getName().equals(SearchConstants.NOTIFICATION))
        {
            if(ICD9Nodes.getChildElement(SearchConstants.ERROR, null) != null)
            {
                sICD9Codes = 'NA';   
            }            
        }
        
        return sICD9Codes;
    }
    
    //Function to return the List of Notes present inside an instructional Note response
    public static List<SearchAPI.Notes> parseICDInstructionalNotes(Dom.Document doc, String sRootNode)
    {
        List<SearchAPI.Notes> lstNotes = new List<SearchAPI.Notes>();
        SearchAPI.Notes oNote;
        Dom.XMLNode ICD10InstructionalNotes = doc.getRootElement();
        
        if(ICD10InstructionalNotes.getName().equals(sRootNode))
        {
            for(Dom.XMLNode Note : ICD10InstructionalNotes.getChildren())
            {
                oNote = new SearchAPI.Notes();
                oNote = getNoteDetails(Note);
                lstNotes.add(oNote);
            }            
        }
        return lstNotes;
    }
    
    //Fucntion to Fetch individual child notes from a Note Type
    public static SearchAPI.Notes getNoteDetails(Dom.XMLNode Note)
    {
        SearchAPI.Notes oNote = new SearchAPI.Notes();
        List<String> lstNodeText = new List<String>();
        oNote.sNoteType = (Note.getName()).capitalize();
        for(Dom.XMLNode ChildNotes : Note.getChildren())
        {
            if(ChildNotes.getName().equals(SearchConstants.HEADER)){
                oNote.sHeaderNote = (ChildNotes.getText()).capitalize();
            }
            else if(ChildNotes.getName().equals(SearchConstants.NOTE))
            {
                lstNodeText.add(ChildNotes.getText());
            }
        }
        oNote.lstNote = lstNodeText;
            
        return oNote;
    }
    
    //Function to return the List of Notes present inside an instructional Note response
    public static List<SearchAPI.Notes> parseICDIncludeExcludeNotes(Dom.Document doc)
    {
        List<SearchAPI.Notes> lstNotes = new List<SearchAPI.Notes>();
        SearchAPI.Notes oNote;
        Dom.XMLNode ICD10InstructionalNotes = doc.getRootElement();
        
        if(ICD10InstructionalNotes.getName().equals(SearchConstants.INCLUDE_EXCLUDE_NOTES))
        {
            for(Dom.XMLNode Note : ICD10InstructionalNotes.getChildren())
            {
                oNote = new SearchAPI.Notes();
                oNote = getIncludeExcludeNoteDetails(Note);
                lstNotes.add(oNote);
            }            
        }
        return lstNotes;
    }
    
    //Function to Fetch individual child notes from a Note Type
    public static SearchAPI.Notes getIncludeExcludeNoteDetails(Dom.XMLNode Note)
    {
        SearchAPI.Notes oNote = new SearchAPI.Notes();
        List<SearchAPI.ICDIncludeExcludeNote> lstNoteTextandIndentation = new List<SearchAPI.ICDIncludeExcludeNote>();
        
        oNote.sNoteType = Note.getName();
        for(Dom.XMLNode ChildNotes : Note.getChildren())
        {
            if(ChildNotes.getName().containsIgnoreCase(SearchConstants.HEADER)){
                oNote.sHeaderType = ChildNotes.getName();
                oNote.sHeaderNote = ChildNotes.getText();
            }
            else if(ChildNotes.getName().containsIgnoreCase(SearchConstants.NOTE))
            {
                String sNoteText = ChildNotes.getChildElement(SearchConstants.CONTENT, null).getText();
                Integer iNoteIndent = Integer.valueOf(ChildNotes.getAttributeValue(SearchConstants.INDENTATION, null));
                lstNoteTextandIndentation.add(new SearchAPI.ICDIncludeExcludeNote(sNoteText,iNoteIndent));
            }
        }
        oNote.lstNoteWithIndentation = lstNoteTextandIndentation;
            
        return oNote;
    }
    
    public static List<Node> parseICD10RangeResults(Dom.Document RangeData){
        System.debug('parseICD10RangeResults');

        List<Node> lstNode = new List<Node>();
        SearchAPIFilters oSearchAPIFilters = new SearchAPIFilters();   
        Map<String, String> mapConfigurations = new Map<String, String>();    
        Node oRangeNode;

        Dom.XmlNode CodeRange = RangeData.getRootElement();
        for(configurations__mdt oConfiguration : [SELECT DeveloperName, value__c FROM configurations__mdt])
        {
            mapConfigurations.put(oConfiguration.DeveloperName, oConfiguration.value__c);
        }
        if(CodeRange.getName().equals(SearchConstants.CODE_RANGE))
        {
            for(Dom.XmlNode rangeItem : CodeRange.getChildren())
            {
                if(rangeItem.getName().equals(SearchConstants.RANGE_ITEM))
                {
                    oRangeNode = new Node();
                    oRangeNode.code = rangeItem.getChildElement(SearchConstants.CODE, null).getText();
                    oRangeNode.description = rangeItem.getChildElement(SearchConstants.DESCRIPTION, null).getText();                                      
                    oRangeNode.href = rangeItem.getAttributeValue(SearchConstants.HREF, null);
                    System.debug('**Calling isparent');
                    oRangeNode.isParent = SearchUtil.hasChildNodes(rangeItem,true,false);     
                    oRangeNode = SearchUtil.mapHCCCode(oRangeNode);  
                    if(String.isNotBlank(oRangeNode.code) && !oSearchAPIFilters.blockNode(oRangeNode, mapConfigurations))
                    {
                         lstNode.add(oRangeNode);
                    }                       
                }
            }
        }
        for(Node n : lstNode){
        	System.debug('**code'+n.code);
            System.debug('**hccCode'+n.hccCode);
            System.debug('**isParent'+n.isParent);
            System.debug('**hasChildWithHcc'+n.hasChildWithHcc);
        }
        
        return lstNode;
    }
}