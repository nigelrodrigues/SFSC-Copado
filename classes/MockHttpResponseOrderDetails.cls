/**
 * Created by ragrawal on 7/12/2019.
 */
@isTest
global class MockHttpResponseOrderDetails implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{' +
                '  "EntryType": "Online",' +
                '  "CustomerFirstName": "JW",' +
                '  "SellerOrganizationCode": "SAKS",' +
                '  "EnteredBy": "Web",' +
                '  "ReturnOrders": {},' +
                '  "OrderDates": {},' +
                '  "Extn": {' +
                '    "ExtnIsOrgPmtRefund": "Y",' +
                '    "HbcOrderHeaderChargesList": {},' +
                '    "ExtnLoyaltyNo": "",' +
                '    "ExtnCommLang": "en_US",' +
                '    "ExtnIsFiftyOne": "N",' +
                '    "HbcHeadertaxBreakupList": {},' +
                '    "ExtnShopRnrAuthTok": "",' +
                '    "ExtnRefundShippingCharge": "N",' +
                '    "ExtnReference1": "UOP",' +
                '    "ExtnAssociateName": "Customer",' +
                '    "ExtnChargeShippingLabel": "Y"' +
                '  },' +
                '  "HeaderTaxes": {},' +
                '  "OriginalTax": "0.00",' +
                '  "PriceInfo": {' +
                '    "TotalAmount": "1051.72",' +
                '    "Currency_x": "USD"' +
                '  },' +
                '  "OrderNo": "2810000537",' +
                '  "OverallTotals": {' +
                '    "SubtotalWithoutTaxes": "965.99",' +
                '    "GrandTax": "85.73",' +
                '    "LineSubTotal": "958.00",' +
                '    "HeaderAdjustmentWithoutShipping": "0.00",' +
                '    "GrandShippingTotal": "7.99",' +
                '    "GrandCharges": "7.99",' +
                '    "GrandRefundTotal": "1051.72",' +
                '    "GrandAdjustmentsWithoutTotalShipping": "0.00",' +
                '    "HdrShippingCharges": "0.00",' +
                '    "GrandTotal": "1051.72",' +
                '    "GrandDiscount": "0.00",' +
                '    "AdjustedSubtotalWithoutTaxes": "965.99"' +
                '  },' +
                '  "DraftOrderFlag": "N",' +
                '  "PersonInfoBillTo": {' +
                '    "EMailID": "joyce.witcher@Hbc.com",' +
                '    "Country": "US",' +
                '    "DayPhone": "6468023456",' +
                '    "LastName": "Test",' +
                '    "ZipCode": "10281",' +
                '    "City": "NY",' +
                '    "MiddleName": "",' +
                '    "State": "NY",' +
                '    "FirstName": "JW",' +
                '    "AddressLine6": "",' +
                '    "MobilePhone": "",' +
                '    "AddressLine1": "225 Liberty St.",' +
                '    "AddressLine2": ""' +
                '  },' +
                '  "DocumentType": "0001",' +
                '  "OrderHoldTypes": {' +
                '    "OrderHoldType": [' +
                '      {' +
                '        "Status": "1300",' +
                '        "HoldType": "AUTH_HOLD",' +
                '        "ReasonText": "",' +
                '        "StatusDescription": "Created",' +
                '        "LastHoldTypeDate": "2020-07-09T14:17:41-04:00"' +
                '      }' +
                '    ]' +
                '  },' +
                '  "OrderDate": "2020-07-09T14:17:38-04:00",' +
                '  "Promotions": {},' +
                '  "PaymentMethods": {' +
                '    "PaymentMethod": [' +
                '      {' +
                '        "CreditCardExpDate": "",' +
                '        "PaymentReference2": "",' +
                '        "UnlimitedCharges": "N",' +
                '        "TotalRefundedAmount": "0.00",' +
                '        "RequestedChargeAmount": "0.00",' +
                '        "DisplaySvcNo": "1535",' +
                '        "RequestedAuthAmount": "0.00",' +
                '        "TotalAuthorized": "500.00",' +
                '        "DisplayPaymentReference1": "",' +
                '        "MaxChargeLimit": "500.00",' +
                '        "PaymentType": "GIFT_CARD",' +
                '        "TotalCharged": "0.00",' +
                '        "CreditCardName": "",' +
                '        "CreditCardType": "",' +
                '        "PersonInfoBillTo": {' +
                '          "EMailID": "joyce.witcher@Hbc.com",' +
                '          "MiddleName": "",' +
                '          "State": "NY",' +
                '          "FirstName": "JW",' +
                '          "AddressLine6": "",' +
                '          "LastName": "Test",' +
                '          "DayPhone": "6468023456",' +
                '          "Country": "US",' +
                '          "ZipCode": "10281",' +
                '          "AddressLine1": "225 Liberty St.",' +
                '          "City": "NY",' +
                '          "AddressLine2": ""' +
                '        },' +
                '        "ChargeSequence": "1",' +
                '        "DisplayCreditCardNo": ""' +
                '      },' +
                '      {' +
                '        "CreditCardExpDate": "",' +
                '        "PaymentReference2": "",' +
                '        "UnlimitedCharges": "N",' +
                '        "TotalRefundedAmount": "0.00",' +
                '        "RequestedChargeAmount": "0.00",' +
                '        "DisplaySvcNo": "",' +
                '        "RequestedAuthAmount": "0.00",' +
                '        "LastName": "PLCC",' +
                '        "TotalAuthorized": "551.72",' +
                '        "DisplayPaymentReference1": "6934",' +
                '        "PaymentType": "PVT_CREDIT_CARD",' +
                '        "MaxChargeLimit": "551.72",' +
                '        "TotalCharged": "0.00",' +
                '        "CreditCardName": "JW PLCC",' +
                '        "CreditCardType": "SAKS",' +
                '        "FirstName": "JW",' +
                '        "PersonInfoBillTo": {' +
                '          "EMailID": "joyce.witcher@Hbc.com",' +
                '          "MiddleName": "",' +
                '          "State": "NY",' +
                '          "FirstName": "JW",' +
                '          "AddressLine6": "",' +
                '          "LastName": "Test",' +
                '          "DayPhone": "6468023456",' +
                '          "Country": "US",' +
                '          "ZipCode": "10281",' +
                '          "AddressLine1": "225 Liberty St.",' +
                '          "City": "NY",' +
                '          "AddressLine2": ""' +
                '        },' +
                '        "ChargeSequence": "2",' +
                '        "CreditCardNo": "12936934",' +
                '        "DisplayCreditCardNo": "6934"' +
                '      }' +
                '    ]' +
                '  },' +
                '  "PersonInfoShipTo": {' +
                '    "EMailID": "joyce.witcher@Hbc.com",' +
                '    "Country": "US",' +
                '    "DayPhone": "6468023456",' +
                '    "LastName": "Test",' +
                '    "ZipCode": "10281",' +
                '    "City": "NY",' +
                '    "MiddleName": "",' +
                '    "State": "NY",' +
                '    "FirstName": "JW",' +
                '    "AddressLine6": "",' +
                '    "MobilePhone": "",' +
                '    "AddressLine1": "225 Liberty St.",' +
                '    "AddressLine2": ""' +
                '  },' +
                '  "CustCustPONo": "",' +
                '  "Notes": {' +
                '    "NumberOfNotes": "0"' +
                '  },' +
                '  "Status": "Released",' +
                '  "ChargeTransactionDetails": {' +
                '    "TotalTransferredIn": "0.00",' +
                '    "TotalOpenBookings": "1051.72",' +
                '    "TotalOpenAuthorizations": "1051.72",' +
                '    "TotalDebits": "0.00",' +
                '    "AdditionalExpectedAuthorizations": "0.00",' +
                '    "ChargeTransactionDetail": [' +
                '      {' +
                '        "ChargeType": "AUTHORIZATION",' +
                '        "Status": "CHECKED",' +
                '        "TransferToOrder": {}' +
                '      },' +
                '      {' +
                '        "ChargeType": "CREATE_ORDER",' +
                '        "Status": "CHECKED",' +
                '        "TransferToOrder": {}' +
                '      },' +
                '      {' +
                '        "ChargeType": "AUTHORIZATION",' +
                '        "Status": "CHECKED",' +
                '        "TransferToOrder": {}' +
                '      },' +
                '      {' +
                '        "ChargeType": "AUTHORIZATION",' +
                '        "Status": "CHECKED",' +
                '        "TransferToOrder": {}' +
                '      },' +
                '      {' +
                '        "ChargeType": "AUTHORIZATION",' +
                '        "Status": "CHECKED",' +
                '        "TransferToOrder": {}' +
                '      },' +
                '      {' +
                '        "ChargeType": "AUTHORIZATION",' +
                '        "Status": "CHECKED",' +
                '        "TransferToOrder": {}' +
                '      },' +
                '      {' +
                '        "ChargeType": "AUTHORIZATION",' +
                '        "Status": "CHECKED",' +
                '        "TransferToOrder": {}' +
                '      }' +
                '    ],' +
                '    "TotalTransferredOut": "0.00",' +
                '    "TotalCredits": "0.00"' +
                '  },' +
                '  "CustomerLastName": "Test",' +
                '  "EnterpriseCode": "SAKS",' +
                '  "OrderLines": {' +
                '    "OrderLine": [' +
                '      {' +
                '        "LineCharges": {' +
                '          "LineCharge": [' +
                '            {' +
                '              "ChargeAmount": "7.67",' +
                '              "ChargeName": "SHIPPINGCHARGE",' +
                '              "ChargeCategory": "SHIPPINGCHARGE",' +
                '              "ChargePerUnit": "3.835",' +
                '              "ChargePerLine": "0.00"' +
                '            }' +
                '          ]' +
                '        },' +
                '        "ItemDetails": {' +
                '          "AdditionalAttributeList": {' +
                '            "AdditionalAttribute": [' +
                '              {' +
                '                "Name": "Color",' +
                '                "AttributeDomainID": "ItemAttribute",' +
                '                "Value": "BLUE",' +
                '                "AttributeGroupID": "Style Variation"' +
                '              },' +
                '              {' +
                '                "Name": "Size",' +
                '                "AttributeDomainID": "ItemAttribute",' +
                '                "Value": "ONE SIZE",' +
                '                "AttributeGroupID": "Style Variation"' +
                '              }' +
                '            ]' +
                '          },' +
                '          "ItemAliasList": {' +
                '            "ItemAlias": [' +
                '              {' +
                '                "AliasName": "ACTIVE_UPC",' +
                '                "AliasValue": "828833517959"' +
                '              }' +
                '            ]' +
                '          },' +
                '          "ItemLocaleList": {' +
                '            "ItemLocale": [' +
                '              {' +
                '                "Language": "en",' +
                '                "Country": "US",' +
                '                "PrimaryInformation": {' +
                '                  "ShortDescription": "Intrecciato Leather Wallet",' +
                '                  "Description": "WALLET"' +
                '                }' +
                '              }' +
                '            ]' +
                '          },' +
                '          "OrganizationCode": "SAKS",' +
                '          "ClassificationCodes": {' +
                '            "Model": "0419700180828"' +
                '          },' +
                '          "PrimaryInformation": {' +
                '            "ShortDescription": "Intrecciato Leather Wallet",' +
                '            "ProductLine": "1",' +
                '            "ManufacturerName": "Bottega Veneta",' +
                '            "IsPickupAllowed": "Y",' +
                '            "ImageID": "0419700180828_BLUE_247x329.jpg",' +
                '            "ColorCode": "468",' +
                '            "IsShippingAllowed": "Y",' +
                '            "SizeCode": "ONE SIZE",' +
                '            "ImageLocation": "https://image.s5a.com/is/image/saks/"' +
                '          }' +
                '        },' +
                '        "MaxLineStatus": "3200",' +
                '        "Extn": {' +
                '          "HbcOrderLineChargesList": {},' +
                '          "ExtnColor": "BLUE",' +
                '          "ExtnTransactionID": "10689093707816201937768980",' +
                '          "ExtnIsReturnable": "Y",' +
                '          "ExtnSize": "ONE SIZE",' +
                '          "HbcLinetaxBreakupList": {},' +
                '          "ExtnWebLineNumber": "1"' +
                '        },' +
                '        "OrderDates": {' +
                '          "OrderDate": [' +
                '            {' +
                '              "ActualDate": "2020-07-15T00:00:00-04:00",' +
                '              "OrderHeaderKey": "202007091417428566335270",' +
                '              "OrderReleaseKey": "",' +
                '              "OrderLineKey": "202007091417428566335299",' +
                '              "DateTypeId": "HBC_ORDER_LINE_CANCEL_DATE"' +
                '            },' +
                '            {' +
                '              "ActualDate": "2020-07-15T00:00:00-04:00",' +
                '              "OrderHeaderKey": "202007091417428566335270",' +
                '              "OrderReleaseKey": "",' +
                '              "OrderLineKey": "202007091417428566335299",' +
                '              "DateTypeId": "ORD_LINE_EXP_DEL_DATE"' +
                '            }' +
                '          ]' +
                '        },' +
                '        "OrderedQty": "2",' +
                '        "CarrierServiceCode": "Standard",' +
                '        "Item": {' +
                '          "ItemID": "180842",' +
                '          "TaxProductCode": "41",' +
                '          "CustomerItemDesc": "Intrecciato Leather Wallet",' +
                '          "UnitCost": "203.00",' +
                '          "ItemShortDesc": "Intrecciato Leather Wallet"' +
                '        },' +
                '        "MinLineStatusDesc": "Released",' +
                '        "OrderHoldTypes": {},' +
                '        "SCAC": "FEDX",' +
                '        "PrimeLineNo": "1",' +
                '        "Createuserid": "7001C12345, 7002C45235",' +
                '        "MaxLineStatusDesc": "Released",' +
                '        "LinePriceInfo": {' +
                '          "ListPrice": "460.00",' +
                '          "TaxableFlag": "N",' +
                '          "Tax": "82.33",' +
                '          "UnitPrice": "460.00"' +
                '        },' +
                '        "OriginalOrderedQty": "2",' +
                '        "SubLineNo": "1",' +
                '        "PersonInfoShipTo": {' +
                '          "EMailID": "joyce.witcher@Hbc.com",' +
                '          "Country": "US",' +
                '          "DayPhone": "6468023456",' +
                '          "LastName": "Test",' +
                '          "ZipCode": "10281",' +
                '          "City": "NY",' +
                '          "MiddleName": "",' +
                '          "State": "NY",' +
                '          "FirstName": "JW",' +
                '          "AddressLine6": "",' +
                '          "MobilePhone": "",' +
                '          "AddressLine1": "225 Liberty St.",' +
                '          "AddressLine2": ""' +
                '        },' +
                '        "GiftFlag": "N",' +
                '        "Notes": {' +
                '          "NumberOfNotes": "6",' +
                '          "Note": [' +
                '            {' +
                '              "ContactUser": "",' +
                '              "ReasonCode": "HBC_SB_SM_001",' +
                '              "Createts": "2020-07-09T22:49:10-04:00",' +
                '              "NoteText": "Backordering the order as no action taken by Store with in targetted duration",' +
                '              "Priority": "0.00"' +
                '            },' +
                '            {' +
                '              "ContactUser": "",' +
                '              "ReasonCode": "HBC_SB_SM_001",' +
                '              "Createts": "2020-07-10T08:04:10-04:00",' +
                '              "NoteText": "Backordering the order as no action taken by Store with in targetted duration",' +
                '              "Priority": "0.00"' +
                '            },' +
                '            {' +
                '              "ContactUser": "",' +
                '              "ReasonCode": "HBC_SB_SM_001",' +
                '              "Createts": "2020-07-10T17:19:10-04:00",' +
                '              "NoteText": "Backordering the order as no action taken by Store with in targetted duration",' +
                '              "Priority": "0.00"' +
                '            },' +
                '            {' +
                '              "ContactUser": "",' +
                '              "ReasonCode": "HBC_SB_SM_001",' +
                '              "Createts": "2020-07-11T02:04:10-04:00",' +
                '              "NoteText": "Backordering the order as no action taken by Store with in targetted duration",' +
                '              "Priority": "0.00"' +
                '            },' +
                '            {' +
                '              "ContactUser": "",' +
                '              "ReasonCode": "HBC_SB_SM_001",' +
                '              "Createts": "2020-07-11T11:19:10-04:00",' +
                '              "NoteText": "Backordering the order as no action taken by Store with in targetted duration",' +
                '              "Priority": "0.00"' +
                '            },' +
                '            {' +
                '              "ContactUser": "",' +
                '              "ReasonCode": "HBC_SB_SM_001",' +
                '              "Createts": "2020-07-11T20:04:10-04:00",' +
                '              "NoteText": "Backordering the order as no action taken by Store with in targetted duration",' +
                '              "Priority": "0.00"' +
                '            }' +
                '          ]' +
                '        },' +
                '        "LineTaxes": {' +
                '          "LineTax": [' +
                '            {' +
                '              "ChargeName": "PRICE",' +
                '              "ChargeCategory": "PRICE",' +
                '              "TaxPercentage": "0.08875",' +
                '              "Tax": "81.65",' +
                '              "TaxName": "General Sales and Use Tax"' +
                '            },' +
                '            {' +
                '              "ChargeName": "SHIPPINGCHARGE",' +
                '              "ChargeCategory": "SHIPPINGCHARGE",' +
                '              "TaxPercentage": "0.08875",' +
                '              "Tax": "0.68",' +
                '              "TaxName": "General Sales and Use Tax"' +
                '            }' +
                '          ]' +
                '        },' +
                '        "LineType": "REGULAR",' +
                '        "Status": "Released",' +
                '        "MinLineStatus": "3200",' +
                '        "Instructions": {' +
                '          "Instruction": [' +
                '            {' +
                '              "InstructionType": "SITE_REFER",' +
                '              "InstructionText": "Y",' +
                '              "InstructionUsage": "COMX",' +
                '              "SequenceNo": "1"' +
                '            },' +
                '            {' +
                '              "InstructionType": "PS_COLUMN",' +
                '              "InstructionText": "N",' +
                '              "InstructionUsage": "",' +
                '              "SequenceNo": "2"' +
                '            },' +
                '            {' +
                '              "InstructionType": "WRAP_TYPE",' +
                '              "InstructionText": "N-",' +
                '              "InstructionUsage": "",' +
                '              "SequenceNo": "3"' +
                '            }' +
                '          ],' +
                '          "NumberOfInstructions": "3"' +
                '        },' +
                '        "LineOverallTotals": {' +
                '          "LineTotal": "1010.00",' +
                '          "ExtendedPrice": "920.00",' +
                '          "Tax": "82.33",' +
                '          "LineTotalWithoutTax": "927.67"' +
                '        },' +
                '        "DeliveryMethod": "SHP",' +
                '        "Shipnode": {' +
                '          "Localecode": "en_US_EST",' +
                '          "Description": "DC-689-585",' +
                '          "NodeType": "DC",' +
                '          "ShipnodeType": "",' +
                '          "ShipNode": "DC-689-585"' +
                '        }' +
                '      },' +
                '      {' +
                '        "LineCharges": {' +
                '          "LineCharge": [' +
                '            {' +
                '              "ChargeAmount": "0.32",' +
                '              "ChargeName": "SHIPPINGCHARGE",' +
                '              "ChargeCategory": "SHIPPINGCHARGE",' +
                '              "ChargePerUnit": "0.16",' +
                '              "ChargePerLine": "0.00"' +
                '            }' +
                '          ]' +
                '        },' +
                '        "ItemDetails": {' +
                '          "AdditionalAttributeList": {' +
                '            "AdditionalAttribute": [' +
                '              {' +
                '                "Name": "Size",' +
                '                "AttributeDomainID": "ItemAttribute",' +
                '                "Value": "NO SIZE",' +
                '                "AttributeGroupID": "Style Variation"' +
                '              },' +
                '              {' +
                '                "Name": "Color",' +
                '                "AttributeDomainID": "ItemAttribute",' +
                '                "Value": "SIN",' +
                '                "AttributeGroupID": "Style Variation"' +
                '              }' +
                '            ]' +
                '          },' +
                '          "ItemAliasList": {' +
                '            "ItemAlias": [' +
                '              {' +
                '                "AliasName": "ACTIVE_UPC",' +
                '                "AliasValue": "773602341368"' +
                '              }' +
                '            ]' +
                '          },' +
                '          "ItemLocaleList": {' +
                '            "ItemLocale": [' +
                '              {' +
                '                "Language": "en",' +
                '                "Country": "US",' +
                '                "PrimaryInformation": {' +
                '                  "ShortDescription": "Matte Lipstick",' +
                '                  "Description": "MATTE LIPSTICK"' +
                '                }' +
                '              }' +
                '            ]' +
                '          },' +
                '          "OrganizationCode": "SAKS",' +
                '          "ClassificationCodes": {' +
                '            "Model": "0400925524067"' +
                '          },' +
                '          "PrimaryInformation": {' +
                '            "ShortDescription": "Matte Lipstick",' +
                '            "ProductLine": "1",' +
                '            "ManufacturerName": "MAC",' +
                '            "IsPickupAllowed": "Y",' +
                '            "ImageID": "0400925524067_SIN_247x329.jpg",' +
                '            "ColorCode": "616",' +
                '            "IsShippingAllowed": "Y",' +
                '            "SizeCode": "NO SIZE",' +
                '            "ImageLocation": "https://image.s5a.com/is/image/saks/"' +
                '          }' +
                '        },' +
                '        "MaxLineStatus": "3200",' +
                '        "Extn": {' +
                '          "HbcOrderLineChargesList": {},' +
                '          "ExtnColor": "SIN",' +
                '          "ExtnTransactionID": "10689093705125201917768980",' +
                '          "ExtnIsReturnable": "Y",' +
                '          "ExtnSize": "NO SIZE",' +
                '          "HbcLinetaxBreakupList": {},' +
                '          "ExtnWebLineNumber": "2"' +
                '        },' +
                '        "OrderDates": {' +
                '          "OrderDate": [' +
                '            {' +
                '              "ActualDate": "2020-07-15T00:00:00-04:00",' +
                '              "OrderHeaderKey": "202007091417428566335270",' +
                '              "OrderReleaseKey": "",' +
                '              "OrderLineKey": "202007091417428566335302",' +
                '              "DateTypeId": "HBC_ORDER_LINE_CANCEL_DATE"' +
                '            },' +
                '            {' +
                '              "ActualDate": "2020-07-15T00:00:00-04:00",' +
                '              "OrderHeaderKey": "202007091417428566335270",' +
                '              "OrderReleaseKey": "",' +
                '              "OrderLineKey": "202007091417428566335302",' +
                '              "DateTypeId": "ORD_LINE_EXP_DEL_DATE"' +
                '            }' +
                '          ]' +
                '        },' +
                '        "OrderedQty": "2",' +
                '        "CarrierServiceCode": "Standard",' +
                '        "Item": {' +
                '          "ItemID": "6903007",' +
                '          "TaxProductCode": "3",' +
                '          "CustomerItemDesc": "Matte Lipstick",' +
                '          "UnitCost": "11.10",' +
                '          "ItemShortDesc": "Matte Lipstick/0.1 oz."' +
                '        },' +
                '        "MinLineStatusDesc": "Released",' +
                '"OrderHoldTypes": {'+
                '"OrderHoldType": ['+
                '{'+
               ' "Status": "1300",'+
                '"HoldType": "AUTH_HOLD",'+
                '"ReasonText": "",'+
                '"StatusDescription": "Created",'+
                '"LastHoldTypeDate": "2020-07-09T14:17:41-04:00"'+
               ' }'+
               ' ]'+
               ' },'+
                '        "SCAC": "FEDX",' +
                '        "PrimeLineNo": "2",' +
                '        "Createuserid": "HBCCreateOrderIntegServer",' +
                '        "MaxLineStatusDesc": "Released",' +
                '        "LinePriceInfo": {' +
                '          "ListPrice": "19.00",' +
                '          "TaxableFlag": "N",' +
                '          "Tax": "3.40",' +
                '          "UnitPrice": "19.00"' +
                '        },' +
                '        "OriginalOrderedQty": "2",' +
                '        "SubLineNo": "1",' +
                '        "PersonInfoShipTo": {' +
                '          "EMailID": "joyce.witcher@Hbc.com",' +
                '          "Country": "US",' +
                '          "DayPhone": "6468023456",' +
                '          "LastName": "Test",' +
                '          "ZipCode": "10281",' +
                '          "City": "NY",' +
                '          "MiddleName": "",' +
                '          "State": "NY",' +
                '          "FirstName": "JW",' +
                '          "AddressLine6": "",' +
                '          "MobilePhone": "",' +
                '          "AddressLine1": "225 Liberty St.",' +
                '          "AddressLine2": ""' +
                '        },' +
                '        "GiftFlag": "N",' +
                '        "Notes": {' +
                '          "NumberOfNotes": "0"' +
                '        },' +
                '        "LineTaxes": {' +
                '          "LineTax": [' +
                '            {' +
                '              "ChargeName": "PRICE",' +
                '              "ChargeCategory": "PRICE",' +
                '              "TaxPercentage": "0.08875",' +
                '              "Tax": "3.37",' +
                '              "TaxName": "General Sales and Use Tax"' +
                '            },' +
                '            {' +
                '              "ChargeName": "SHIPPINGCHARGE",' +
                '              "ChargeCategory": "SHIPPINGCHARGE",' +
                '              "TaxPercentage": "0.08875",' +
                '              "Tax": "0.03",' +
                '              "TaxName": "General Sales and Use Tax"' +
                '            }' +
                '          ]' +
                '        },' +
                '        "LineType": "REGULAR",' +
                '        "Status": "Released",' +
                '        "MinLineStatus": "3200",' +
                '        "Instructions": {' +
                '          "Instruction": [' +
                '            {' +
                '              "InstructionType": "PS_RET_FLG",' +
                '              "InstructionText": "Y",' +
                '              "InstructionUsage": "",' +
                '              "SequenceNo": "1"' +
                '            },' +
                '            {' +
                '              "InstructionType": "PS_COLUMN",' +
                '              "InstructionText": "N",' +
                '              "InstructionUsage": "",' +
                '              "SequenceNo": "2"' +
                '            },' +
                '            {' +
                '              "InstructionType": "WRAP_TYPE",' +
                '              "InstructionText": "N-",' +
                '              "InstructionUsage": "",' +
                '              "SequenceNo": "3"' +
                '            }' +
                '          ],' +
                '          "NumberOfInstructions": "3"' +
                '        },' +
                '        "LineOverallTotals": {' +
                '          "LineTotal": "41.72",' +
                '          "ExtendedPrice": "38.00",' +
                '          "Tax": "3.40",' +
                '          "LineTotalWithoutTax": "38.32"' +
                '        },' +
                '        "DeliveryMethod": "SHP",' +
                '        "Shipnode": {' +
                '          "Localecode": "en_US_EST",' +
                '          "Description": "DC-689-585",' +
                '          "NodeType": "DC",' +
                '          "ShipnodeType": "",' +
                '          "ShipNode": "DC-689-585"' +
                '        }' +
                '      }' +
                '    ]' +
                '  },' +
                '  "Shipments": {' +
                '    "Shipment": [' +
                '      {' +
                '        "CarrierServiceCode": "Home Delivery",' +
                '        "Containers": {},' +
                '        "Status": {' +
                '          "Status": "9000",' +
                '          "Description": "Shipment Cancelled"' +
                '        },' +
                '        "SCAC": "FEDX",' +
                '        "ShipmentNo": "200485320",' +
                '        "OrderInvoiceList": {' +
                '          "TotalNumberOfRecords": "0"' +
                '        },' +
                '        "ExpectedDeliveryDate": "2020-07-09T14:35:59-04:00",' +
                '        "ShipDate": "2020-07-09T14:35:59-04:00",' +
                '        "ShipmentLines": {' +
                '          "ShipmentLine": [' +
                '            {' +
                '              "ItemID": "180842",' +
                '              "Quantity": "0",' +
                '              "PrimeLineNo": "1",' +
                '              "OrderNo": "2810000537",' +
                '              "ReleaseNo": "2",' +
                '              "ShipmentTagSerials": {' +
                '                "TotalNumberOfRecords": "0"' +
                '              }' +
                '            }' +
                '          ]' +
                '        },' +
                '        "DeliveryMethod": "SHP",' +
                '        "Extn": {' +
                '          "ExtnLoyaltyNo": ""' +
                '        },' +
                '        "ShipNode_scattr": "8601",' +
                '        "ShipNode": {' +
                '          "ReturnsNode": "N",' +
                '          "ShipNodePersonInfo": {' +
                '            "EMailID": "",' +
                '            "Country": "US",' +
                '            "DayPhone": "8775517257",' +
                '            "LastName": "",' +
                '            "ZipCode": "10022",' +
                '            "City": "New York",' +
                '            "State": "NY",' +
                '            "FirstName": "NEW YORK",' +
                '            "AddressLine6": "",' +
                '            "Company": "",' +
                '            "Department": "",' +
                '            "AddressLine1": "611 Fifth Avenue",' +
                '            "AddressLine2": ""' +
                '          },' +
                '          "NodeType": "Store",' +
                '          "Extn": {' +
                '            "ExtnReturnableCopyFR": "",' +
                '            "ExtnReturnableCopy": "",' +
                '            "ExtnReturnable": "Y"' +
                '          },' +
                '          "ShippingNode": "Y",' +
                '          "ShipNode": "8601"' +
                '        }' +
                '      },' +
                '      {' +
                '        "CarrierServiceCode": "Home Delivery",' +
                '        "Containers": {},' +
                '        "Status": {' +
                '          "Status": "9000",' +
                '          "Description": "Shipment Cancelled"' +
                '        },' +
                '        "SCAC": "FEDX",' +
                '        "ShipmentNo": "200485332",' +
                '        "OrderInvoiceList": {' +
                '          "TotalNumberOfRecords": "0"' +
                '        },' +
                '        "ExpectedDeliveryDate": "2020-07-09T23:56:58-04:00",' +
                '        "ShipDate": "2020-07-09T23:56:58-04:00",' +
                '        "ShipmentLines": {' +
                '          "ShipmentLine": [' +
                '            {' +
                '              "ItemID": "180842",' +
                '              "Quantity": "0",' +
                '              "PrimeLineNo": "1",' +
                '              "OrderNo": "2810000537",' +
                '              "ReleaseNo": "3",' +
                '              "ShipmentTagSerials": {' +
                '                "TotalNumberOfRecords": "0"' +
                '              }' +
                '            }' +
                '          ]' +
                '        },' +
                '        "DeliveryMethod": "SHP",' +
                '        "Extn": {' +
                '          "ExtnLoyaltyNo": ""' +
                '        },' +
                '        "ShipNode_scattr": "8601",' +
                '        "ShipNode": {' +
                '          "ReturnsNode": "N",' +
                '          "ShipNodePersonInfo": {' +
                '            "EMailID": "",' +
                '            "Country": "US",' +
                '            "DayPhone": "8775517257",' +
                '            "LastName": "",' +
                '            "ZipCode": "10022",' +
                '            "City": "New York",' +
                '            "State": "NY",' +
                '            "FirstName": "NEW YORK",' +
                '            "AddressLine6": "",' +
                '            "Company": "",' +
                '            "Department": "",' +
                '            "AddressLine1": "611 Fifth Avenue",' +
                '            "AddressLine2": ""' +
                '          },' +
                '          "NodeType": "Store",' +
                '          "Extn": {' +
                '            "ExtnReturnableCopyFR": "",' +
                '            "ExtnReturnableCopy": "",' +
                '            "ExtnReturnable": "Y"' +
                '          },' +
                '          "ShippingNode": "Y",' +
                '          "ShipNode": "8601"' +
                '        }' +
                '      },' +
                '      {' +
                '        "CarrierServiceCode": "Home Delivery",' +
                '        "Containers": {},' +
                '        "Status": {' +
                '          "Status": "9000",' +
                '          "Description": "Shipment Cancelled"' +
                '        },' +
                '        "SCAC": "FEDX",' +
                '        "ShipmentNo": "200485369",' +
                '        "OrderInvoiceList": {' +
                '          "TotalNumberOfRecords": "0"' +
                '        },' +
                '        "ExpectedDeliveryDate": "2020-07-10T09:08:59-04:00",' +
                '        "ShipDate": "2020-07-10T09:08:59-04:00",' +
                '        "ShipmentLines": {' +
                '          "ShipmentLine": [' +
                '            {' +
                '              "ItemID": "180842",' +
                '              "Quantity": "0",' +
                '              "PrimeLineNo": "1",' +
                '              "OrderNo": "2810000537",' +
                '              "ReleaseNo": "4",' +
                '              "ShipmentTagSerials": {' +
                '                "TotalNumberOfRecords": "0"' +
                '              }' +
                '            }' +
                '          ]' +
                '        },' +
                '        "DeliveryMethod": "SHP",' +
                '        "Extn": {' +
                '          "ExtnLoyaltyNo": ""' +
                '        },' +
                '        "ShipNode_scattr": "8601",' +
                '        "ShipNode": {' +
                '          "ReturnsNode": "N",' +
                '          "ShipNodePersonInfo": {' +
                '            "EMailID": "",' +
                '            "Country": "US",' +
                '            "DayPhone": "8775517257",' +
                '            "LastName": "",' +
                '            "ZipCode": "10022",' +
                '            "City": "New York",' +
                '            "State": "NY",' +
                '            "FirstName": "NEW YORK",' +
                '            "AddressLine6": "",' +
                '            "Company": "",' +
                '            "Department": "",' +
                '            "AddressLine1": "611 Fifth Avenue",' +
                '            "AddressLine2": ""' +
                '          },' +
                '          "NodeType": "Store",' +
                '          "Extn": {' +
                '            "ExtnReturnableCopyFR": "",' +
                '            "ExtnReturnableCopy": "",' +
                '            "ExtnReturnable": "Y"' +
                '          },' +
                '          "ShippingNode": "Y",' +
                '          "ShipNode": "8601"' +
                '        }' +
                '      },' +
                '      {' +
                '        "CarrierServiceCode": "Home Delivery",' +
                '        "Containers": {},' +
                '        "Status": {' +
                '          "Status": "9000",' +
                '          "Description": "Shipment Cancelled"' +
                '        },' +
                '        "SCAC": "FEDX",' +
                '        "ShipmentNo": "200485403",' +
                '        "OrderInvoiceList": {' +
                '          "TotalNumberOfRecords": "0"' +
                '        },' +
                '        "ExpectedDeliveryDate": "2020-07-10T17:53:59-04:00",' +
                '        "ShipDate": "2020-07-10T17:53:59-04:00",' +
                '        "ShipmentLines": {' +
                '          "ShipmentLine": [' +
                '            {' +
                '              "ItemID": "180842",' +
                '              "Quantity": "0",' +
                '              "PrimeLineNo": "1",' +
                '              "OrderNo": "2810000537",' +
                '              "ReleaseNo": "5",' +
                '              "ShipmentTagSerials": {' +
                '                "TotalNumberOfRecords": "0"' +
                '              }' +
                '            }' +
                '          ]' +
                '        },' +
                '        "DeliveryMethod": "SHP",' +
                '        "Extn": {' +
                '          "ExtnLoyaltyNo": ""' +
                '        },' +
                '        "ShipNode_scattr": "8629",' +
                '        "ShipNode": {' +
                '          "ReturnsNode": "N",' +
                '          "ShipNodePersonInfo": {' +
                '            "EMailID": "",' +
                '            "Country": "US",' +
                '            "DayPhone": "8775517257",' +
                '            "LastName": "",' +
                '            "ZipCode": "02199-7698",' +
                '            "City": "BOSTON",' +
                '            "State": "MA",' +
                '            "FirstName": "8629 ATLANTA",' +
                '            "AddressLine6": "",' +
                '            "Company": "",' +
                '            "Department": "",' +
                '            "AddressLine1": "750 BOYLSTON ST",' +
                '            "AddressLine2": ""' +
                '          },' +
                '          "NodeType": "Store",' +
                '          "Extn": {' +
                '            "ExtnReturnableCopyFR": "",' +
                '            "ExtnReturnableCopy": "",' +
                '            "ExtnReturnable": "Y"' +
                '          },' +
                '          "ShippingNode": "Y",' +
                '          "ShipNode": "8629"' +
                '        }' +
                '      },' +
                '      {' +
                '        "CarrierServiceCode": "Home Delivery",' +
                '        "Containers": {},' +
                '        "Status": {' +
                '          "Status": "9000",' +
                '          "Description": "Shipment Cancelled"' +
                '        },' +
                '        "SCAC": "FEDX",' +
                '        "ShipmentNo": "200485417",' +
                '        "OrderInvoiceList": {' +
                '          "TotalNumberOfRecords": "0"' +
                '        },' +
                '        "ExpectedDeliveryDate": "2020-07-11T03:08:59-04:00",' +
                '        "ShipDate": "2020-07-11T03:08:59-04:00",' +
                '        "ShipmentLines": {' +
                '          "ShipmentLine": [' +
                '            {' +
                '              "ItemID": "180842",' +
                '              "Quantity": "0",' +
                '              "PrimeLineNo": "1",' +
                '              "OrderNo": "2810000537",' +
                '              "ReleaseNo": "6",' +
                '              "ShipmentTagSerials": {' +
                '                "TotalNumberOfRecords": "0"' +
                '              }' +
                '            }' +
                '          ]' +
                '        },' +
                '        "DeliveryMethod": "SHP",' +
                '        "Extn": {' +
                '          "ExtnLoyaltyNo": ""' +
                '        },' +
                '        "ShipNode_scattr": "8601",' +
                '        "ShipNode": {' +
                '          "ReturnsNode": "N",' +
                '          "ShipNodePersonInfo": {' +
                '            "EMailID": "",' +
                '            "Country": "US",' +
                '            "DayPhone": "8775517257",' +
                '            "LastName": "",' +
                '            "ZipCode": "10022",' +
                '            "City": "New York",' +
                '            "State": "NY",' +
                '            "FirstName": "NEW YORK",' +
                '            "AddressLine6": "",' +
                '            "Company": "",' +
                '            "Department": "",' +
                '            "AddressLine1": "611 Fifth Avenue",' +
                '            "AddressLine2": ""' +
                '          },' +
                '          "NodeType": "Store",' +
                '          "Extn": {' +
                '            "ExtnReturnableCopyFR": "",' +
                '            "ExtnReturnableCopy": "",' +
                '            "ExtnReturnable": "Y"' +
                '          },' +
                '          "ShippingNode": "Y",' +
                '          "ShipNode": "8601"' +
                '        }' +
                '      },' +
                '      {' +
                '        "CarrierServiceCode": "Home Delivery",' +
                '        "Containers": {},' +
                '        "Status": {' +
                '          "Status": "9000",' +
                '          "Description": "Shipment Cancelled"' +
                '        },' +
                '        "SCAC": "FEDX",' +
                '        "ShipmentNo": "200485426",' +
                '        "OrderInvoiceList": {' +
                '          "TotalNumberOfRecords": "0"' +
                '        },' +
                '        "ExpectedDeliveryDate": "2020-07-11T11:53:59-04:00",' +
                '        "ShipDate": "2020-07-11T11:53:59-04:00",' +
                '        "ShipmentLines": {' +
                '          "ShipmentLine": [' +
                '            {' +
                '              "ItemID": "180842",' +
                '              "Quantity": "0",' +
                '              "PrimeLineNo": "1",' +
                '              "OrderNo": "2810000537",' +
                '              "ReleaseNo": "7",' +
                '              "ShipmentTagSerials": {' +
                '                "TotalNumberOfRecords": "0"' +
                '              }' +
                '            }' +
                '          ]' +
                '        },' +
                '        "DeliveryMethod": "SHP",' +
                '        "Extn": {' +
                '          "ExtnLoyaltyNo": ""' +
                '        },' +
                '        "ShipNode_scattr": "8629",' +
                '        "ShipNode": {' +
                '          "ReturnsNode": "N",' +
                '          "ShipNodePersonInfo": {' +
                '            "EMailID": "",' +
                '            "Country": "US",' +
                '            "DayPhone": "8775517257",' +
                '            "LastName": "",' +
                '            "ZipCode": "02199-7698",' +
                '            "City": "BOSTON",' +
                '            "State": "MA",' +
                '            "FirstName": "8629 ATLANTA",' +
                '            "AddressLine6": "",' +
                '            "Company": "",' +
                '            "Department": "",' +
                '            "AddressLine1": "750 BOYLSTON ST",' +
                '            "AddressLine2": ""' +
                '          },' +
                '          "NodeType": "Store",' +
                '          "Extn": {' +
                '            "ExtnReturnableCopyFR": "",' +
                '            "ExtnReturnableCopy": "",' +
                '            "ExtnReturnable": "Y"' +
                '          },' +
                '          "ShippingNode": "Y",' +
                '          "ShipNode": "8629"' +
                '        }' +
                '      }' +
                '    ]' +
                '  },' +
                '  "HeaderCharges": {},' +
                '  "OriginalTotalAmount": "1051.72",' +
                '  "ResponseCode": "0",' +
                '  "ResposneMessage": "Sucess"' +
                '}');
        res.setStatusCode(200);
        return res;
    }
}