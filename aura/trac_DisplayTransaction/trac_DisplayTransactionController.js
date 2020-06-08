/**
 * Created by nrodrigues on 6/4/2020.
 */

({
    fireEvent : function (component, event, helper) {
        var count = event.getSource().get("v.value");
        var compEvent = component.getEvent("TractionComponentEvent");
        compEvent.setParams({"count": count});
        compEvent.fire();
    }
});