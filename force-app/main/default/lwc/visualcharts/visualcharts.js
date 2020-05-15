import { LightningElement, api } from 'lwc';

import getReportVals from '@salesforce/apex/AA_VisualChartController.getReportVals';
import getReportTable from '@salesforce/apex/AA_VisualChartController.getReportTable';
import getTotalAccounts from '@salesforce/apex/AA_VisualChartController.getTotalAccounts';

export default class Visualcharts extends LightningElement {

@api chartTitle;
@api chart;
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
@api isAsc = false;
@api sortField;
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
    
    sort(event){
        console.log('Sort Event Caused by: ' + event.target.name);
                var field = event.target.name;
                var sortAsc = this.isAsc;
                let records = [...this.tableData];
                var paginationList = [];
                var i;
            
                var key =(a) => a[field]; 
                var reverse;
                if(sortAsc === false){
                    reverse = -1;
                    sortAsc = true;
                    }
                else{
                    reverse = 1;
                    sortAsc = false;
                    }
                    this.isAsc = sortAsc;
                    this.sortField = field;
                    this.tableData = records;
                records.sort((a,b) => {
                    let valueA = key(a) ? key(a).toLowerCase() : '';
                    let valueB = key(b) ? key(b).toLowerCase() : '';
                    return reverse * ((valueA > valueB) - (valueB > valueA));
                    });
                this.sortAsc = sortAsc;
                this.sortField = field;
                
                var pageSize = this.pageSize;
                var paginationList = [];
             
                var paginationList = [];
                this.start = 0;
                this.end = pageSize-1;
                var loopSize;
                if(records.length > pageSize){
                    loopSize = pageSize;
                    }
                else{
                    loopSize = records.length;
                    }
                for(var i=0; i< loopSize; i++){
                    paginationList.push(records[i]);    
                    }
                this.paginationList = paginationList;
                this.tableData = records;
        }
    
    downloadCsv(){
        // get the Records list from 'tableData' attribute 
        var stockData = this.tableData;
        console.log('tableData: ' + this.tableData);
        var levelType = this.role;
        var reportType = this.report;
        console.log("Report Type: " + reportType);
        // call the helper function which "return" the CSV data as a String   
        //if(levelType === 'National' || reportType === 'QBR Tracking' || reportType === 'Risk Account (SNF Only)' || reportType === 'Facility Reporting'){
        //var csv = this.convertArrayOfObjectsToCSV(stockData);
        //    }
       // else{
            var csv = this.convertArrayOfObjectsToCSV2(stockData);
        //    }
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
        this.chartlstData = null;
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
                                var repList = JSON.parse(response);
                                console.log('===repList====',repList);
                                this.tableTitle = this.report;
                                this.tableData = repList;
                                this.totalSize = this.tableData.length;
                                this.start = 0;
                                this.end = pageSize-1;
                                this.tableData = repList;
                                var paginationList = [];
                                var loopSize;
                                if(result.length > pageSize){
                                    loopSize = pageSize;
                                    this.nextButtonDisabled = false;
                                    this.prevButtonDisabled = false;
                                    }
                                else{
                                    loopSize = result.length;
                                    }
                                for(var i=0; i< pageSize; i++){
                                    paginationList.push(response[i]);    
                                    }
                                this.paginationList = paginationList;
                                console.log('result.length: ' + result.length);
                                if(result.length > 2){
                                    if(this.report !== 'ADO Activities'){
                                        this.showStandardReport = true;
                                        this.showADOReport = false;
                                        }
                                    else{
                                        this.showStandardReport = false;
                                        this.showADOReport = true;
                                        }
                                    }
                                else{
                                    this.showStandardReport = false;
                                    this.showADOReport = false;
                                    alert('Selected chart(s) have no data to display.');
                                    }
                                this.next();
                                this.previous();
                                console.log('Show Standard?: ' + this.showStandardReport);
                                console.log('Show ADO?: ' + this.showADOReport);
                            }
                    )
                    .catch(
                        error=>{
                            console.log('Error getting report table: ' + error.message);
                        }
                    );
        }
    
        openItem(event){
            event.preventDefault();
            var id = event.target.value;
            var url = '/' + id;
            window.open(url);
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
                if(i <=totalSize - 1 ){
                    paginationList.push(countList[i]);
                    counter ++ ;
                    }
                }
            start = start + counter;
            end = end + counter;
                
            this.start = start;
            this.end = end;
            this.paginationList = paginationList;
            console.log('end: ' + this.end);
            console.log('totalSize: ' + totalSize);
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
 
        keys = ['Account Name','Account Owner','Last Activity Date','Reason for Risk ','Risk Date', 'Tier'];
        
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
                 if(skey == 'Account Name'){
                     if(objectRecords[i].itemName != undefined){  
                        csvStringResult += '"'+ objectRecords[i].itemName+'"';
                     	}
                     else{
                        csvStringResult += '"'+ ' ' +'"';	
                     	}
                     
                 }
                 else if(skey == 'Account Owner'){
                    csvStringResult += '"Partner First"';
                 }
                 else if(skey == 'Last Activity Date'){
                     
                     if(objectRecords[i].lastActivity != undefined){  
                        csvStringResult += '"'+ objectRecords[i].lastActivity+'"';
                     	}
                     else{
                        csvStringResult += '"'+ ' ' +'"';
                     	}
                 }
                 
                 else if(skey == 'Reason for Risk'){
                     if(objectRecords[i].riskReason != undefined){  
                        csvStringResult += '"'+ objectRecords[i].riskReason+'"';
                     	}
                     else{
                        csvStringResult += '"'+ ' ' +'"';
                     	}
                 }
                 else if(skey == 'Risk Date Stamp'){
                     if(objectRecords[i].riskDate != undefined){  
                        csvStringResult += '"'+ objectRecords[i].riskDate+'"';
                     	}
                     else{
                        csvStringResult += '"'+ ' ' +'"';
                     	}
                 }
                 
                 else if(skey == 'Tier'){
                     if(objectRecords[i].tier != undefined){  
                        csvStringResult += '"'+ objectRecords[i].tier+'"';
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