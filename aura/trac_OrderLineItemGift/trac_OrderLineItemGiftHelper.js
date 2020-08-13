/**
 * Created by macuser on 8/12/20.
 */

({
    setGiftOptions : function(component, event, helper) {
        var orderLineItem =  component.get('v.orderLineItem')
        var message = ""
        for(var instruction of orderLineItem.Instructions.Instruction) {
            if(instruction.InstructionType.includes('GIFT_MSG')) {
                message = message.concat(' ', instruction.InstructionText)
            }
            if(instruction.InstructionType === 'WRAP_TYPE') {
                component.set('v.detail', instruction.InstructionText)
            }
            if(instruction.InstructionType === 'GIFT_RECP') {
                component.set('v.recipient', instruction.InstructionText)
            }
        }
        component.set('v.message', message)
    },

    setIsBM : function(component, event, helper) {
        let order = component.get('v.order');
        let isBM = helper.isBetweenRange(order.BMRange, order.OrderNo);
        component.set('v.isBM', isBM);
    },

    isBetweenRange : function (rangeStr, number) {
        var ranges = rangeStr.split("-");
        return (ranges[0] <= number && ranges[1] >= number ) ? true : false
    },
});