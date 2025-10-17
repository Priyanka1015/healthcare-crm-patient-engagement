public with sharing class AppointmentReminderService {
    @future
    public static void sendAppointmentReminder(Id appointmentId) {
        // 1) Pull the appointment + patient's primary email
        Appointment__c a = [
            SELECT Id, Name, Start__c,
                   Patient__r.Name,
                   Patient__r.Primary_Email__c
            FROM Appointment__c
            WHERE Id = :appointmentId
            LIMIT 1
        ];

        if (String.isBlank(a.Patient__r.Primary_Email__c)) {
            // No email on patient; nothing to send
            return;
        }

        // 2) Build RSVP links (replace with your real API Gateway URL)
        String baseUrl = 'https://4gidambccc.execute-api.us-west-2.amazonaws.com/Prod/rsvp';
        // https://4gidambccc.execute-api.us-west-2.amazonaws.com/Prod/presign
        String confirmUrl    = baseUrl + '?appointmentId=' + a.Id + '&action=Confirmed';
        String rescheduleUrl = baseUrl + '?appointmentId=' + a.Id + '&action=Reschedule';
        String cancelUrl     = baseUrl + '?appointmentId=' + a.Id + '&action=Cancelled';

        // 3) Compose email
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        msg.setToAddresses(new String[] { a.Patient__r.Primary_Email__c });
        msg.setSubject('Appointment Reminder – ' + a.Name);

        String html =
            'Hello ' + a.Patient__r.Name + ',<br/><br/>' +
            'Your appointment is scheduled for <b>' + String.valueOf(a.Start__c.format()) + '</b>.<br/><br/>' +
            'Please confirm or manage your appointment:<br/><br/>' +
            '<a href="' + confirmUrl + '">✅ Confirm</a>&nbsp;&nbsp;' +
            '<a href="' + rescheduleUrl + '">🔁 Reschedule</a>&nbsp;&nbsp;' +
            '<a href="' + cancelUrl + '">❌ Cancel</a><br/><br/>' +
            'Thank you,<br/>Healthcare CRM';

        msg.setHtmlBody(html);

        // (Optional) send from Org-Wide Email Address if available
        List<OrgWideEmailAddress> owea = [SELECT Id FROM OrgWideEmailAddress LIMIT 1];
        if (!owea.isEmpty()) msg.setOrgWideEmailAddressId(owea[0].Id);

        // 4) Send
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { msg });
    }
}
