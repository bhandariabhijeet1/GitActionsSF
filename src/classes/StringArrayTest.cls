public class StringArrayTest {
    public static List<String> generateStringArray(Integer iNumber){
        List<String> lstString = new List<String>();
        for(Integer iIndex = 0; iIndex < iNumber ; iIndex++){
            lstString.add('Test '+iIndex);
        }
        return lstString;
    }
}