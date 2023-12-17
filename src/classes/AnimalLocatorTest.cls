@isTest 
private class AnimalLocatorTest{
	@isTest    
	static void AnimalLocatorTestMethod() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new AnimalLocatorMock()); 
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        String actualValue = AnimalLocator.getAnimalNameById(1);
        // Verify that the response received contains fake values
        String expectedValue = 'chicken';
        System.assertEquals(actualValue, expectedValue);
    }
}