public class AnimalLocator {
	public static String getAnimalNameById(Integer iIdentifier) {
        String animalsName = '';
        String animalsSays = '';
        String animalsEats = '';
        Integer animalsId = 0;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://th-apex-http-callout.herokuapp.com/animals/'+iIdentifier);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response.
		if (response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            // Cast the values in the 'animals' key as a list
            Object animals = (Object)results.get('animal');
            System.debug('Received the following animals:'+JSON.serialize(animals));
            animal oAnimal = (animal)JSON.deserialize(JSON.serialize(animals), animal.class);
            animalsName = oAnimal.name;
            animalsSays = oAnimal.says;
                animalsEats = oAnimal.eats;
                animalsId = oAnimal.id;
        }
        return animalsName;
    }
    
    class animal{
        public Integer id{get;set;}
        public String says{get;set;}
        public String eats{get;set;}
        public String name{get;set;}
    }
}