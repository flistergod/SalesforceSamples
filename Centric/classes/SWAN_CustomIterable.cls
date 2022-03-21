public class SWAN_CustomIterable implements Iterator<CSVWrapper>, Iterable<CSVWrapper>{ 
   List<CSVWrapper> lstCSVWrapper {get; set;} 
   Integer i {get; set;} 
   public SWAN_CustomIterable(map<string,Object>OSinput){ 
       lstCSVWrapper=new List<CSVWrapper>();
       List<object>allData=(List<object>)((Map<String, Object>)OSinput.get('AccountHierarchy')).get('ServiceLocations');
       string RCtype=(string)((Map<String, Object>)OSinput.get('ParentAccount')).get('ServiceRecordTypeID');
       string pan=(string)((Map<String, Object>)OSinput.get('AccountHierarchy')).get('ParentAccountName');
       string pai=(string)((Map<String, Object>)OSinput.get('AccountHierarchy')).get('ParentAccountId');
       string custSegment=(string)((Map<String, Object>)OSinput.get('AccountHierarchy')).get('CustomerSegment');
       string microBusinessSel=(string)((Map<String, Object>)OSinput.get('AccountHierarchy')).get('MicroBusinessSelection');
       for(object eachnode : allData){
           CSVWrapper obj=new CSVWrapper();
           obj.ServicePointId=(string)((Map<String, Object>)eachnode).get('ServicePointId');
           obj.Datalogger=(string)((Map<String, Object>)eachnode).get('Datalogger');
           obj.Corrector=(string)((Map<String, Object>)eachnode).get('Corrector');
           obj.SPrecordtype=(string)((Map<String, Object>)eachnode).get('SPrecordtype');
           obj.RegistrationType=(string)((Map<String, Object>)eachnode).get('RegistrationType');
           obj.ParentAccountName=pan;
           obj.ParentAccountId=pai;
           obj.CustomerSegment=custSegment;
           obj.MicroBusinessSelection=microBusinessSel;
           obj.ServiceRecordTypeID=RCtype;
           lstCSVWrapper.add(obj);    
       }
       i = 0; 
   }   
   public boolean hasNext(){ 
       return (i >= lstCSVWrapper.size()) ? false : true; 
   }    
   public CSVWrapper next(){ 
       if(i < lstCSVWrapper.size())
        {
            i = i+1;
            return lstCSVWrapper[i-1]; 
        }
        return null;
   } 
   
   public Iterator<CSVWrapper> iterator() 
   { 
       return this; 
   } 
   
   public class CSVWrapper
   {
       public string ServicePointId;
       public string Datalogger;
       public string Corrector;
       public string SPrecordtype;
       public string ParentAccountName;
       public string ParentAccountId;
       public string CustomerSegment;
       public string MicroBusinessSelection;
       public string ServiceRecordTypeID;
       public string RegistrationType;

   }
}