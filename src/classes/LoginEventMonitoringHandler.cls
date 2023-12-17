public with sharing class LoginEventMonitoringHandler {
    public static List<LoginEvent> getLoginEvents() {
        return [SELECT Username,SourceIp, Country, City FROM LoginEvent where EventDate = Today];
    }
}