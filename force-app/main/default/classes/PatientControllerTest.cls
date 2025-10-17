@IsTest
private class PatientControllerTest {

    @TestSetup
    static void setupData() {
        // Seed one patient
        Patient__c p = new Patient__c(
            Name = 'John Test',
            Date_of_Birth__c = Date.newInstance(1990, 1, 1),
            Primary_Email__c = 'john@test.com',
            MRN__c = 'MRN-001'
        );
        insert p;
    }

    @IsTest
    static void testListPatients() {
        Test.startTest();
        List<PatientController.PatientDTO> res =
            PatientController.listPatients('John');
        Test.stopTest();

        System.assertEquals(1, res.size(), 'Should find 1 patient named John');
        System.assertEquals('John Test', res[0].name);
    }

    @IsTest
    static void testCreateAppointment_NoOverlap() {
        Id pId = [SELECT Id FROM Patient__c LIMIT 1].Id;
        Datetime startDt = System.now().addDays(1);
        Datetime endDt   = startDt.addHours(1);

        Test.startTest();
        Id apptId = PatientController.createAppointment(pId, startDt, endDt);
        Test.stopTest();

        System.assertNotEquals(null, apptId, 'Appointment should be created');
    }

    @IsTest
    static void testCreateAppointment_OverlapBlocked() {
        Id pId = [SELECT Id FROM Patient__c LIMIT 1].Id;

        Datetime s1 = System.now().addDays(2);
        Datetime e1 = s1.addHours(1);

        insert new Appointment__c(
            Patient__c = pId,
            Start__c   = s1,
            End__c     = e1,
            Status__c  = 'Scheduled'
        );

        Appointment__c overlap = new Appointment__c(
            Patient__c = pId,
            Start__c   = s1.addMinutes(30),
            End__c     = e1.addMinutes(30),
            Status__c  = 'Scheduled'
        );

        Test.startTest();
        Database.SaveResult sr = Database.insert(overlap, /*allOrNone*/ false);
        Test.stopTest();

        System.assertEquals(false, sr.isSuccess(),
            'Second overlapping appointment should be blocked by trigger');
    }
}
