public with sharing class testAPEXClass {
    public Integer iAccountCount = 0;
    
    public testAPEXClass() {
        Integer iAccountCount = 0;
        for(Account oAccount : [SELECT ID, Name FROM Account LIMIT 50000]){
            System.debug('======here111======'+oAccount.Name);
            iAccountCount++;
        }
        System.debug('======here222======'+iAccountCount);
    }
}