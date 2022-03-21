public without sharing class SWAN_WINSFileController {
    @AuraEnabled
    public static List <SWAN_ReportData> getReportData(Date fromDate) {
        
        system.debug(fromDate);
        Date fromDateVal = Date.today();
        if(fromDate != null)
        {
            fromDateVal = fromDate;
        }
        List<SWAN_ReportData> reportDataList = new List<SWAN_ReportData>();
        
        Map<id,SWAN_Custom_Report__c> WINSReportMap = new Map<id,SWAN_Custom_Report__c>([SELECT Id, name, CreatedDate FROM SWAN_Custom_Report__c WHERE CreatedDate >= :fromDateVal AND SWAN_Report_Type__c ='WINS' ORDER BY createdDate ASC]);
        system.debug(WINSReportMap);
        //List<Attachment> attachmentList = [SELECT id,Name,CreatedDate,ParentId FROM Attachment WHERE ParentId IN :WINSReportMap.keyset() AND CreatedDate >= :fromDateVal ORDER BY createdDate DESC];
        //system.debug(attachmentList);
        for(Attachment att : [SELECT id,Name,CreatedDate,ParentId FROM Attachment WHERE ParentId IN :WINSReportMap.keyset() AND CreatedDate >= :fromDateVal ORDER BY createdDate DESC])
        {
            SWAN_Custom_Report__c WINS = WINSReportMap.get(att.ParentId);
            reportDataList.add(new SWAN_ReportData(att.name,WINS.CreatedDate,att.id));
        }
        system.debug('reportDataList='+reportDataList);
        
        return reportDataList;
    }

    @AuraEnabled
    public static void runWINSReport(){
        Database.executeBatch(new SWAN_BatchGenerateCSVForWins(),2000);        
    }

}