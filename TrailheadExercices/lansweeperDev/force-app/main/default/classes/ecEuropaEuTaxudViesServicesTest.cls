@isTest
public class ecEuropaEuTaxudViesServicesTest {
    @isTest static void testEcEuropaCheckVatCallout() {
        Test.setMock(WebServiceMock.class, new ecEuropaEuTaxudViesServicesMock('SyncValid'));
        Test.startTest();

        ecEuropaEuTaxudViesServicesCheckva.checkVatPort vatChecker = new ecEuropaEuTaxudViesServicesCheckva.checkVatPort();
        ecEuropaEuTaxudViesServicesCheckva.checkVatResponse_element checkData = vatChecker.checkVat('BE','0538668417');

        Test.stopTest();

        System.assertEquals(checkData.valid, true); 
    }

    @isTest static void testEcEuropaCheckVatApproxCallout() {
        Test.setMock(WebServiceMock.class, new ecEuropaEuTaxudViesServicesMock('SyncValidApprox'));
        Test.startTest();

        ecEuropaEuTaxudViesServicesCheckva.checkVatPort vatChecker = new ecEuropaEuTaxudViesServicesCheckva.checkVatPort();
        ecEuropaEuTaxudViesServicesCheckva.checkVatApproxResponse_element checkData = vatChecker.checkVatApprox('BE','0538668417', null,null,null,'1000-100','Lisbon','PT','515815454');
        system.debug(checkData);
        Test.stopTest();

        System.assertEquals(checkData.vatNumber, '0538668417'); 
    }

    @isTest static void testAsyncEcEuropaCheckVatCallout() {
        Test.setMock(WebServiceMock.class, new ecEuropaEuTaxudViesServicesMock('AsyncValid'));
        Test.startTest();

        AsyncEcEuropaEuTaxudViesServicesCheckva.AsynccheckVatPort vatChecker = new AsyncEcEuropaEuTaxudViesServicesCheckva.AsynccheckVatPort();
        AsyncEcEuropaEuTaxudViesServicesCheckva.checkVatResponse_elementFuture checkData = vatChecker.beginCheckVat(new Continuation(1000),'BE','0538668417');

        Test.stopTest();
    }

    @isTest static void testAsyncEcEuropaCheckVatApproxCallout() {
        Test.setMock(WebServiceMock.class, new ecEuropaEuTaxudViesServicesMock('AsyncValidApprox'));
        Test.startTest();

        AsyncEcEuropaEuTaxudViesServicesCheckva.AsynccheckVatPort vatChecker = new AsyncEcEuropaEuTaxudViesServicesCheckva.AsynccheckVatPort();
        AsyncEcEuropaEuTaxudViesServicesCheckva.checkVatApproxResponse_elementFuture checkData = vatChecker.beginCheckVatApprox(new Continuation(1000),'BE','0538668417', null,null,null,'1000-100','Lisbon','PT','515815454');

        Test.stopTest();
    }
}