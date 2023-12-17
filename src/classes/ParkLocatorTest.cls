@isTest 
private class ParkLocatorTest{
	@isTest    
	static void ParkLocatorTestMethod() {
        // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new ParkServiceMock());
        // Call the method that invokes a callout
        List<String> lstParks = new List<String>();
        lstParks = ParkLocator.country('India');
        // Verify that a fake result is returned
        System.assert(lstParks.size() > 0); 
    }
}