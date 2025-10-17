import { LightningElement, track } from 'lwc';
import getAppointments from '@salesforce/apex/PatientController.listAppointments';
import { subscribe, onError } from 'lightning/empApi';

export default class AppointmentLiveBoard extends LightningElement {
  @track appointments = [];
  channelName = '/event/Appointment_Event__e';
  subscription = null;

  connectedCallback() {
    this.loadAppointments();
    this.subscribeToEvents();
    onError(error => {
      // eslint-disable-next-line no-console
      console.error('EMP API error: ', JSON.stringify(error));
    });
  }

  loadAppointments() {
    getAppointments()
      .then(res => this.appointments = res)
      .catch(err => console.error(err));
  }

  subscribeToEvents() {
    if (this.subscription) return;
    subscribe(this.channelName, -1, () => {
      // whenever a platform event arrives, refresh the list
      this.loadAppointments();
    }).then(response => {
      this.subscription = response;
    });
  }
}
