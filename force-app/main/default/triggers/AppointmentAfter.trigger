trigger AppointmentAfter on Appointment__c (after insert, after update) {
  List<Appointment_Event__e> evs = new List<Appointment_Event__e>();
  for(Appointment__c a: Trigger.new){
    Appointment_Event__e e = new Appointment_Event__e();
    e.PatientId__c = ''+a.Patient__c; e.AppointmentId__c=''+a.Id; e.Status__c=a.Status__c; e.Start__c=a.Start__c; e.End__c=a.End__c;
    evs.add(e);
  }
  if(!evs.isEmpty()) EventBus.publish(evs);
}
