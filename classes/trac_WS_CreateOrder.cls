/**
 *  @description Create Order web service class
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        7/3/2019
 */
public with sharing class trac_WS_CreateOrder {
    public final String ENDPOINT = (trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c != null) ?
            trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c + trac_WS_WebServiceHelper.webServiceSettings.Create_Order_Endpoint__c : trac_WS_WebServiceHelper.webServiceSettings.Create_Order_Endpoint__c;
    private HttpResponse res = new HttpResponse();
    public CreateOrderRequest createOrderRequest;
    public CreateOrderResponse createOrderResponse;
    public String jsonError;

    public trac_WS_CreateOrder() {
        createOrderRequest = new CreateOrderRequest();
    }

    public Boolean send() {
        res = trac_WS_WebServiceHelper.SendPostRequest(ENDPOINT, createOrderRequest);

        if(trac_WS_WebServiceHelper.isValidResponse(res)) {
            createOrderResponse = parse(res.getBody());
            return true;
        }
        else {
            jsonError = trac_WS_WebServiceHelper.getError(res);
            System.debug('Error: ' + trac_WS_WebServiceHelper.getError(res));
        }

        return false;
    }

    public static CreateOrderResponse parse(String json) {
        return (CreateOrderResponse) System.JSON.deserialize(json, CreateOrderResponse.class);
    }

    public class CreateOrderRequest {
        public req_OrderWrapper Order;

        public CreateOrderRequest() {
            Order = new req_OrderWrapper();
        }
    }

    public class CreateOrderResponse {
        public String OrderHeaderKey;
        public String OrderNo;
        public String EnterpriseCode;
        public String DocumentType;
    }

    public class req_OrderWrapper {
        public String Action;
        public String AllocationRuleID;
        public String AuthorizedClient;
        public String BillToID;
        public String CustomerContactID;
        public String CustomerEMailID;
        public String DocumentType;
        public String EnteredBy;
        public String EnterpriseCode;
        public String EntryType;
        public String OrderDate;
        public String OrderNo;
        public String SellerOrganizationCode;
        public req_OrderLinesWrapper OrderLines;
        public req_AddressWrapper PersonInfoShipTo;
        public req_AddressWrapper PersonInfoBillTo;
        public req_HeaderChargesWrapper HeaderCharges;
        public req_PaymentMethodsWrapper PaymentMethods;
        public req_ExtnWrapper Extn;

        public req_OrderWrapper() {
            PersonInfoShipTo = new req_AddressWrapper();
            PersonInfoBillTo = new req_AddressWrapper();
        }
    }

    public class req_OrderLinesWrapper {
        public req_OrderLineWrapper OrderLine;
    }

    public class req_OrderLineWrapper {
        public String CarrierServiceCode;
        public String Createuserid;
        public String DeliveryMethod;
        public String FulfillmentType;
        public String GiftFlag;
        public String GiftWrap;
        public String LineType;
        public String OrderedQty;
        public String PrimeLineNo;
        public String SCAC;
        public String SubLineNo;
        public req_ItemWrapper Item;
        public req_AddressWrapper PersonInfoShipTo;
        public List<req_InstructionsWrapper> Instructions;
        public req_LinePriceInfoWrapper LinePriceInfo;
        public req_LineChargesWrapper LineCharges;
        public List<req_LineTaxesWrapper> LineTaxes;
        public req_OrderDatesWrapper OrderDates;
        public req_OrderLineReservationsWrapper OrderLineReservations;
        public req_ExtnWrapper Extn;
    }

    public class req_ItemWrapper {
        public String ItemID;
        public String UnitOfMeasure;
    }

    public class req_AddressWrapper {
        public String AddressLine1;
        public String AddressLine2;
        public String AddressLine3;
        public String City;
        public String Company;
        public String Country;
        public String DayPhone;
        public String EMailID;
        public String FirstName;
        public String IsCommercialAddress;
        public String LastName;
        public String MiddleName;
        public String State;
        public String Title;
        public String ZipCode;
    }

    public class req_InstructionsWrapper {
        public String InstructionText;
        public String InstructionType;
    }

    public class req_LinePriceInfoWrapper {
        public String IsLinePriceForInformationOnly;
        public String ListPrice;
        public String PricingQuantityStrategy;
        public String RetailPrice;
        public String TaxExemptionCertificate;
        public String TaxableFlag;
        public String UnitPrice;
    }

    public class req_LineChargesWrapper {
        public req_LineChargeWrapper LineCharge;
    }

    public class req_LineChargeWrapper {
        public String ChargeCategory;
        public String ChargeName;
        public String ChargePerLine;
    }

    public class req_LineTaxesWrapper {
        public String ChargeCategory;
        public String Tax;
        public String TaxName;
        public String TaxPercentage;
    }

    public class req_OrderDatesWrapper {
        public req_OrderDateWrapper OrderDate;
    }

    public class req_OrderDateWrapper {
        public String ActualDate;
        public String DateTypeId;
    }

    public class req_OrderLineReservationsWrapper {
        public req_OrderLineReservationWrapper OrderLineReservation;
    }

    public class req_OrderLineReservationWrapper {
        public String ItemID;
        public String Node;
        public String Quantity;
        public String ReservationID;
        public String UnitOfMeasure;
    }

    public class req_ExtnWrapper {
        public String ExtnIsReturnable;
        public String ExtnPackSlpPrcSuppress;
        public String ExtnShipZone;
        public String ExtnSignatureRequired;
        public String ExtnWebLineNumber;
        public String ExtnWebOrderSuffix;
    }

    public class req_HeaderChargesWrapper {
        public req_HeaderChargeWrapper HeaderCharge;
    }

    public class req_HeaderChargeWrapper {
        public String ChargeAmount;
        public String ChargeCategory;
        public String ChargeName;
    }

    public class req_PaymentMethodsWrapper {
        public req_PaymentMethodWrapper PaymentMethod;
    }

    public class req_PaymentMethodWrapper {
        public String ChargeSequence;
        public String CreditCardExpDate;
        public String CreditCardName;
        public String CreditCardNo;
        public String CreditCardType;
        public String DisplayCardNo;
        public String DisplayCreditCardNo;
        public String FirstName;
        public String LastName;
        public String MaxChargeLimit;
        public String MiddleName;
        public String PaymentReference1;
        public String PaymentReference4;
        public String PaymentService;
        public String PaymentType;
        public String UnlimitedCharges;
        public req_PaymentDetailsWrapper PaymentDetails;
        public req_AddressWrapper PersonInfoBillTo;
    }

    public class req_PaymentDetailsWrapper {
        public String AuthAvs;
        public String AuthReturnCode;
        public String AuthReturnMessage;
        public String AuthorizationExpirationDate;
        public String AuthorizationID;
        public String ChargeType;
        public String ProcessedAmount;
        public String Reference1;
        public String Reference2;
        public String RequestAmount;
    }
}