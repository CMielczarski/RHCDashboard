import { LightningElement, api } from 'lwc';

import { loadStyle } from 'lightning/platformResourceLoader';
import ChartJS from '@salesforce/resourceUrl/TBN_Slds_Static_Resource';

import getRoles from '@salesforce/apex/AA_Dashboard.getRoles';
import getIndividuals from '@salesforce/apex/AA_Dashboard.getIndividuals';
import getRoleNames from '@salesforce/apex/AA_Dashboard.getRoleNames';
import getRoleAlt from '@salesforce/apex/AA_Dashboard.getRoleAlt';
import getRoleAlt2 from '@salesforce/apex/AA_Dashboard.getRoleAlt2';
import getReportNames from '@salesforce/apex/AA_Dashboard.getReportNames';

export default class Rhcdashboard extends LightningElement {

    @api selRoles = [];
    @api selRoleList = [];
    @api selReports = [];
    @api selIndLst = [];
    @api selDteFrom;
    @api selDteTo;
    @api selIndividual;
    @api selFacilities = [];
    @api errorString;
    @api showFacilities;
    @api hierarchyDisabled = false;
    @api individualDisabled = false;
    @api selectedRole;
    @api selectedHirearchy;
    @api selectedReport;
    @api selectedIndividual;
    @api selectedFromDate;
    @api selectedToDate;


    chartJsInitialised = false;
    
    connectedCallback(){
        this.hierarchyDisabled = true;
        this.individualDisabled = true;
        if(this.chartJsInitialised) {
            return;
            }
        this.chartJsInitialised = true;
    Promise.all([
        loadStyle(this, ChartJS + '/assets/styles/salesforce-lightning-design-system-ltng.css')
        ]);
        getRoleNames()
        .then(
            result=>{
                this.selRoles = result; 
                this.selRoleList = '--None Selected--';
                getReportNames()
                    .then(
                        result=>{
                            this.selReports = result;
                            var rad = this.template.querySelectorAll(".rad");
                            rad.forEach(function(element){
                                if(element.name === 'InputSelectRole'){
                                    element.value = 'National';
                                    }
                                else if(element.name === 'InputSelectReport'){
                                        element.value = 'Accounts Without Activity';
                                        }
                                else if(element.name === 'InputSelectRoleHierarchy'){
                                    element.value = '--None Selected--';
                                    }
                                }, this);
                            }
                        )
                    .catch(
                        error=>{
                            console.log('Error fetching report names: ' + error.message);
                        }
                    );
                }
            )
        .catch(
            error=>{
                console.log('Error fetching roles: ' + error.message);
            }
        );
        
        }

    showChart(){
        // regular expression to match required date format
        this.checkEntries();
        if(this.selectedRole !== 'National' && (this.selectedHirearchy === '--None Selected--' || this.selectedHirearchy === null || this.selectedHirearchy === undefined)){
            alert('Please select a Hierarchy Value or change role selection to National');
        	}
        else{
                var selRole = this.selectedRole;
                var selReport = this.selectedReport;
                var selRoleName = this.selectedHirearchy;
                var selIndividual = this.selectedIndividual;
                var selDteFrom = this.selectedFromDate;
                var selDteTo = this.selectedToDate;
                this.template.querySelector('c-visualcharts').eventHandler(selRole, selReport, selRoleName, selIndividual, selDteFrom, selDteTo);
                console.log('Event Fired');
            }
        }
    
    disableSelectIndividual(){
        var inputSelReport = this.selectedReport;
        console.log('report: ' + inputSelReport);
        console.log('Selected Hierarchy: ' + this.selectedHirearchy);
        
        if(this.selectedHirearchy === '--None Selected--'){
            this.individualDisabled = true;
            this.selectedIndividual = '--None Selected--';
            this.selIndLst = null;
            }
        else{
            getIndividuals({
                            "selRole" : this.selectedRole
                            })
                        .then(
                            result=>{
                                this.individualDisabled = false;
                                this.selectedIndividual = "--None Selected--";
                                this.selIndLst = result;
                                }
                        )
                        .catch(
                            error=>{
                                console.log('Error fetching Individual List: ' + error.message);
                            }
                        );
            }
        }
    
    onRoleChange(){
        this.checkEntries();
        this.disableSelectIndividual();
        this.disableSelectRole();
        this.getRoleNamePicklist();
        }
    
    onRoleHierarchyChange(){
        this.checkEntries();
        this.disableSelectIndividual();
        }
    
    checkEntries(){
        var rad = this.template.querySelectorAll(".rad");
            rad.forEach(function(element){
                if(element.name === 'InputSelectReport'){
                    this.selectedReport = element.value;
                    console.log('Selected Report: ' + this.selectedReport);
                    }
                else if(element.name === 'InputSelectRole'){
                    this.selectedRole = element.value;
                    console.log('Selected Role: ' + this.selectedRole);
                    }
                else if(element.name === 'InputSelectRoleHierarchy'){
                    console.log('Selected Hierarchy: ' + this.selectedHierarchy);
                    this.selectedHirearchy = element.value;
                    }
                else if(element.name === 'InputDteFrom'){
                    console.log('Selected Date From: ' + this.selectedFromDate);
                    this.selectedFromDate = element.value;
                    }
                else if(element.name === 'InputDteTo'){
                    console.log('Selected Date To: ' + this.selectedToDate);
                    this.selectedToDate = element.value;
                    }
                else if(element.name === 'InputSelectIndividual'){
                    console.log('Selected Individual: ' + this.selectedIndividual);
                    this.selectedIndividual = element.value;
                    }
                    }, this);
        }

    onReportChange(){
        this.checkEntries();
        console.log('selected report: ' + this.selectedReport);
        this.disableSelectRole();
        if(this.selectedReport == 'Facility Reporting'){
            this.getRoleAlt();
            }
        else if(this.selectedReport == 'ADO Activities'){
            this.getRoleAlt2();
            }
        else{
            this.getRoleNamePicklist();
            }
        this.disableSelectIndividual();
            }
    
    getRoleAlt(){
        getRoleAlt()
            .then(
                result=>{
                    this.selRoles = result; 
                    this.selRoleList = '--None Selected--';
                    }
                )
            .catch(
                error=>{
                    console.log('Error getting role alt: ' + error.message);
                }
            );
        }
    
    getRoleAlt2(){
        getRoleAlt2()
            .then(
                result=>{
                    this.selRoles = result; 
                    this.selRoleList = '--None Selected--';
                    }
                )
            .catch(
                error=>{
                    console.log('Error getting role 2: ' + error.message);
                }
            );
        }

    getRoleNamePicklist(){
        getRoles({
                "selRole" : this.selectedRole
                })
            .then(
                result=>{
                    this.selRoleList = result; 
                    this.selectedHirearchy = "--None Selected--";
                    }
                )
            .catch(
                error=>{
                    console.log('Error getting role name picklist: ' + error.message);
                    }
                );
        }
    
    disableSelectRole(){
        if(this.selectedRole == 'National'){
            this.hierarchyDisabled = true; 
            }
        else{
            this.hierarchyDisabled = false;
            }
        }
    
}