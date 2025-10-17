@isTest
private class AppointmentTriggerHandlerTest {
    @isTest
    static void testPreventOverlaps() {
        // Create a Patient
        Patient__c p = new Patient__c(
            Name = 'Test Patient',
            Primary_Email__c = 'test@example.com',
            Date_of_Birth__c = Date.today()
        );
        insert p;

        // Create a first Appointment
        Appointment__c a1 = new Appointment__c(
            Patient__c = p.Id,
            Start__c = System.now().addDays(1),
            End__c = System.now().addDays(1).addHours(1),
            Status__c = 'Scheduled'
        );
        insert a1;

        // Try creating an overlapping appointment
        Appointment__c a2 = new Appointment__c(
            Patient__c = p.Id,
            Start__c = a1.Start__c.addMinutes(30),
            End__c = a1.End__c.addHours(1),
            Status__c = 'Scheduled'
        );

        Test.startTest();
        Database.SaveResult result = Database.insert(a2, false);
        Test.stopTest();

        System.assertEquals(false, result.isSuccess(), 'Should prevent overlapping appointments');
    }
}
