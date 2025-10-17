public with sharing class AppointmentReminderAction {
    @InvocableMethod(
        label='Send Appointment Reminder'
        description='Sends the standard reminder email for each Appointment Id'
    )
    public static void sendReminders(List<Id> appointmentIds) {
        for (Id apptId : appointmentIds) {
            AppointmentReminderService.sendAppointmentReminder(apptId);
        }
    }
}
