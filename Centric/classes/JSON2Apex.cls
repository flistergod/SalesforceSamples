public class JSON2Apex {

    public List<SWAN_SP_ATT_CAT> SWAN_SP_ATT_CAT {get;set;} 
    public JSON2Apex() {}
    public JSON2Apex(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'SWAN_SP_ATT_CAT') {
                        SWAN_SP_ATT_CAT = arrayOfSWAN_SP_ATT_CAT(parser);
                    } else {
                        //System.debug(LoggingLevel.WARN, 'JSON2Apex consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    public class SWAN_SP_ATT_CAT {
         
        public String attributedisplayname {get;set;} 
        public String value {get;set;}
        //public AttributeRunTimeInfo attributeRunTimeInfo {get;set;} 

        public SWAN_SP_ATT_CAT(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    //System.debug('TextingText'+text);
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'attributedisplayname__c') {
                            attributedisplayname = parser.getText();
                        } else if (text == 'attributeRunTimeInfo') {
                            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                                    String inside_text = parser.getText();
                                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                                        if (inside_text == 'value') {
                                            //System.debug('parsernew'+parser +'currenttt'+parser.getCurrentToken());
                                            value = parser.getText();   
                                        } else 
                                            {
                                                //System.debug(LoggingLevel.WARN, 'AttributeRunTimeInfo consuming unrecognized property: '+inside_text);
                                                consumeObject(parser);
                                            }
                                    }
                                }
                            }
                        } else {
                            //System.debug(LoggingLevel.WARN, 'SWAN_SP_ATT_CAT consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    /*public class AttributeRunTimeInfo { 
        public String value {get;set;} 

        public AttributeRunTimeInfo(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'value') {
                            System.debug('parsernew'+parser +'currenttt'+parser.getCurrentToken());
                            value = parser.getText();   
                        } else {
                            System.debug(LoggingLevel.WARN, 'AttributeRunTimeInfo consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }*/
    
    public static JSON2Apex parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        //System.debug('Parser'+parser);
        return new JSON2Apex(parser);
    }
    
    public static void consumeObject(System.JSONParser parser) {
        Integer depth = 0;
        do {
            System.JSONToken curr = parser.getCurrentToken();
            if (curr == System.JSONToken.START_OBJECT || 
                curr == System.JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == System.JSONToken.END_OBJECT ||
                curr == System.JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }
    
    
    private static List<SWAN_SP_ATT_CAT> arrayOfSWAN_SP_ATT_CAT(System.JSONParser p) {
        List<SWAN_SP_ATT_CAT> res = new List<SWAN_SP_ATT_CAT>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new SWAN_SP_ATT_CAT(p));
        }
        return res;
    }





}