@isTest
global class ecEuropaEuTaxudViesServicesMock implements WebServiceMock {
    public String type;

    global ecEuropaEuTaxudViesServicesMock(final String type){
        this.type = type;
    }

    global void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType) {
        if(type == 'SyncValid'){
            // start - specify the response you want to send
            ecEuropaEuTaxudViesServicesCheckva.checkVatResponse_element response_x = 
                new ecEuropaEuTaxudViesServicesCheckva.checkVatResponse_element();
            response_x.valid = true;
            response_x.countryCode = 'BE';
            response_x.vatNumber = '0538668417';
            response_x.name = 'NV LANSWEEPER';
            response_x.address = 'Zeelsebaan (GRE) 83/Z 9200 Dendermonde';
            // end
            response.put('response_x', response_x); 
        }
        if(type == 'SyncValidApprox'){
            // start - specify the response you want to send
            ecEuropaEuTaxudViesServicesCheckva.checkVatApproxResponse_element response_x = 
                new ecEuropaEuTaxudViesServicesCheckva.checkVatApproxResponse_element();
            response_x.valid = true;
            response_x.countryCode = 'BE';
            response_x.vatNumber = '0538668417';
            // end
            response.put('response_x', response_x); 
        }
        if(type == 'AsyncValid'){
            AsyncEcEuropaEuTaxudViesServicesCheckva.checkVatResponse_elementFuture futureResponse = new AsyncEcEuropaEuTaxudViesServicesCheckva.checkVatResponse_elementFuture();
            ecEuropaEuTaxudViesServicesCheckva.checkVatResponse_element response_x = 
                new ecEuropaEuTaxudViesServicesCheckva.checkVatResponse_element();
            response_x.valid = true;
            response_x.countryCode = 'BE';
            response_x.vatNumber = '0538668417';
            response_x.name = 'NV LANSWEEPER';
            response_x.address = 'Zeelsebaan (GRE) 83/Z 9200 Dendermonde';
            // end
            response.put('response_x', response_x); 
        }
        if(type == 'AsyncValidApprox'){
            AsyncEcEuropaEuTaxudViesServicesCheckva.checkVatApproxResponse_elementFuture futureResponse = new AsyncEcEuropaEuTaxudViesServicesCheckva.checkVatApproxResponse_elementFuture();
            ecEuropaEuTaxudViesServicesCheckva.checkVatApproxResponse_element response_x = 
                new ecEuropaEuTaxudViesServicesCheckva.checkVatApproxResponse_element();
            response_x.valid = true;
            response_x.countryCode = 'BE';
            response_x.vatNumber = '0538668417';
            // end
            response.put('response_x', response_x); 
        }
    }
}