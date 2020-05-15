public with sharing class AA_VisualChartController {
  
    //list to store the records types of Accounts to be shown
    public static list<RecordType> lstRTAccount = [Select SobjectType, Name, DeveloperName 
                                                            From RecordType 
                                                            Where SobjectType = 'Account' AND DeveloperName IN ('PF_Chain', 'PF_Client')];
    
    public static ID rhcEvent = [SELECT ID FROM RecordType WHERE sObjectType = 'Event' AND DeveloperName = 'Partner_First'].ID;
    
    //Constructor
    public AA_VisualChartController(){
      }
    
    public static Integer totalAccounts;  
    
    /**
    @ClassName  : SNFChartRatio
    @Description: Wrapper class to contain list value which contains segment name and value. 
    **/
    public class SNFChartRatio{
        @AuraEnabled
        public String label  {get;set;}
        @AuraEnabled
        public String legendLabel  {get;set;}
        @AuraEnabled
        public decimal value  {get;set;}
        @AuraEnabled
        public String colorVal  {get;set;}
         
        public SNFChartRatio(String strType, string legendLabel, decimal cnt, string colorVal){
            this.label = strType;
            this.legendLabel = legendLabel;
            this.value = cnt;
            this.colorVal = colorVal;
            }
        }
    
    /**
    @ClassName  : SNFChartRatioForMultipleCharts
    @Description: Wrapper class to contain chart name and the list of SNFChartRatio.
    **/
    public class SNFChartRatioForMultipleCharts{
        @AuraEnabled
        public String label  {get;set;}
        @AuraEnabled
        public list<SNFChartRatio> lstSNFRatio  {get;set;}
         
        public SNFChartRatioForMultipleCharts(String strType, list<SNFChartRatio> lstSNFRatio){
            this.label = strType;
            this.lstSNFRatio = lstSNFRatio;
          }
      }
    
      public class reportWrapper{
        @AuraEnabled
        public string itemID  {get;set;}
        @AuraEnabled
        public string itemName  {get;set;}
        @AuraEnabled
        public string ownerName  {get;set;}
        @AuraEnabled
        public string lastActivity  {get;set;}
        @AuraEnabled
        public string riskReason  {get;set;}
        @AuraEnabled
        public datetime riskDate  {get;set;}
        @AuraEnabled
        public string activityDate  {get;set;}
        @AuraEnabled
        public string activityType  {get;set;}
        @AuraEnabled
        public string description  {get;set;}
        @AuraEnabled
        public string tier  {get;set;}
        @AuraEnabled
        public boolean render {get;set;}
        
        public reportWrapper(string itemID, string itemName, string ownerName, string lastActivity, string riskReason, dateTime riskDate, string activityDate, string activityType, string description, string tier){
            this.itemID = itemID;
            this.itemName = itemName;
            this.ownerName = ownerName;
            this.lastActivity = lastActivity;
            this.riskReason = riskReason;
            this.riskDate = riskDate;
            this.activityType = activityType;
            this.description = description;
            this.tier = tier;
            if(itemID != null){
                this.render = true;
                }
            else{
                this.render = false;
                }
            }
        }
    
    /**
    @MethodName : getReportVals
    @Param      : string selRole, string selRoleName, string selReport
    @Description: Method is called to get report data which is returned based on rolename, role and reportname parameters.
    **/ 
    @AuraEnabled
    public static string getReportVals(string selRole, string selRoleName, string selReport, string selIndividual, string SelDteFrom, string SelDteTo) {
    system.debug('SelRole value: ' + selRole);
        system.debug('SelRoleName value: ' + selRoleName);
        system.debug('SelReport value: ' + selReport);
        system.debug('SelIndividual value: ' + selIndividual);
        system.debug('SelDteFrom value: ' + SelDteFrom);
        system.debug('SelDteTo value: ' + SelDteTo);
        string errorString;
          
        String JsonString;
        //calls the method based on selReport value and assigns result to JsonString.
        if(selReport == 'Accounts Without Activity'){
            JsonString = getAccountWithoutActivity(selRole, selRoleName, selIndividual, SelDteFrom, SelDteTo);
          }
        else if(selReport == 'QBR Tracking'){
            JsonString = getDashboardData(selRole, selRoleName, selReport, selIndividual, SelDteFrom, SelDteTo);
          }
        else if(selReport == 'Risk Account (SNF Only)'){
            JsonString = getRiskAccount(selRole, selRoleName, selIndividual, SelDteFrom, SelDteTo);
          }
        else if(selReport == 'Facility Reporting'){
        	JsonString = getFaciltyReportingChart(selRole, selRoleName, selIndividual, SelDteFrom, SelDteTo);
        	}
        else if(selReport == 'ADO Activities'){
        	JsonString = getADOActivityChart(selRole, selRoleName, selIndividual, SelDteFrom, SelDteTo);
        	}	  
        return JsonString;
    	}
    	
      /**
    @MethodName : getReportVals
    @Param      : string selRole, string selRoleName, string selReport
    @Description: Method is called to get report data which is returned based on rolename, role and reportname parameters.
    **/ 
    @AuraEnabled
    public static string getReportTable(string selRole, string selRoleName, string selReport, string selIndividual, string SelDteFrom, string SelDteTo) {
    
        string sortStr;
        system.debug('SelRole value: ' + selRole);
        system.debug('SelRoleName value: ' + selRoleName);
        system.debug('SelReport value: ' + selReport);
        system.debug('SelIndividual value: ' + selIndividual);
        system.debug('SelDteFrom value: ' + SelDteFrom);
        system.debug('SelDteTo value: ' + SelDteTo);
        string errorString;
        
        String JsonString ;
        //calls the method based on selReport value and assigns result to JsonString.
        if(selReport == 'Accounts Without Activity'){
            JsonString = getWithoutActivityTable(selRole, selRoleName, selIndividual, SelDteFrom, SelDteTo, sortStr);
          }
        else if(selReport == 'QBR Tracking'){
            JsonString = getDashboardTable(selRole, selRoleName, selReport, selIndividual, SelDteFrom, SelDteTo, sortStr);
          }
        else if(selReport == 'Risk Account (SNF Only)'){
             JsonString = getRiskAccountTable(selRole, selRoleName, selIndividual, SelDteFrom, SelDteTo, sortStr);
          }
        else if(selReport == 'Facility Reporting'){
        	JsonString = getFaciltyReportingTable(selRole, selRoleName, selIndividual, SelDteFrom, SelDteTo, sortStr);
        	}
        else if(selReport == 'ADO Activities'){
        	JsonString = getADOActivityTable(selRole, selRoleName, selIndividual, SelDteFrom, SelDteTo, sortStr);
        	}	 
        return JsonString;
      }
      	
    /*
    Get ADO Activity Chart: supplies chart values for the ADO specific activity chart option.
    */
    @AuraEnabled 
    public static string getADOActivityChart(string selRole, string selRoleName, string selIndividual, string SelDteFrom, string SelDteTo){
    	 integer f2f = 0;
    	 integer f2fQBR = 0;
    	 
    	 system.debug('SelDteFrom: ' + SelDteFrom);
         system.debug('SelDteTo: ' + SelDteTo);
            
            string dtToStr;
            string dtFromStr;
            if(!string.isBlank(SelDteFrom)){
                  Datetime dteFromFrmt = dateTime.NewInstance(date.valueOf(SelDteFrom), Time.newInstance(0,0,0,0));
                  dtFromStr = dteFromFrmt.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
                  }
                
                if(!string.isBlank(SelDteTo)){
                  Datetime dteToFrmt = dateTime.NewInstance(date.valueOf(SelDteTo), Time.newInstance(0,0,0,0));
                  dtToStr = dteToFrmt.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
                  }
                    
        list<Event> events = new list<Event>();
    	
    	set<Id> setRoleId = new set<Id>();   
        set<Id> setAllRoleId = new set<Id>(); 
        //If selected Role from first picklist is not national, getAllSubRoleIds is called to get all the roles beneath the selected role in second picklist.
        if((selRole != 'National' && (selRole == 'ADO')) && (selRoleName != '--None Selected--' || selRoleName != null)){
        	system.debug('selIndividual: ' + selIndividual);
        	if(selIndividual == '--None Selected--'){
        		Id RoleId = [select id, Name From UserRole where Name =: selRoleName].Id;
                setRoleId.add(RoleId);
                //assigns the roles returned from getAllSubRoleIds to set, setAllRoleId.
                setAllRoleId = getAllSubRoleIds(setRoleId); 
                setAllRoleId.add(RoleId);
                }
          	set<ID> ids = new set<ID>();
            string eventQuery = 'SELECT AccountId, Account.Name, Owner.Name, Owner.UserRoleId, Type, ActivityDate FROM Event WHERE RecordTypeId =: rhcEvent AND (Type = \'F2F - QBR\' OR Type = \'F2F\')  AND (Account.PF_Product_Type__c = \'SNFSAU\' OR Account.PF_Product_Type__c = \'SNF Skilled\' OR Account.PF_Product_Type__c = \'SNFTCC\' OR Account.PF_Product_Type__c = \'SNFTCU\')';
      		if(!string.isBlank(SelDteFrom) && !string.isBlank(SelDteTo)){
              eventQuery = eventQuery + ' AND (StartDateTime >='+dtFromStr+' AND StartDateTime <='+dtToStr +')';
              }
            else if (!string.isBlank(SelDteFrom) && string.isBlank(SelDteTo)){
              eventQuery = eventQuery + ' AND (StartDateTime >=' + dtFromStr + ')';
              }
            else if(string.isBlank(SelDteFrom) && !string.isBlank(SelDteTo)){
              eventQuery = eventQuery + ' AND (StartDateTime <=' + dtToStr + ')';
              }
            else if(string.isBlank(SelDteFrom) && string.isBlank(SelDteTo)){
              eventQuery = eventQuery;
              }
           if(selIndividual == '--None Selected--'){
              	eventQuery = eventQuery + ' AND Owner.UserRoleId IN: setAllRoleId';
              	}
            else{
               eventQuery = eventQuery + ' AND Owner.Name = \'' + selIndividual + '\'';
                }    
            events = database.query(eventQuery);
            	system.debug('Events Size: ' + events.size());
      			system.debug('Events: ' + events);
      			for(Event e : events){
        			system.debug('Owner Name: ' + e.Owner.Name);
        			system.debug('Owner Role ID: ' + e.Owner.UserRoleID);
        			if(e.Type == 'F2F - QBR'){
        				f2fQBR += 1;
        				}
        			else if(e.Type == 'F2F'){
        				f2f += 1;
        				}		
        			}
          	}
    	//list to store the value which contains segment name and count. 
        List<SNFChartRatio>lstSNFChartRatio = new List<SNFChartRatio>();
        //list to store the chart name and list of lstSNFChartRatio which is passed back as JSON format
        list<SNFChartRatioForMultipleCharts> lstSNFChartRatioForMultipleCharts = new list<SNFChartRatioForMultipleCharts>();
        
        List<string> listColors = new List<string>();
        List<Chart_Colors_for_Partner_Charts__c> lstChartcolor = Chart_Colors_for_Partner_Charts__c.getall().values();
        for(Chart_Colors_for_Partner_Charts__c objPartnerColor : lstChartcolor){
          listColors.add(objPartnerColor.Name);
          }
		  
		  Integer randomIndex1 = Math.floor(Math.random() * listColors.size()).intValue();
        Integer randomIndex2;
        string Index3 = '#3360FF';
        if(randomIndex1 < listColors.size()-1){
            randomIndex2 = randomIndex1+1;
            }
        else{
            randomIndex2 = 0;
            }
          
          lstSNFChartRatio.add(new SNFChartRatio('F2F Activities', 'F2F Activities', f2f, listColors[randomIndex2]));
          lstSNFChartRatio.add(new SNFChartRatio('F2F - QBR Activities', 'F2F - QBR Activities', f2fQBR, listColors[randomIndex1]));
          //lstSNFChartRatio is added with the report title and converted to JSON format and returned.
          lstSNFChartRatioForMultipleCharts.add(new SNFChartRatioForMultipleCharts('ADO Activity', lstSNFChartRatio));
          String JSONString = JSON.serialize(lstSNFChartRatioForMultipleCharts);
          System.debug('Serialized list of ADO Activities into JSON format: ' + JSONString);
      
        return JSONString;
    	}
    
    /*Provides the details for the ADO Activites Dashboard results
    */	
    @AuraEnabled 
    public static string getADOActivityTable(string selRole, string selRoleName, string selIndividual, string SelDteFrom, string SelDteTo, string sortStr){
    	 String JSONString;
    	 
    	 system.debug('SelDteFrom: ' + SelDteFrom);
         system.debug('SelDteTo: ' + SelDteTo);
            
            string dtToStr;
            string dtFromStr;
            if(!string.isBlank(SelDteFrom)){
                  Datetime dteFromFrmt = dateTime.NewInstance(date.valueOf(SelDteFrom), Time.newInstance(0,0,0,0));
                  dtFromStr = dteFromFrmt.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
                  }
                
                if(!string.isBlank(SelDteTo)){
                  Datetime dteToFrmt = dateTime.NewInstance(date.valueOf(SelDteTo), Time.newInstance(0,0,0,0));
                  dtToStr = dteToFrmt.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
                  }
                    
        list<Account> accounts = new list<Account>();
        list<Account> accountTeam = new list<Account>();
    	list<Event> events = new list<Event>();
    	list<ID> userIDs = new list<ID>();
    	list<User> users = new list<User>();
    	
    	set<Id> setRoleId = new set<Id>();   
        set<Id> setAllRoleId = new set<Id>(); 
        //If selected Role from first picklist is not national, getAllSubRoleIds is called to get all the roles beneath the selected role in second picklist.
        if((selRole != 'National' && (selRole == 'ADO')) && (selRoleName != '--None Selected--' || selRoleName != null)){
        	system.debug('selIndividual: ' + selIndividual);
        	if(selIndividual == '--None Selected--'){
            	Id RoleId = [select id, Name From UserRole where Name =: selRoleName].Id;
                setRoleId.add(RoleId);
                //assigns the roles returned from getAllSubRoleIds to set, setAllRoleId.
                setAllRoleId = getAllSubRoleIds(setRoleId); 
                setAllRoleId.add(RoleId);
            	}
          	set<ID> ids = new set<ID>();
            string eventQuery = 'SELECT AccountId, Description, Account.Name, Owner.Name, Account.PF_Risk_Date_Stamp__c, Account.PF_Reason_for_Risk__c, Owner.UserRoleId, Type, ActivityDate FROM Event WHERE RecordTypeId =: rhcEvent AND (Type = \'F2F - QBR\' OR Type = \'F2F\') AND (Account.PF_Product_Type__c = \'SNFSAU\' OR Account.PF_Product_Type__c = \'SNF Skilled\' OR Account.PF_Product_Type__c = \'SNFTCC\' OR Account.PF_Product_Type__c = \'SNFTCU\')';
      		if(!string.isBlank(SelDteFrom) && !string.isBlank(SelDteTo)){
              eventQuery = eventQuery + ' AND (StartDateTime >='+dtFromStr+' AND StartDateTime <='+dtToStr +')';
              }
            else if (!string.isBlank(SelDteFrom) && string.isBlank(SelDteTo)){
              eventQuery = eventQuery + ' AND (StartDateTime >=' + dtFromStr + ')';
              }
            else if(string.isBlank(SelDteFrom) && !string.isBlank(SelDteTo)){
              eventQuery = eventQuery + ' AND (StartDateTime <=' + dtToStr + ')';
              }
            else if(string.isBlank(SelDteFrom) && string.isBlank(SelDteTo)){
              eventQuery = eventQuery;
              }
           if(selIndividual == '--None Selected--'){
              	eventQuery = eventQuery + ' AND Owner.UserRoleId IN: setAllRoleId';
              	}
            else{
               	eventQuery = eventQuery + ' AND Owner.Name = \'' + selIndividual + '\'';
                }    
            if(sortStr != null){
                  eventQuery = eventQuery + sortStr;
                  }
            
            events = database.query(eventQuery);
      		set<Event> eventClean = new set<Event>(events);
            events.clear();
            events.addAll(eventClean);
            system.debug('Events: ' + events);
            list<reportWrapper> processList = new list<reportWrapper>();
            for(Event e : events){
              processList.add(new reportWrapper(e.AccountID, e.Account.Name, e.Owner.Name, null, e.Account.PF_Reason_for_Risk__c, e.Account.PF_Risk_Date_Stamp__c, string.valueOf(e.ActivityDate), e.Type, e.Description, null));
              }
            JSONString = JSON.serialize(processList);
            }
    	return JSONString;
    	}
    	
    /*Provides the chart for activities based on either the National, COO, DVP, OR RVP Level and other filters the user selects.
    */
    @AuraEnabled 
    public static string getFaciltyReportingChart(string selRole, string selRoleName, string selIndividual, string SelDteFrom, string SelDteTo){
    	 integer cooAct = 0;
    	 integer dvpAct = 0;
    	 integer rvpAct = 0;
    	 
    	 list<ID> dvpIDs = new list<ID>();
    	 list<ID> rvpIDs = new list<ID>();
    	 list<UserRole> roleList = new list<UserRole>();
    	 
    	 roleList = [SELECT ID, Name FROM UserRole WHERE (Name = 'DVP - Black' OR Name = 'DVP - Reifenrath' OR Name = 'DVP - Sharp' OR Name = 'RVP - Black*' OR Name = 'RVP - Dunn' OR Name = 'RVP - Grace' OR Name = 'RVP - Makowski' OR Name = 'RVP - Melillo' OR Name = 'RVP - Sheridan' OR Name = 'RVP - Reifenrath*' OR Name = 'RVP - Sharp*' OR Name = 'RVP - Van Ruden')]; 
    	 for(UserRole ur: roleList){
    	 	if(ur.Name == 'DVP - Black' || ur.Name == 'DVP - Reifenrath' || ur.Name == 'DVP - Sharp'){
    	 		dvpIDs.add(ur.ID);
    	 		}
    	 	if(ur.Name == 'RVP - Black*' || ur.Name == 'RVP - Dunn' || ur.Name == 'RVP - Grace' || ur.Name == 'RVP - Makowski' || ur.Name == 'RVP - Melillo' || ur.Name == 'RVP - Sheridan' || ur.Name == 'RVP - Reifenrath*' || ur.Name == 'RVP - Sharp*' || ur.Name == 'RVP - Van Ruden'){
    	 		rvpIDs.add(ur.ID);
    	 		}	
    	 }
    	 
    	 system.debug('SelDteFrom: ' + SelDteFrom);
         system.debug('SelDteTo: ' + SelDteTo);
            
            string dtToStr;
            string dtFromStr;
            if(!string.isBlank(SelDteFrom)){
                  Datetime dteFromFrmt = dateTime.NewInstance(date.valueOf(SelDteFrom), Time.newInstance(0,0,0,0));
                  dtFromStr = dteFromFrmt.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
                  }
                
                if(!string.isBlank(SelDteTo)){
                  Datetime dteToFrmt = dateTime.NewInstance(date.valueOf(SelDteTo), Time.newInstance(0,0,0,0));
                  dtToStr = dteToFrmt.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
                  }
                    
        list<Event> events = new list<Event>();
    	
    	set<Id> setRoleId = new set<Id>();   
        set<Id> setAllRoleId = new set<Id>(); 
        //If selected Role from first picklist is not national, getAllSubRoleIds is called to get all the roles beneath the selected role in second picklist.
        if((selRole != 'National' && (selRole == 'DVP' || selRole == 'RVP' ||selRole == 'COO')) && (selRoleName != '--None Selected--' || selRoleName != null)){
        	system.debug('selIndividual: ' + selIndividual);
        	if(selIndividual == '--None Selected--'){
        		if(selRole == 'COO'){
        			selRoleName = 'KRS';
        			}
            	Id RoleId = [select id, Name From UserRole where Name =: selRoleName].Id;
                setRoleId.add(RoleId);
                //assigns the roles returned from getAllSubRoleIds to set, setAllRoleId.
                setAllRoleId = getAllSubRoleIds(setRoleId); 
                setAllRoleId.add(RoleId);
                }
          	set<ID> ids = new set<ID>();
            string eventQuery = 'SELECT AccountId, Account.Name, Owner.Name, Owner.UserRoleId, Type, ActivityDate FROM Event WHERE RecordTypeId =: rhcEvent AND (Type = \'F2F - QBR\' OR Type = \'F2F\' OR Type = \'Phone Call\')  AND (Account.PF_Product_Type__c = \'SNFSAU\' OR Account.PF_Product_Type__c = \'SNF Skilled\' OR Account.PF_Product_Type__c = \'SNFTCC\' OR Account.PF_Product_Type__c = \'SNFTCU\')';
      		if(!string.isBlank(SelDteFrom) && !string.isBlank(SelDteTo)){
              eventQuery = eventQuery + ' AND (StartDateTime >='+dtFromStr+' AND StartDateTime <='+dtToStr +')';
              }
            else if (!string.isBlank(SelDteFrom) && string.isBlank(SelDteTo)){
              eventQuery = eventQuery + ' AND (StartDateTime >=' + dtFromStr + ')';
              }
            else if(string.isBlank(SelDteFrom) && !string.isBlank(SelDteTo)){
              eventQuery = eventQuery + ' AND (StartDateTime <=' + dtToStr + ')';
              }
            else if(string.isBlank(SelDteFrom) && string.isBlank(SelDteTo)){
              eventQuery = eventQuery;
              }
           if(selIndividual == '--None Selected--'){
              	eventQuery = eventQuery + ' AND Owner.UserRoleId IN: setAllRoleId';
              	}
            else{
               eventQuery = eventQuery + ' AND Owner.Name = \'' + selIndividual + '\'';
                }    
            events = database.query(eventQuery);
            	system.debug('Events Size: ' + events.size());
      			for(Event e : events){
        			if(e.Owner.Name == 'Glenda Mack'){
        				cooAct += 1;
        				system.debug('Event: ' + e.Owner.Id);
        				}
        			else if(dvpIDs.contains(e.Owner.UserRoleId)){
        				dvpAct += 1;
        				system.debug('Event: ' + e.Owner.Id);
      					}
        			else if(rvpIDs.contains(e.Owner.UserRoleId)){
        				rvpAct += 1;
        				system.debug('Event: ' + e.Owner.Id);
        				}		
        			}
          	}
    	else if(selRole == 'National'){
            set<ID> ids = new set<ID>();
            string eventQuery = 'SELECT Owner.Name, Owner.UserRoleId, ActivityDate FROM Event WHERE RecordTypeId =: rhcEvent AND (Type = \'F2F - QBR\' OR Type = \'F2F\' OR Type = \'Phone Call\') AND (Account.PF_Product_Type__c = \'SNFSAU\' OR Account.PF_Product_Type__c = \'SNF Skilled\' OR Account.PF_Product_Type__c = \'SNFTCC\' OR Account.PF_Product_Type__c = \'SNFTCU\')';
      		if(!string.isBlank(SelDteFrom) && !string.isBlank(SelDteTo)){
              eventQuery = eventQuery + ' AND (StartDateTime >='+dtFromStr+' AND StartDateTime <='+dtToStr +')';
              }
            else if (!string.isBlank(SelDteFrom) && string.isBlank(SelDteTo)){
              eventQuery = eventQuery + ' AND (StartDateTime >=' + dtFromStr + ')';
              }
            else if(string.isBlank(SelDteFrom) && !string.isBlank(SelDteTo)){
              eventQuery = eventQuery + ' AND (StartDateTime <=' + dtToStr + ')';
              }
            else if(string.isBlank(SelDteFrom) && string.isBlank(SelDteTo)){
              eventQuery = eventQuery;
              }  
            
            events = database.query(eventQuery);
            system.debug('Event Size: ' + events.size());
      	for(Event e : events){
      		system.debug('Owner Name: ' + e.Owner.Name);
      		system.debug('Owner ID ' + e.Owner.UserRoleId);
        	if(selRole == 'COO' && e.Owner.Name == 'Glenda Mack'){
        		cooAct =+ 1;
        		}
        	else if(selRole == 'DVP' && dvpIDs.contains(string.valueOf(e.Owner.UserRoleId))){
        		dvpAct += 1;
        		}
        	else if(selRole == 'RVP' && rvpIDs.contains(string.valueOf(e.Owner.UserRoleId))){
        		rvpAct += 1;
        		}		
        	}
        }
        //list to store the value which contains segment name and count. 
        List<SNFChartRatio>lstSNFChartRatio = new List<SNFChartRatio>();
        //list to store the chart name and list of lstSNFChartRatio which is passed back as JSON format
        list<SNFChartRatioForMultipleCharts> lstSNFChartRatioForMultipleCharts = new list<SNFChartRatioForMultipleCharts>();
        
        List<string> listColors = new List<string>();
        List<Chart_Colors_for_Partner_Charts__c> lstChartcolor = Chart_Colors_for_Partner_Charts__c.getall().values();
        for(Chart_Colors_for_Partner_Charts__c objPartnerColor : lstChartcolor){
          listColors.add(objPartnerColor.Name);
          }
		  
		  Integer randomIndex1 = Math.floor(Math.random() * listColors.size()).intValue();
        Integer randomIndex2;
        string Index3 = '#3360FF';
        if(randomIndex1 < listColors.size()-1){
            randomIndex2 = randomIndex1+1;
            }
        else{
            randomIndex2 = 0;
            }
          
          //lstSNFChartRatio.add(new SNFChartRatio('COO Activities', 'COO Activities', cooAct, listColors[randomIndex1]));
          lstSNFChartRatio.add(new SNFChartRatio('DVP Activities', 'DVP Activities', dvpAct, listColors[randomIndex2]));
          lstSNFChartRatio.add(new SNFChartRatio('RVP Activities', 'RVP Activities', rvpAct, listColors[randomIndex1]));
          //lstSNFChartRatio is added with the report title and converted to JSON format and returned.
          lstSNFChartRatioForMultipleCharts.add(new SNFChartRatioForMultipleCharts('Account Activity', lstSNFChartRatio));
          String JSONString = JSON.serialize(lstSNFChartRatioForMultipleCharts);
          System.debug('Serialized list of Facilities into JSON format: ' + JSONString);
      
        return JSONString;
    	}
    	
    /*Provides the table details to go along with the Facility Activity Reporting Chart
    */
    @AuraEnabled 
    public static string getFaciltyReportingTable(string selRole, string selRoleName, string selIndividual, string SelDteFrom, string SelDteTo, string sortStr){
    	 String JSONString;
    	 
    	 list<ID> dvpIDs = new list<ID>();
    	 list<ID> rvpIDs = new list<ID>();
    	 list<UserRole> roleList = new list<UserRole>();
    	 
    	 roleList = [SELECT ID, Name FROM UserRole WHERE (Name = 'DVP - Black' OR Name = 'DVP - Reifenrath' OR Name = 'DVP - Sharp' OR Name = 'RVP - Black*' OR Name = 'RVP - Dunn' OR Name = 'RVP - Grace' OR Name = 'RVP - Makowski' OR Name = 'RVP - Melillo' OR Name = 'RVP - Sheridan' OR Name = 'RVP - Reifenrath*' OR Name = 'RVP - Sharp*' OR Name = 'RVP - Van Ruden')]; 
    	 for(UserRole ur: roleList){
    	 	if(ur.Name == 'DVP - Black' || ur.Name == 'DVP - Reifenrath' || ur.Name == 'DVP - Sharp'){
    	 		dvpIDs.add(ur.ID);
    	 		}
    	 	if(ur.Name == 'RVP - Black*' || ur.Name == 'RVP - Dunn' || ur.Name == 'RVP - Grace' || ur.Name == 'RVP - Makowski' || ur.Name == 'RVP - Melillo' || ur.Name == 'RVP - Sheridan' || ur.Name == 'RVP - Reifenrath*' || ur.Name == 'RVP - Sharp*' || ur.Name == 'RVP - Van Ruden'){
    	 		rvpIDs.add(ur.ID);
    	 		}	
    	 }
    	 	system.debug('SelDteFrom: ' + SelDteFrom);
            system.debug('SelDteTo: ' + SelDteTo);
            
            string dtToStr;
            string dtFromStr;
            if(!string.isBlank(SelDteFrom)){
                  Datetime dteFromFrmt = dateTime.NewInstance(date.valueOf(SelDteFrom), Time.newInstance(0,0,0,0));
                  dtFromStr = dteFromFrmt.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
                  }
                
                if(!string.isBlank(SelDteTo)){
                  Datetime dteToFrmt = dateTime.NewInstance(date.valueOf(SelDteTo), Time.newInstance(0,0,0,0));
                  dtToStr = dteToFrmt.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
                  }
                    
        list<Account> accounts = new list<Account>();
        list<Account> accountTeam = new list<Account>();
    	list<Event> events = new list<Event>();
    	list<ID> userIDs = new list<ID>();
    	list<User> users = new list<User>();
    	
    	set<Id> setRoleId = new set<Id>();   
        set<Id> setAllRoleId = new set<Id>(); 
        //If selected Role from first picklist is not national, getAllSubRoleIds is called to get all the roles beneath the selected role in second picklist.
        if((selRole != 'National' && (selRole == 'DVP' || selRole == 'RVP' ||selRole == 'COO')) && (selRoleName != '--None Selected--' || selRoleName != null)){
        	system.debug('selIndividual: ' + selIndividual);
        	if(selIndividual == '--None Selected--'){
            	if(selRole == 'COO'){
        			selRoleName = 'KRS';
        			}
            	Id RoleId = [select id, Name From UserRole where Name =: selRoleName].Id;
                setRoleId.add(RoleId);
                //assigns the roles returned from getAllSubRoleIds to set, setAllRoleId.
                setAllRoleId = getAllSubRoleIds(setRoleId); 
                setAllRoleId.add(RoleId);
            	}
          	set<ID> ids = new set<ID>();
            string eventQuery = 'SELECT AccountId, Account.Name, Owner.Name, Owner.UserRoleId, Type, ActivityDate FROM Event WHERE RecordTypeId =: rhcEvent AND (Type = \'F2F - QBR\' OR Type = \'F2F\' OR Type = \'Phone Call\')  AND (Account.PF_Product_Type__c = \'SNFSAU\' OR Account.PF_Product_Type__c = \'SNF Skilled\' OR Account.PF_Product_Type__c = \'SNFTCC\' OR Account.PF_Product_Type__c = \'SNFTCU\')';
      		if(!string.isBlank(SelDteFrom) && !string.isBlank(SelDteTo)){
              eventQuery = eventQuery + ' AND (StartDateTime >='+dtFromStr+' AND StartDateTime <='+dtToStr +')';
              }
            else if (!string.isBlank(SelDteFrom) && string.isBlank(SelDteTo)){
              eventQuery = eventQuery + ' AND (StartDateTime >=' + dtFromStr + ')';
              }
            else if(string.isBlank(SelDteFrom) && !string.isBlank(SelDteTo)){
              eventQuery = eventQuery + ' AND (StartDateTime <=' + dtToStr + ')';
              }
            else if(string.isBlank(SelDteFrom) && string.isBlank(SelDteTo)){
              eventQuery = eventQuery;
              }
           if(selIndividual == '--None Selected--'){
              	eventQuery = eventQuery + ' AND Owner.UserRoleId IN: setAllRoleId';
              	}
            else{
               eventQuery = eventQuery + ' AND Owner.Name = \'' + selIndividual + '\'';
                }    
              
      		events = database.query(eventQuery);
      		system.debug('Events: ' + events);
      		for(Event e : events){
        		if(e.Owner.Name == 'Glenda Mack'){
        			ids.add(e.Account.ID);
        			}
        		else if(dvpIDs.contains(string.valueOf(e.Owner.UserRoleId))){
        			ids.add(e.Account.ID);
        			}
        		else if(rvpIDs.contains(string.valueOf(e.Owner.UserRoleId))){
        			ids.add(e.Account.ID);
        			}
        		}
        	system.debug('IDs:' + ids);
            //query string to fetch the account from AccountTeamMember based on given PF_Product_Type__c value, having role from above set and recordtypeid in lstRTAccount and adds account into the map, mapAccountidtoAccount.
            string AccountQuery = 'Select PF_Product_Type__c, DaysSinceLastActivity__c, Last_Activity_Type__c, PF_Risk_Date_Stamp__c, PF_Last_Activity_Date__c, Name, ID, ShippingCity, ShippingState, Owner.Name, PF_Tier__c, PF_Reason_for_Risk__c '+
                                         'FROM Account WHERE Status__c = \'Active\' AND (PF_Product_Type__c = \'SNFSAU\' OR PF_Product_Type__c = \'SNF Skilled\' OR PF_Product_Type__c = \'SNFTCC\' OR PF_Product_Type__c = \'SNFTCU\')'+
                                         ' AND ID IN: ids';
            
            if(sortStr != null){
                  AccountQuery = AccountQuery + sortStr;
                  }
            AccountTeam = database.query(AccountQuery);    
            system.debug('AccountTeam: ' + AccountTeam);
            set<Account> accountClean = new set<Account>(AccountTeam);
            AccountTeam.clear();
            AccountTeam.addAll(accountClean);
            list<reportWrapper> processList = new list<reportWrapper>();
            for(Account a: AccountTeam){
              processList.add(new reportWrapper(a.ID, a.Name, a.Owner.Name, string.valueOf(a.PF_Last_Activity_Date__c), a.PF_Reason_for_Risk__c, a.PF_Risk_Date_Stamp__c, null, null, null, a.PF_Tier__c));
              }
            JSONString = JSON.serialize(processList);
            }
    	else if(selRole == 'National'){
            set<ID> ids = new set<ID>();
            string eventQuery = 'SELECT Owner.Name, Owner.UserRoleId, ActivityDate, Account.ID FROM Event WHERE RecordTypeId =: rhcEvent AND (Type = \'F2F - QBR\' OR Type = \'F2F\' OR Type = \'Phone Call\')  AND (Account.PF_Product_Type__c = \'SNFSAU\' OR Account.PF_Product_Type__c = \'SNF Skilled\' OR Account.PF_Product_Type__c = \'SNFTCC\' OR Account.PF_Product_Type__c = \'SNFTCU\')';
      		if(!string.isBlank(SelDteFrom) && !string.isBlank(SelDteTo)){
              eventQuery = eventQuery + ' AND (StartDateTime >='+dtFromStr+' AND StartDateTime <='+dtToStr +')';
              }
            else if (!string.isBlank(SelDteFrom) && string.isBlank(SelDteTo)){
              eventQuery = eventQuery + ' AND (StartDateTime >=' + dtFromStr + ')';
              }
            else if(string.isBlank(SelDteFrom) && !string.isBlank(SelDteTo)){
              eventQuery = eventQuery + ' AND (StartDateTime <=' + dtToStr + ')';
              }
            else if(string.isBlank(SelDteFrom) && string.isBlank(SelDteTo)){
              eventQuery = eventQuery;
              }  
            
            events = database.query(eventQuery);
            system.debug('Event Size: ' + events.size());
            
      		for(Event e : events){
      			if(e.Owner.Name == 'Glenda Mack'){
        			ids.add(e.Account.ID);
        			}
        		if(dvpIDs.contains(string.valueOf(e.Owner.UserRoleId))){
        			ids.add(e.Account.ID);
        			}
        		if(rvpIDs.contains(string.valueOf(e.Owner.UserRoleId))){
        			ids.add(e.Account.ID);
        			}
        		}
            
            string AccountQuery = 'Select PF_Product_Type__c, DaysSinceLastActivity__c, Last_Activity_Type__c, PF_Risk_Date_Stamp__c, PF_Last_Activity_Date__c, Name, ID, ShippingCity, ShippingState, Owner.Name, PF_Tier__c, PF_Reason_for_Risk__c '+
                                         'FROM Account WHERE Status__c = \'Active\' AND (PF_Product_Type__c = \'SNFSAU\' OR PF_Product_Type__c = \'SNF Skilled\' OR PF_Product_Type__c = \'SNFTCC\' OR PF_Product_Type__c = \'SNFTCU\')'+
                                         ' AND recordtypeid IN: lstRTAccount AND ID IN: ids';
            if(sortStr != null){
                    AccountQuery = AccountQuery + sortStr;
                  } 
            system.debug('National Facility Table activity query: ' + AccountQuery);
            accounts = database.query(AccountQuery);
            set<Account> accountClean = new set<Account>(accounts);
            accounts.clear();
            accounts.addAll(accountClean);
            list<reportWrapper> processList = new list<reportWrapper>();
                for(Account a: accounts){
                  processList.add(new reportWrapper(a.ID, a.Name, a.Owner.Name, string.valueOf(a.PF_Last_Activity_Date__c), a.PF_Reason_for_Risk__c, a.PF_Risk_Date_Stamp__c, null, null, null, a.PF_Tier__c));
                  }
            JSONString = JSON.serialize(processList);
            system.debug('National Facility size: ' + accounts.size());
            }
        return JSONString;
    	}
    
      /*Provides the table details to go along with the withoutActivity chart based on user filter selections.
      */
      public static string getWithoutActivityTable(string selRole, string selRoleName, string selIndividual, string SelDteFrom, string SelDteTo, string sortStr){
            system.debug('SelDteFrom: ' + SelDteFrom);
            system.debug('SelDteTo: ' + SelDteTo);
            
            string dtToStr;
            string dtFromStr;
            if(!string.isBlank(SelDteFrom)){
                  Datetime dteFromFrmt = dateTime.NewInstance(date.valueOf(SelDteFrom), Time.newInstance(0,0,0,0));
                  dtFromStr = dteFromFrmt.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
                  }
                
                if(!string.isBlank(SelDteTo)){
                  Datetime dteToFrmt = dateTime.NewInstance(date.valueOf(SelDteTo), Time.newInstance(0,0,0,0));
                  dtToStr = dteToFrmt.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
                  }  
            String JSONString;
            list<Account> accounts = new list<Account>();
            list<AccountTeamMember> accountTeam = new list<AccountTeamMember>();
            
          set<Id> setRoleId = new set<Id>();   
          set<Id> setAllRoleId = new set<Id>(); 
          //If selected Role from first picklist is not national, getAllSubRoleIds is called to get all the roles beneath the selected role in second picklist.
          if((selRole != 'National' && (selRole == 'DVP' || selRole == 'RVP' ||selRole == 'ADO')) && (selRoleName != '--None Selected--' || selRoleName != null)){
              system.debug('selIndividual: ' + selIndividual);
            if(selIndividual == '--None Selected--'){
                Id RoleId = [select id, Name From UserRole where Name =: selRoleName].Id;
                setRoleId.add(RoleId);
                //assigns the roles returned from getAllSubRoleIds to set, setAllRoleId.
                setAllRoleId = getAllSubRoleIds(setRoleId); 
                setAllRoleId.add(RoleId);
              }
              
            set<ID> ids = new set<ID>();
            string eventQuery = 'SELECT AccountId, Type, ActivityDate FROM Event WHERE RecordTypeId =: rhcEvent AND (Type = \'F2F - QBR\' OR Type = \'F2F - PD Monthly Meeting\' OR Type = \'F2F\' OR Type = \'CPS Live Client Engagement - CPS Use Only\' OR Type = \'CPS Live Rehab Engagement - CPS Use Only\' OR Type = \'CPS Remote Client Engagement - CPS Use Only\' OR Type = \'CPS Remote Rehab Engagement - CPS Use Only\' OR Type = \'Phone Call\' OR Type = \'Email\')';
      if(!string.isBlank(SelDteFrom) && !string.isBlank(SelDteTo)){
              eventQuery = eventQuery + ' AND (StartDateTime >='+dtFromStr+' AND StartDateTime <='+dtToStr +')';
              }
            else if (!string.isBlank(SelDteFrom) && string.isBlank(SelDteTo)){
              eventQuery = eventQuery + ' AND (StartDateTime >=' + dtFromStr + ')';
              }
            else if(string.isBlank(SelDteFrom) && !string.isBlank(SelDteTo)){
              eventQuery = eventQuery + ' AND (StartDateTime <=' + dtToStr + ')';
              }
            else if(string.isBlank(SelDteFrom) && string.isBlank(SelDteTo)){
              eventQuery = eventQuery;
              }  
              
      for(Event objEvent : database.query(eventQuery)){
        ids.add(objEvent.AccountId);
        }  
            
            //query string to fetch the account from AccountTeamMember based on given PF_Product_Type__c value, having role from above set and recordtypeid in lstRTAccount and adds account into the map, mapAccountidtoAccount.
            string AccountTeamMemberQuery = 'Select UserId, User.Name, User.UserRoleId, Account.PF_Reason_for_Risk__c, Account.PF_Risk_Date_Stamp__c, Account.Last_Activity_Type__c, Account.PF_Product_Type__c, Account.PF_Last_Activity_Date__c, Account.DaysSinceLastActivity__c, Account.Name, Account.ID, Account.ShippingCity, Account.ShippingState, Account.Owner.Name, Account.PF_Tier__c  '+
                                         'From AccountTeamMember WHERE Account.Status__c = \'Active\' AND (Account.PF_Product_Type__c = \'SNFSAU\' OR Account.PF_Product_Type__c = \'SNF Skilled\' OR Account.PF_Product_Type__c = \'SNFTCC\' OR Account.PF_Product_Type__c = \'SNFTCU\')'+
                                         ' AND Account.recordtypeid IN: lstRTAccount AND Account.ID NOT IN: ids';
            
            if(selIndividual == '--None Selected--'){
              AccountTeamMemberQuery = AccountTeamMemberQuery + ' AND User.UserRoleId IN: setAllRoleId ';
                }
            else{
               AccountTeamMemberQuery = AccountTeamMemberQuery + ' AND User.Name = \'' + selIndividual + '\'';
                }  
            
            
            if(sortStr != null){
              AccountTeamMemberQuery = AccountTeamMemberQuery + sortStr;
                }
            system.debug('QueryStr: ' + AccountTeamMemberQuery);    
            accountTeam = database.query(AccountTeamMemberQuery);
                map<ID, AccountTeamMember> accountMap = new map<ID, AccountTeamMember>();
                map<ID, AccountTeamMember> accountMap2 = new map<ID, AccountTeamMember>();
                set<AccountTeamMember> accountTeamClean = new set<AccountTeamMember>();
                for(AccountTeamMember tA : accountTeam){
                      accountMap.put(tA.Account.ID, tA);
                      }
                for(ID i : accountMap.keySet()){
                    if(!accountMap2.containsKey(i)){
                        accountMap2.put(i, accountMap.get(i));
                      }                   
                  }
                for(ID i : accountMap2.keySet()){
                    accountTeamClean.add(accountMap2.get(i));
                  }
                
                system.debug('Account Team Size: ' + accountTeamClean.size());
                
                accountTeam.clear();
                accountTeam.addAll(accountTeamClean);
                list<reportWrapper> processList = new list<reportWrapper>();
                for(AccountTeamMember atm: accountTeam){
                  processList.add(new reportWrapper(atm.AccountID, atm.Account.Name, atm.Account.Owner.Name, string.valueOf(atm.Account.PF_Last_Activity_Date__c), atm.Account.PF_Reason_for_Risk__c, atm.Account.PF_Risk_Date_Stamp__c, null, null, null, atm.Account.PF_Tier__c));
                  }
                JSONString = JSON.serialize(processList);
          }
        
        //If selected Role from first picklist is not national, it queries the account based on PF_Product_Type__c and recordtypeid and adds it to the map, mapAccountidtoAccount
        else if(selRole == 'National'){
            set<ID> ids = new set<ID>();
            string eventQuery = 'SELECT AccountId, Type, StartDateTime FROM Event WHERE RecordTypeId =: rhcEvent AND (Type = \'F2F - QBR\' OR Type = \'F2F - PD Monthly Meeting\' OR Type = \'F2F\' OR Type = \'CPS Live Client Engagement - CPS Use Only\' OR Type = \'CPS Live Rehab Engagement - CPS Use Only\' OR Type = \'CPS Remote Client Engagement - CPS Use Only\' OR Type = \'CPS Remote Rehab Engagement - CPS Use Only\' OR Type = \'Phone Call\' OR Type = \'Email\')';
      	if(!string.isBlank(SelDteFrom) && !string.isBlank(SelDteTo)){
              eventQuery = eventQuery + ' AND (StartDateTime >='+dtFromStr+' AND StartDateTime <='+dtToStr +')';
              }
            else if (!string.isBlank(SelDteFrom) && string.isBlank(SelDteTo)){
              eventQuery = eventQuery + ' AND (StartDateTime >=' + dtFromStr + ')';
              }
            else if(string.isBlank(SelDteFrom) && !string.isBlank(SelDteTo)){
              eventQuery = eventQuery + ' AND (StartDateTime <=' + dtToStr + ')';
              }
            else if(string.isBlank(SelDteFrom) && string.isBlank(SelDteTo)){
              eventQuery = eventQuery;
              }  
              
      for(Event objEvent : database.query(eventQuery)){
        ids.add(objEvent.AccountId);
        }
            
            string AccountQuery = 'Select PF_Product_Type__c, DaysSinceLastActivity__c, Last_Activity_Type__c, PF_Risk_Date_Stamp__c, PF_Last_Activity_Date__c, Name, ID, ShippingCity, ShippingState, Owner.Name, PF_Tier__c, PF_Reason_for_Risk__c '+
                                         'FROM Account WHERE Status__c = \'Active\' AND (PF_Product_Type__c = \'SNFSAU\' OR PF_Product_Type__c = \'SNF Skilled\' OR PF_Product_Type__c = \'SNFTCC\' OR PF_Product_Type__c = \'SNFTCU\')'+
                                         ' AND recordtypeid IN: lstRTAccount AND ID NOT IN: ids';
             
            if(sortStr != null){
              AccountQuery = AccountQuery + sortStr;
                }
            system.debug('National Account without activity query: ' + AccountQuery);
            accounts = database.query(AccountQuery);
            set<Account> accountClean = new set<Account>(accounts);
            accounts.clear();
            accounts.addAll(accountClean);
            system.debug('National Account size: ' + accounts.size());
            list<reportWrapper> processList = new list<reportWrapper>();
                for(Account a: accounts){
                  processList.add(new reportWrapper(a.ID, a.Name, a.Owner.Name, string.valueOf(a.PF_Last_Activity_Date__c), a.PF_Reason_for_Risk__c, a.PF_Risk_Date_Stamp__c, null, null, null, a.PF_Tier__c));
                  }
            JSONString = JSON.serialize(processList);
          	}
          system.debug('accounts size: ' + accounts.size());
          system.debug('accountTeam/Individual size: ' + accountTeam.size());
          System.debug('Serialized list of accounts into JSON format: ' + JSONString);
          system.debug('Table JSON: ' + JSONString);
          return JSONString;
          }
    
      public static string getDashboardTable(string selRole, string selRoleName, string selReport, string selIndividual, string SelDteFrom, string SelDteTo, string sortStr){
          String JsonString ;
          map<Id, Account> mapAccountidtoAccount = new map<Id, Account>();
          set<id> setAccountId = new set<Id>();
          set<Id> setRoleId = new set<Id>();  
          set<Id> setAllRoleId = new set<Id>(); 
        
          if((selRole != 'National' && (selRole == 'DVP' || selRole == 'RVP' ||selRole == 'ADO')) && (selRoleName != '--None Selected--' || selRoleName != null)){
               if(selIndividual == '--None Selected--'){
                Id RoleId = [select id, Name From UserRole where Name =: selRoleName].Id;
                setRoleId.add(RoleId);
                //assigns the roles returned from getAllSubRoleIds to set, setAllRoleId.
                setAllRoleId = getAllSubRoleIds(setRoleId); 
                setAllRoleId.add(RoleId);
                }
            
              string AccountTeamMemberQuery = 'Select UserId, User.UserRoleId, Account.Last_Activity_Type__c, Account.PF_Risk_Date_Stamp__c, Account.PF_Product_Type__c, Account.DaysSinceLastActivity__c, Account.PF_Reason_for_Risk__c, Account.PF_Last_Activity_Date__c, Account.PF_Tier__c, Account.ID '+
                                           'From AccountTeamMember Where Account.Status__c = \'Active\' AND User.UserRoleId IN: setAllRoleId'+
                                           ' AND (Account.PF_Product_Type__c = \'SNFSAU\' OR Account.PF_Product_Type__c = \'SNF Skilled\' OR Account.PF_Product_Type__c = \'SNFTCC\' OR Account.PF_Product_Type__c = \'SNFTCU\')'+
                                           ' AND Account.recordtypeid IN: lstRTAccount AND Account.PF_Tier__c != null';
              if(selIndividual == '--None Selected--'){
                AccountTeamMemberQuery = AccountTeamMemberQuery + ' AND User.UserRoleId IN: setAllRoleId ';
                  }
              else{
                 AccountTeamMemberQuery = AccountTeamMemberQuery + ' AND User.Name = \'' + selIndividual + '\'';
                  }
                for(AccountTeamMember objAccountTeamMember : database.query(AccountTeamMemberQuery)){
                  mapAccountidtoAccount.put(objAccountTeamMember.AccountId,objAccountTeamMember.Account);
                  }
            }
    	else if(selRole == 'National'){
            if(!string.isBlank(SelDteFrom) && !string.isBlank(SelDteTo)){
                   mapAccountidtoAccount = new Map<Id, Account>([Select Id, PF_Tier__c, Last_Activity_Type__c, PF_Last_Activity_Date__c, PF_Risk_Date_Stamp__c 
                                                                From Account 
                                                                Where Status__c = 'Active' AND recordtypeid IN: lstRTAccount AND PF_Tier__c!= null
                                                                AND (PF_Product_Type__c =: 'SNFSAU' OR PF_Product_Type__c =: 'SNF Skilled' OR PF_Product_Type__c =: 'SNFTCC' OR PF_Product_Type__c =: 'SNFTCU')
                                                                AND (PF_Last_Activity_Date__c >=: date.valueOf(SelDteFrom) AND PF_Last_Activity_Date__c <=: date.valueOf(SelDteTo))]);
                   }
                else if(!string.isBlank(SelDteFrom) && string.isBlank(SelDteTo)){
                   mapAccountidtoAccount = new Map<Id, Account>([Select Id, PF_Tier__c, Last_Activity_Type__c, PF_Last_Activity_Date__c, PF_Risk_Date_Stamp__c 
                                                                From Account 
                                                                Where Status__c = 'Active' AND recordtypeid IN: lstRTAccount AND PF_Tier__c!= null
                                                                AND (PF_Product_Type__c =: 'SNFSAU' OR PF_Product_Type__c =: 'SNF Skilled' OR PF_Product_Type__c =: 'SNFTCC' OR PF_Product_Type__c =: 'SNFTCU')
                                                                AND (PF_Last_Activity_Date__c >=: date.valueOf(SelDteFrom))]);
                   }
                else if(string.isBlank(SelDteFrom) && !string.isBlank(SelDteTo)){
                   mapAccountidtoAccount = new Map<Id, Account>([Select Id, PF_Tier__c, Last_Activity_Type__c, PF_Last_Activity_Date__c, PF_Risk_Date_Stamp__c 
                                                                From Account 
                                                                Where Status__c = 'Active' AND recordtypeid IN: lstRTAccount AND PF_Tier__c!= null
                                                                AND (PF_Product_Type__c =: 'SNFSAU' OR PF_Product_Type__c =: 'SNF Skilled' OR PF_Product_Type__c =: 'SNFTCC' OR PF_Product_Type__c =: 'SNFTCU')
                                                                AND (PF_Last_Activity_Date__c <=: date.valueOf(SelDteTo))]);
                   }
            	else{
              		mapAccountidtoAccount = new Map<Id, Account>([Select Id, PF_Tier__c, Last_Activity_Type__c, PF_Last_Activity_Date__c, PF_Risk_Date_Stamp__c 
                                                                 From Account 
                                                                 Where Status__c = 'Active' AND recordtypeid IN: lstRTAccount AND PF_Tier__c!= null
                                                                 AND (PF_Product_Type__c =: 'SNFSAU' OR PF_Product_Type__c =: 'SNF Skilled' OR PF_Product_Type__c =: 'SNFTCC' OR PF_Product_Type__c =: 'SNFTCU')]);
              		}
              }
              /*if(selReport == 'PD Monthly Meeting'){
                JsonString = getPDMonthlyTable(mapAccountidtoAccount, sortStr, selDteFrom, selDteTo);
                }*/
              if(selReport == 'QBR Tracking'){
                JsonString = getQBRTable(mapAccountidtoAccount, sortStr, selDteFrom, selDteTo);
                }
          return JsonString;
          }
      
      /*public static string getPDMonthlyTable(map<id, Account> mapAccountidtoAccount, string sortStr, string selDteFrom, string selDteTo){
          set<id> setAccountId = new set<Id>();
          if(!string.isBlank(SelDteFrom) && !string.isBlank(SelDteTo)){
            for(Event objEvent : [SELECT id, AccountId, Type FROM Event WHERE type=: 'F2F - PD Monthly Meeting' and AccountId IN:mapAccountidtoAccount.keySet() AND (ActivityDate >=: date.valueOf(SelDteFrom) AND ActivityDate <=: date.valueOf(SelDteTo))]){
                setAccountId.add(objEvent.AccountId);
              }
            }
          else if(!string.isBlank(SelDteFrom) && string.isBlank(SelDteTo)){
            for(Event objEvent : [SELECT id, AccountId, Type FROM Event WHERE type=: 'F2F - PD Monthly Meeting' and AccountId IN:mapAccountidtoAccount.keySet() AND (ActivityDate >=: date.valueOf(SelDteFrom))]){
                setAccountId.add(objEvent.AccountId);
              }
            }
          else if(string.isBlank(SelDteFrom) && !string.isBlank(SelDteTo)){
            for(Event objEvent : [SELECT id, AccountId, Type FROM Event WHERE type=: 'F2F - PD Monthly Meeting' and AccountId IN:mapAccountidtoAccount.keySet() AND (ActivityDate <=: date.valueOf(SelDteTo))]){
                setAccountId.add(objEvent.AccountId);
              }
            }
          else{
            for(Event objEvent : [SELECT id, AccountId, Type FROM Event WHERE type=: 'F2F - PD Monthly Meeting' and AccountId IN:mapAccountidtoAccount.keySet()]){
                setAccountId.add(objEvent.AccountId);
              }
            }      
            
          system.debug('Account Set: ' + setAccountId);
          list<Account> accounts = new list<Account>(); 
            if(sortStr == null){
              accounts = [SELECT Id, PF_Tier__c, Owner.Name, Name, ShippingCity, ShippingState, PF_Last_Activity_Date__c, PF_Risk_Date_Stamp__c, PF_Reason_for_Risk__c FROM ACCOUNT where Status__c = 'Active' AND Id IN:setAccountId];
              }
            else{
                string accStr = 'SELECT Id, PF_Tier__c, Owner.Name, Name, ShippingCity, ShippingState, PF_Last_Activity_Date__c, PF_Risk_Date_Stamp__c, PF_Reason_for_Risk__c FROM ACCOUNT where Status__c = \'Active\' AND Id IN:setAccountId' + sortStr;
              accounts = database.query(accStr);
              }
            set<Account> accClean = new set<Account>(accounts);
            accounts.clear();
            accounts.addAll(accClean);
            String JSONString = JSON.serialize(accounts);
        return JSONString;
        }*/
        
      public static string getQBRTable(map<id, Account> mapAccountidtoAccount, string sortStr, string selDteFrom, string selDteTo){
          set<id> setAccountId = new set<Id>();
        
        if(!string.isBlank(SelDteFrom) && !string.isBlank(SelDteTo)){
          for(Event objEvent : [SELECT id, AccountId, Type FROM Event WHERE type=: 'F2F - QBR' and AccountId IN:mapAccountidtoAccount.keySet() AND (ActivityDate >=: date.valueOf(SelDteFrom) AND ActivityDate <=: date.valueOf(SelDteTo))]){
                setAccountId.add(objEvent.AccountId);
              }
          }
        else if(!string.isBlank(SelDteFrom) && string.isBlank(SelDteTo)){
          for(Event objEvent : [SELECT id, AccountId, Type FROM Event WHERE type=: 'F2F - QBR' and AccountId IN:mapAccountidtoAccount.keySet() AND (ActivityDate >=: date.valueOf(SelDteFrom))]){
                setAccountId.add(objEvent.AccountId);
              }
          }
        else if(string.isBlank(SelDteFrom) && !string.isBlank(SelDteTo)){
          for(Event objEvent : [SELECT id, AccountId, Type FROM Event WHERE type=: 'F2F - QBR' and AccountId IN:mapAccountidtoAccount.keySet() AND (ActivityDate <=: date.valueOf(SelDteTo))]){
                setAccountId.add(objEvent.AccountId);
              }
          }
        else{
          for(Event objEvent : [SELECT id, AccountId, Type FROM Event WHERE type=: 'F2F - QBR' and AccountId IN:mapAccountidtoAccount.keySet()]){
                setAccountId.add(objEvent.AccountId);
              }
          }      
           list<Account> accounts = new list<Account>();
            if(sortStr == null){
                accounts = [SELECT Id, PF_Tier__c, Owner.Name, Name, ShippingCity, ShippingState, PF_Last_Activity_Date__c, PF_Risk_Date_Stamp__c, PF_Reason_for_Risk__c FROM ACCOUNT where Status__c = 'Active' AND Id IN:setAccountId];
                }
            else{
              string accStr = 'SELECT Id, PF_Tier__c, Owner.Name, Name, ShippingCity, ShippingState, PF_Last_Activity_Date__c, PF_Risk_Date_Stamp__c, PF_Reason_for_Risk__c FROM ACCOUNT where Status__c = \'Active\' AND Id IN:setAccountId' + sortStr;
              accounts = database.query(accStr);
              }
            set<Account> accClean = new set<Account>(accounts);
            accounts.clear();
            accounts.addAll(accClean);
            list<reportWrapper> processList = new list<reportWrapper>();
                for(Account a: accounts){
                  processList.add(new reportWrapper(a.ID, a.Name, a.Owner.Name, string.valueOf(a.PF_Last_Activity_Date__c), a.PF_Reason_for_Risk__c, a.PF_Risk_Date_Stamp__c, null, null, null, a.PF_Tier__c));
                  }
            String JSONString = JSON.serialize(processList);
          return JSONString;
        }
        
      public static string getRiskAccountTable(string selRole, string selRoleName, string selIndividual, string SelDteFrom, string SelDteTo, string sortStr){
          list<Account> riskAccounts = new list<Account>();
          list<AccountTeamMember> riskMembers = new list<AccountTeamMember>();
          set<id> setAccountId = new set<Id>();
          set<Id> setRoleId = new set<Id>();  
          set<Id> setAllRoleId = new set<Id>(); 
          set<string> setRiskReason = new set<String>();
          string JSONString;
          string dtFromStr;
          string dtToStr;
          for(Dashboard_Risk_Reason__c objRisk : [select Name from Dashboard_Risk_Reason__c]){
                setRiskReason.add(objRisk.Name);
              }
            
          //If selected Role from first picklist is not national, getAllSubRoleIds is called to get all the roles beneath the selected role in second picklist.
          if((selRole != 'National' && (selRole == 'DVP' || selRole == 'RVP' ||selRole == 'ADO')) && (selRoleName != '--None Selected--' || selRoleName != null)){
              if(selIndividual == '--None Selected--'){
                Id RoleId = [select id, Name From UserRole where Name =: selRoleName].Id;
                setRoleId.add(RoleId);
                //assigns the roles returned from getAllSubRoleIds to set, setAllRoleId.
                setAllRoleId = getAllSubRoleIds(setRoleId); 
                setAllRoleId.add(RoleId);
                }
              //query on AccountTeamMember to get the accounts based on user's role, Account's Risk reason and Account's status.
              if(!string.isBlank(SelDteFrom)){
                  Datetime dteFromFrmt = dateTime.NewInstance(date.valueOf(SelDteFrom), Time.newInstance(0,0,0,0));
                  dtFromStr = dteFromFrmt.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
                  }
                
                if(!string.isBlank(SelDteTo)){
                  Datetime dteToFrmt = dateTime.NewInstance(date.valueOf(SelDteTo), Time.newInstance(0,0,0,0));
                  dtToStr = dteToFrmt.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
                  }
              string AccountTeamMemberQuery = 'Select UserId, Account.Name, Account.Last_Activity_Type__c, Account.Owner.Name, Account.PF_Last_Activity_Date__c, User.UserRoleId, Account.PF_Reason_for_Risk__c, Account.PF_Tier__c, Account.ID, Account.PF_Risk_Date_Stamp__c '+
                                            'From AccountTeamMember Where Account.Status__c = \'Active\' AND (Account.PF_Product_Type__c = \'SNFSAU\' OR Account.PF_Product_Type__c = \'SNF Skilled\' OR Account.PF_Product_Type__c = \'SNFTCC\' OR Account.PF_Product_Type__c = \'SNFTCU\')'+
                                            ' AND Account.recordtypeid IN: lstRTAccount '+
                                            ' AND  Account.PF_Risk__c = true AND Account.PF_Risk_Date_Stamp__c != null AND Account.Status__c = \'Active\'';
              if(!string.isBlank(SelDteFrom) && !string.isBlank(SelDteTo)){
                AccountTeamMemberQuery = AccountTeamMemberQuery + ' AND Account.PF_Risk_Date_Stamp__c >= ' + dtFromStr + ' AND Account.PF_Risk_Date_Stamp__c <= ' + dtToStr;
                }
               else if(!string.isBlank(SelDteFrom) && string.isBlank(SelDteTo)){
                  AccountTeamMemberQuery = AccountTeamMemberQuery + ' AND Account.PF_Risk_Date_Stamp__c >= ' + dtFromStr;
                }
               else if(string.isBlank(SelDteFrom) && !string.isBlank(SelDteTo)){
                  AccountTeamMemberQuery = AccountTeamMemberQuery + ' AND Account.PF_Risk_Date_Stamp__c <= ' + dtToStr;
                }
              if(selIndividual != '--None Selected--' && selIndividual != null){
                AccountTeamMemberQuery = AccountTeamMemberQuery + ' AND User.Name = \'' + selIndividual + '\'';
                }
              else{
                AccountTeamMemberQuery = AccountTeamMemberQuery + ' AND User.UserRoleId IN: setAllRoleId';
                }  
                if(sortStr != null){
                    AccountTeamMemberQuery = AccountTeamMemberQuery + sortStr;
                  }
              system.debug('Risk Members Query: ' + AccountTeamMemberQuery);
              riskMembers = database.query(AccountTeamMemberQuery);
                map<ID, AccountTeamMember> riskMap = new map<ID, AccountTeamMember>();
                map<ID, AccountTeamMember> riskMap2 = new map<ID, AccountTeamMember>();
                set<AccountTeamMember> accountTeamClean = new set<AccountTeamMember>();
                for(AccountTeamMember tA : riskMembers){
                      riskMap.put(tA.Account.ID, tA);
                      }
                for(ID i : riskMap.keySet()){
                    if(!riskMap2.containsKey(i)){
                        riskMap2.put(i, riskMap.get(i));
                      }                   
                  }
                for(ID i : riskMap2.keySet()){
                    accountTeamClean.add(riskMap2.get(i));
                  }
                
                system.debug('Account Team Size: ' + accountTeamClean.size());
                
                riskMembers.clear();
                riskMembers.addAll(accountTeamClean);
                list<reportWrapper> processList = new list<reportWrapper>();
                for(AccountTeamMember atm: riskMembers){
                  processList.add(new reportWrapper(atm.AccountID, atm.Account.Name, atm.Account.Owner.Name, string.valueOf(atm.Account.PF_Last_Activity_Date__c), atm.Account.PF_Reason_for_Risk__c, atm.Account.PF_Risk_Date_Stamp__c, null, null, null, atm.Account.PF_Tier__c));
                  }
                JSONString = JSON.serialize(processList);
            System.debug('Serialized list of at-risk Accounts into JSON format: ' + JSONString);
         	}
          else if(selRole == 'National'){
                string riskStr;
                if(!string.isBlank(SelDteFrom)){
                  Datetime dteFromFrmt = dateTime.NewInstance(date.valueOf(SelDteFrom), Time.newInstance(0,0,0,0));
                  dtFromStr = dteFromFrmt.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
                  }
                
                if(!string.isBlank(SelDteTo)){
                  Datetime dteToFrmt = dateTime.NewInstance(date.valueOf(SelDteTo), Time.newInstance(0,0,0,0));
                  dtToStr = dteToFrmt.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
                  }
                
                if(!string.isBlank(SelDteFrom) && !string.isBlank(SelDteTo)){
                  
                    riskStr = 'Select Id,PF_Reason_for_Risk__c, Name, Last_Activity_Type__c, ShippingState, ShippingCity, Owner.Name, PF_Last_Activity_Date__c, PF_Tier__c, PF_Risk_Date_Stamp__c From Account ' +
                            'Where recordtypeid IN: lstRTAccount AND PF_Risk__c = true AND PF_Risk_Date_Stamp__c != null AND (Account.PF_Product_Type__c = \'SNFSAU\' OR Account.PF_Product_Type__c = \'SNF Skilled\' OR Account.PF_Product_Type__c = \'SNFTCC\' OR Account.PF_Product_Type__c = \'SNFTCU\')' + 
                              'AND Status__c = \'Active\' AND PF_Risk_Date_Stamp__c >= ' + dtFromStr + ' AND PF_Risk_Date_Stamp__c <= ' + dtToStr;
                  }
                else if(!string.isBlank(SelDteFrom) && string.isBlank(SelDteTo)){
                    riskStr = 'Select Id,PF_Reason_for_Risk__c, Name, Last_Activity_Type__c, ShippingState, ShippingCity, Owner.Name, PF_Last_Activity_Date__c, PF_Tier__c, PF_Risk_Date_Stamp__c From Account ' +
                          'Where recordtypeid IN: lstRTAccount AND PF_Risk__c = true AND PF_Risk_Date_Stamp__c != null AND (Account.PF_Product_Type__c = \'SNFSAU\' OR Account.PF_Product_Type__c = \'SNF Skilled\' OR Account.PF_Product_Type__c = \'SNFTCC\' OR Account.PF_Product_Type__c = \'SNFTCU\')' +
                             'AND Status__c = \'Active\' AND PF_Risk_Date_Stamp__c >= '+ dtFromStr;
                  }
                else if(string.isBlank(SelDteFrom) && !string.isBlank(SelDteTo)){
                    riskStr = 'Select Id,PF_Reason_for_Risk__c, Name, Last_Activity_Type__c, ShippingState, ShippingCity, Owner.Name, PF_Last_Activity_Date__c, PF_Tier__c, PF_Risk_Date_Stamp__c From Account ' +
                          'Where recordtypeid IN: lstRTAccount AND (Account.PF_Product_Type__c = \'SNFSAU\' OR Account.PF_Product_Type__c = \'SNF Skilled\' OR Account.PF_Product_Type__c = \'SNFTCC\' OR Account.PF_Product_Type__c = \'SNFTCU\')' +
                             'AND Status__c = \'Active\' AND PF_Risk_Date_Stamp__c <= ' + dtToStr;
                  }
                else{
                  riskStr = 'Select Id,PF_Reason_for_Risk__c, Name, Last_Activity_Type__c, ShippingState, ShippingCity, Owner.Name, PF_Last_Activity_Date__c, PF_Tier__c, PF_Risk_Date_Stamp__c From Account ' + 
                          'Where recordtypeid IN: lstRTAccount AND (Account.PF_Product_Type__c = \'SNFSAU\' OR Account.PF_Product_Type__c = \'SNF Skilled\' OR Account.PF_Product_Type__c = \'SNFTCC\' OR Account.PF_Product_Type__c = \'SNFTCU\') AND Status__c = \'Active\' AND PF_Risk_Date_Stamp__c != null';
                  }
                if(sortStr != null){
                    riskStr = riskStr + sortStr;
                  }
            riskAccounts = database.query(riskStr);
            list<reportWrapper> processList = new list<reportWrapper>();
                for(Account a: riskAccounts){
                  processList.add(new reportWrapper(a.ID, a.Name, a.Owner.Name, string.valueOf(a.PF_Last_Activity_Date__c), a.PF_Reason_for_Risk__c, a.PF_Risk_Date_Stamp__c, null, null, null, a.PF_Tier__c));
                  }
            JSONString = JSON.serialize(processList);
            System.debug('Serialized list of at-risk Accounts into JSON format: ' + JSONString);
             }
            return JSONString;
        	}    
    
    @AuraEnabled
    public static integer getTotalAccounts(string selRole, string selRoleName, string selIndividual){
      system.debug('selRoleT : ' + selRole);
      system.debug('selRoleNameT : ' + selRoleName);
      system.debug('selIndividualT : ' + selIndividual);
      integer totalAccounts;
      set<Id> setRoleId = new set<Id>();  
      set<Id> setAllRoleId = new set<Id>();
      if((selRole != 'National' && (selRole == 'DVP' || selRole == 'RVP' ||selRole == 'ADO')) && (selRoleName != '--None Selected--' || selRoleName != null)){
      	if(selIndividual == '--None Selected--'){
                Id RoleId = [select id, Name From UserRole where Name =: selRoleName].Id;
                setRoleId.add(RoleId);
                //assigns the roles returned from getAllSubRoleIds to set, setAllRoleId.
                setAllRoleId = getAllSubRoleIds(setRoleId); 
                setAllRoleId.add(RoleId);
                }
      if(selIndividual != '--None Selected--' && selIndividual != null){
                AggregateResult total = database.Query('SELECT Count(Account.ID)result FROM AccountTeamMember WHERE Account.Status__c = \'Active\' AND (Account.PF_Product_Type__c = \'SNFSAU\' OR Account.PF_Product_Type__c = \'SNF Skilled\' OR Account.PF_Product_Type__c = \'SNFTCC\' OR Account.PF_Product_Type__c = \'SNFTCU\') AND Account.recordtypeid IN: lstRTAccount AND User.Name = \'' + selIndividual + '\'');
                totalAccounts = integer.valueOf(total.get('result'));
                }
               else{
                  AggregateResult total = database.Query('SELECT Count(Account.ID)result FROM AccountTeamMember WHERE Account.Status__c = \'Active\' AND (Account.PF_Product_Type__c = \'SNFSAU\' OR Account.PF_Product_Type__c = \'SNF Skilled\' OR Account.PF_Product_Type__c = \'SNFTCC\' OR Account.PF_Product_Type__c = \'SNFTCU\') AND Account.recordtypeid IN: lstRTAccount AND User.UserRoleId IN: setAllRoleId');
                  totalAccounts = integer.valueOf(total.get('result')); 
                  }
      		}
      else if(selRole == 'National'){
      	totalAccounts = [SELECT COUNT() FROM Account WHERE Status__c = 'Active' AND recordtypeid IN: lstRTAccount 
                                                          AND (PF_Product_Type__c =: 'SNFSAU' OR PF_Product_Type__c =: 'SNF Skilled' OR PF_Product_Type__c =: 'SNFTCC' OR PF_Product_Type__c =: 'SNFTCU')];
      	}		
      return totalAccounts;
      }    
      
    /*
    Method Name: getAccountWithoutActivity
    Return type: string selRole, string selRoleName
    Description: Method is called when selected report name is 'Accounts Without Activity' and returns list of data containing count of 
                active and inactive account in the JSON format. 
    */
    public static string getAccountWithoutActivity(string selRole, string selRoleName, string selIndividual, string SelDteFrom, string SelDteTo){
        string dtFromStr;
        string dtToStr;
        integer totalActive;
        if(!string.isBlank(SelDteFrom)){
                  Datetime dteFromFrmt = dateTime.NewInstance(date.valueOf(SelDteFrom), Time.newInstance(0,0,0,0));
                  dtFromStr = dteFromFrmt.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
                  }
                
                if(!string.isBlank(SelDteTo)){
                  Datetime dteToFrmt = dateTime.NewInstance(date.valueOf(SelDteTo), Time.newInstance(0,0,0,0));
                  dtToStr = dteToFrmt.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
                  }
        List<string> listColors = new List<string>();
        List<Chart_Colors_for_Partner_Charts__c> lstChartcolor = Chart_Colors_for_Partner_Charts__c.getall().values();
        for(Chart_Colors_for_Partner_Charts__c objPartnerColor : lstChartcolor){
          listColors.add(objPartnerColor.Name);
          }
        
        list<String> typeList = new list<String>();
        //list to store the chart name and list of lstSNFChartRatio which is passed back as JSON format
        list<SNFChartRatioForMultipleCharts> lstSNFChartRatioForMultipleCharts = new list<SNFChartRatioForMultipleCharts>();
        
        //list to store the value which contains segment name and count. 
        List<SNFChartRatio>lstSNFChartRatio = new List<SNFChartRatio>();
        map<Id, Account> mapAccountidtoAccount = new map<Id, Account>();
        
        set<Id> setRoleId = new set<Id>();   
        set<Id> setAllRoleId = new set<Id>(); 
        
        //If selected Role from first picklist is not national, getAllSubRoleIds is called to get all the roles beneath the selected role in second picklist.
        if((selRole != 'National' && (selRole == 'DVP' || selRole == 'RVP' ||selRole == 'ADO')) && (selRoleName != '--None Selected--' || selRoleName != null)){
            system.debug('selRoleName: ' + selRoleName);
            if(selIndividual == '--None Selected--'){
              Id RoleId = [select id, Name From UserRole where Name =: selRoleName].Id;
              setRoleId.add(RoleId);
              //assigns the roles returned from getAllSubRoleIds to set, setAllRoleId.
              setAllRoleId = getAllSubRoleIds(setRoleId); 
              setAllRoleId.add(RoleId);
              }
            
            set<ID> ids = new set<ID>();
            string eventQuery = 'SELECT AccountId, Type, ActivityDate FROM Event WHERE RecordTypeId =: rhcEvent AND (Type = \'F2F - QBR\' OR Type = \'F2F - PD Monthly Meeting\' OR Type = \'F2F\' OR Type = \'CPS Live Client Engagement - CPS Use Only\' OR Type = \'CPS Live Rehab Engagement - CPS Use Only\' OR Type = \'CPS Remote Client Engagement - CPS Use Only\' OR Type = \'CPS Remote Rehab Engagement - CPS Use Only\' OR Type = \'Phone Call\' OR Type = \'Email\')';
      if(!string.isBlank(SelDteFrom) && !string.isBlank(SelDteTo)){
              eventQuery = eventQuery + ' AND (StartDateTime >='+dtFromStr+' AND StartDateTime <='+dtToStr +')';
              }
            else if (!string.isBlank(SelDteFrom) && string.isBlank(SelDteTo)){
              eventQuery = eventQuery + ' AND (StartDateTime >=' + dtFromStr + ')';
              }
            else if(string.isBlank(SelDteFrom) && !string.isBlank(SelDteTo)){
              eventQuery = eventQuery + ' AND (StartDateTime <=' + dtToStr + ')';
              }
            else if(string.isBlank(SelDteFrom) && string.isBlank(SelDteTo)){
              eventQuery = eventQuery;
              }  
              
      for(Event objEvent : database.query(eventQuery)){
        ids.add(objEvent.AccountId);
        }
        
            //query string to fetch the account from AccountTeamMember based on given PF_Product_Type__c value, having role from above set and recordtypeid in lstRTAccount and adds account into the map, mapAccountidtoAccount.
            string AccountTeamMemberQuery = 'Select UserId, User.UserRoleId, Account.PF_Product_Type__c, Account.DaysSinceLastActivity__c, Account.PF_Last_Activity_Date__c, Account.Last_Activity_Type__c, Account.PF_Risk_Date_Stamp__c, Account.PF_Reason_for_Risk__c '+
                                         'From AccountTeamMember WHERE Account.Status__c = \'Active\' AND (Account.PF_Product_Type__c = \'SNFSAU\' OR Account.PF_Product_Type__c = \'SNF Skilled\' OR Account.PF_Product_Type__c = \'SNFTCC\' OR Account.PF_Product_Type__c = \'SNFTCU\')'+
                                         ' AND Account.recordtypeid IN: lstRTAccount AND Account.ID NOT IN: ids';
             system.debug('query dateFrom: ' + SelDteFrom + ' query dateTo: ' + SelDteTo);
              
              if(selIndividual != '--None Selected--' && selIndividual != null){
                AccountTeamMemberQuery = AccountTeamMemberQuery + ' AND User.Name = \'' + selIndividual + '\'';
                AggregateResult total = database.Query('SELECT Count(Account.ID)result FROM AccountTeamMember WHERE Account.Status__c = \'Active\' AND (Account.PF_Product_Type__c = \'SNFSAU\' OR Account.PF_Product_Type__c = \'SNF Skilled\' OR Account.PF_Product_Type__c = \'SNFTCC\' OR Account.PF_Product_Type__c = \'SNFTCU\') AND Account.recordtypeid IN: lstRTAccount AND User.Name = \'' + selIndividual + '\'');
                totalAccounts = integer.valueOf(total.get('result'));
                }
               else{
                  AccountTeamMemberQuery = AccountTeamMemberQuery + ' AND User.UserRoleId IN: setAllRoleId';
                  AggregateResult total = database.Query('SELECT Count(Account.ID)result FROM AccountTeamMember WHERE Account.Status__c = \'Active\' AND (Account.PF_Product_Type__c = \'SNFSAU\' OR Account.PF_Product_Type__c = \'SNF Skilled\' OR Account.PF_Product_Type__c = \'SNFTCC\' OR Account.PF_Product_Type__c = \'SNFTCU\') AND Account.recordtypeid IN: lstRTAccount AND User.UserRoleId IN: setAllRoleId');
                  totalAccounts = integer.valueOf(total.get('result')); 
                  }
            
            system.debug('Query: ' + AccountTeamMemberQuery);  
            for(AccountTeamMember objAccountTeamMember : database.query(AccountTeamMemberQuery)){
              mapAccountidtoAccount.put(objAccountTeamMember.AccountId,objAccountTeamMember.Account);
              }
          }
        //If selected Role from first picklist is not national, it queries the account based on PF_Product_Type__c and recordtypeid and adds it to the map, mapAccountidtoAccount
        else if(selRole == 'National'){
          set<ID> ids = new set<ID>();
            string eventQuery = 'SELECT AccountId, Type, StartDateTime FROM Event WHERE RecordTypeId =: rhcEvent AND (Type = \'F2F - QBR\' OR Type = \'F2F - PD Monthly Meeting\' OR Type = \'F2F\' OR Type = \'CPS Live Client Engagement - CPS Use Only\' OR Type = \'CPS Live Rehab Engagement - CPS Use Only\' OR Type = \'CPS Remote Client Engagement - CPS Use Only\' OR Type = \'CPS Remote Rehab Engagement - CPS Use Only\' OR Type = \'Phone Call\' OR Type = \'Email\')';
      		if(!string.isBlank(SelDteFrom) && !string.isBlank(SelDteTo)){
              eventQuery = eventQuery + ' AND (StartDateTime >='+dtFromStr+' AND StartDateTime <='+dtToStr +')';
              }
            else if (!string.isBlank(SelDteFrom) && string.isBlank(SelDteTo)){
              eventQuery = eventQuery + ' AND (StartDateTime >=' + dtFromStr + ')';
              }
            else if(string.isBlank(SelDteFrom) && !string.isBlank(SelDteTo)){
              eventQuery = eventQuery + ' AND (StartDateTime <=' + dtToStr + ')';
              }
            else if(string.isBlank(SelDteFrom) && string.isBlank(SelDteTo)){
              eventQuery = eventQuery;
              }  
            
              
      for(Event objEvent : database.query(eventQuery)){
        ids.add(objEvent.AccountId);
        }
       system.debug('National Event Chart Query: ' + eventQuery);
            
          mapAccountidtoAccount = new Map<Id, Account>([Select Id, DaysSinceLastActivity__c, Last_Activity_Type__c, PF_Last_Activity_Date__c, PF_Risk_Date_Stamp__c, PF_Reason_for_Risk__c 
                                                          From Account 
                                                          Where Status__c = 'Active' AND recordtypeid IN: lstRTAccount AND ID NOT IN: ids
                                                          AND (PF_Product_Type__c =: 'SNFSAU' OR PF_Product_Type__c =: 'SNF Skilled' OR PF_Product_Type__c =: 'SNFTCC' OR PF_Product_Type__c =: 'SNFTCU')]);  
          
          totalAccounts = [SELECT COUNT() FROM Account WHERE Status__c = 'Active' AND recordtypeid IN: lstRTAccount 
                                                          AND (PF_Product_Type__c =: 'SNFSAU' OR PF_Product_Type__c =: 'SNF Skilled' OR PF_Product_Type__c =: 'SNFTCC' OR PF_Product_Type__c =: 'SNFTCU')];
          
          }
        integer cntInactive = 0;
        
        //based on Last Activity Date value of the account in mapAccountidtoAccount, calculates active and inative account count and adds to wrapper list lstSNFChartRatio.
        for(Account objAccount : mapAccountidtoAccount.values()){
                cntInactive += 1;
                }
        
        Integer randomIndex1 = Math.floor(Math.random() * listColors.size()).intValue();
        Integer randomIndex2;
        string Index3 = '#3360FF';
        if(randomIndex1 < listColors.size()-1){
            randomIndex2 = randomIndex1+1;
            }
        else{
            randomIndex2 = 0;
            }
          totalActive = totalAccounts - cntInactive;  
        
        
          lstSNFChartRatio.add(new SNFChartRatio('Accounts With Activity', 'Accounts With Activity', totalActive, listColors[randomIndex1]));
          lstSNFChartRatio.add(new SNFChartRatio('Accounts Without Activity', 'Accounts Without Activity', cntInactive, listColors[randomIndex2]));
        //lstSNFChartRatio is added with the report title and converted to JSON format and returned.
        lstSNFChartRatioForMultipleCharts.add(new SNFChartRatioForMultipleCharts('SNF Accounts Without Activity', lstSNFChartRatio));
        String JSONString = JSON.serialize(lstSNFChartRatioForMultipleCharts);
        System.debug('Serialized list of invoices into JSON format: ' + JSONString);
      return JSONString;
        }
    
    /*
    Method Name: getDashboardData
    Return type: string selRole, string selRoleName, string selReport
    Description: Method is called when selected report name is 'PD Monthly Meeting' Or 'QBR Tracking'
    */
    public static string getDashboardData(string selRole, string selRoleName, string selReport, string selIndividual, string SelDteFrom, string SelDteTo){
        String JsonString ;
        //list to store the value which contains segment name and count. 
        List<SNFChartRatio>lstSNFChartRatio = new List<SNFChartRatio>();
        //list to store the chart name and list of lstSNFChartRatio which is passed back as JSON format
        list<SNFChartRatioForMultipleCharts> lstSNFChartRatioForMultipleCharts = new list<SNFChartRatioForMultipleCharts>();
        
        map <string, Decimal> mapPFTiertoCount = new map<string, Decimal>();
        map<Id, Account> mapAccountidtoAccount = new map<Id, Account>();
        set<id> setAccountId = new set<Id>();
        
        set<Id> setRoleId = new set<Id>();  
        set<Id> setAllRoleId = new set<Id>(); 
        if((selRole != 'National' && (selRole == 'DVP' || selRole == 'RVP' ||selRole == 'ADO')) && (selRoleName != '--None Selected--' || selRoleName != null)){
            if(selIndividual == '--None Selected--'){
                Id RoleId = [select id, Name From UserRole where Name =: selRoleName].Id;
                setRoleId.add(RoleId);
                //assigns the roles returned from getAllSubRoleIds to set, setAllRoleId.
                setAllRoleId = getAllSubRoleIds(setRoleId); 
                setAllRoleId.add(RoleId);
              }
            
            string AccountTeamMemberQuery = 'Select UserId, User.UserRoleId, Account.PF_Product_Type__c, Account.PF_Risk_Date_Stamp__c, Account.Last_Activity_Type__c, Account.PF_Tier__c, Account.PF_Reason_for_Risk__c, Account.DaysSinceLastActivity__c '+
                                         'From AccountTeamMember Where Account.Status__c = \'Active\' AND User.UserRoleId IN: setAllRoleId'+
                                         ' AND (Account.PF_Product_Type__c = \'SNFSAU\' OR Account.PF_Product_Type__c = \'SNF Skilled\' OR Account.PF_Product_Type__c = \'SNFTCC\' OR Account.PF_Product_Type__c = \'SNFTCU\')'+
                                         ' AND Account.recordtypeid IN: lstRTAccount AND Account.PF_Tier__c != null';
            
            if(selIndividual != '--None Selected--' && selIndividual != null){
                AccountTeamMemberQuery = AccountTeamMemberQuery + ' AND User.Name = \'' + selIndividual + '\'';
              	}
            else{
              AccountTeamMemberQuery = AccountTeamMemberQuery + ' AND User.UserRoleId IN: setAllRoleId';
              }  
            for(AccountTeamMember objAccountTeamMember : database.query(AccountTeamMemberQuery)){
              mapAccountidtoAccount.put(objAccountTeamMember.AccountId,objAccountTeamMember.Account);
              }
            }
        else if(selRole == 'National'){
            mapAccountidtoAccount = new Map<Id, Account>([Select Id, PF_Tier__c 
                                                              From Account 
                                                              Where Status__c = 'Active' AND recordtypeid IN: lstRTAccount AND PF_Tier__c!= null
                                                          AND (PF_Product_Type__c =: 'SNFSAU' OR PF_Product_Type__c =: 'SNF Skilled' OR PF_Product_Type__c =: 'SNFTCC' OR PF_Product_Type__c =: 'SNFTCU')]); 
            }
        /*if(selReport == 'PD Monthly Meeting'){
            JsonString = getPDMonthlyMeeting(mapAccountidtoAccount, SelDteFrom, SelDteTo);
            }*/
        if(selReport == 'QBR Tracking'){
            JsonString = getQBRTracking(mapAccountidtoAccount, SelDteFrom, SelDteTo);
            }
        return JsonString;
        }
    
    /*
    Method Name: getPDMonthlyMeeting
    Return type: string selRole, string selRoleName, string selReport
    Description: Method is called when selected report name is 'PD Monthly Meeting'. and retuns list of data containing count based on PF Tier value
    */
    /*public static string getPDMonthlyMeeting(map<id, Account> mapAccountidtoAccount, string SelDteFrom, string SelDteTo){
        //list to store the value which contains segment name and count. 
        List<SNFChartRatio>lstSNFChartRatio = new List<SNFChartRatio>();
        //list to store the chart name and list of lstSNFChartRatio which is passed back as JSON format
        list<SNFChartRatioForMultipleCharts> lstSNFChartRatioForMultipleCharts = new list<SNFChartRatioForMultipleCharts>();
        map<string, list<SNFChartRatio>> mapPFTiertoSNFChartRatioForMultipleCharts = new map<string, list<SNFChartRatio>>();
        map<string, Integer> mapPFTiertoTotalAccounts = new map<string, Integer>();
        set<id> setAccountId = new set<Id>();
        Integer intTotalAccounts= 0;
        
        List<string> listColors = new List<string>();
        List<Chart_Colors_for_Partner_Charts__c> lstChartcolor = Chart_Colors_for_Partner_Charts__c.getall().values();
        
        for(Chart_Colors_for_Partner_Charts__c objPartnerColor : lstChartcolor){
            listColors.add(objPartnerColor.Name);
          }
        AggregateResult[] groupedResultsTotalAccounts = [SELECT COUNT(Id),PF_Tier__c FROM ACCOUNT where Id IN:mapAccountidtoAccount.keyset() GROUP BY PF_Tier__c];
        for(AggregateResult ar : groupedResultsTotalAccounts){
            mapPFTiertoTotalAccounts.put(String.valueOf(ar.get('PF_Tier__c')), Integer.valueOf(ar.get('expr0')));
            intTotalAccounts=intTotalAccounts+Integer.valueOf(ar.get('expr0'));
          }
        for(Event objEvent : [SELECT id, AccountId, Type, ActivityDate FROM Event WHERE type=: 'F2F - PD Monthly Meeting' and AccountId IN:mapAccountidtoAccount.keySet()]){
            if(!string.isBlank(SelDteFrom) && !string.isBlank(SelDteTo)){
              if(objEvent.ActivityDate >= date.valueOf(SelDteFrom) && objEvent.ActivityDate <= date.valueOf(SelDteTo)){
                setAccountId.add(objEvent.AccountId);
                }
              }
            else if(!string.isBlank(SelDteFrom) && string.isBlank(SelDteTo)){
              if(objEvent.ActivityDate >= date.valueOf(SelDteFrom)){
                setAccountId.add(objEvent.AccountId);
                }
              }
            else if(string.isBlank(SelDteFrom) && !string.isBlank(SelDteTo)){
              if(objEvent.ActivityDate <= date.valueOf(SelDteTo)){
                  setAccountId.add(objEvent.AccountId);
                  }    
                }
            else{
                setAccountId.add(objEvent.AccountId);
                }
            }
        
        list<string> listPFVal = new list<string>();
        
        Schema.DescribeFieldResult fieldResult = Account.PF_Tier__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for(Schema.PicklistEntry f : ple){
            listPFVal.add(f.getValue());
            }
        decimal AllPFCount = 0;
        AggregateResult[] groupedResults = [SELECT COUNT(Id),PF_Tier__c FROM ACCOUNT where Id IN:setAccountId GROUP BY PF_Tier__c];
        
        set<string> setPFValfromRecords = new set<string>();
        for(AggregateResult ar : groupedResults){
            lstSNFChartRatio = new list<SNFChartRatio>();
            Integer randomIndex1 = Math.floor(Math.random() * listColors.size()).intValue();
            Integer randomIndex2;
            if(randomIndex1 < listColors.size()-1){
                randomIndex2 = randomIndex1+1;
                }
            else{
                randomIndex2 = 0;
              }
            AllPFCount = AllPFCount+ Integer.valueOf(ar.get('expr0')); 
            lstSNFChartRatio.add(new SNFChartRatio('PF Tier '+String.valueOf(ar.get('PF_Tier__c')), 'PF Tier '+String.valueOf(ar.get('PF_Tier__c'))+' Accounts with Activity' , Integer.valueOf(ar.get('expr0')), listColors[randomIndex1]));
            lstSNFChartRatio.add(new SNFChartRatio('All Accounts', 'All Accounts', mapPFTiertoTotalAccounts.get(String.valueOf(ar.get('PF_Tier__c'))),listColors[randomIndex2]));
            mapPFTiertoSNFChartRatioForMultipleCharts.put(String.valueOf(ar.get('PF_Tier__c')), lstSNFChartRatio);
          }
        listPFVal.sort();
        for(string strPF : listPFVal){
            if(mapPFTiertoSNFChartRatioForMultipleCharts.containsKey(strPF)){
                lstSNFChartRatioForMultipleCharts.add(new SNFChartRatioForMultipleCharts('PD Monthly Meeting - PF Tier '+strPF, mapPFTiertoSNFChartRatioForMultipleCharts.get(strPF)));
              }
            else{
                Integer randomIndex1 = Math.floor(Math.random() * listColors.size()).intValue();
                Integer randomIndex2;
                if(randomIndex1 < listColors.size()-1){
                    randomIndex2 = randomIndex1+1;
                  }
                else{
                    randomIndex2 = 0;
                  }
                lstSNFChartRatio = new list<SNFChartRatio>();
                
                lstSNFChartRatio.add(new SNFChartRatio('PF Tier '+strPF, 'PF Tier '+strPF+' Accounts with Activity', 0, listColors[randomIndex1]));
                if(mapPFTiertoTotalAccounts.get(strPF) == null){
                    lstSNFChartRatio.add(new SNFChartRatio('PF Tier '+strPF, 'PF Tier '+strPF+' Accounts with Activity', 0, listColors[randomIndex1]));
                  }
                else{    
                    lstSNFChartRatio.add(new SNFChartRatio('All Accounts', 'All Accounts', mapPFTiertoTotalAccounts.get(strPF),listColors[randomIndex2]));
                  }
                lstSNFChartRatioForMultipleCharts.add(new SNFChartRatioForMultipleCharts('PD Monthly Meeting - PF Tier '+strPF, lstSNFChartRatio));
              }
        
          }
        lstSNFChartRatio = new list<SNFChartRatio>();
        Integer randomIndex1 = Math.floor(Math.random() * listColors.size()).intValue();
        for(string strPF : listPFVal){
            if(strPF == '1'){
                decimal idealPFVal = (25*intTotalAccounts)/100;
                decimal idealPFValCeil = idealPFVal.round(System.RoundingMode.CEILING);
                lstSNFChartRatio.add(new SNFChartRatio('PF Tier '+strPF, 'PF Tier '+strPF, idealPFValCeil, listColors[randomIndex1]));
              }
            else if(strPF == '2' || strPF == '3'){
                if(randomIndex1 < listColors.size()-1){
                    randomIndex1 = randomIndex1+1;
                  }
                else{
                    randomIndex1 = 0;
                  }
                decimal idealPFVal = (50*intTotalAccounts)/100;
                decimal idealPFValCeil = idealPFVal.round(System.RoundingMode.CEILING);
                lstSNFChartRatio.add(new SNFChartRatio('PF Tier '+strPF, 'PF Tier '+strPF, idealPFValCeil, listColors[randomIndex1]));
              }
          }
        lstSNFChartRatioForMultipleCharts.add(new SNFChartRatioForMultipleCharts('PD Monthly Meeting - All Chart Goals', lstSNFChartRatio));
        String JSONString = JSON.serialize(lstSNFChartRatioForMultipleCharts);
        return JSONString;
        }*/
    
    /*
    Method Name: getQBRTracking
    Return type: string selRole, string selRoleName, string selReport
    Description: 
    */
    public static string getQBRTracking(map<id, Account> mapAccountidtoAccount, string SelDteFrom, string SelDteTo){
        //list to store the value which contains segment name and count. 
        List<SNFChartRatio>lstSNFChartRatio = new List<SNFChartRatio>();
        //list to store the chart name and list of lstSNFChartRatio which is passed back as JSON format
        list<SNFChartRatioForMultipleCharts> lstSNFChartRatioForMultipleCharts = new list<SNFChartRatioForMultipleCharts>();
        map<string, list<SNFChartRatio>> mapPFTiertoSNFChartRatioForMultipleCharts = new map<string, list<SNFChartRatio>>();
        map<string, Integer> mapPFTiertoTotalAccounts = new map<string, Integer>();
        set<id> setAccountId = new set<Id>();
        
        Integer intTotalAccounts= 0;
        list<string> listPFVal = new list<string>();
        
        List<string> listColors = new List<string>();
        List<Chart_Colors_for_Partner_Charts__c> lstChartcolor = Chart_Colors_for_Partner_Charts__c.getall().values();
        system.debug('=====lstChartcolor==='+lstChartcolor);
        
        for(Chart_Colors_for_Partner_Charts__c objPartnerColor : lstChartcolor){
            listColors.add(objPartnerColor.Name);
            }
        
        AggregateResult[] groupedResultsTotalAccounts = [SELECT COUNT(Id),PF_Tier__c FROM ACCOUNT where Id IN:mapAccountidtoAccount.keyset() GROUP BY PF_Tier__c];
        
        for(AggregateResult ar : groupedResultsTotalAccounts){
            mapPFTiertoTotalAccounts.put(String.valueOf(ar.get('PF_Tier__c')), Integer.valueOf(ar.get('expr0')));
            intTotalAccounts=intTotalAccounts+Integer.valueOf(ar.get('expr0'));
            }
        
        for(Event objEvent : [SELECT id, AccountId, Type, ActivityDate FROM Event WHERE type=: 'F2F - QBR' and AccountId IN:mapAccountidtoAccount.keySet()]){
            if(!string.isBlank(SelDteFrom) && !string.isBlank(SelDteTo)){
              if(objEvent.ActivityDate >= date.valueOf(SelDteFrom) && objEvent.ActivityDate <= date.valueOf(SelDteTo)){
                setAccountId.add(objEvent.AccountId);
                }
              }
            else if(!string.isBlank(SelDteFrom) && string.isBlank(SelDteTo)){
                if(objEvent.ActivityDate >= date.valueOf(SelDteFrom)){
                  setAccountId.add(objEvent.AccountId);
                  }
              }
            else if(string.isBlank(SelDteFrom) && !string.isBlank(SelDteTo)){
                if(objEvent.ActivityDate <= date.valueOf(SelDteTo)){
                  setAccountId.add(objEvent.AccountId);
                  }    
              }
          else{
              setAccountId.add(objEvent.AccountId);
              }
            }
        
        Schema.DescribeFieldResult fieldResult = Account.PF_Tier__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple){
            listPFVal.add(f.getValue());
            } 
        
        decimal SNFCount = mapAccountidtoAccount.size();
        decimal AllPFCount = 0;
        AggregateResult[] groupedResults = [SELECT COUNT(Id),PF_Tier__c FROM ACCOUNT where Id IN:setAccountId GROUP BY PF_Tier__c];
        
        set<string> setPFValfromRecords = new set<string>();
        for(AggregateResult ar : groupedResults){
            Integer randomIndex1 = Math.floor(Math.random() * listColors.size()).intValue();
            Integer randomIndex2;
            if(randomIndex1 < listColors.size()-1){
                randomIndex2 = randomIndex1+1;
                }
            else{
                randomIndex2 = 0;
                }
            lstSNFChartRatio = new list<SNFChartRatio>();
            AllPFCount = AllPFCount+ Integer.valueOf(ar.get('expr0')); 
            lstSNFChartRatio.add(new SNFChartRatio('PF Tier '+String.valueOf(ar.get('PF_Tier__c')), 'PF Tier '+String.valueOf(ar.get('PF_Tier__c'))+' Accounts with Activity', Integer.valueOf(ar.get('expr0')), listColors[randomIndex1]));
            lstSNFChartRatio.add(new SNFChartRatio('All Accounts', 'All Accounts', mapPFTiertoTotalAccounts.get(String.valueOf(ar.get('PF_Tier__c'))), listColors[randomIndex2]));
            mapPFTiertoSNFChartRatioForMultipleCharts.put(String.valueOf(ar.get('PF_Tier__c')), lstSNFChartRatio);
            }
        listPFVal.sort();
        
        for(string strPF : listPFVal){
            lstSNFChartRatio = new list<SNFChartRatio>();
            if(mapPFTiertoSNFChartRatioForMultipleCharts.containsKey(strPF)){
                lstSNFChartRatioForMultipleCharts.add(new SNFChartRatioForMultipleCharts('QBR Tracking - PF Tier '+strPF, mapPFTiertoSNFChartRatioForMultipleCharts.get(strPF)));
                }
            else{
                Integer randomIndex1 = Math.floor(Math.random() * listColors.size()).intValue();
                Integer randomIndex2;
                if(randomIndex1 < listColors.size()-1){
                    randomIndex2 = randomIndex1+1;
                    }
                else{
                    randomIndex2 = 0;
                    }
                lstSNFChartRatio.add(new SNFChartRatio('PF Tier '+strPF, 'PF Tier '+strPF+' Accounts with Activity', 0, listColors[randomIndex1]));
                if(mapPFTiertoTotalAccounts.get(strPF) == null ){
                    lstSNFChartRatio.add(new SNFChartRatio('PF Tier '+strPF, 'PF Tier '+strPF+' Accounts with Activity', 0, listColors[randomIndex1]));
                    }
                else{    
                    lstSNFChartRatio.add(new SNFChartRatio('All Accounts', 'All Accounts', mapPFTiertoTotalAccounts.get(strPF), listColors[randomIndex2]));
                    }
                lstSNFChartRatioForMultipleCharts.add(new SNFChartRatioForMultipleCharts('QBR Tracking - PF Tier '+strPF, lstSNFChartRatio));
                }
            lstSNFChartRatio.clear();
            }
        
        lstSNFChartRatio = new list<SNFChartRatio>();
        for(string strPF : listPFVal){
            
            Integer randomIndex1 = Math.floor(Math.random() * listColors.size()).intValue();
            if(strPF == '1'){
                decimal idealPFVal = (50*intTotalAccounts)/100;
                decimal idealPFValCeil = idealPFVal.round(System.RoundingMode.CEILING);
                lstSNFChartRatio.add(new SNFChartRatio('PF Tier '+strPF, 'PF Tier '+strPF, idealPFValCeil, listColors[randomIndex1]));
                }
            else if(strPF == '2' || strPF == '3'){
                
                if(randomIndex1 < listColors.size()-1){
                    randomIndex1 = randomIndex1+1;
                    }
                else{
                    randomIndex1 = 0;
                    }
                decimal idealPFVal = (50*intTotalAccounts)/100;
                decimal idealPFValCeil = idealPFVal.round(System.RoundingMode.CEILING);
                lstSNFChartRatio.add(new SNFChartRatio('PF Tier '+strPF, 'PF Tier '+strPF, idealPFValCeil, listColors[randomIndex1]));
                }
            }
        lstSNFChartRatioForMultipleCharts.add(new SNFChartRatioForMultipleCharts('QBR Tracking - All Chart Goals', lstSNFChartRatio));
        String JSONString = JSON.serialize(lstSNFChartRatioForMultipleCharts);
        return JSONString;
        }
    
    /*
    Method Name: getRiskAccount
    Return type: string selRole, string selRoleName
    Description: method is called when selected report name is 'Risk Account', 
    */
    public static string getRiskAccount(string selRole, string selRoleName, string selIndividual, string SelDteFrom, string SelDteTo){
        set<string> setRiskReason = new set<string>();
        string dtFromStr;
        string dtToStr;
        //list to store the value which contains segment name and count. 
        List<SNFChartRatio>lstSNFChartRatio = new List<SNFChartRatio>();
        //list to store the chart name and list of lstSNFChartRatio which is passed back as JSON format
        list<SNFChartRatioForMultipleCharts> lstSNFChartRatioForMultipleCharts = new list<SNFChartRatioForMultipleCharts>();
        map <string, Decimal> mapRisktoCount = new map<string, Decimal>();
        map<Id, Account> mapAccountidtoAccount = new map<Id, Account>();
        set<id> setAccountId = new set<Id>();
        system.debug('SelDteFrom: ' + SelDteFrom + ' SelDteTo: ' + SelDteTo);
        List<string> listColors = new List<string>();
        List<Chart_Colors_for_Partner_Charts__c> lstChartcolor = Chart_Colors_for_Partner_Charts__c.getall().values();
        system.debug('=====lstChartcolor==='+lstChartcolor);
        list<Account> accs = new list<Account>();
        for(Chart_Colors_for_Partner_Charts__c objPartnerColor : lstChartcolor){
            listColors.add(objPartnerColor.Name);
            }
        
        //query for custom setting to get all the risk values and add it tho the set.
        for(Dashboard_Risk_Reason__c objRisk : [select Name from Dashboard_Risk_Reason__c]){
            setRiskReason.add(objRisk.Name);
            }
        set<Id> setRoleId = new set<Id>();  
        set<Id> setAllRoleId = new set<Id>(); 
        integer intTotalAccount = 0;
        set<ID> accIds = new set<ID>();
        //If selected Role from first picklist is not national, getAllSubRoleIds is called to get all the roles beneath the selected role in second picklist.
        if((selRole != 'National' && (selRole == 'DVP' || selRole == 'RVP' ||selRole == 'ADO')) && (selRoleName != '--None Selected--' || selRoleName != null)){
            if(selIndividual == '--None Selected--'){
                Id RoleId = [select id, Name From UserRole where Name =: selRoleName].Id;
                setRoleId.add(RoleId);
                //assigns the roles returned from getAllSubRoleIds to set, setAllRoleId.
                setAllRoleId = getAllSubRoleIds(setRoleId); 
                setAllRoleId.add(RoleId);
              }
            //query on AccountTeamMember to get the accounts based on user's role, Account's Risk reason and Account's status.
            string AccountTeamMemberQuery = 'Select UserId, User.UserRoleId, Account.ID, Account.PF_Reason_for_Risk__c, Account.PF_Risk_Date_Stamp__c '+
                                            'From AccountTeamMember Where Account.recordtypeid IN: lstRTAccount '+
                                            ' AND Account.PF_Risk__c = true AND (Account.PF_Product_Type__c = \'SNFSAU\' OR Account.PF_Product_Type__c = \'SNF Skilled\' OR Account.PF_Product_Type__c = \'SNFTCC\' OR Account.PF_Product_Type__c = \'SNFTCU\') AND Account.PF_Risk_Date_Stamp__c != null AND Account.Status__c = \'Active\'';
            if(!string.isBlank(SelDteFrom)){
                  Datetime dteFromFrmt = dateTime.NewInstance(date.valueOf(SelDteFrom), Time.newInstance(0,0,0,0));
                  dtFromStr = dteFromFrmt.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
                  }
                
                if(!string.isBlank(SelDteTo)){
                  Datetime dteToFrmt = dateTime.NewInstance(date.valueOf(SelDteTo), Time.newInstance(0,0,0,0));
                  dtToStr = dteToFrmt.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
                  }
            if(!string.isBlank(SelDteFrom) && !string.isBlank(SelDteTo)){
                AccountTeamMemberQuery = AccountTeamMemberQuery + ' AND (Account.PF_Risk_Date_Stamp__c >='+ dtFromStr +' AND Account.PF_Risk_Date_Stamp__c <='+ dtToStr + ')';
                }
            else if (!string.isBlank(SelDteFrom) && string.isBlank(SelDteTo)){
              AccountTeamMemberQuery = AccountTeamMemberQuery + ' AND (Account.PF_Risk_Date_Stamp__c >=' + dtFromStr + ')';
              }
            else if(string.isBlank(SelDteFrom) && !string.isBlank(SelDteTo)){
              AccountTeamMemberQuery = AccountTeamMemberQuery + ' AND (Account.PF_Risk_Date_Stamp__c <=' + dtToStr + ')';
              }
            else if(string.isBlank(SelDteFrom) && string.isBlank(SelDteTo)){
              AccountTeamMemberQuery = AccountTeamMemberQuery;
              }  
            string accountQuery = 'Select Account.ID From AccountTeamMember Where Account.recordtypeid IN: lstRTAccount AND Account.Status__c = \'Active\'';  
            if(selIndividual == '--None Selected--'){
                AccountTeamMemberQuery = AccountTeamMemberQuery + ' AND User.UserRoleId IN: setAllRoleId ';
                accountQuery = accountQuery + ' AND User.UserRoleId IN: setAllRoleId ';
                }
            else{
                 AccountTeamMemberQuery = AccountTeamMemberQuery + ' AND User.Name = \'' + selIndividual + '\'';
                accountQuery = accountQuery + ' AND User.Name = \'' + selIndividual + '\'';
                }
            system.debug('Risk Query: ' + AccountTeamMemberQuery);
            system.debug('Risk Query Result: ' + database.query(AccountTeamMemberQuery));    
            for(AccountTeamMember objAccountTeamMember : database.query(AccountTeamMemberQuery)){
                mapAccountidtoAccount.put(objAccountTeamMember.AccountId,objAccountTeamMember.Account);
                }
            for(AccountTeamMember atm: database.query(accountQuery)){
              accIds.add(atm.Account.ID);
              }    
          }
        else if(selRole == 'National'){
          if(!string.isBlank(SelDteFrom) && !string.isBlank(SelDteTo)){
              mapAccountidtoAccount = new Map<Id, Account>([Select Id,PF_Reason_for_Risk__c From Account 
                                                            Where recordtypeid IN: lstRTAccount AND PF_Risk__c = true AND PF_Risk_Date_Stamp__c != null AND (Account.PF_Product_Type__c = 'SNFSAU' OR Account.PF_Product_Type__c = 'SNF Skilled' OR Account.PF_Product_Type__c = 'SNFTCC' OR Account.PF_Product_Type__c = 'SNFTCU') 
                                                              AND Status__c =: 'Active' AND (PF_Risk_Date_Stamp__c >=: date.valueOf(SelDteFrom) AND PF_Risk_Date_Stamp__c <=: date.valueOf(SelDteTo))]);
              }
            else if(!string.isBlank(SelDteFrom) && string.isBlank(SelDteTo)){
              mapAccountidtoAccount = new Map<Id, Account>([Select Id,PF_Reason_for_Risk__c From Account 
                                                            Where recordtypeid IN: lstRTAccount AND PF_Risk__c = true AND PF_Risk_Date_Stamp__c != null AND (Account.PF_Product_Type__c = 'SNFSAU' OR Account.PF_Product_Type__c = 'SNF Skilled' OR Account.PF_Product_Type__c = 'SNFTCC' OR Account.PF_Product_Type__c = 'SNFTCU')
                                                            AND Status__c =: 'Active' AND (PF_Risk_Date_Stamp__c >=: date.valueOf(SelDteFrom))]);
              }
            else if(string.isBlank(SelDteFrom) && !string.isBlank(SelDteTo)){
              mapAccountidtoAccount = new Map<Id, Account>([Select Id,PF_Reason_for_Risk__c From Account 
                                                            Where recordtypeid IN: lstRTAccount AND PF_Risk__c = true AND PF_Risk_Date_Stamp__c != null AND (Account.PF_Product_Type__c = 'SNFSAU' OR Account.PF_Product_Type__c = 'SNF Skilled' OR Account.PF_Product_Type__c = 'SNFTCC' OR Account.PF_Product_Type__c = 'SNFTCU')
                                                            AND Status__c =: 'Active' AND (PF_Risk_Date_Stamp__c <=: date.valueOf(SelDteTo))]);
              }
            else if(string.isBlank(SelDteFrom) && string.isBlank(SelDteTo)){
            mapAccountidtoAccount = new Map<Id, Account>([Select Id,PF_Reason_for_Risk__c From Account 
                                                            Where recordtypeid IN: lstRTAccount AND PF_Risk__c = true AND PF_Risk_Date_Stamp__c != null AND (Account.PF_Product_Type__c = 'SNFSAU' OR Account.PF_Product_Type__c = 'SNF Skilled' OR Account.PF_Product_Type__c = 'SNFTCC' OR Account.PF_Product_Type__c = 'SNFTCU')
                                                            AND Status__c =: 'Active']);
              }
          accs = [SELECT ID FROM Account WHERE recordtypeid IN: lstRTAccount AND Status__c =: 'Active'];
          for(Account a: accs){
            accIds.add(a.ID);
            }    
          system.debug('Risk Query Result 2: ' + mapAccountidtoAccount);
          }
          
        //count of account which are active to show in the 2nd chart of 4th dashboard.
        intTotalAccount = [SELECT count() FROM Account WHERE ID IN: accIds AND recordtypeid IN: lstRTAccount AND (Account.PF_Product_Type__c = 'SNFSAU' OR Account.PF_Product_Type__c = 'SNF Skilled' OR Account.PF_Product_Type__c = 'SNFTCC' OR Account.PF_Product_Type__c = 'SNFTCU') AND Status__c =: 'Active'];
        
            
        //query to get count of accounts each PF_Reason_for_Risk__c value.
        AggregateResult[] groupedResults = [SELECT COUNT(Id),PF_Reason_for_Risk__c FROM ACCOUNT where Id IN:mapAccountidtoAccount.keyset() GROUP BY PF_Reason_for_Risk__c];
        Integer randomIndex1 = Math.floor(Math.random() * listColors.size()).intValue();
        system.debug('=randomIndex1==='+randomIndex1);
        for(AggregateResult ar : groupedResults){
            if(randomIndex1 < listColors.size()-1){
                randomIndex1 =randomIndex1+1;
              }
            else{
                randomIndex1 = 0;
              }
            lstSNFChartRatio.add(new SNFChartRatio(String.valueOf(ar.get('PF_Reason_for_Risk__c')), String.valueOf(ar.get('PF_Reason_for_Risk__c')), Integer.valueOf(ar.get('expr0')), listColors[randomIndex1]));
          }
        
        lstSNFChartRatioForMultipleCharts.add(new SNFChartRatioForMultipleCharts('Reasons For Risk (SNF Only)', lstSNFChartRatio));
        
        randomIndex1 = Math.floor(Math.random() * listColors.size()).intValue();
        Integer randomIndex2;
        if(randomIndex1 < listColors.size()-1){
          randomIndex2 =randomIndex1+1;
            }
        else{
          randomIndex2 = 0;
            }
        lstSNFChartRatio = new list<SNFChartRatio>();
        lstSNFChartRatio.add(new SNFChartRatio('At Risk Accounts', 'At Risk Accounts',mapAccountidtoAccount.size(), listColors[randomIndex1]));
        lstSNFChartRatio.add(new SNFChartRatio('All Accounts', 'All Accounts',intTotalAccount,listColors[randomIndex2]));
        
        lstSNFChartRatioForMultipleCharts.add(new SNFChartRatioForMultipleCharts('At Risk Accounts (SNF Only)',lstSNFChartRatio));
        String JSONString = JSON.serialize(lstSNFChartRatioForMultipleCharts);
        System.debug('Serialized list of invoices into JSON format: ' + JSONString);
     return JSONString;
      }
    
    /**
    @MethodName : getAllSubRoleIds
    @Param      : set<Id> setRoleId
    @Description: method is called to get all the roles below the selected role from the second picklist in the dashboard component.
    **/
    public static set<Id> getAllSubRoleIds(set<Id> setRoleId){
        //set to store the role id's of the roles that are to be returned.
        Set<ID> currentRoleIds = new Set<ID>();
        for(UserRole userRole :[select Id from UserRole where ParentRoleId 
                                IN :setRoleId AND ParentRoleID != null]){
            currentRoleIds.add(userRole.Id);
          }
        if(currentRoleIds.size() > 0){
            currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
          }
    return currentRoleIds;
      }
      
   //Row Sorting
   @AuraEnabled
   public static string sortTable(String sortField, boolean isAsc, string selRole, string selRoleName, string selReport, string selIndividual, string SelDteFrom, string SelDteTo) {
       system.debug('selRole: ' + selRole);
         system.debug('selRoleName: ' + selRoleName);
         system.debug('selReport: ' + selReport);
         system.debug('selIndividual: ' + selIndividual);
         system.debug('SelDteFrom: ' + SelDteFrom);
         system.debug('SelDteTo: ' + SelDteTo);
         
         string errorString;
        String JsonString ;
        
         system.debug('sortField-->' + sortField);
       string sortStr = '';
         string sortVal = '';
        if(sortField != ''){
            if(selRole != 'National' || selReport == 'ADO Activities'){
                if(sortField == 'accountName'){
                    sortVal = 'Account.Name';
                  }
                if(sortField == 'ownerName'){
                    sortVal = 'Account.Owner.Name';
                  }
                if(sortField == 'activity'){
                    sortVal = 'Account.PF_Last_Activity_Date__c';
                  }
                if(sortField == 'activityType'){
                    sortVal = 'Account.Last_Activity_Date__c';
                  }  
                if(sortField == 'risk'){
                    sortVal = 'Account.PF_Reason_for_Risk__c';
                  }
                if(sortField == 'tier'){
                    sortVal = 'Account.PF_Tier__c';
                  }
                if(sortField == 'riskDate'){
                    sortVal = 'PF_Risk_Date_Stamp__c';
                  }
                sortStr += ' ORDER by ' + sortVal;
              }
            else if(selRole == 'National'){
              if(sortField == 'accountName'){
                    sortVal = 'Name';
                  }
                if(sortField == 'ownerName'){
                    sortVal = 'Owner.Name';
                  }
                if(sortField == 'activity'){
                    sortVal = 'PF_Last_Activity_Date__c';
                  }
                if(sortField == 'activityType'){
                    sortVal = 'Last_Activity_Type__c';
                  }  
                if(sortField == 'risk'){
                    sortVal = 'PF_Reason_for_Risk__c';
                  }
                if(sortField == 'riskDate'){
                    sortVal = 'PF_Risk_Date_Stamp__c';
                  }
                if(sortField == 'tier'){
                    sortVal = 'PF_Tier__c';
                  }
                sortStr += ' ORDER by ' + sortVal;
              }
      // if isAsc is equal to true then set 'asc' order otherwise set 'desc' order.
         if(isAsc){
            sortStr += ' ASC';
           }
          else{
            sortStr += ' DESC';
           }
        }
      System.debug('@Developer -->searchString:' + sortStr);
      
      try{
         system.debug('The query is' + sortStr);
         //calls the method based on selReport value and assigns result to JsonString.
         if(selReport == 'Accounts Without Activity'){
              JsonString = getWithoutActivityTable(selRole, selRoleName, selIndividual, SelDteFrom, SelDteTo, sortStr);
            }
         else if(selReport == 'QBR Tracking'){
              JsonString = getDashboardTable(selRole, selRoleName, selReport, selIndividual, SelDteFrom, SelDteTo, sortStr);
            }
         else if(selReport == 'Risk Account'){
               JsonString = getRiskAccountTable(selRole, selRoleName, selIndividual, SelDteFrom, SelDteTo, sortStr);
            }
        else if(selReport == 'Facility Reporting'){
        	JsonString = getFaciltyReportingTable(selRole, selRoleName, selIndividual, SelDteFrom, SelDteTo, sortStr);
        	}    
        system.debug('JSON SORT: ' + JsonString);
        return JsonString;
        } 
      catch(Exception ex){
        // for handle Exception
        return null;
        }
   }
}