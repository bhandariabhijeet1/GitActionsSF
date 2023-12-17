public class Node implements Comparable {
        
    	@AuraEnabled
    	public String code {get;set;}
        @AuraEnabled
    	public String description {get;set;}
        @AuraEnabled
    	public String href {get;set;}
        @AuraEnabled
    	public Integer rank {get;set;}
    	@AuraEnabled
    	public String hccCode {get;set;}
    	@AuraEnabled
    	public String hccDescription {get;set;}
    	@AuraEnabled
    	public Boolean isParent {get;set;}
    	@AuraEnabled
    	public Boolean hasChildWithHcc {get;set;}
    	@AuraEnabled
    	public List<Node> Node{get;set;}
    
        public Integer compareTo(Object obj) {
             Node nodeObj = (Node) obj;
            if(rank > nodeObj.rank && code.compareTo(nodeObj.code) == 1){
                return 1;
            }else if (rank < nodeObj.rank && code.compareTo(nodeObj.code) < 0){
                return -1;
            }else{
                return 0;
            }
        }
      	public String getParent() {
        if(code != null) {
            if(!code.containsAny('.')) {
                return '';
            }
            else {
                String [] splitCodeArray = code.split('\\.');
                String category = splitCodeArray[0];
                String subCategory = splitCodeArray[1];
                if(subCategory.length() == 1) {
                    return category;
                }
                else {
                   return category +'.' + subCategory.substring(0, 1);
                }
            }
         }
            return '';
     }
 
    public Boolean equals(Object obj) { 
        Node nodeObj = (Node) obj;
        if(nodeObj.code != null && code != null) {
        	if(nodeObj.code.compareTo(code) == 0) {
            	 return true;
        	}    
        }    
        return false;  
    } 
    
  }