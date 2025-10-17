public with sharing class AppointmentFileController {
    @AuraEnabled
    public static void attachFileKey(Id appointmentId, String fileKey) {
        if (appointmentId == null || String.isBlank(fileKey)) {
            throw new AuraHandledException('appointmentId and fileKey are required.');
        }
        update new Appointment__c(
            Id = appointmentId,
            File_Key__c = fileKey
        );
    }
}
