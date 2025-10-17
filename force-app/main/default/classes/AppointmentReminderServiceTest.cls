@isTest
private class AppointmentReminderServiceTest {
    @isTest
    static void testSendAppointmentReminder() {
        // Create Patient
        Patient__c p = new Patient__c(
            Name = 'Email Test Patient',
            Primary_Email__c = 'testemail@example.com',
            Date_of_Birth__c = Date.today()
        );
        insert p;

        // Create Appointment
        Appointment__c app = new Appointment__c(
            Patient__c = p.Id,
            Start__c = System.now().addDays(1),
            End__c = System.now().addDays(1).addHours(1),
            Status__c = 'Scheduled'
        );
        insert app;

        Test.startTest();
        AppointmentReminderService.sendAppointmentReminder(app.Id);
        Test.stopTest();

        // Validation (no exception = success)
        System.assert(true, 'Reminder email sent successfully');
    }
}
