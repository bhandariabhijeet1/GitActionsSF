public class ContactSearch {
    public static List<Contact> searchForContacts(String sContactLastName, String sMailingPostalCode){
        return ([SELECT Id, Name FROM Contact WHERE lastName=:sContactLastName AND MailingPostalCode=:sMailingPostalCode]);
    }
}