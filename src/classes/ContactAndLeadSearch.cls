public class ContactAndLeadSearch {
    public static List<List<SObject>> searchContactsAndLeads(String sSearchTerm){
        List<List<SObject>> lstSearchResult = [FIND :sSearchTerm IN NAME FIELDS RETURNING Contact(lastName),LEAD(lastName)];
        return lstSearchResult;
    }
}