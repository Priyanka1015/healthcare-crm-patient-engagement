public with sharing class PatientController {

    // ---------- DTO used by patientList LWC ----------
    public class PatientDTO {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public Date   dob;
        @AuraEnabled public String email;

        public PatientDTO() {} // no-arg ctor (for safety)

        public PatientDTO(Patient__c p) {
            id    = (String)p.Id;
            name  = p.Name;
            dob   = p.Date_of_Birth__c;
            email = p.Primary_Email__c;
        }
    }

    // ---------- LWC: patientList ----------
    @AuraEnabled(cacheable=true)
    public static List<PatientDTO> listPatients() {
        List<PatientDTO> out = new List<PatientDTO>();
        for (Patient__c p : [
            SELECT Id, Name, Date_of_Birth__c, Primary_Email__c
            FROM Patient__c
            ORDER BY Name
            LIMIT 200
        ]) {
            out.add(new PatientDTO(p));
        }
        return out;
    }

    // ---------- LWC: appointmentLiveBoard ----------
    @AuraEnabled(cacheable=true)
    public static List<Appointment__c> listAppointments() {
        return [
            SELECT Id, Patient__c, Patient__r.Name, Start__c, End__c, Status__c
            FROM Appointment__c
            ORDER BY Start__c DESC
            LIMIT 50
        ];
    }

    // ---------- LWC: appointmentScheduler ----------
    @AuraEnabled
    public static Id createAppointment(Id patientId, Datetime startTime, Datetime endTime) {
        Appointment__c a = new Appointment__c(
            Patient__c = patientId,
            Start__c   = startTime,
            End__c     = endTime,
            Status__c  = 'Scheduled'
        );
        insert a;

        // Publish a platform event for live updates
        Appointment_Event__e evt = new Appointment_Event__e();
        evt.PatientId__c     = (String)patientId;
        evt.AppointmentId__c = (String)a.Id;
        evt.Start__c         = startTime;
        evt.End__c           = endTime;
        evt.Status__c        = 'Scheduled';
        Database.SaveResult evRes = EventBus.publish(evt);
        // (ignore evRes here; LWC also refreshes via CDC if enabled)

        return a.Id;
    }

    // ---------- File upload: presigned URL request ----------
    // Make sure your Named Credential "Presign_Service" is configured and you set the API key header value.
    @AuraEnabled
    public static String requestPresignedUrl(Id appointmentId, String fileName, String contentType) {
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint('callout:Presign_Service/Prod/presign');
        // req.setHeader('YZcm7G1MRPn246WYj8TN9fFlMm5AFla6WDsbVvx6', 'sztjbvdvcș'); // TODO: replace

        Map<String, Object> payload = new Map<String, Object>{
            'fileName'    => fileName,
            'contentType' => contentType,
            'prefix'      => 'uploads'
        };
        req.setBody(JSON.serialize(payload));

        Http http = new Http();
        HTTPResponse res = http.send(req);

        if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
            return res.getBody();
        }
        throw new AuraHandledException('Failed to get presigned URL: ' + res.getStatus() + ' ' + res.getBody());
    }
    @AuraEnabled(cacheable=true)
public static List<Patient__c> getAllPatients() {
    return [
        SELECT Id, Name
        FROM Patient__c
        ORDER BY Name
    ];
}

}
