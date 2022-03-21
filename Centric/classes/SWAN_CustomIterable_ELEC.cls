public class SWAN_CustomIterable_ELEC implements Iterator<CSVWrapper_ELEC>, Iterable<CSVWrapper_ELEC>{ 
   List<CSVWrapper_ELEC> lstCSVWrapper_ELEC {get; set;} 
   Integer i {get; set;} 
   public SWAN_CustomIterable_ELEC (map<string,Object>OSinput){ 
       lstCSVWrapper_ELEC=new List<CSVWrapper_ELEC>();
       List<object>allData=(List<object>)((Map<String, Object>)OSinput.get('AccountHierarchy')).get('ServiceLocations');
       string RCtype=(string)((Map<String, Object>)OSinput.get('ParentAccount')).get('ServiceRecordTypeID');
       string pan=(string)((Map<String, Object>)OSinput.get('AccountHierarchy')).get('ParentAccountName');
       string pai=(string)((Map<String, Object>)OSinput.get('AccountHierarchy')).get('ParentAccountId');
       string custSegment=(string)((Map<String, Object>)OSinput.get('AccountHierarchy')).get('CustomerSegment');
       string microBusinessSel=(string)((Map<String, Object>)OSinput.get('AccountHierarchy')).get('MicroBusinessSelection');
       for(object eachnode : allData){
           CSVWrapper_ELEC obj=new CSVWrapper_ELEC();
           obj.ServicePointId=(string)((Map<String, Object>)eachnode).get('ServicePointId');
           obj.SupplyCapacity=String.valueof(((Map<String, Object>)eachnode).get('SupplyCapacity'));
           obj.SPrecordtype=(string)((Map<String, Object>)eachnode).get('SPrecordtype');
           obj.RegistrationType=(string)((Map<String, Object>)eachnode).get('RegistrationType');
           obj.ParentAccountName=pan;
           obj.ParentAccountId=pai;
           obj.CustomerSegment=custSegment;
           obj.MicroBusinessSelection=microBusinessSel;
           obj.ServiceRecordTypeID=RCtype;
           lstCSVWrapper_ELEC.add(obj);    
       }
       i = 0; 
   }   
   public boolean hasNext(){ 
       return (i >= lstCSVWrapper_ELEC.size()) ? false : true; 
   }    
   public CSVWrapper_ELEC next(){ 
       if(i < lstCSVWrapper_ELEC.size())
        {
            i = i+1;
            return lstCSVWrapper_ELEC[i-1]; 
        }
        return null;
   } 
   
   public Iterator<CSVWrapper_ELEC> iterator() 
   { 
       return this; 
   } 
   
   public class CSVWrapper_ELEC
   {
       public string ServicePointId;
       public string SupplyCapacity;
       public string SPrecordtype;
       public string ParentAccountName;
       public string ParentAccountId;
       public string CustomerSegment;
       public string MicroBusinessSelection;
       public string ServiceRecordTypeID;
       public string RegistrationType;
   }
}