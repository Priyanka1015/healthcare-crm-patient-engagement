public with sharing class AppointmentTriggerHandler {
  public static void preventOverlaps(List<Appointment__c> news){
    Set<Id> pids = new Set<Id>(); for(Appointment__c a:news) if(a.Patient__c!=null) pids.add(a.Patient__c);
    if(pids.isEmpty()) return;
    Map<Id,List<Appointment__c>> mapx = new Map<Id,List<Appointment__c>>();
    for(Appointment__c ex:[SELECT Id, Patient__c, Start__c, End__c FROM Appointment__c WHERE Patient__c IN :pids]){
      List<Appointment__c> b = mapx.get(ex.Patient__c); if(b==null){ b=new List<Appointment__c>(); mapx.put(ex.Patient__c,b);} b.add(ex);
    }
    for(Appointment__c a:news){
      if(a.Patient__c==null || a.Start__c==null || a.End__c==null) continue;
      if(a.End__c <= a.Start__c){ a.addError('End time must be after Start time.'); continue; }
      List<Appointment__c> others = mapx.get(a.Patient__c); if(others==null) continue;
      for(Appointment__c b:others){ if(a.Id==b.Id) continue; if(a.Start__c < b.End__c && b.Start__c < a.End__c){ a.addError('This patient already has an appointment overlapping this time.'); break; } }
    }
  }

   // 🔔 Send reminder after the record is inserted
    public static void afterInsert(List<Appointment__c> newSK) {
        for (Appointment__c a : newSK) {
            if (a.Start__c != null) {
                AppointmentReminderService.sendAppointmentReminder(a.Id);
            }
        }
    }
}

