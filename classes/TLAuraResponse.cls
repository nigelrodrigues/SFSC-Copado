/**
 *  @description Generic Aura Response Object - Holds any map of values to be sent to Lightning Components
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        11/1/2018
 */
public with sharing class TLAuraResponse {
    @AuraEnabled public String              message         {get;set;}
    @AuraEnabled public Boolean             isSuccess       {get;set;}
    @AuraEnabled public Map<Object, Object> returnValuesMap {get;set;}

    /**
     *  @description Constructor with message
     *  @author 	 Jeremy Horan, Traction on Demand.
     *  @date        2017-03-22
     */
    public TLAuraResponse(Boolean result, String messageReturned) {
        isSuccess       = result;
        message         = messageReturned;
        returnValuesMap = new Map<Object, Object>();
    }

    /**
     *  @description Constructor Convenience method
     *  @author 	 Jeremy Horan, Traction on Demand.
     *  @date        2017-03-22
     */
    public TLAuraResponse(Boolean result) {
        isSuccess       = result;
        message         = '';
        returnValuesMap = new Map<Object, Object>();
    }
}