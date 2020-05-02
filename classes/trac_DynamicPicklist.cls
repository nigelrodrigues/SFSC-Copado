/**
* @description Helper for trac_DynamicPicklist
* @author      Abhishek Solanki, Traction on Demand
* @date        2020-02-03
*/
global class trac_DynamicPicklist extends VisualEditor.DynamicPickList {

    global override VisualEditor.DataRow getDefaultValue() {
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('--None--', '--None--');
        return defaultValue;
    }

    global override VisualEditor.DynamicpickListRows getValues() {
        Map<String, RecordTypeInfo> recordTypeInfoByName = SObjectType.Case.getRecordTypeInfosByName();

        VisualEditor.DynamicpickListRows recordTypes = new VisualEditor.DynamicpickListRows();

        for (String recTypeName : recordTypeInfoByName.keySet()) {
            if(!recTypeName.equals('Master')){
                String recTypeId = recordTypeInfoByName.get(recTypeName).getRecordTypeId();
                VisualEditor.DataRow value = new VisualEditor.DataRow(recTypeName, recTypeId);
                recordTypes.addRow(value);
            }
        }
        return recordTypes;
    }
}