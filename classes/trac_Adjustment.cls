/**
 *  @description Wrapper for Adjustments used in API calls
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        2/10/2020
 */
public without sharing class trac_Adjustment {

    @AuraEnabled public Integer id;
    @AuraEnabled public Integer line_number;
    @AuraEnabled public String order_number;
    @AuraEnabled public String status;
    @AuraEnabled public line_detailsWrapper line_details;
    @AuraEnabled public amountsWrapper amounts;
    @AuraEnabled public customerWrapper customer;
    @AuraEnabled public stateWrapper state;
    @AuraEnabled public logWrapper log;

    public class line_detailsWrapper {
        @AuraEnabled public String description;
        @AuraEnabled public String group_id;
        @AuraEnabled public String group_name;
        @AuraEnabled public String product_code;
        @AuraEnabled public String ccd_brand;
        @AuraEnabled public String shipping_method;
        @AuraEnabled public String scan_upc;
        @AuraEnabled public String tracking_number;
        @AuraEnabled public String shipped_dateline;
        @AuraEnabled public String fulfillment_location;
        @AuraEnabled public Integer quantity;
    }

    public class amountsWrapper {
        @AuraEnabled public Decimal extended_price;
        @AuraEnabled public Decimal item_price;
        @AuraEnabled public Decimal line_tax;
        @AuraEnabled public Decimal shipping_tax;
        @AuraEnabled public Decimal shipping_fee;
        @AuraEnabled public Decimal gift_wrap_fee;
        @AuraEnabled public Decimal return_label_fee;
        @AuraEnabled public Decimal adjusted_price;
        @AuraEnabled public Decimal adjusted_tax;
        @AuraEnabled public Decimal price_diff;
        @AuraEnabled public Decimal tax_diff;
        @AuraEnabled public Decimal total_diff;
        @AuraEnabled public Decimal adjusted_value;
        @AuraEnabled public Decimal adjusted_amount;
        @AuraEnabled public Decimal adjusted_percent;
        @AuraEnabled public String adjust_type;
    }

    public class customerWrapper {
        @AuraEnabled public String customer_name;
        @AuraEnabled public String email_address;
        @AuraEnabled public billingWrapper billing;
        @AuraEnabled public shippingWrapper shipping;
    }

    public class billingWrapper {
        @AuraEnabled public String address_1;
        @AuraEnabled public String city;
        @AuraEnabled public String state;
        @AuraEnabled public String zip;
    }

    public class shippingWrapper {
        @AuraEnabled public String address_1;
        @AuraEnabled public String city;
        @AuraEnabled public String state;
        @AuraEnabled public String zip;
    }

    public class stateWrapper {
        @AuraEnabled public Boolean audited;
        @AuraEnabled public Boolean processed;
        @AuraEnabled public Boolean spa;
        @AuraEnabled public Boolean submitted;
        @AuraEnabled public Boolean voided;
        @AuraEnabled public String issue;
        @AuraEnabled public Integer chain;
        @AuraEnabled public String spa_comments;
        @AuraEnabled public String submitter_comments;
        @AuraEnabled public String process_comments;
        @AuraEnabled public String spa_audit_comments;
        @AuraEnabled public String manual;
        @AuraEnabled public String waiting;
    }

    public class logWrapper {
        @AuraEnabled public String created_on;
        @AuraEnabled public String agent_id;
        @AuraEnabled public String modified_on;
        @AuraEnabled public String modified_by;
        @AuraEnabled public String working_on;
        @AuraEnabled public String submitted_on;
        @AuraEnabled public String submitted_by;
        @AuraEnabled public String submitter_number;
        @AuraEnabled public String processed_on;
        @AuraEnabled public String processed_by;
        @AuraEnabled public String audited_on;
        @AuraEnabled public String audited_by;
        @AuraEnabled public String auditor_id;
    }
}