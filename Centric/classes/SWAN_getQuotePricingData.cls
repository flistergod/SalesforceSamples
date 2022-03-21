global with sharing class SWAN_getQuotePricingData implements vlocity_cmt.VlocityOpenInterface {
  /**
   * Top level call by a Vlocity Remote Action
   *
   * @param inputMap  - The input provided to the Remote Action
   * @param outputMap - Any output to be provided back to the Remote Action
   * @param options   - Any options to aid in the execution of this class
   *
   * @returns true if the method completes successfully, false otherwise
   */
  global Boolean invokeMethod(
    String methodName,
    Map<String, Object> inputMap,
    Map<String, Object> outputMap,
    Map<String, Object> options
  ) {
    if (methodName == 'extractQuotePrice') {
      return extractQuotePrice(inputMap, outputMap, options);
    }

    return false;
  }

  public Boolean extractQuotePrice(
    Map<String, Object> inputMap,
    Map<String, Object> outputMap,
    Map<String, Object> options
  ) {
    String masterQuoteId = (string) inputMap.get('ContextId');
    Quote qt = [
      SELECT Id, SWAN_Quote_Type__c
      FROM Quote
      WHERE Id = :masterQuoteId
      LIMIT 1
    ];

    outputMap.put('quoteType', qt.SWAN_Quote_Type__c);

    if (qt.SWAN_Quote_Type__c == 'Flex') {
      return extractQuotePriceFlex(inputMap, outputMap, options);
    } else {
      return extractQuotePriceFixed(inputMap, outputMap, options);
    }
  }

  public Boolean extractQuotePriceFixed(
    Map<String, Object> inputMap,
    Map<String, Object> outputMap,
    Map<String, Object> options
  ) {
    String masterQuoteId = (string) inputMap.get('ContextId');
    String QuoteFuelType = '';
    List<Object> quotePricingList = new List<Object>();
    List<AggregateResult> results = [
      SELECT count(Id)
      FROM Quote
      WHERE
        vlocity_cmt__ParentQuoteId__c = :masterQuoteId
        AND recordType.DeveloperName != 'GroupCart'
    ];

    Integer total = Integer.valueOf(results[0].get('expr0'));
    /*if(total == 0)
           {
               Map<String, Object> eachRec = new Map<String, Object>();
               eachRec.put('NumOLIs', total);
               eachRec.put('Msg', 'No Data To Display');
               quotePricingList.add(eachRec);
           }*/

    for (Quote childQt : [
      SELECT
        id,
        Name,
        SWAN_Service_Point_Start_Date__c,
        SWAN_Annual_Spend__c,
        SWAN_Contract_Spend__c,
        vlocity_cmt__ParentQuoteId__r.SWAN_Quote_for_Fuel_Type__c,
        SWAN_Contract_Volume_KWh__c,
        vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__ServicePointNumber__c,
        vlocity_cmt__DefaultServicePointId__r.SWAN_Formula_Year_Annual_Quantity__c,
        vlocity_cmt__DefaultServicePointId__c,
        vlocity_cmt__DefaultServicePointId__r.SWAN_Formula_Year_Offtake_Quantity__c,
        (
          SELECT
            id,
            vlocity_cmt__RecurringCharge__c,
            SWAN_UnitRate__c,
            vlocity_cmt__UsageUnitPrice__c,
            Product2.Name,
            Product2.ProductCode
          FROM QuoteLineItems
          WHERE Product2.vlocity_cmt__IsOrderable__c = FALSE
        )
      FROM Quote
      WHERE
        vlocity_cmt__ParentQuoteId__c = :masterQuoteId
        AND recordType.DeveloperName != 'GroupCart'
    ]) {
      QuoteFuelType = childQt.vlocity_cmt__ParentQuoteId__r.SWAN_Quote_for_Fuel_Type__c;
      Map<String, Object> eachRec = new Map<String, Object>();
      List<Object> Prices = new List<Object>();
      eachRec.put('ServicePointId', childQt.id);
      eachRec.put('AnnualSpend', '£ ' + childQt.SWAN_Annual_Spend__c == null?'':(childQt.SWAN_Annual_Spend__c?.format())); // currRounded
      //eachRec.put('AnnualSpend', '£ ' + childQt.SWAN_Annual_Spend__c?.format()); // currRounded
      eachRec.put(
        'ContractSpend',
        '£ ' + childQt.SWAN_Contract_Spend__c?.format()
      ); // currRounded
      eachRec.put(
        'Consumption',
        childQt.SWAN_Contract_Volume_KWh__c?.format() + ' kWh'
      );
      //eachRec.put('FYAQ', childQt.vlocity_cmt__DefaultServicePointId__r.SWAN_Formula_Year_Annual_Quantity__c+' kWh');
      //eachRec.put('FYSOQ', childQt.vlocity_cmt__DefaultServicePointId__r.SWAN_Formula_Year_Offtake_Quantity__c+' kWh');
      eachRec.put(
        'FuelType',
        childQt.vlocity_cmt__ParentQuoteId__r.SWAN_Quote_for_Fuel_Type__c
      );
      eachRec.put(
        'ServicePointNumber',
        childQt.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__ServicePointNumber__c
      );
      //eachRec.put('NumOLIs', total);

      /*if(childQt.SWAN_Service_Point_Start_Date__c != null)
               {
                   String startDay = (String.valueOf(childQt.SWAN_Service_Point_Start_Date__c.day()).length()<2?'0'+childQt.SWAN_Service_Point_Start_Date__c.day():''+childQt.SWAN_Service_Point_Start_Date__c.day());
                   String startMonth = (String.valueOf(childQt.SWAN_Service_Point_Start_Date__c.month()).length()<2?'0'+childQt.SWAN_Service_Point_Start_Date__c.month():''+childQt.SWAN_Service_Point_Start_Date__c.month());
                   string startDate = startDay +'/'+startMonth+'/'+childQt.SWAN_Service_Point_Start_Date__c.year();
                   eachRec.put('ServicePointStartDate', startDate);
               } */

      for (QuoteLineItem qli : childQt.QuoteLineItems) {
        if (qli.Product2.ProductCode == 'BG_STD') {
          String stdCharge = '0.000';
          if (qli.vlocity_cmt__UsageUnitPrice__c != null) {
            string temp = string.valueOf(
              qli.vlocity_cmt__UsageUnitPrice__c.format()
            );
            stdCharge = (!temp.contains('.')
              ? (temp + '.000')
              : (temp + '000').substring(0, ((temp + '000').indexOf('.')) + 4));
          } else if (qli.vlocity_cmt__RecurringCharge__c != null) {
            string temp = string.valueOf(
              qli.vlocity_cmt__RecurringCharge__c.format()
            );
            stdCharge = (!temp.contains('.')
              ? (temp + '.000')
              : (temp + '000').substring(0, ((temp + '000').indexOf('.')) + 4));
          }

          eachRec.put('StandingCharge', stdCharge + ' p/day');
          Map<String, Object> eachPrice = new Map<String, Object>();
          eachPrice.put('Price', stdCharge + ' p/day');
          eachPrice.put('PriceName', 'Standing Charge');
          Prices.add(eachPrice);
        } else if (qli.Product2.ProductCode == 'BG_UNITRATE') {
          String unitCharge = '0.000';
          if (qli.SWAN_UnitRate__c != null) {
            string temp = string.valueOf(qli.SWAN_UnitRate__c.format());
            unitCharge = (!temp.contains('.')
              ? (temp + '.000')
              : (temp + '000').substring(0, ((temp + '000').indexOf('.')) + 4));
          }
          eachRec.put('UnitCharge', unitCharge + ' p/kWh');
        } else if (qli.Product2.ProductCode == 'BG_AVAILABILITY_CHARGE') {
          String unitCharge = '0.000';
          if (qli.vlocity_cmt__UsageUnitPrice__c != null) {
            string temp = string.valueOf(
              qli.vlocity_cmt__UsageUnitPrice__c.format()
            );
            unitCharge = (!temp.contains('.')
              ? (temp + '.000')
              : (temp + '000').substring(0, ((temp + '000').indexOf('.')) + 4));
          }
          Map<String, Object> eachPrice = new Map<String, Object>();
          eachPrice.put('Price', unitCharge + ' p/kVA/day');
          eachPrice.put('PriceName', 'Availability Charge');
          Prices.add(eachPrice);
        } else {
          String unitCharge = '0.000';
          if (qli.SWAN_UnitRate__c != null) {
            string temp = string.valueOf(qli.SWAN_UnitRate__c.format());
            unitCharge = (!temp.contains('.')
              ? (temp + '.000')
              : (temp + '000').substring(0, ((temp + '000').indexOf('.')) + 4));
          }
          Map<String, Object> eachPrice = new Map<String, Object>();
          eachPrice.put('Price', unitCharge + ' p/kWh');
          eachPrice.put('PriceName', qli.Product2.Name);
          Prices.add(eachPrice);
        }
      }
      eachRec.put('Prices', Prices);
      quotePricingList.add(eachRec);
    }
    outputMap.put('quotePricingList', quotePricingList);
    outputMap.put('QuoteFuelType', QuoteFuelType);
    outputMap.put('NumOLIs', total);
    return true;
  }

  public boolean extractQuotePriceFlex(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {

    String masterQuoteId = (string) inputMap.get('ContextId');
    List<String> lstProdQuoteTab = new List<String>();

    List<String> lstProdQuoteTabElec = new List<String>{
      'BG_ELECTRICITY_MANAGEMENT_FEE',
      'BG_BALANCE_IMBALANCE',
      'BG_SHAPING',
      'BG_ELECTRICITY_INDUSTRY_CHARGES',
      'BG_RENEWABLE_CHARGE'
    };

    List<String> lstProdQuoteTabGas = new List<String>{
      'BG_GAS_MANAGEMENT_FEE',
      'BG_BALANCE_IMBALANCE',
      'BG_GAS_INDUSTRY_CHARGES'
    };

    Map<String, String> positionProdQuoteTab = new Map<String, String>();
    Integer numOLIs = 0;
    String fuelType = '';
    Id masterProd;
    List<Object> quotePricingList = new List<Object>();

    Map<Id, QuoteLineItem> mapQLI = new Map<Id, QuoteLineItem>(
      [
        SELECT
          Id,
          vlocity_cmt__OneTimeCost__c,
          vlocity_cmt__UsageUnitPrice__c,
          SWAN_UnitRate__c,
          SWAN_Unit_Rate_Therms__c,
          SWAN_UsageUnitPriceGSP__c,
          SWAN_UsageUnitPriceNBP__c,
          Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Management_Fee_End_Date__c,
          Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Balance_and_Imbalance_End_Date__c,
          Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Industry_Charges_End_Date__c,
          Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Shaping_Premium_End_Date__c,
          Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Renewable_Charge_End_Date__c,
          Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Quote_Renewable__c,
          Quote.SWAN_Quote_for_Fuel_Type__c,
          Product2Id,
          Product2.Name,
          Product2.ProductCode,
          Product2.vlocity_cmt__IsOrderable__c
        FROM QuoteLineItem
        WHERE
          Product2.vlocity_cmt__Type__c != 'Cost'
          AND Product2.vlocity_cmt__Type__c != 'Cost Flex'
          AND QuoteId IN (
            SELECT Id
            FROM Quote
            WHERE
              vlocity_cmt__ParentQuoteId__c = :masterQuoteId
              AND RecordType.DeveloperName = 'SubQuote'
              AND vlocity_cmt__QuoteGroupId__r.vlocity_cmt__MemberType__c = 'Business_Account'
          ) ORDER BY LineNumber
      ]
    );

    Map<Id, Id> mapQLItoProd = new Map<Id, Id>();

    //map quotelineitem to product
    for (QuoteLineItem qli : mapQLI.values()) {
      if (qli.Product2.vlocity_cmt__IsOrderable__c) {
        masterProd = qli.Product2Id;
        fuelType = qli.Quote.SWAN_Quote_for_Fuel_Type__c;
        lstProdQuoteTab = (fuelType == 'Gas'
          ? lstProdQuoteTabGas
          : lstProdQuoteTabElec);
      }
      mapQLItoProd.put(qli.Product2Id, qli.id);
    }

    //get child products of child products
    List<vlocity_cmt__ProductChildItem__c> productChildParent = new List<vlocity_cmt__ProductChildItem__c>(
      [
        SELECT
          Id,
          Name,
          vlocity_cmt__ParentProductId__r.ProductCode,
          vlocity_cmt__ChildProductId__c,
          vlocity_cmt__ChildProductId__r.name,
          vlocity_cmt__ParentProductId__c,
          vlocity_cmt__ParentProductId__r.name
        FROM vlocity_cmt__ProductChildItem__c
        WHERE
          vlocity_cmt__ParentProductId__r.ProductCode IN :lstProdQuoteTab
          AND vlocity_cmt__ChildProductId__c != NULL
        ORDER BY vlocity_cmt__ParentProductId__c DESC, vlocity_cmt__ChildLineNumber__c NULLS LAST
      ]
    );

    Map<String, List<Object>> mapTable = new Map<String, List<Object>>();

    for (vlocity_cmt__ProductChildItem__c prodChild : productChildParent) {
      //parent product
      if (mapTable.get(prodChild.vlocity_cmt__ParentProductId__c) == null && mapQLI.get(mapQLItoProd.get(prodChild.vlocity_cmt__ParentProductId__c)) != null) {
        QuoteLineItem ql = mapQLI.get(mapQLItoProd.get(prodChild.vlocity_cmt__ParentProductId__c));
       
        Object row = rowTable(
          ql,
          fuelType,
          'Total',
          ql.Product2.Name,
          fixedUntil(ql)
        );

        mapTable.put(
          prodChild.vlocity_cmt__ParentProductId__c,
          (new List<Object>{ row })
        );

        numOLIs = numOLIs + 1;

        // map current position
        positionProdQuoteTab.put(
          ql.Product2.ProductCode,
          prodChild.vlocity_cmt__ParentProductId__c
        );

      }

      //child products
      if (prodChild.vlocity_cmt__ChildProductId__c != null && mapQLI.get(mapQLItoProd.get(prodChild.vlocity_cmt__ChildProductId__c)) != null) {
        QuoteLineItem ql = mapQLI.get(mapQLItoProd.get(prodChild.vlocity_cmt__ChildProductId__c)        );

        QuoteLineItem qlParent = mapQLI.get(mapQLItoProd.get(prodChild.vlocity_cmt__ParentProductId__c));

        Object row = rowTable(
          ql,
          fuelType,
          ql.Product2.Name,
          prodChild.vlocity_cmt__ParentProductId__r.name,
          fixedUntil(qlParent)
        );

        mapTable.get(prodChild.vlocity_cmt__ParentProductId__c).add(row);
        numOLIs = numOLIs + 1;

      }

    }

    //reorder final list
    for (String positionProduct : lstProdQuoteTab) {
      String parentProductId = positionProdQuoteTab.get(positionProduct);
      
      if (positionProdQuoteTab.get(positionProduct) != null) {
        List<Object> listObj = mapTable.get(parentProductId);
        Object total = listObj.remove(0);
        listObj.add(total);
        listObj.add(blankRowTable(fuelType));
        quotePricingList.addAll(listObj);
      }

    }

    outputMap.put('quotePricingList', quotePricingList);
    outputMap.put('QuoteFuelType', fuelType);
    outputMap.put('NumOLIs', numOLIs);

    return true;
  }

  public String fixedUntil(QuoteLineItem qli) {
    if (qli.Product2.ProductCode == 'BG_ELECTRICITY_MANAGEMENT_FEE' || qli.Product2.ProductCode == 'BG_GAS_MANAGEMENT_FEE') {

      Date bg_MANAGEMENT_FEE_date = qli.Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Management_Fee_End_Date__c;

      return DateTime.newInstance(
          bg_MANAGEMENT_FEE_date.year(),
          bg_MANAGEMENT_FEE_date.month(),
          bg_MANAGEMENT_FEE_date.day()
        )
        .format('dd-MM-yyyy');     

    } else if (qli.Product2.ProductCode == 'BG_BALANCE_IMBALANCE' && qli.Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Balance_and_Imbalance_End_Date__c != null) {

      Date bg_BALANCE_IMBALANCE_date = qli.Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Balance_and_Imbalance_End_Date__c;
      return DateTime.newInstance(
          bg_BALANCE_IMBALANCE_date.year(),
          bg_BALANCE_IMBALANCE_date.month(),
          bg_BALANCE_IMBALANCE_date.day()
        )
        .format('dd-MM-yyyy');

    } else if (qli.Product2.ProductCode == 'BG_SHAPING' && qli.Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Shaping_Premium_End_Date__c != null) {
      Date bg_SHAPING_date = qli.Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Shaping_Premium_End_Date__c;
      return DateTime.newInstance(
          bg_SHAPING_date.year(),
          bg_SHAPING_date.month(),
          bg_SHAPING_date.day()
        )
        .format('dd-MM-yyyy');

    } else if ((qli.Product2.ProductCode == 'BG_ELECTRICITY_INDUSTRY_CHARGES' || qli.Product2.ProductCode == 'BG_GAS_INDUSTRY_CHARGES') && qli.Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Industry_Charges_End_Date__c != null) {
      
      Date bg_INDUSTRY_CHARGES_date = qli.Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Industry_Charges_End_Date__c;
      return DateTime.newInstance(
          bg_INDUSTRY_CHARGES_date.year(),
          bg_INDUSTRY_CHARGES_date.month(),
          bg_INDUSTRY_CHARGES_date.day()
        )
        .format('dd-MM-yyyy');

    } else if (qli.Product2.ProductCode == 'BG_RENEWABLE_CHARGE') {

      if (qli.Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Quote_Renewable__c) {

        Date bg_RENEWABLE_CHARGE_date = qli.Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Renewable_Charge_End_Date__c;

        return DateTime.newInstance(
            bg_RENEWABLE_CHARGE_date.year(),
            bg_RENEWABLE_CHARGE_date.month(),
            bg_RENEWABLE_CHARGE_date.day()
          )
          .format('dd-MM-yyyy');

        } else {
        return '';
      }
    }
    return '';
  }

  public Map<String, Object> rowTable(
    QuoteLineItem qli,
    String fuelType,
    String detail,
    String masterProd,
    String FixedUntil
  ) {
    Map<String, Object> flexPrices = new Map<String, Object>();

    if (fuelType == 'Electricity') {
      
      flexPrices.put('Cost', masterProd);
      flexPrices.put('Details', '');
      flexPrices.put('FixedUntil', FixedUntil);
      flexPrices.put('DetailedBreakdown', detail);
      flexPrices.put('Price@NBP', qli.SWAN_UsageUnitPriceNBP__c != null ? formatPrice(qli.SWAN_UsageUnitPriceNBP__c) : null);
      flexPrices.put('Price@GSP', qli.SWAN_UsageUnitPriceGSP__c != null ? formatPrice(qli.SWAN_UsageUnitPriceGSP__c) : null);
      flexPrices.put('Price@MSP', qli.vlocity_cmt__UsageUnitPrice__c != null ? formatPrice(qli.vlocity_cmt__UsageUnitPrice__c) : null);
      flexPrices.put('Cost(£)', qli.vlocity_cmt__OneTimeCost__c != null ? qli.vlocity_cmt__OneTimeCost__c.format() : null);
    } else {
      flexPrices.put('Cost', masterProd);
      flexPrices.put('FixedUntil', FixedUntil);
      flexPrices.put('DetailedBreakdown', detail);
      flexPrices.put('£/MWh', qli.vlocity_cmt__UsageUnitPrice__c != null ? formatPrice(qli.vlocity_cmt__UsageUnitPrice__c) : null);
      flexPrices.put('p/kWh', qli.SWAN_UnitRate__c != null ? formatPrice(qli.SWAN_UnitRate__c) : null);
      flexPrices.put('p/th', qli.SWAN_Unit_Rate_Therms__c != null ? formatPrice(qli.SWAN_Unit_Rate_Therms__c) : null);
      flexPrices.put('Cost(£)', qli.vlocity_cmt__OneTimeCost__c != null ? qli.vlocity_cmt__OneTimeCost__c.format() : null);
    }
    return flexPrices;
  }
  
  private String formatPrice (Decimal priceToFormat) {
    String price = priceToFormat.format(); // format the price
    String tempValue = (price.indexOf('.')) == -1 ? price + '.000' : price + '000'; // pad with zeroes at the end
    return tempValue.substring(0,tempValue.indexOf('.') + 4); // keep at most three decimals
  }
  
  private Map<String, Object> blankRowTable(String FuelType) {
    Map<String, Object> blankRow = new Map<String, Object>();

    if (FuelType == 'Gas') {
      blankRow.put('Cost', '');
      blankRow.put('FixedUntil', '');
      blankRow.put('DetailedBreakdown', '');
      blankRow.put('£/MWh', '');
      blankRow.put('p/kWh', '');
      blankRow.put('p/th', '');
      blankRow.put('Cost(£)', '');
      return blankRow;
    } else {
      blankRow.put('Cost', '');
      blankRow.put('Details', '');
      blankRow.put('FixedUntil', '');
      blankRow.put('DetailedBreakdown', '');
      blankRow.put('Price@NBP', '');
      blankRow.put('Price@GSP', '');
      blankRow.put('Price@MSP', '');
      blankRow.put('Cost(£)', '');
      return blankRow;
    }
  }
}