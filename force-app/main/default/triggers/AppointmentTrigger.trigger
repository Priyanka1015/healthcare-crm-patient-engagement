trigger AppointmentTrigger on Appointment__c (
    before insert, before update,
    after insert
) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            AppointmentTriggerHandler.preventOverlaps(Trigger.new);
        }
    }
    if (Trigger.isAfter && Trigger.isInsert) {
        AppointmentTriggerHandler.afterInsert(Trigger.new);
    }
}
