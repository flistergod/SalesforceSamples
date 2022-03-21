public without sharing class SWAN_HnFController {
    @AuraEnabled
    public static List <SWAN_ReportData> getReportData(Date fromDate) {
        
        system.debug(fromDate);
        Date fromDateVal = Date.today();
        if(fromDate != null)
        {
            fromDateVal = fromDate;
        }
        List<SWAN_ReportData> reportDataList = new List<SWAN_ReportData>();
        
        Map<id,SWAN_Custom_Report__c> ATLASReportMap = new Map<id,SWAN_Custom_Report__c>([SELECT Id, name, CreatedDate FROM SWAN_Custom_Report__c WHERE CreatedDate >= :fromDateVal AND SWAN_Report_Type__c ='HnF Report' ORDER BY createdDate ASC]);
        system.debug(ATLASReportMap);
        
        
        for(Attachment att : [SELECT id,Name,CreatedDate,ParentId FROM Attachment WHERE ParentId IN :ATLASReportMap.keyset() AND CreatedDate >= :fromDateVal ORDER BY createdDate DESC])
        {
            SWAN_Custom_Report__c ATLAS = ATLASReportMap.get(att.ParentId);
            reportDataList.add(new SWAN_ReportData(att.name,ATLAS.CreatedDate,att.id));
        }
        system.debug(reportDataList);
        
        return reportDataList;
    }

    @AuraEnabled
    public static void runATLASReport(){
        Database.executeBatch(new SWAN_BatchGenerateCSVHedgAndForecast(),2000);
    }
    
    @AuraEnabled
    public static boolean getUserProfileInfo(){
        Boolean sysAdmin = false;
        Profile p = [select id,Name from Profile where id=:Userinfo.getProfileid()];
        if(p.Name == 'System Administrator')
            sysAdmin = true;
        return sysAdmin;
    }
    
}