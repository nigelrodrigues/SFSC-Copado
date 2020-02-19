/**
 * Tests for TLJSONGenerator
 * @author Doug Jodrell, Traction on Demand
 * @date 2017-12-20
 * @group TLJSONGenerator
 */
@IsTest
private class TLJSONGeneratorTest {
    private static final Boolean TEST_BOOLEAN = true;

    @IsTest
    static void testWriteFields() {
        TLJSONGenerator generator = new TLJSONGenerator();

        generator.writeStartObject();

        generator.writeFieldName('blob');
        generator.writeBlob(Blob.valueOf('blob'));
        generator.writeBlobField('blob', Blob.valueOf('blob'));

        generator.writeFieldName('boolean');
        generator.writeBoolean(TEST_BOOLEAN);
        generator.writeBooleanField('boolean', TEST_BOOLEAN);

        generator.writeFieldName('date');
        generator.writeDate(Date.newInstance(2000, 1, 1));
        generator.writeDateField('date', Date.newInstance(2000, 1, 1));

        generator.writeFieldName('dateTime');
        generator.writeDateTime(Datetime.newInstance(2000, 1, 1));
        generator.writeDateTimeField('dateTime', Datetime.newInstance(2000, 1, 1));

        generator.writeFieldName('time');
        generator.writeTime(Time.newInstance(1,2,3,4));
        generator.writeTimeField('time', Time.newInstance(1,2,3,4));

        generator.writeFieldName('id');
        generator.writeId(UserInfo.getUserId());
        generator.writeIdField('id', UserInfo.getUserId());

        generator.writeFieldName('null');
        generator.writeNull();
        generator.writeNullField('null');

        generator.writeFieldName('Integer');
        generator.writeNumber((Integer) 1);
        generator.writeNumberField('Integer', (Integer) 1);

        generator.writeFieldName('Decimal');
        generator.writeNumber((Decimal) 1);
        generator.writeNumberField('Decimal', (Decimal) 1);

        generator.writeFieldName('Double');
        generator.writeNumber((Double) 1);
        generator.writeNumberField('Double', (Double) 1);

        generator.writeFieldName('Long');
        generator.writeNumber((Long) 1);
        generator.writeNumberField('Long', (Long) 1);

        generator.writeFieldName('object');
        generator.writeObject(new Account());
        generator.writeObjectField('object', new Account());
        generator.writeObjectMapField('object_map', new Map<Id, String>{UserInfo.getUserId()=>'string'});
        generator.writeObjectListField('object_list', new List<Object>());

        generator.writeFieldName('String');
        generator.writeString('String');
        generator.writeStringField('String', 'String');

        generator.writeFieldName('array');
        generator.writeStartArray();
        generator.writeEndArray();

        generator.writeEndObject();

        System.assertNotEquals(null, generator.getAsString(), 'null JSON String.');
        generator.close();
        System.assert(generator.isClosed(), 'Generator did not close.');
    }
}