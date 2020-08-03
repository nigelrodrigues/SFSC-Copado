/**
 *  @description Get Order Details web service class
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        6/25/2019
 */
public with sharing class trac_WS_GetOrderDetails {
    public final String ENDPOINT = (trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c != null) ?
            trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c + trac_WS_WebServiceHelper.webServiceSettings.Get_Order_Details_Endpoint__c : trac_WS_WebServiceHelper.webServiceSettings.Get_Order_Details_Endpoint__c;
    private final String PRE_ORDER_DATE_TYPE = 'YCD_COMPLETELY_SHIPPED_OR_CANCELLED';
    private final String ITEM_ALIAS_UPC = 'ACTIVE_UPC';
    private HttpResponse res = new HttpResponse();
    public GetOrderDetailsRequest getOrderDetailsRequest;
    public GetOrderDetailsResponse getOrderDetailsResponse;
    public String jsonError;

    public Boolean send() {
        Boolean success = false;

        res = trac_WS_WebServiceHelper.sendPostRequest(getEndpoint(), getOrderDetailsRequest);

        if (trac_WS_WebServiceHelper.isValidResponse(res)) {
            getOrderDetailsResponse = parse(res.getBody());
            updateDataFormat();
            success = true;
        } else {
            jsonError = trac_WS_WebServiceHelper.getError(res);
            System.debug('Error: ' + trac_WS_WebServiceHelper.getError(res));
        }

        return success;
    }

    public static GetOrderDetailsResponse parse(String json) {
//        String regex = '"Hudson.s Bay';
//        json = json.replaceAll(regex, '"Hudson\'s Bay'); // replace any special apostrophe chars with a plain single quote
        return (GetOrderDetailsResponse) System.JSON.deserialize(json, GetOrderDetailsResponse.class);
    }

    private String getEndpoint() {
        String dynamicEndpoint = ENDPOINT;

        if (getOrderDetailsRequest != null && getOrderDetailsRequest.Order != null) {

            String businessUnit = trac_WS_OrderUtils.getBusinessUnitFromEnterpriseCode(getOrderDetailsRequest.Order.EnterpriseCode);

            dynamicEndpoint = trac_WS_OrderUtils.getDynamicEndpoint(dynamicEndpoint, businessUnit);
        }

        return dynamicEndpoint;
    }

    private void updateDataFormat() {
        try {
            linkItemsToContainers();
            linkItemsToShipmentLines();
            setPreOrderDateFields();
            setItemUPCs();
            setBlueMartiniStatus();
            sortItems();
            setShipmentLoyaltyFields();
        } catch (Exception e) {
        }
    }

    private void sortItems() {
        if (getOrderDetailsResponse != null && getOrderDetailsResponse.OrderLines != null && getOrderDetailsResponse.OrderLines.OrderLine != null) {
            getOrderDetailsResponse.OrderLines.OrderLine.sort();
        }
    }

    private void linkItemsToContainers() {
        Map<String, String> itemNamesByItemId = getItemNamesByItemId();
        Map<String, res_OrderLineWrapper> itemsByItemId = getItemsByItemId();

        if (getOrderDetailsResponse != null) {
            if (getOrderDetailsResponse.Shipments != null && getOrderDetailsResponse.Shipments.Shipment != null) {
                for (res_ShipmentWrapper shipmentWrapper : getOrderDetailsResponse.Shipments.Shipment) {
                    if (shipmentWrapper != null && shipmentWrapper.Containers != null && shipmentWrapper.Containers.Container != null) {
                        for (res_ContainerWrapper containerWrapper : shipmentWrapper.Containers.Container) {
                            if (containerWrapper != null && containerWrapper.ContainerDetails != null && containerWrapper.ContainerDetails.ContainerDetail != null) {
                                for (res_ContainerDetailWrapper containerDetailWrapper : containerWrapper.ContainerDetails.ContainerDetail) {
                                    if (containerDetailWrapper != null && containerDetailWrapper.ItemID != null) {
                                        if (itemNamesByItemId.containsKey(containerDetailWrapper.ItemID)) {
                                            containerDetailWrapper.customItemName = itemNamesByItemId.get(containerDetailWrapper.ItemID);
                                        }
                                        if (itemsByItemId.containsKey(containerDetailWrapper.ItemID)) {
                                            itemsByItemId.get(containerDetailWrapper.ItemID).customContainer = containerWrapper;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private void linkItemsToShipmentLines() {
        Map<String, res_OrderLineWrapper> itemsByItemId = getItemsByItemId();

        if (getOrderDetailsResponse != null) {
            if (getOrderDetailsResponse.Shipments != null && getOrderDetailsResponse.Shipments.Shipment != null) {
                for (res_ShipmentWrapper shipmentWrapper : getOrderDetailsResponse.Shipments.Shipment) {
                    if (shipmentWrapper != null && shipmentWrapper.ShipmentLines != null && shipmentWrapper.ShipmentLines.ShipmentLine != null) {
                        for (res_ShipmentLineWrapper shipmentLineWrapper : shipmentWrapper.ShipmentLines.ShipmentLine) {
                            if (itemsByItemId.containsKey(shipmentLineWrapper.ItemID)) {
                                itemsByItemId.get(shipmentLineWrapper.ItemID).customShipmentLine = shipmentLineWrapper;
                            }
                        }
                    }
                }
            }
        }
    }

    private Map<String, String> getItemNamesByItemId() {
        Map<String, String> itemNamesByItemId = new Map<String, String>();

        if (getOrderDetailsResponse != null) {
            if (getOrderDetailsResponse.OrderLines != null && getOrderDetailsResponse.OrderLines.OrderLine != null) {
                for (res_OrderLineWrapper orderLineWrapper : getOrderDetailsResponse.OrderLines.OrderLine) {
                    if (orderLineWrapper != null && orderLineWrapper.Item != null && orderLineWrapper.Item.ItemID != null) {

                        if (orderLineWrapper.ItemDetails != null && orderLineWrapper.ItemDetails.PrimaryInformation != null
                                && orderLineWrapper.ItemDetails.PrimaryInformation.ShortDescription != null) {
                            itemNamesByItemId.put(orderLineWrapper.Item.ItemID, orderLineWrapper.ItemDetails.PrimaryInformation.ShortDescription);
                        }
                    }
                }
            }
        }

        return itemNamesByItemId;
    }

    private Map<String, res_OrderLineWrapper> getItemsByItemId() {
        Map<String, res_OrderLineWrapper> itemsByItemId = new Map<String, res_OrderLineWrapper>();

        if (getOrderDetailsResponse != null) {
            if (getOrderDetailsResponse.OrderLines != null && getOrderDetailsResponse.OrderLines.OrderLine != null) {
                for (res_OrderLineWrapper orderLineWrapper : getOrderDetailsResponse.OrderLines.OrderLine) {
                    if (orderLineWrapper != null && orderLineWrapper.Item != null && orderLineWrapper.Item.ItemID != null) {

                        itemsByItemId.put(orderLineWrapper.Item.ItemID, orderLineWrapper);
                    }
                }
            }
        }

        return itemsByItemId;
    }

    private void setPreOrderDateFields() {
        if (getOrderDetailsResponse != null) {
            if (getOrderDetailsResponse.OrderLines != null && getOrderDetailsResponse.OrderLines.OrderLine != null) {
                for (res_OrderLineWrapper orderLineWrapper : getOrderDetailsResponse.OrderLines.OrderLine) {
                    if (orderLineWrapper.OrderDates != null && orderLineWrapper.OrderDates.OrderDate != null) {
                        for (res_OrderDateWrapper orderDateWrapper : orderLineWrapper.OrderDates.OrderDate) {
                            if (orderDateWrapper.DateTypeId == PRE_ORDER_DATE_TYPE) {
                                orderLineWrapper.customRequestedDate = orderDateWrapper.RequestedDate;
                                orderLineWrapper.customExpectedDate = orderDateWrapper.ExpectedDate;
                            }
                        }
                    }
                }
            }
        }
    }

    private void setBlueMartiniStatus() {
        if (getOrderDetailsResponse != null) {
            if (getOrderDetailsResponse.Extn != null) {
                getOrderDetailsResponse.customBlueMartiniStatus = getBlueMartiniDisplayStatusFromCode(getOrderDetailsResponse.Extn.ExtnBlueMartiniStatus);
            }
            if (getOrderDetailsResponse.OrderLines != null && getOrderDetailsResponse.OrderLines.OrderLine != null) {
                for (res_OrderLineWrapper orderLineWrapper : getOrderDetailsResponse.OrderLines.OrderLine) {
                    if (orderLineWrapper.Extn != null) {
                        orderLineWrapper.customBlueMartiniStatus = getBlueMartiniDisplayStatusFromCode(orderLineWrapper.Extn.ExtnBlueMartiniStatus);
                        orderLineWrapper.customBlueMartiniCancelCode = getBlueMartiniDisplayCancelCode(orderLineWrapper.Extn.ExtnBlueMartiniCancellationCode);
                    }
                }
            }
        }
    }

    private void setItemUPCs() {
        if (getOrderDetailsResponse != null && getOrderDetailsResponse.OrderLines != null && getOrderDetailsResponse.OrderLines.OrderLine != null) {
            for (res_OrderLineWrapper orderLineWrapper : getOrderDetailsResponse.OrderLines.OrderLine) {
                if (orderLineWrapper.ItemDetails != null && orderLineWrapper.ItemDetails.ItemAliasList != null && orderLineWrapper.ItemDetails.ItemAliasList.ItemAlias != null) {

                    for (res_ItemAliasWrapper itemAliasWrapper : orderLineWrapper.ItemDetails.ItemAliasList.ItemAlias) {
                        if (itemAliasWrapper.AliasName == ITEM_ALIAS_UPC) {
                            orderLineWrapper.customUPC = itemAliasWrapper.AliasValue;
                        }
                    }
                }
            }
        }
    }

    private static String getBlueMartiniDisplayStatusFromCode(String blueMartiniStatusCode) {
        String displayStatus = blueMartiniStatusCode;

        Map<String, Map<String, Reference_Data__mdt>> referenceDataBySystemValueByType = trac_ReferenceData.getReferenceDataMappedByValueByType('Blue Martini', 'System_Value__c');

        if (referenceDataBySystemValueByType.containsKey('Status')) {
            Map<String, Reference_Data__mdt> referenceDataByStatus = referenceDataBySystemValueByType.get('Status');

            if (referenceDataByStatus.containsKey(blueMartiniStatusCode)) {
                displayStatus = referenceDataByStatus.get(blueMartiniStatusCode).Salesforce_Value__c;
            }
        }

        return displayStatus;
    }

    private static String getBlueMartiniDisplayCancelCode(String blueMartiniStatusCode) {
        String displayStatus = blueMartiniStatusCode;

        Map<String, Map<String, Reference_Data__mdt>> referenceDataBySystemValueByType = trac_ReferenceData.getReferenceDataMappedByValueByType('Blue Martini', 'System_Value__c');

        if (referenceDataBySystemValueByType.containsKey('Cancel Code')) {
            Map<String, Reference_Data__mdt> referenceDataByStatus = referenceDataBySystemValueByType.get('Cancel Code');

            if (referenceDataByStatus.containsKey(blueMartiniStatusCode)) {
                displayStatus = referenceDataByStatus.get(blueMartiniStatusCode).Salesforce_Value__c;
            }
        }

        return displayStatus;
    }

    private void setShipmentLoyaltyFields() {
        if (getOrderDetailsResponse == null) {
            return;
        }
        // calculate total point label and value
        if (getOrderDetailsResponse.Extn != null) {
            String displayValue = 'N/A';
            getOrderDetailsResponse.displayTotalPointsLabel = 'Total Points Earned';
            if (getOrderDetailsResponse.Extn.ExtnPointsLost != null) {
                getOrderDetailsResponse.displayTotalPointsLabel = 'Total Points Lost';
                displayValue = getOrderDetailsResponse.Extn.ExtnPointsLost;
            } else if (getOrderDetailsResponse.Extn.ExtnPointsEarned != null) {
                displayValue = getOrderDetailsResponse.Extn.ExtnPointsEarned;
            }
            getOrderDetailsResponse.displayTotalPointsValue = displayValue;


            // set order level displayExtnLoyaltyNo and displayExtnLoyaltyTier
            getOrderDetailsResponse.Extn.displayExtnLoyaltyNo = String.isNotBlank(getOrderDetailsResponse.Extn.ExtnLoyaltyNo) ? getOrderDetailsResponse.Extn.ExtnLoyaltyNo : '-';
            getOrderDetailsResponse.Extn.displayExtnLoyaltyTier = String.isNotBlank(getOrderDetailsResponse.Extn.ExtnLoyaltyTier) ? getOrderDetailsResponse.Extn.ExtnLoyaltyTier : 'N/A';

        }

        // prepare primeLines map
        Map<String,Map<String,String>> mapPrimeLines = new Map<String,Map<String,String>>();
        if (getOrderDetailsResponse.OrderLines != null && !getOrderDetailsResponse.OrderLines.OrderLine.isEmpty()) {
            for (res_OrderLineWrapper orderLine : getOrderDetailsResponse.OrderLines.OrderLine) {
                Map<String,String> primeLineRow = new Map<String,String>();
                primeLineRow.put('ShortDescription', orderLine.ItemDetails.PrimaryInformation.ShortDescription);
                primeLineRow.put('Status', orderLine.Status);
                primeLineRow.put('UnitPrice', orderLine.LinePriceInfo.UnitPrice);
                primeLineRow.put('Model', orderLine.ItemDetails.ClassificationCodes.Model);
                mapPrimeLines.put(orderLine.PrimeLineNo, primeLineRow);
            }
        }


        // loop over payment method list
        if (getOrderDetailsResponse.PaymentMethods != null && !getOrderDetailsResponse.PaymentMethods.PaymentMethod.isEmpty()) {
            for (res_PaymentMethodWrapper paymentMethod : getOrderDetailsResponse.PaymentMethods.PaymentMethod) {
                paymentMethod.DisplayPointsAuthorized = String.valueOf(Integer.valueOf(String.isNotBlank(paymentMethod.TotalAuthorized) ? Decimal.valueOf(paymentMethod.TotalAuthorized) * 200 : 0.00));
                paymentMethod.DisplayPointsCharged = String.valueOf(Integer.valueOf(String.isNotBlank(paymentMethod.TotalCharged) ? Decimal.valueOf(paymentMethod.TotalCharged) * 200 : 0.00));
            }
        }


        // loop over shipments to fill out fields from primeLines
        if (getOrderDetailsResponse.Shipments != null && !getOrderDetailsResponse.Shipments.Shipment.isEmpty()) {
            for (res_ShipmentWrapper shipment : getOrderDetailsResponse.Shipments.Shipment) {
                // set shipment display extn fields
                shipment.Extn.displayExtnPointsLabel = 'Points Earned';
                String displayPointsValue = 'N/A';
                if (shipment.Extn != null) {
                    if (String.isNotBlank(shipment.Extn.ExtnPointsLost)) {
                        shipment.Extn.displayExtnPointsLabel = 'Points Lost';
                        displayPointsValue = shipment.Extn.ExtnPointsLost;
                    } else if (String.isNotBlank(shipment.Extn.ExtnPointsEarned)) {
                        displayPointsValue = shipment.Extn.ExtnPointsEarned;
                    }
                }
                shipment.Extn.displayExtnPointsValue = displayPointsValue;
                shipment.Extn.displayExtnLoyaltyNo = String.isNotBlank(shipment.Extn.ExtnLoyaltyNo) ? shipment.Extn.ExtnLoyaltyNo : '-';
                shipment.Extn.displayExtnLoyaltyTier = String.isNotBlank(shipment.Extn.ExtnLoyaltyTier) ? shipment.Extn.ExtnLoyaltyTier : 'N/A';

                // loop over order invoice list
                shipment.customInvoiceNo = '';
                if (shipment.OrderInvoiceList != null && !shipment.OrderInvoiceList.OrderInvoice.isEmpty()) {
                    for (res_OrderInvoiceWrapper invoice : shipment.OrderInvoiceList.OrderInvoice) {
                        shipment.customInvoiceNo += (shipment.customInvoiceNo.length() > 0 ? ', ' : '') + invoice.InvoiceNo;
                    }
                }

                // loop over shipment lines
                if (shipment.ShipmentLines != null && !shipment.ShipmentLines.ShipmentLine.isEmpty()) {
                    Integer i = 1;
                    for (res_ShipmentLineWrapper shipmentLine : shipment.ShipmentLines.ShipmentLine) {
                        Map<String,String> primeLine = mapPrimeLines.get(shipmentLine.PrimeLineNo);
                        shipmentLine.customIdx = shipment.ShipmentNo + '-' + i;
                        shipmentLine.customShortDescription = primeLine.get('ShortDescription');
                        shipmentLine.customStatus = primeLine.get('Status');
                        shipmentLine.customUnitPrice = primeLine.get('UnitPrice');
                        shipmentLine.customModel = primeLine.get('Model');
                        i++;
                    }
                }
            }
        }
    }

    public class GetOrderDetailsRequest {
        public req_OrderWrapper Order;
    }

    public class req_OrderWrapper {
        public String OrderNo;
        public String EnterpriseCode;
        public String DocumentType;
        public PersonInfoBillToWrapper PersonInfoBillTo;
        public String IsTrackURLReq;
    }
    public class PersonInfoBillToWrapper {
        public String ZipCode;
    }

    public class GetOrderDetailsResponse {
        @AuraEnabled public String OrderPurpose;
        @AuraEnabled public String EntryType;
        @AuraEnabled public res_ContainersWrapper Containers;
        @AuraEnabled public String OrderDate;
        @AuraEnabled public String SellerOrganizationCode;
        @AuraEnabled public res_PromotionsWrapper Promotions;
        @AuraEnabled public res_PaymentMethodsWrapper PaymentMethods;
        @AuraEnabled public res_HeaderTaxesWrapper HeaderTaxes;
        @AuraEnabled public String Status;
        @AuraEnabled public String BillToID;
        @AuraEnabled public res_PriceInfoWrapper PriceInfo;
        @AuraEnabled public String OrderNo;
        @AuraEnabled public res_OverallTotalsWrapper OverallTotals;
        @AuraEnabled public String EnterpriseCode;
        @AuraEnabled public res_OrderLinesWrapper OrderLines;
        @AuraEnabled public res_AddressWrapper PersonInfoBillTo;
        @AuraEnabled public res_AddressWrapper PersonInfoShipTo;
        @AuraEnabled public String DocumentType;
        @AuraEnabled public res_HeaderChargesWrapper HeaderCharges;
        @AuraEnabled public String CustomerFirstName;
        @AuraEnabled public String EnteredBy;
        @AuraEnabled public res_ExtnWrapper Extn;
        @AuraEnabled public String CustomerContactID;
        @AuraEnabled public res_ChargeTransactionDetailsWrapper ChargeTransactionDetails;
        @AuraEnabled public String CustomerLastName;
        @AuraEnabled public res_ReturnOrdersForExchangeWrapper ReturnOrdersForExchange;
        @AuraEnabled public String DraftOrderFlag;
        @AuraEnabled public res_ShipmentsWrapper Shipments;
        @AuraEnabled public res_NotesWrapper Notes;
        @AuraEnabled public res_ReturnOrdersWrapper ReturnOrders;
        @AuraEnabled public String CustCustPONo;
        @AuraEnabled public res_OrderHoldTypesWrapper OrderHoldTypes;
        @AuraEnabled public res_OrderDatesWrapper OrderDates;
        @AuraEnabled public String customBlueMartiniStatus;
        @AuraEnabled public String displayTotalPointsLabel;
        @AuraEnabled public String displayTotalPointsValue;
        @AuraEnabled public String ResponseCode;
        @AuraEnabled public String ResposneMessage;
    }

    public class res_OrderLineWrapper implements Comparable {
        @AuraEnabled public String SCAC;
        @AuraEnabled public res_LinePriceInfoWrapper LinePriceInfo;
        @AuraEnabled public res_LineChargesWrapper LineCharges;
        @AuraEnabled public res_ItemDetailsWrapper ItemDetails;
        @AuraEnabled public res_ExtnWrapper Extn;
        @AuraEnabled public String OrderedQty;
        @AuraEnabled public String GiftWrap;
        @AuraEnabled public res_OrderStatusesWrapper OrderStatuses;
        @AuraEnabled public res_AddressWrapper PersonInfoShipTo;
        @AuraEnabled public res_LineTaxesWrapper LineTaxes;
        @AuraEnabled public String CarrierServiceCode;
        @AuraEnabled public String Status;
        @AuraEnabled public res_ItemWrapper Item;
        @AuraEnabled public String OrderLineKey;
        @AuraEnabled public res_InstructionsWrapper Instructions;
        @AuraEnabled public res_LineOverallTotalsWrapper LineOverallTotals;
        @AuraEnabled public String DeliveryMethod;
        @AuraEnabled public String PrimeLineNo;
        @AuraEnabled public String GiftFlag;
        @AuraEnabled public res_NotesWrapper Notes;
        @AuraEnabled public res_ContainerWrapper customContainer;
        @AuraEnabled public res_OrderDatesWrapper OrderDates;
        @AuraEnabled public String customRequestedDate;
        @AuraEnabled public String customExpectedDate;
        @AuraEnabled public res_ShipmentLineWrapper customShipmentLine;
        @AuraEnabled public String customUPC;
        @AuraEnabled public String customBlueMartiniStatus;
        @AuraEnabled public String customBlueMartiniCancelCode;
        @AuraEnabled public res_OrderHoldTypesWrapper OrderHoldTypes;

        public Integer compareTo(Object compareTo) {
            res_OrderLineWrapper compareToOrderLineWrapper = (res_OrderLineWrapper) compareTo;
            return (PrimeLineNo != null && compareToOrderLineWrapper != null && Integer.valueOf(PrimeLineNo) > Integer.valueOf(compareToOrderLineWrapper.PrimeLineNo)) ? 1 : -1;
        }
    }

    public class res_OrderHoldTypesWrapper {
        @AuraEnabled public List<res_OrderHoldTypeWrapper> OrderHoldType;
    }

    public class res_OrderHoldTypeWrapper {
        @AuraEnabled public String Status;
        @AuraEnabled public String HoldType;
        @AuraEnabled public String ReasonText;
        @AuraEnabled public String StatusDescription;
        @AuraEnabled public String LastHoldTypeDate;
    }

    public class res_ContainersWrapper {
        @AuraEnabled public List<res_ContainerWrapper> Container;
    }

    public class res_ContainerWrapper {
        @AuraEnabled public String CarrierServiceCode;
        @AuraEnabled public String IsManifested;
        @AuraEnabled public String SCAC;
        @AuraEnabled public String ContainerNo;
        @AuraEnabled public res_ContainerDetailsWrapper ContainerDetails;
        @AuraEnabled public String ContainerScm;
        @AuraEnabled public String TrackingNo;
        @AuraEnabled public String URL;
        @AuraEnabled public res_ShipmentWrapper Shipment;
    }

    public class res_ContainerDetailsWrapper {
        @AuraEnabled public String TotalNumberOfRecords;
        @AuraEnabled public List<res_ContainerDetailWrapper> ContainerDetail;
    }

    public class res_ContainerDetailWrapper {
        @AuraEnabled public String ItemID;
        @AuraEnabled public res_ShipmentLineWrapper ShipmentLine;
        @AuraEnabled public String Quantity;
        @AuraEnabled public String UnitOfMeasure;
        @AuraEnabled public String ShipmentContainerKey;
        @AuraEnabled public String ShipmentLineKey;
        @AuraEnabled public String ShipmentKey;
        @AuraEnabled public String Modifyprogid;
        @AuraEnabled public String Modifyuserid;
        @AuraEnabled public String OrderReleaseKey;
        @AuraEnabled public String Createts;
        @AuraEnabled public String ContainerDetailsKey;
        @AuraEnabled public String Modifyts;
        @AuraEnabled public String Action;
        @AuraEnabled public String OrderLineKey;
        @AuraEnabled public String OrderReleaseStatusKey;
        @AuraEnabled public String QuantityPlaced;
        @AuraEnabled public String CountryOfOrigin;
        @AuraEnabled public String Createprogid;
        @AuraEnabled public String OrderHeaderKey;
        @AuraEnabled public String Createuserid;
        @AuraEnabled public String EnterpriseKey;
        @AuraEnabled public String FifoNo;
        @AuraEnabled public String OrigOrderLineScheduleKey;
        @AuraEnabled public String ProductClass;
        @AuraEnabled public String isHistory;
        @AuraEnabled public String Lockid;
        @AuraEnabled public String customItemName;
    }

    public class res_PromotionsWrapper {
        @AuraEnabled public List<res_PromotionWrapper> Promotion;
    }

    public class res_ShipmentLineWrapper {
        @AuraEnabled public String ItemID;
        @AuraEnabled public String Quantity;
        @AuraEnabled public String PrimeLineNo;
        @AuraEnabled public res_ShipmentTagSerialsWrapper ShipmentTagSerials;
        @AuraEnabled public String customIdx;
        @AuraEnabled public String customShortDescription;
        @AuraEnabled public String customUnitPrice;
        @AuraEnabled public String customStatus;
        @AuraEnabled public String customModel;
    }

    public class res_PromotionWrapper {
        @AuraEnabled public String PromotionId;
    }

    public class res_PaymentMethodsWrapper {
        @AuraEnabled public List<res_PaymentMethodWrapper> PaymentMethod;
    }

    public class res_PaymentMethodWrapper {
        @AuraEnabled public String PaymentReference1;
        @AuraEnabled public String PaymentReference2;
        @AuraEnabled public String PaymentReference3;
        @AuraEnabled public String PaymentReference9;
        @AuraEnabled public String CreditCardExpDate;
        @AuraEnabled public String UnlimitedCharges;
        @AuraEnabled public String TotalRefundedAmount;
        @AuraEnabled public String RequestedChargeAmount;
        @AuraEnabled public String DisplaySvcNo;
        @AuraEnabled public String RequestedAuthAmount;
        @AuraEnabled public String LastName;
        @AuraEnabled public String TotalAuthorized;
        @AuraEnabled public String DisplayPaymentReference1;
        @AuraEnabled public String PaymentType;
        @AuraEnabled public String MaxChargeLimit;
        @AuraEnabled public String MiddleName;
        @AuraEnabled public String TotalCharged;
        @AuraEnabled public String CreditCardName;
        @AuraEnabled public String CreditCardType;
        @AuraEnabled public String FirstName;
        @AuraEnabled public String ChargeSequence;
        @AuraEnabled public String CreditCardNo;
        @AuraEnabled public String DisplayCreditCardNo;
        @AuraEnabled public res_AddressWrapper PersonInfoBillTo;
        @AuraEnabled public String DisplayPointsAuthorized;
        @AuraEnabled public String DisplayPointsCharged;
    }

    public class res_HeaderTaxesWrapper {
    }

    public class res_PriceInfoWrapper {
        @AuraEnabled public String TotalAmount;
        @AuraEnabled public String Currency_x;
    }

    public class res_OverallTotalsWrapper {
        @AuraEnabled public String HdrTotal;
        @AuraEnabled public String GrandTax;
        @AuraEnabled public String LineSubTotal;
        @AuraEnabled public String HdrCharges;
        @AuraEnabled public String GrandCharges;
        @AuraEnabled public String HdrTax;
        @AuraEnabled public String HdrDiscount;
        @AuraEnabled public String GrandTotal;
        @AuraEnabled public String GrandDiscount;
        @AuraEnabled public String SubtotalWithoutTaxes;
        @AuraEnabled public String HeaderAdjustmentWithoutShipping;
        @AuraEnabled public String GrandShippingTotal;
        @AuraEnabled public String GrandRefundTotal;
        @AuraEnabled public String GrandAdjustmentsWithoutTotalShipping;
        @AuraEnabled public String HdrShippingCharges;
        @AuraEnabled public String AdjustedSubtotalWithoutTaxes;
        @AuraEnabled public String RefundedAmount;
        @AuraEnabled public String PendingRefundAmount;
        @AuraEnabled public String GrandExchangeTotal;
    }

    public class res_NotesWrapper {
        @AuraEnabled public String NumberOfNotes;
        @AuraEnabled public List<res_NoteWrapper> Note;
    }

    public class res_NoteWrapper {
        @AuraEnabled public String ContactUser;
        @AuraEnabled public String ReasonCode;
        @AuraEnabled public String NoteText;
        @AuraEnabled public String Priority;
    }

    public class res_OrderLinesWrapper {
        @AuraEnabled public List<res_OrderLineWrapper> OrderLine;
    }

    public class res_OrderDatesWrapper {
        @AuraEnabled public List<res_OrderDateWrapper> OrderDate;
    }

    public class res_OrderDateWrapper {
        @AuraEnabled public String ActualDate;
        @AuraEnabled public String OrderHeaderKey;
        @AuraEnabled public String OrderReleaseKey;
        @AuraEnabled public String OrderLineKey;
        @AuraEnabled public String DateTypeId;
        @AuraEnabled public String ExpectedDate;
        @AuraEnabled public String CommittedDate;
        @AuraEnabled public String RequestedDate;
    }

    public class res_ReturnOrdersWrapper {
        @AuraEnabled public List<res_ReturnOrderWrapper> ReturnOrder;
    }
    public class res_ReturnOrderWrapper {
        @AuraEnabled public String EntryType;
        @AuraEnabled public String OrderDate;
        @AuraEnabled public String CustomerFirstName;
        @AuraEnabled public String SellerOrganizationCode;
        @AuraEnabled public res_NotesWrapper Notes;
        @AuraEnabled public String Status;
        @AuraEnabled public String CustomerContactID;
        @AuraEnabled public String BillToID;
        @AuraEnabled public res_PriceInfoWrapper PriceInfo;
        @AuraEnabled public String OrderNo;
        @AuraEnabled public String CustomerLastName;
        @AuraEnabled public String EnterpriseCode;
        @AuraEnabled public res_OverallTotalsWrapper OverallTotals;
        @AuraEnabled public String CustomerZipCode;
        @AuraEnabled public String CustomerPhoneNo;
        @AuraEnabled public String DraftOrderFlag;
        @AuraEnabled public String CustomerEMailID;
        @AuraEnabled public String MaxOrderStatusDesc;
        @AuraEnabled public String DocumentType;
        @AuraEnabled public res_ExtnWrapper Extn;
    }

    public class res_LinePriceInfoWrapper {
        @AuraEnabled public String ListPrice;
        @AuraEnabled public String UnitPrice;
        @AuraEnabled public String RetailPrice;
        @AuraEnabled public String TaxableFlag;
        @AuraEnabled public String Tax;
    }

    public class res_LineChargesWrapper {
        @AuraEnabled public List<res_LineChargeWrapper> LineCharge;
    }

    public class res_LineChargeWrapper {
        @AuraEnabled public String ChargeAmount;
        @AuraEnabled public String ChargeName;
        @AuraEnabled public String ChargeCategory;
        @AuraEnabled public String ChargePerUnit;
        @AuraEnabled public String ChargePerLine;
    }

    public class res_ItemDetailsWrapper {
        @AuraEnabled public String ItemID;
        @AuraEnabled public res_AdditionalAttributeListWrapper AdditionalAttributeList;
        @AuraEnabled public res_ClassificationCodesWrapper ClassificationCodes;
        @AuraEnabled public res_PrimaryInformationWrapper PrimaryInformation;
        @AuraEnabled public res_ItemAliasListWrapper ItemAliasList;
        @AuraEnabled public res_ItemLocaleListWrapper ItemLocaleList;
        @AuraEnabled public String OrganizationCode;
        @AuraEnabled public res_ExtnWrapper Extn;
    }

    public class res_AdditionalAttributeListWrapper {
        @AuraEnabled public List<res_AdditionalAttributeWrapper> AdditionalAttribute;
    }

    public class res_AdditionalAttributeWrapper {
        @AuraEnabled public String Name;
        @AuraEnabled public String AttributeDomainID;
        @AuraEnabled public String Value;
        @AuraEnabled public String AttributeGroupID;
    }

    public class res_ItemLocaleListWrapper {
        @AuraEnabled public List<res_ItemLocaleWrapper> ItemLocale;
    }

    public class res_ItemLocaleWrapper {
        @AuraEnabled public String Language;
        @AuraEnabled public String Country;
        @AuraEnabled public res_PrimaryInformationWrapper PrimaryInformation;
    }

    public class res_ItemAliasListWrapper {
        @AuraEnabled public List<res_ItemAliasWrapper> ItemAlias;
    }

    public class res_ItemAliasWrapper {
        @AuraEnabled public String AliasName;
        @AuraEnabled public String AliasValue;
    }

    public class res_ClassificationCodesWrapper {
        @AuraEnabled public String Model;
    }

    public class res_PrimaryInformationWrapper {
        @AuraEnabled public String Description;
        @AuraEnabled public String ShortDescription;
        @AuraEnabled public String ManufacturerName;
        @AuraEnabled public String ImageID;
        @AuraEnabled public String ImageLocation;
    }

    public class res_ExtnWrapper {
        @AuraEnabled public String ExtnTransactionID;
        @AuraEnabled public String ExtnWebLineNumber;
        @AuraEnabled public String ExtnSignatureRequired;
        @AuraEnabled public String ExtnIsReturnable;
        @AuraEnabled public String ExtnIsOrgPmtRefund;
        @AuraEnabled public String ExtnLoyaltyNo;
        @AuraEnabled public String ExtnLoyaltyTier;
        @AuraEnabled public String ExtnCommLang;
        @AuraEnabled public String ExtnIsFiftyOne;
        @AuraEnabled public String ExtnFiftyOneOrderNo;
        @AuraEnabled public String ExtnRefundShippingCharge;
        @AuraEnabled public String ExtnReference1;
        @AuraEnabled public String ExtnChargeShippingLabel;
        @AuraEnabled public String ExtnShopRnrAuthTok;
        @AuraEnabled public String ExtnRegisterNo;
        @AuraEnabled public String ExtnTransactionNo;
        @AuraEnabled public String ExtnResponseDate;
        @AuraEnabled public String ExtnResponseCode;
        @AuraEnabled public String ExtnApprovalCode;
        @AuraEnabled public String ExtnReturnTrackingNo;
        @AuraEnabled public String ExtnReturnTrackingURL;
        @AuraEnabled public String ExtnAssociateName;
        @AuraEnabled public String ExtnBlueMartiniStatus;
        @AuraEnabled public String ExtnBlueMartiniCancellationCode;
        @AuraEnabled public String ExtnEstimatedShipDate;
        @AuraEnabled public String ExtnFirstEstimatedShipDate;
        @AuraEnabled public String ExtnPointsEarned;
        @AuraEnabled public String ExtnPointsLost;
        @AuraEnabled public String displayExtnPointsLabel;
        @AuraEnabled public String displayExtnPointsValue;
        @AuraEnabled public String displayExtnLoyaltyNo;
        @AuraEnabled public String displayExtnLoyaltyTier;
    }

    public class res_OrderStatusesWrapper {
        @AuraEnabled public List<res_OrderStatusWrapper> OrderStatus;
    }

    public class res_OrderStatusWrapper {
        @AuraEnabled public String TotalQuantity;
        @AuraEnabled public String Status;
        @AuraEnabled public String OrderHeaderKey;
        @AuraEnabled public String StatusDate;
        @AuraEnabled public res_DetailsWrapper Details;
        @AuraEnabled public String StatusDescription;
        @AuraEnabled public String StatusQty;
    }

    public class res_DetailsWrapper {
        @AuraEnabled public String ExpectedDeliveryDate;
    }

    public class res_LineTaxesWrapper {
        @AuraEnabled public List<res_LineTaxWrapper> LineTax;
    }

    public class res_LineTaxWrapper {
        @AuraEnabled public String ChargeName;
        @AuraEnabled public String ChargeCategory;
        @AuraEnabled public String Tax;
        @AuraEnabled public String TaxName;
        @AuraEnabled public String TaxPercentage;
    }

    public class res_ItemWrapper {
        @AuraEnabled public String ItemID;
        @AuraEnabled public String ProductLine;
        @AuraEnabled public String UnitOfMeasure;
        @AuraEnabled public String TaxProductCode;
        @AuraEnabled public String ItemDesc;
        @AuraEnabled public String UnitCost;
        @AuraEnabled public String ItemShortDesc;
    }

    public class res_InstructionsWrapper {
        @AuraEnabled public List<res_InstructionWrapper> Instruction;
        @AuraEnabled public String NumberOfInstructions;
    }

    public class res_InstructionWrapper {
        @AuraEnabled public String InstructionType;
        @AuraEnabled public String InstructionText;
        @AuraEnabled public String SequenceNo;
    }

    public class res_LineOverallTotalsWrapper {
        @AuraEnabled public String LineTotal;
        @AuraEnabled public String ExtendedPrice;
        @AuraEnabled public String Tax;
        @AuraEnabled public String Discount;
        @AuraEnabled public String UnitPrice;
        @AuraEnabled public String Charges;
    }

    public class res_HeaderChargesWrapper {
        @AuraEnabled public List<res_HeaderChargeWrapper> HeaderCharge;
    }

    public class res_HeaderChargeWrapper {
        @AuraEnabled public String ChargeAmount;
        @AuraEnabled public String ChargeName;
        @AuraEnabled public String ChargeCategory;
    }

    public class res_ChargeTransactionDetailsWrapper {
        @AuraEnabled public String TotalTransferredIn;
        @AuraEnabled public String RemainingAmountToAuth;
        @AuraEnabled public List<res_ChargeTransactionDetailWrapper> ChargeTransactionDetail;
        @AuraEnabled public String TotalTransferredOut;
        @AuraEnabled public String TotalOpenBookings;
        @AuraEnabled public String TotalOpenAuthorizations;
        @AuraEnabled public String TotalDebits;
        @AuraEnabled public String AdditionalExpectedAuthorizations;
        @AuraEnabled public String TotalCredits;
    }

    public class res_ChargeTransactionDetailWrapper {
        @AuraEnabled public String AuthorizationExpirationDate;
        @AuraEnabled public String OpenAuthorizedAmount;
        @AuraEnabled public String DebitAmount;
        @AuraEnabled public String CreditAmount;
        @AuraEnabled public res_InvoiceCollectionDetailsWrapper InvoiceCollectionDetails;
        @AuraEnabled public String ChargeType;
        @AuraEnabled public String Status;
        @AuraEnabled public res_TransferToOrderWrapper TransferToOrder;
        @AuraEnabled public res_TransferFromOrderWrapper TransferFromOrder;
    }

    public class res_TransferToOrderWrapper {
    }

    public class res_TransferFromOrderWrapper {
    }

    public class res_InvoiceCollectionDetailsWrapper {
        @AuraEnabled public List<res_InvoiceCollectionDetailWrapper> InvoiceCollectionDetail;
    }
    public class res_InvoiceCollectionDetailWrapper {
        @AuraEnabled public String InvoiceType;
        @AuraEnabled public String MasterInvoiceNo;
        @AuraEnabled public String InvoiceNo;
        @AuraEnabled public String TotalAmount;
        @AuraEnabled public String DateInvoiced;
        @AuraEnabled public String AmountCollected;
    }

    public class res_ReturnOrdersForExchangeWrapper {
    }

    public class res_ShipmentsWrapper {
        @AuraEnabled public List<res_ShipmentWrapper> Shipment;
    }

    public class res_ShipmentWrapper {
        @AuraEnabled public String ShipmentConfirmUpdatesDone;
        @AuraEnabled public res_ContainersWrapper Containers;
        @AuraEnabled public String StatusDate;
        @AuraEnabled public String ExpectedShipmentDate;
        @AuraEnabled public String SellerOrganizationCode;
        @AuraEnabled public res_ShipmentLinesWrapper ShipmentLines;
        @AuraEnabled public res_ShipNodeWrapper ShipNode;
        @AuraEnabled public String CarrierServiceCode;
        @AuraEnabled public String OrderNo;
        @AuraEnabled public String ShipmentClosedFlag;
        @AuraEnabled public String TotalVolumeUOM;
        @AuraEnabled public String ShipmentType;
        @AuraEnabled public String ActualShipmentDate;
        @AuraEnabled public String SCAC;
        @AuraEnabled public String TotalVolume;
        @AuraEnabled public String ShipmentContainerizedFlag;
        @AuraEnabled public String TotalWeightUOM;
        @AuraEnabled public res_AddressWrapper BillToAddress;
        //@AuraEnabled public String Status;
        @AuraEnabled public res_ShipmentStatusWrapper Status;
        @AuraEnabled public String ShipmentNo;
        @AuraEnabled public String TotalWeight;
        @AuraEnabled public String EnterpriseCode;
        @AuraEnabled public String ShipDate;
        @AuraEnabled public String DeliveryMethod;
        @AuraEnabled public String ShipNode_scattr;
        @AuraEnabled public res_AddressWrapper ToAddress;
        @AuraEnabled public String ExpectedDeliveryDate;
        @AuraEnabled public res_OrderInvoiceListWrapper OrderInvoiceList;
        @AuraEnabled public res_ExtnWrapper Extn;
        @AuraEnabled public String customInvoiceNo;
    }

    public class res_ShipmentStatusWrapper {
        @AuraEnabled public String Status;
        @AuraEnabled public String Description;
    }

    public class res_OrderInvoiceListWrapper {
        @AuraEnabled public String TotalNumberOfRecords;
        @AuraEnabled public List<res_OrderInvoiceWrapper> OrderInvoice;
    }

    public class res_OrderInvoiceWrapper {
        @AuraEnabled public String SellerOrganizationCode;
        @AuraEnabled public String LineSubTotal;
        @AuraEnabled public res_HeaderChargeListWrapper HeaderChargeList;
        @AuraEnabled public res_TaxBreakupListWrapper TaxBreakupList;
        @AuraEnabled public String HeaderTax;
        @AuraEnabled public String AmountCollected;
        @AuraEnabled public String ShipNode;
        @AuraEnabled public String Status;
        @AuraEnabled public String OtherCharges;
        @AuraEnabled public String InvoiceType;
        @AuraEnabled public String ShipmentNo;
        @AuraEnabled public String Reference1;
        @AuraEnabled public String InvoiceNo;
        @AuraEnabled public String OrderNo;
        @AuraEnabled public String EnterpriseCode;
        @AuraEnabled public String TotalTax;
        @AuraEnabled public res_LineDetailsWrapper LineDetails;
        @AuraEnabled public String isHistory;
        @AuraEnabled public String TotalAmount;
        @AuraEnabled public String DocumentType;
        @AuraEnabled public String Currency_x;
        @AuraEnabled public String DateInvoiced;
    }

    public class res_HeaderChargeListWrapper {
        @AuraEnabled public String TotalNumberOfRecords;
    }

    public class res_TaxBreakupListWrapper {
        @AuraEnabled public List<res_TaxBreakupWrapper> TaxBreakup;
        @AuraEnabled public String TotalNumberOfRecords;
    }

    public class res_TaxBreakupWrapper {
        @AuraEnabled public String ChargeName;
        @AuraEnabled public String ChargeCategory;
        @AuraEnabled public String TaxPercentage;
        @AuraEnabled public String TaxableFlag;
        @AuraEnabled public String Tax;
        @AuraEnabled public String InvoicedTax;
        @AuraEnabled public String TaxName;
    }

    public class res_LineDetailsWrapper {
        @AuraEnabled public List<res_LineDetailWrapper> LineDetail;
        @AuraEnabled public String TotalNumberOfRecords;
    }

    public class res_LineDetailWrapper {
        @AuraEnabled public String ItemID;
        @AuraEnabled public String PrimeLineNo;
        @AuraEnabled public String LineTotal;
        @AuraEnabled public String UnitOfMeasure;
        @AuraEnabled public res_LineChargeListWrapper LineChargeList;
        @AuraEnabled public String ExtendedPrice;
        @AuraEnabled public String ShippedQty;
        @AuraEnabled public res_LineTaxListWrapper LineTaxList;
        @AuraEnabled public String UnitPrice;
        @AuraEnabled public String SubLineNo;
        @AuraEnabled public String Charges;
    }

    public class res_LineChargeListWrapper {
        @AuraEnabled public String TotalNumberOfRecords;
    }

    public class res_LineTaxListWrapper {
        @AuraEnabled public List<res_LineTaxWrapper> LineTax;
    }

    public class res_ShipmentLinesWrapper {
        @AuraEnabled public List<res_ShipmentLineWrapper> ShipmentLine;
    }

    public class res_ShipmentTagSerialsWrapper {
        @AuraEnabled public String TotalNumberOfRecords;
        @AuraEnabled public List<res_ShipmentTagSerialWrapper> ShipmentTagSerial;
    }

    public class res_ShipmentTagSerialWrapper {
        @AuraEnabled public String SerialNo;
        @AuraEnabled public res_ExtnWrapper Extn;
    }

    public class res_ShipNodeWrapper {
        @AuraEnabled public String ReturnsNode;
        @AuraEnabled public res_AddressWrapper ShipNodePersonInfo;
        @AuraEnabled public String NodeType;
        @AuraEnabled public res_ExtnWrapper Extn;
        @AuraEnabled public String ShippingNode;
        @AuraEnabled public String ShipNode;
    }

    public class res_AddressWrapper {
        @AuraEnabled public String AlternateEmailID;
        @AuraEnabled public String EMailID;
        @AuraEnabled public String Country;
        @AuraEnabled public String DayPhone;
        @AuraEnabled public String LastName;
        @AuraEnabled public String ZipCode;
        @AuraEnabled public String Title;
        @AuraEnabled public String City;
        @AuraEnabled public String MiddleName;
        @AuraEnabled public String State;
        @AuraEnabled public String FirstName;
        @AuraEnabled public String MobilePhone;
        @AuraEnabled public String Company;
        @AuraEnabled public String AddressLine1;
        @AuraEnabled public String AddressLine2;
        @AuraEnabled public String AddressLine3;
    }
}