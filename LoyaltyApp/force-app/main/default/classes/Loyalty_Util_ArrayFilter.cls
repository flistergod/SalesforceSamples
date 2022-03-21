public with sharing class Loyalty_Util_ArrayFilter {
    public class Loyalty_Util_ArrayFilterException extends Exception {}

    public static List<sObject> filter(List<sObject> arrayToFilter, List<Loyalty_Util_ArrayFilter.Filter> filters, String filterLogic){
        List<sObject> retVal = new List<sObject>();
    
        if(arrayToFilter == null){
          return retVal;
        }
    
        if(filterLogic == 'OR'){
          for(Integer i = 0; i < arrayToFilter.size(); i++){
            for(Integer j = 0; j < filters.size(); j++){
              Filter f = filters[j];
              if(Loyalty_Util_ArrayFilter.Assert(arrayToFilter[i], f)){
                retVal.add(arrayToFilter[i]);
                continue;
              }
            }
          }
        }else if(filterLogic == 'AND'){
          for(Integer i = 0; i < arrayToFilter.size(); i++){
            Boolean passedTheFilter = true;
            for(Integer j = 0; j < filters.size(); j++){
              Filter f = filters[j];
              if(Loyalty_Util_ArrayFilter.Assert(arrayToFilter[i], f) == false){
                passedTheFilter = false;
                break;
              }
            }
            if(passedTheFilter){
              retVal.add(arrayToFilter[i]);
            }
          }
        }else{
          throw new Loyalty_Util_ArrayFilterException('Invalid filter logic "' + filterLogic + '" in class Loyalty_Util_ArrayFilter. \n\nAvailable options are "OR" and "AND"');
        }
    
        return retVal;
    }
    
    public static Boolean Assert(sObject o, Filter f){
      try {
        if(f.valueType == 'boolean'){
          if(f.operator == '!='){
            return ((Boolean)o.get(f.fieldName)) != f.valBoolean;
          }else{
            return ((Boolean)o.get(f.fieldName)) == f.valBoolean;
          }
        }else if(f.valueType == 'date'){
          if(f.operator == '!='){
            return ((Date)o.get(f.fieldName)) != f.valDate;
          }else if(f.operator == '>'){
            return ((Date)o.get(f.fieldName)) > f.valDate;
          }else if(f.operator == '<'){
            return ((Date)o.get(f.fieldName)) < f.valDate;
          }else{
            return ((Date)o.get(f.fieldName)) == f.valDate;
          }
        }else if(f.valueType == 'datetime'){
          if(f.operator == '!='){
            return ((DateTime)o.get(f.fieldName)) != f.valDateTime;
          }else if(f.operator == '>'){
            return ((DateTime)o.get(f.fieldName)) > f.valDateTime;
          }else if(f.operator == '<'){
            return ((DateTime)o.get(f.fieldName)) < f.valDateTime;
          }else{
            return ((DateTime)o.get(f.fieldName)) == f.valDateTime;
          }
        }else if(f.valueType == 'time'){
          if(f.operator == '!='){
            return ((Time)o.get(f.fieldName)) != f.valTime;
          }else if(f.operator == '>'){
            return ((Time)o.get(f.fieldName)) > f.valTime;
          }else if(f.operator == '<'){
            return ((Time)o.get(f.fieldName)) < f.valTime;
          }else{
            return ((Time)o.get(f.fieldName)) == f.valTime;
          }
        }else if(f.valueType == 'integer'){
          if(f.operator == '!='){
            return ((Integer)o.get(f.fieldName)) != f.valInteger;
          }else if(f.operator == '>'){
            return ((Integer)o.get(f.fieldName)) > f.valInteger;
          }else if(f.operator == '<'){
            return ((Integer)o.get(f.fieldName)) < f.valInteger;
          }else{
            return ((Integer)o.get(f.fieldName)) == f.valInteger;
          }
        }else if(f.valueType == 'decimal'){
          if(f.operator == '!='){
            return ((Decimal)o.get(f.fieldName)) != f.valDecimal;
          }else if(f.operator == '>'){
            return ((Decimal)o.get(f.fieldName)) > f.valDecimal;
          }else if(f.operator == '<'){
            return ((Decimal)o.get(f.fieldName)) < f.valDecimal;
          }else{
            return ((Decimal)o.get(f.fieldName)) == f.valDecimal;
          }
        }else if(f.valueType == 'double'){
          if(f.operator == '!='){
            return ((Double)o.get(f.fieldName)) != f.valDouble;
          }else if(f.operator == '>'){
            return ((Double)o.get(f.fieldName)) > f.valDouble;
          }else if(f.operator == '<'){
            return ((Double)o.get(f.fieldName)) < f.valDouble;
          }else{
            return ((Double)o.get(f.fieldName)) == f.valDouble;
          }
        }else if(f.valueType == 'long'){
          if(f.operator == '!='){
            return ((Long)o.get(f.fieldName)) != f.valLong;
          }else if(f.operator == '>'){
            return ((Long)o.get(f.fieldName)) > f.valLong;
          }else if(f.operator == '<'){
            return ((Long)o.get(f.fieldName)) < f.valLong;
          }else{
            return ((Long)o.get(f.fieldName)) == f.valLong;
          }
        }else if(f.valueType == 'id'){
          if(f.operator == '!='){
            return ((Id)o.get(f.fieldName)) != f.valId;
          }else{
            return ((Id)o.get(f.fieldName)) == f.valId;
          }
        }else if(f.valueType == 'string'){
          if(f.operator == '!='){
            return !((String)o.get(f.fieldName)).equals(f.valString);
          }else if(f.operator == 'CONTAINS'){
            return ((String)o.get(f.fieldName)).contains(f.valString);
          }else if(f.operator == 'STARTS'){
            return ((String)o.get(f.fieldName)).startsWith(f.valString);
          }else if(f.operator == 'ENDS'){
            return ((String)o.get(f.fieldName)).endsWith(f.valString);
          }else{
            return ((String)o.get(f.fieldName)).equals(f.valString);
          }
        }
      }
      catch (Exception ex) {
        throw new Loyalty_Util_ArrayFilterException(ex.getTypeName() + ': ' + ex.getMessage() + ' Data: ' + f.fieldName + '|' + f.valueType + '|' + f.operator);
      }
        return false;
    }

    public static Object Calculate(SObject obj, Loyalty_Util_ArrayFilter.Filter filter) {
      Set<String> assertOperators = new Set<String>{'<', '>', '=', '<=', '>=', '!=', 'CONTAINS', 'STARTS', 'ENDS'};
      if (assertOperators.contains(filter.operator)) {
        return Assert(obj, filter);
      }
      else if (filter.firstValDecimal != null && filter.firstValDecimal > 0) {
        if (filter.operator == '/') {
          return (Decimal)(filter.firstValDecimal / filter.valDecimal);
        }
        else if (filter.operator == '*') {
          return (Decimal)(filter.firstValDecimal * filter.valDecimal);
        }
        else if (filter.operator == '+') {
          return (Decimal)(filter.firstValDecimal + filter.valDecimal);
        }
        else if (filter.operator == '-') {
          return (Decimal)(filter.firstValDecimal - filter.valDecimal);
        }
        else {
          return 0;
        }
      }
      else {
        if(filter.valueType == 'integer'){
          if (filter.operator == '/') {
            return (Decimal)((Integer)obj.get(filter.fieldName) / filter.valInteger);
          }
          else if (filter.operator == '*') {
            return (Decimal)((Integer)obj.get(filter.fieldName) * filter.valInteger);
          }
          else if (filter.operator == '+') {
            return (Decimal)((Integer)obj.get(filter.fieldName) + filter.valInteger);
          }
          else if (filter.operator == '-') {
            return (Decimal)((Integer)obj.get(filter.fieldName) - filter.valInteger);
          }
          else {
            return 0;
          }
        }
        else if(filter.valueType == 'decimal'){
          if (filter.operator == '/') {
            return ((Decimal)obj.get(filter.fieldName) / filter.valDecimal);
          }
          else if (filter.operator == '*') {
            return ((Decimal)obj.get(filter.fieldName) * filter.valDecimal);
          }
          else if (filter.operator == '+') {
            return ((Decimal)obj.get(filter.fieldName) + filter.valDecimal);
          }
          else if (filter.operator == '-') {
            return ((Decimal)obj.get(filter.fieldName) - filter.valDecimal);
          }
          else {
            return 0;
          }
        }
        else if(filter.valueType == 'double'){
          if (filter.operator == '/') {
            return (Decimal)((Double)obj.get(filter.fieldName) / filter.valDouble);
          }
          else if (filter.operator == '*') {
            return (Decimal)((Double)obj.get(filter.fieldName) * filter.valDouble);
          }
          else if (filter.operator == '+') {
            return (Decimal)((Double)obj.get(filter.fieldName) + filter.valDouble);
          }
          else if (filter.operator == '-') {
            return (Decimal)((Double)obj.get(filter.fieldName) - filter.valDouble);
          }
          else {
            return 0;
          }
        }
        else if(filter.valueType == 'long'){
          if (filter.operator == '/') {
            return (Decimal)((Long)obj.get(filter.fieldName) / filter.valLong);
          }
          else if (filter.operator == '*') {
            return (Decimal)((Long)obj.get(filter.fieldName) * filter.valLong);
          }
          else if (filter.operator == '+') {
            return (Decimal)((Long)obj.get(filter.fieldName) + filter.valLong);
          }
          else if (filter.operator == '-') {
            return (Decimal)((Long)obj.get(filter.fieldName) - filter.valLong);
          }
          else {
            return 0;
          }
        }
        else {
          return 0;
        }
      }
    }

    public class Filter {

        public String fieldName {get; private set;}
        public String valueType {get; private set;}
        public String operator {get; private set;}//>,<,=,!=, CONTAINS, STARTS, ENDS
    
        public Decimal firstValDecimal {get; private set;}
        public Boolean valBoolean {get; private set;}
        public Date valDate {get; private set;}
        public DateTime valDateTime {get; private set;}
        public Time valTime {get; private set;}
        public Integer valInteger {get; private set;}
        public Decimal valDecimal {get; private set;}
        public Double valDouble {get; private set;}
        public Long valLong {get; private set;}
        public Id valId {get; private set;}
        public String valString {get; private set;}

        public Filter(String fieldName, String operator, String value, String valueType){
          this.fieldName = fieldName;
          this.valueType = valueType.toLowerCase();
          switch on this.valueType {
            when 'boolean' { this.valBoolean = Boolean.valueOf(value); } 
            when 'currency' {
              this.valueType = 'decimal';
              this.valDecimal = Decimal.valueOf(value);
            }
            when 'reference' {
              this.valueType = 'string';
              this.valString = value;
            }
            when 'id' {
              this.valId = value;
            }
            when 'integer' { this.valInteger = Integer.valueOf(value); }
            when 'time' {
              DateTime temp = DateTime.parse(value);
              this.valTime = Time.newInstance(temp.hour(), temp.minute(), temp.second(), temp.millisecond());
            }
            when 'date' {this.valDate = Date.parse(value);}
            when 'datetime' {this.valDateTime = DateTime.parse(value);}
            when else {
              this.valueType = 'string';
              this.valString = value;
            }
          }
          this.operator = operator;
        }

        public Filter(Decimal firstValue, String operator, Decimal secondValue){
          this.firstValDecimal = firstValue;
          this.valueType = 'Decimal';
          this.valDecimal = secondValue;
          this.operator = operator;
        }
    
        public Filter(String fieldName, String operator, Boolean value){
          this.fieldName = fieldName;
          this.valueType = 'Boolean';
          this.valBoolean = value;
          this.operator = operator;
        }
    
        public Filter(String fieldName, String operator, Date value){
          this.fieldName = fieldName;
          this.valueType = 'Date';
          this.valDate = value;
          this.operator = operator;
        }
    
        public Filter(String fieldName, String operator, DateTime value){
          this.fieldName = fieldName;
          this.valueType = 'DateTime';
          this.valDateTime = value;
          this.operator = operator;
        }
    
        public Filter(String fieldName, String operator, Time value){
          this.fieldName = fieldName;
          this.valueType = 'Time';
          this.valTime = value;
          this.operator = operator;
        }
    
        public Filter(String fieldName, String operator, Integer value){
          this.fieldName = fieldName;
          this.valueType = 'Integer';
          this.valInteger = value;
          this.operator = operator;
        }
    
        public Filter(String fieldName, String operator, Decimal value){
          this.fieldName = fieldName;
          this.valueType = 'Decimal';
          this.valDecimal = value;
          this.operator = operator;
        }
    
        public Filter(String fieldName, String operator, Double value){
          this.fieldName = fieldName;
          this.valueType = 'Double';
          this.valDouble = value;
          this.operator = operator;
        }
    
        public Filter(String fieldName, String operator, Long value){
          this.fieldName = fieldName;
          this.valueType = 'Long';
          this.valLong = value;
          this.operator = operator;
        }
    
        public Filter(String fieldName, String operator, Id value){
          this.fieldName = fieldName;
          this.valueType = 'Id';
          this.valId = value;
          this.operator = operator;
        }
    
        public Filter(String fieldName, String operator, String value){
          this.fieldName = fieldName;
          this.valueType = 'String';
          this.valString = value;
          this.operator = operator;
        }
    
    }
}