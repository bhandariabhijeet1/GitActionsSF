public class ParkLocator {
    public static List<String> country(String sCountry){
        List<String> lstParks = new List<String>();
        ParkService.ParksImplPort oPark = new ParkService.ParksImplPort();
        lstParks = oPark.byCountry(sCountry);
        System.debug('==============='+lstParks);
        return lstParks;
    }
}