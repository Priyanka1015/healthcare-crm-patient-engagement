public with sharing class AppointmentReminder implements Schedulable {
  public void execute(SchedulableContext sc){
    Datetime nowDt=System.now(); Datetime in2=nowDt.addHours(2);
    List<Appointment__c> ups=[SELECT Id,Patient__c,Start__c,End__c,Status__c FROM Appointment__c WHERE Start__c>=:nowDt AND Start__c<=:in2 AND Status__c='Scheduled' LIMIT 200];
    Set<Id> pids=new Set<Id>(); for(Appointment__c a:ups) if(a.Patient__c!=null) pids.add(a.Patient__c);
    Map<Id,Patient__c> pm=new Map<Id,Patient__c>([SELECT Id,Name,Primary_Email__c FROM Patient__c WHERE Id IN :pids]);
    List<Messaging.SingleEmailMessage> ms=new List<Messaging.SingleEmailMessage>();
    for(Appointment__c a:ups){ Patient__c p=pm.get(a.Patient__c); if(p==null || String.isBlank(p.Primary_Email__c)) continue;
      Messaging.SingleEmailMessage m=new Messaging.SingleEmailMessage(); m.setToAddresses(new String[]{p.Primary_Email__c}); m.setSubject('Appointment Reminder'); m.setPlainTextBody('Hello '+p.Name+', reminder for your appointment at '+String.valueOf(a.Start__c)+'.'); ms.add(m); }
    if(!ms.isEmpty()) Messaging.sendEmail(ms,false);
  }
}
