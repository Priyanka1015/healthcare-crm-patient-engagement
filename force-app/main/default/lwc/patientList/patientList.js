import { LightningElement, track } from 'lwc';
import listPatients from '@salesforce/apex/PatientController.listPatients';

export default class PatientList extends LightningElement {
  @track patients = [];
  columns = [
    { label: 'Name', fieldName: 'name' },
    { label: 'Date of Birth', fieldName: 'dob', type: 'date' },
    { label: 'Email', fieldName: 'email' },
    { label: 'Id', fieldName: 'id' }
  ];

  connectedCallback() {
    this.loadPatients();
  }

  loadPatients() {
    listPatients()
      .then(res => { this.patients = res || []; })
      .catch(err => { console.error('Error loading patients:', err); });
  }
}
