public with sharing class AppointmentFileService {

    public class FileInput {
        @AuraEnabled public Id appointmentId;
        @AuraEnabled public String fileName;
        @AuraEnabled public String bucket;
        @AuraEnabled public String key;
        @AuraEnabled public String contentType;
        @AuraEnabled public Integer sizeBytes;
    }
    public class FileRow {
        @AuraEnabled public Id id;
        @AuraEnabled public String fileName;
        @AuraEnabled public String bucket;
        @AuraEnabled public String key;
        @AuraEnabled public String contentType;
        @AuraEnabled public Integer sizeBytes;
        @AuraEnabled public Datetime uploadedOn;
    }

    @AuraEnabled
    public static Id createFile(FileInput input) {
        Appointment_File__c af = new Appointment_File__c(
            Appointment__c = input.appointmentId,
            File_Name__c    = input.fileName,
            S3_Bucket__c    = input.bucket,
            S3_Key__c       = input.key,
            Content_Type__c = input.contentType,
            Size_Bytes__c   = input.sizeBytes
        );
        insert af;
        return af.Id;
    }

    @AuraEnabled(cacheable=true)
    public static List<FileRow> listByAppointment(Id appointmentId) {
        List<FileRow> out = new List<FileRow>();
        for (Appointment_File__c r : [
            SELECT Id, File_Name__c, S3_Bucket__c, S3_Key__c, Content_Type__c, Size_Bytes__c, CreatedDate
            FROM Appointment_File__c
            WHERE Appointment__c = :appointmentId
            ORDER BY CreatedDate DESC
        ]) {
            FileRow row = new FileRow();
            row.id = r.Id;
            row.fileName = r.File_Name__c;
            row.bucket = r.S3_Bucket__c;
            row.key = r.S3_Key__c;
            row.contentType = r.Content_Type__c;
            row.sizeBytes = (Integer)r.Size_Bytes__c;
            row.uploadedOn = r.CreatedDate;
            out.add(row);
        }
        return out;
    }

    // Calls your API Gateway /download to get a short-lived signed GET URL.
    @AuraEnabled
    public static String getDownloadUrl(Id fileId) {
        Appointment_File__c r = [
            SELECT S3_Bucket__c, S3_Key__c, File_Name__c FROM Appointment_File__c WHERE Id = :fileId
        ];
        HttpRequest req = new HttpRequest();
        // Named Credential you already use (same domain as /presign)
        // Adjust path if your Lambda expects /download?bucket=...&key=...
        req.setMethod('POST');
        req.setEndpoint('callout:PresignService/download');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(new Map<String,Object>{
            'bucket' => r.S3_Bucket__c,
            'key'    => r.S3_Key__c,
            'dispositionFilename' => r.File_Name__c,
            'expiresIn' => 60
        }));

        Http http = new Http();
        HTTPResponse res = http.send(req);
        if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
            Map<String,Object> body = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
            return (String)body.get('url');
        }
        throw new AuraHandledException('Failed to get download URL: ' + res.getStatus() + ' ' + res.getBody());
    }
}
