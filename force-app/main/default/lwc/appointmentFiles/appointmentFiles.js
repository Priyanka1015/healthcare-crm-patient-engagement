import { LightningElement, api, wire } from 'lwc';
import listByAppointment from '@salesforce/apex/AppointmentFileService.listByAppointment';
import getDownloadUrl from '@salesforce/apex/AppointmentFileService.getDownloadUrl';

export default class AppointmentFiles extends LightningElement {
  @api recordId; // Appointment__c Id (from record page)
  rows = [];

  @wire(listByAppointment, { appointmentId: '$recordId' })
  wired({ data, error }) {
    if (data) this.rows = data;
    if (error) console.error(error);
  }

  async download(e) {
    const id = e.target.dataset.id;
    try {
      const url = await getDownloadUrl({ fileId: id });
      window.open(url, '_blank');
    } catch (err) {
      // eslint-disable-next-line no-alert
      alert('Could not get download link.');
      console.error(err);
    }
  }
}
