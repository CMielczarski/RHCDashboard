import { LightningElement, api } from 'lwc';

import getReportVals from '@salesforce/apex/AA_VisualChartController.getReportVals';
import getReportTable from '@salesforce/apex/AA_VisualChartController.getReportTable';
import getADOActivityChart from '@salesforce/apex/AA_VisualChartController.getADOActivityChart';
import getADOActivityTable from '@salesforce/apex/AA_VisualChartController.getADOActivityTable';
import getFaciltyReportingChart from '@salesforce/apex/AA_VisualChartController.getFaciltyReportingChart';
import getFaciltyReportingTable from '@salesforce/apex/AA_VisualChartController.getFaciltyReportingTable';
import getTotalAccounts from '@salesforce/apex/AA_VisualChartController.getTotalAccounts';
import sortTable from '@salesforce/apex/AA_VisualChartController.sortTable';

export default class Visualcharts extends LightningElement {

@api chartTitle;
@api chart;
@api chartLegend;
@api chartData;
@api chartlstData = [];
@api chartlstCount;
@api tableData = [];
@api tableTitle;
@api report;
@api person;
@api role;
@api roleName;
@api dteFrom;
@api dteTo;
@api showButton = false;
@api ListOfContact = [];
@api arrowDirection = 'arrowup';
@api isAsc = false;
@api selectedTabsoft ='firstName';
@api paginationList = [];
@api pageSize = 20;
@api totalSize;
@api start;
@api end;
@api totalAccounts;
@api showTotal = false;
@api showStandardReport = false;
@api showADOReport = false;

@api nextButtonDisabled = false;
@api prevButtonDisabled = false;

    connectedCallback(){
        this.nextButtonDisabled = true;
        this.prevButtonDisabled = true;
        }

        constructor() {
            super();
            this.template.addEventListener('next', this.handleCustomEvent.bind(this));
            }
            handleCustomEvent(event) {
                console.log("Event 1: " + event.detail);
            }
            
        @api
        eventHandler(selRole, selReport, selRoleName, selIndividual, selDteFrom, selDteTo){
            console.log("Event Role: " + selRole);
            console.log("Event Report: " + selReport);
            console.log("Event Hierarchy: " + selRoleName);
            console.log("Event Individual: " + selIndividual);
            console.log("Event Date From: " + selDteFrom);
            console.log("Event Date To: " + selDteTo);
            this.role = selRole;
            this.report = selReport;
            this.roleName = selRoleName;
            this.person = selIndividual;
            this.dteFrom = selDteFrom;
            this.dteTo = selDteTo;
        
            if(this.report === 'Accounts Without Activity' || this.report === 'Accounts without Activity'){
                this.reportData();
                this.getTotalCount();
                }
            else{
                this.showTotal = false;
                this.reportData();
                }
            }
    
    showDetail(){
        this.reportTable();
        }
    
    sortAccountName(){
        this.accountName();
        }
    
    sortOwner(){
        this.owner();
        }
    
    sortActivity(){
        this.activity();
        }
    
    sortRisk(){
        this.risk();
        }
    
    sortRiskDate(){
        this.riskDate();
        }
    
    sortTier(){
        this.tier();
        }
    
    downloadCsv(){
        // get the Records list from 'tableData' attribute 
        var stockData = this.tableData;
        console.log('tableData: ' + this.tableData);
        var levelType = this.role;
        var reportType = this.report;
        console.log("Report Type: " + reportType);
        // call the helper function which "return" the CSV data as a String   
        if(levelType === 'National' || reportType === 'QBR Tracking' || reportType === 'Risk Account (SNF Only)' || reportType === 'Facility Reporting'){
            var csv = this.convertArrayOfObjectsToCSV(stockData);
            }
        else{
            var csv = this.convertArrayOfObjectsToCSV2(stockData);
            }
         if (csv == null){return;} 
        
        
        let downloadElement = document.createElement('a');
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        downloadElement.target = '_self';
        downloadElement.setAttribute("download","download");
        downloadElement.download = 'AccountData.csv';
        downloadElement.click();
        }
        
    reportData(){
        this.showChart = false;
        this.chartData = null;
        getReportVals({
                        "selRole" : this.role,
                        "selReport" : this.report,
                        "selRoleName" : this.roleName,
                        "selIndividual" : this.person,
                        "SelDteFrom" : this.dteFrom,
                        "SelDteTo" : this.dteTo
                    })
                .then(
                    result=>{
                        var response = result;
                        var arr = [];
                        var repList = JSON.parse(response);
                        console.log('repList: ' + repList);
                        this.chartlstCount = repList.length;
                        for(var i = 0; i < repList.length; i++){ 
                           var lstRep = repList[i].lstSNFRatio; 
                            this.chartTitle = repList[i].label;
                            this.chartData = lstRep;
                            arr.push(repList[i]);
                            }
                        this.showButton = true;
                        this.chartlstData = arr;
                        }
                    )
                .catch();
        }
    
    getTotalCount(){
        console.log('Start Total ');
        getTotalAccounts({
                        "selRole" : this.role,
                        "selRoleName" : this.roleName,
                        "selIndividual" : this.person
                })
                .then(
                    result=>{
                        var repList = JSON.parse(result);
                        this.totalAccounts = repList;
                        console.log("total:" + this.totalAccounts);
                        this.showTotal = true;
                        }
                    )
                .catch(
                    error=>{
                        console.log('Error getting count: ' + error.message);
                    }
                );
        }
    
    openItem(event){
        event.preventDefault();
        var url = '/' + event.target.value;
        window.open(url);
        }

    reportTable(){
        var pageSize = this.pageSize;
        this.paginationList = null;
        this.tableData = null;
        this.showChart = true;
        getReportTable({
                        "selRole" : this.role,
                        "selReport" : this.report,
                        "selRoleName" : this.roleName,
                        "selIndividual" : this.person,
                        "SelDteFrom" : this.dteFrom,
                        "SelDteTo" : this.dteTo
                        }
                    )
                    .then(
                        result=>{
                            var response = result;
                        if(this.report !== 'ADO Activities'){
                            var repList = JSON.parse(response);
                            console.log('===repList====',repList);
                            this.tableTitle = this.report;
                            this.tableData = repList;
                            this.totalSize = this.tableData.length;
                            this.start = 0;
                            this.end = pageSize-1;
                            this.tableData = repList;
                            var paginationList = [];
                        for(var i=0; i< pageSize; i++){
                            paginationList.push(response[i]);    
                            }
                    this.paginationList = paginationList;
                    this.showStandardReport = true;
                    this.showADOReport = false;
                    this.next();
                    this.previous();
                    }
                else{
                    var repList = JSON.parse(response);
                    console.log('===repList====',repList);
                    this.tableTitle = this.report;
                    this.tableData = repList;
                    this.totalSize = this.tableData.length;
                    this.start = 0;
                    this.end = pageSize-1;
                    this.tableData = repList;
                    var paginationList = [];
                    for(var i=0; i< pageSize; i++){
                        paginationList.push(response[i]);
                        }
                    this.paginationList = paginationList;
                    this.showStandardReport = false;
                    this.showADOReport = true;
                    this.next();
                    this.previous();
                    }
                        }
                    )
                    .catch(
                        error=>{
                            console.log('Error getting report table: ' + error.message);
                        }
                    );
        }
    
    onSort(sortField){
        //call apex class method
        var pageSize = this.pageSize;
        this.paginationList = null;
      	this.tableData = null;
        sortTable({
                    'sortField': sortField,
                    'isAsc': this.isAsc,
                    "selRole" : this.role,
                    "selReport" : this.report,
                    "selRoleName" : this.roleName,
                    "selIndividual" : this.person,
                    "SelDteFrom" : this.dteFrom,
                    "SelDteTo" : this.dteTo
            })
            .then(
                result=>{
                    var repList = JSON.parse(result);
                    this.tableTitle = this.report;
                    this.tableData = repList;
                    this.totalSize = this.tableData.length;
                    this.start = 0;
                    this.end = pageSize-1;
                    var paginationList = [];
                    for(var i=0; i< pageSize; i++){
                        paginationList.push(response[i]);
                        }
                    this.paginationList = paginationList;
                    this.next();
                    this.previous();
                    }
            )
            .catch(
                error=>{
                    console.log('Error fetching sort result');
                    }
                );
        }
    
    sortHelper(sortFieldName){
        var currentDir = this.arrowDirection;
      	if(currentDir == 'arrowdown'){
            // set the arrowDirection attribute for conditionally rendred arrow sign  
            this.arrowDirection = 'arrowup';
            // set the isAsc flag to true for sort in Assending order.  
            this.isAsc = true;
            }
       else{
       	    this.arrowDirection = 'arrowdown';
            this.isAsc = false;
            }
      	this.onSort(sortFieldName);
        }
       
   accountName(){
       	// set current selected header field on selectedTabsoft attribute.     
       	this.selectedTabsoft = 'accountName';
       	// call the helper function with pass sortField Name   
       	this.sortHelper(this.selectedTabsoft);
        }
 
    owner(){
       	// set current selected header field on selectedTabsoft attribute.    
       	this.selectedTabsoft = 'ownerName';
       	// call the helper function with pass sortField Name  
       	this.sortHelper(this.selectedTabsoft);
    	}
 
    city(){
       	// set current selected header field on selectedTabsoft attribute.        
       	this.selectedTabsoft = 'city';
       	// call the helper function with pass sortField Name      
       	this.sortHelper(this.selectedTabsoft);
    	}
        
    state(){
       	// set current selected header field on selectedTabsoft attribute.        
       	this.selectedTabsoft = 'state';
       	// call the helper function with pass sortField Name      
       	this.sortHelper(this.selectedTabsoft);
    	}
        
    activity(){
       	// set current selected header field on selectedTabsoft attribute.        
       	this.selectedTabsoft = 'activity';
       	// call the helper function with pass sortField Name      
       	this.sortHelper(this.selectedTabsoft);
    	}
        
    risk(){
       	// set current selected header field on selectedTabsoft attribute.        
       	this.selectedTabsoft = 'risk';
       	// call the helper function with pass sortField Name      
       	this.sortHelper(this.selectedTabsoft);
    	}
    
    riskDate(){
       	// set current selected header field on selectedTabsoft attribute.        
       	this.selectedTabsoft = 'riskDate';
       	// call the helper function with pass sortField Name      
       	this.sortHelper(this.selectedTabsoft);
    	}
        
    tier(){
       	// set current selected header field on selectedTabsoft attribute.        
       	this.selectedTabsoft = 'tier';
       	// call the helper function with pass sortField Name      
       	this.sortHelper(this.selectedTabsoft);
    	}

        next(){
            let countList = [...this.tableData];
            var end = this.end;
            var start = this.start;
            var pageSize = this.pageSize;
            var paginationList = [];
            var i;
            var totalSize = this.totalSize;
            var counter = 0;
            for(i=end+1; i<end+pageSize+1; i++){
                if(countList.length > end){
                    paginationList.push(countList[i]);
                    counter ++ ;
                    }
                }
            start = start + counter;
            end = end + counter;
                
            this.start = start;
            this.end = end;
            this.paginationList = paginationList;
            
            if(this.end >= totalSize){
                this.nextButtonDisabled = true;
                }
            else{
                this.nextButtonDisabled = false;
                }
            
            if(this.start === 0){
                this.prevButtonDisabled = true;
                }
            else{
                this.prevButtonDisabled = false;
                } 
            }
                
        previous(){
            let countList = [...this.tableData];
            var end = this.end;
            var start = this.start;
            var pageSize = this.pageSize;
            var paginationList = [];
            var i;
            var totalSize = this.totalSize;
            var counter = 0;
            for(i = start-pageSize; i < start ; i++){
                if(i > -1){
                    paginationList.push(countList[i]);
                    counter ++;
                    }
                else{
                    start++;
                    }
                }
            start = start - counter;
            end = end - counter;
                
            this.start = start;
            this.end = end;
            this.paginationList = paginationList;
            
            if(this.end >= totalSize){
                this.nextButtonDisabled = true;
                }
            else{
                this.nextButtonDisabled = false;
                }
            
            if(this.start === 0){
                this.prevButtonDisabled = true;
                }
            else{
                this.prevButtonDisabled = false;
                } 
            }

	convertArrayOfObjectsToCSV(objectRecords){
        // declare variables
        var csvStringResult, counter, keys, columnDivider, lineDivider;

        // check if "objectRecords" parameter is null, then return from function
        if (objectRecords == null || !objectRecords.length) {
            return null;
         }
        columnDivider = ',';
        lineDivider =  '\n';
 
        keys = ['Name','Owner','LastActivityDate','PF_Reason_for_Risk__c','PF_Risk_Date_Stamp__c', 'PF_Tier__c'];
        
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;
 
        for(var i=0; i < objectRecords.length; i++){   
            counter = 0;

             for(var sTempkey in keys) {
                var skey = keys[sTempkey] ;  
                if(counter > 0){ 
                      csvStringResult += columnDivider; 
                   }
                 
                 if(skey == 'Owner'){
                     if(objectRecords[i][skey] != undefined){  
                         csvStringResult += '"'+ objectRecords[i][skey].Name+'"';
                     	 }
                     else{
                         csvStringResult += '"'+ ' ' +'"';
                     	 }
                 } 
                 else{
                     if(objectRecords[i][skey] != undefined){  
                        csvStringResult += '"'+ objectRecords[i][skey]+'"';
                     	}
                     else{
                        csvStringResult += '"'+ ' ' +'"';
                     	}
                 }
                 
               counter++;
 
            }
            csvStringResult += lineDivider;
          }
          return csvStringResult;        
        }

	convertArrayOfObjectsToCSV2(objectRecords){
        var csvStringResult, counter, keys, columnDivider, lineDivider;
		
        if (objectRecords == null || !objectRecords.length){
            return null;
         }
        columnDivider = ',';
        lineDivider =  '\n';
 
        keys = ['Account.Name','Account.Owner','Account.LastActivityDate','Account.PF_Reason_for_Risk__c','Account.PF_Risk_Date_Stamp__c', 'Account.PF_Tier__c'];
        
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;
 
        for(var i=0; i < objectRecords.length; i++){   
            counter = 0;

             for(var sTempkey in keys) {
                var skey = keys[sTempkey] ;  

              // add , [comma] after every String value,. [except first]
                  if(counter > 0){ 
                      csvStringResult += columnDivider; 
                   }  
                 if(skey == 'Account.Name'){
                     if(objectRecords[i].Account.Name != undefined){  
                        csvStringResult += '"'+ objectRecords[i].Account.Name+'"';
                     	}
                     else{
                        csvStringResult += '"'+ ' ' +'"';	
                     	}
                     
                 }
                 else if(skey == 'Account.Owner'){
                     if(objectRecords[i].Account.Owner.Name == undefined){  
                        csvStringResult += '"'+ objectRecords[i].Account.Owner.Name+'"';
                     	}
                     else{
                        csvStringResult += '"'+ ' ' +'"';
                     	}
                 }
                 else if(skey == 'Account.LastActivityDate'){
                     
                     if(objectRecords[i].Account.LastActivityDate != undefined){  
                        csvStringResult += '"'+ objectRecords[i].Account.LastActivityDate+'"';
                     	}
                     else{
                        csvStringResult += '"'+ ' ' +'"';
                     	}
                 }
                 
                 else if(skey == 'Account.PF_Reason_for_Risk__c'){
                     if(objectRecords[i].Account.PF_Reason_for_Risk__c != undefined){  
                        csvStringResult += '"'+ objectRecords[i].Account.PF_Reason_for_Risk__c+'"';
                     	}
                     else{
                        csvStringResult += '"'+ ' ' +'"';
                     	}
                 }
                 else if(skey == 'Account.PF_Risk_Date_Stamp__c'){
                     if(objectRecords[i].Account.PF_Risk_Date_Stamp__c != undefined){  
                        csvStringResult += '"'+ objectRecords[i].Account.PF_Risk_Date_Stamp__c+'"';
                     	}
                     else{
                        csvStringResult += '"'+ ' ' +'"';
                     	}
                 }
                 
                 else if(skey == 'Account.PF_Tier__c'){
                     if(objectRecords[i].Account.PF_Tier__c != undefined){  
                        csvStringResult += '"'+ objectRecords[i].Account.PF_Tier__c+'"';
                     	}
                     else{
                        csvStringResult += '"'+ ' ' +'"';
                     	}
                 }
               
               counter++;
 
            } // inner for loop close 
             csvStringResult += lineDivider;
          }// outer main for loop close 
       
       // return the CSV formate String 
        return csvStringResult;        
    }

}