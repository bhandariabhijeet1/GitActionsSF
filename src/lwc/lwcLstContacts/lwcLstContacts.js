import { LightningElement,wire,track} from 'lwc';
import fetchContactList from '@salesforce/apex/ctrlContactList.fetchContactList';

const columns = [
    { label: 'First Name', fieldName: 'FirstName' },
    { label: 'Last Name', fieldName: 'LastName' },
    { label: 'Title', fieldName: 'Title' },
    { label: 'Phone', fieldName: 'Phone', type: 'phone' },
    { label: 'Email', fieldName: 'Email', type: 'email' }
];

export default class LwcLstContacts extends LightningElement {
    @track error;
    @track columns = columns;

    @wire(fetchContactList) contacts;   
}