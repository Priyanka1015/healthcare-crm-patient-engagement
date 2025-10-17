import { LightningElement, track } from 'lwc';
import getAllPatients from '@salesforce/apex/PatientController.getAllPatients';
import createAppointment from '@salesforce/apex/PatientController.createAppointment';
import requestPresignedUrl from '@salesforce/apex/PatientController.requestPresignedUrl';

export default class AppointmentScheduler extends LightningElement {
  @track patients = [];
  @track selectedPatient;
  @track startTime;
  @track endTime;

  @track lastAppointmentId = null;
  @track file = null;
  @track uploadStatus = '';
  get disableUpload() {
    return !this.file || !this.lastAppointmentId;
  }

  connectedCallback() {
    this.loadPatients();
  }

  loadPatients() {
    getAllPatients()
      .then((res) => {
        this.patients = res.map(p => ({ label: p.Name, value: p.Id }));
      })
      .catch((err) => console.error('Error fetching patients:', err));
  }

  handlePatientChange(e) { this.selectedPatient = e.detail.value; }
  handleStartChange(e) { this.startTime = e.target.value; }
  handleEndChange(e) { this.endTime = e.target.value; }

  async handleCreate() {
    if (!this.selectedPatient || !this.startTime || !this.endTime) {
      alert('Please fill in all required fields.');
      return;
    }
    try {
      const id = await createAppointment({
        patientId: this.selectedPatient,
        startTime: this.startTime,
        endTime: this.endTime
      });
      this.lastAppointmentId = id;
      this.uploadStatus = `Appointment created: ${id}`;
    } catch (e) {
      console.error(e);
      this.uploadStatus = 'Error creating appointment';
    }
  }

  handleFileChange(e) {
    const files = e.target.files || [];
    this.file = files.length ? files[0] : null;
  }

  async handleUpload() {
    if (!this.file || !this.lastAppointmentId) return;
    try {
      // 1) ask Apex for a presigned URL
      const raw = await requestPresignedUrl({
        appointmentId: this.lastAppointmentId,
        fileName: this.file.name,
        contentType: this.file.type || 'application/octet-stream'
      });

      // 2) parse Lambda response (support either {uploadUrl} or {url, headers})
      let data = {};
      try { data = JSON.parse(raw); } catch (_) { data = {}; }
      const uploadUrl = data.uploadUrl || data.url || raw; // be flexible
      const extraHeaders = data.headers || {};            // sometimes empty

      if (!uploadUrl) throw new Error('No uploadUrl returned from API.');

      // 3) PUT the file to S3
      const resp = await fetch(uploadUrl, {
        method: 'PUT',
        headers: {
          'Content-Type': this.file.type || 'application/octet-stream',
          ...extraHeaders
        },
        body: this.file
      });

      if (!resp.ok) {
        const t = await resp.text();
        throw new Error(`S3 PUT failed: ${resp.status} ${resp.statusText} :: ${t}`);
      }

      this.uploadStatus = `Uploaded ${this.file.name} ✔`;
      // clear selection
      this.file = null;
      // refresh file input UI
      const input = this.template.querySelector('input[type="file"]');
      if (input) input.value = '';
    } catch (e) {
      console.error(e);
      this.uploadStatus = `Upload failed: ${e.message || e}`;
    }
  }
}
