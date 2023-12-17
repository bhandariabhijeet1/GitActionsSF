@isTest
global class smartLogicICDAPIMock implements HttpCalloutMock{
global System.HttpResponse respond(System.HttpRequest req){
        String endPoint = req.getEndpoint();
        System.debug('URIMock: '+endPoint);
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        System.debug('In Mock');
        res.setBody('{"codeProperties":[{"code":"M84.4","descFull":"Pathological fracture, not elsewhere classified","serviceDate":"10/01/2015","status":"New"},{"code":"S78.929A","descFull":"Partial traumatic amputation of unspecified hip and thigh, level unspecified, initial encounter","hcc":"HCC173","hccDesc":"Traumatic Amputations and Complications","serviceDate":"10/01/2015","status":"New"},{"code":"F10.29","descFull":"Alcohol dependence with unspecified alcohol-induced disorder","hcc":"HCC55","hccDesc":"Drug/Alcohol Dependence","serviceDate":"10/01/2015","status":"New"}],"status":{"messages":[{"code":1000,"name":"SUCCESS","severity":"INFO","description":"Successful service call","transactionId":"1495759188066"}]}}');

         system.assert(true);    
         System.debug('Returnig response: '+res.getBody());
	     return res;
    }
}