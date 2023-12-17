public class AccountHandler {
    public static Account insertNewAccount(String sAccountName){
        Account oAccount = new Account(name=sAccountName);
        try{
            insert oAccount;
            return oAccount;
        }
        catch(Exception e){
            return null;
        }
    }
}