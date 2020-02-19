/**
 * TLJSONGenerator
 * A class that wraps sfdc's JSONGenerator but handles nulls gracefully (by not writing)
 * @author Jonny Power, Traction on Demand
 * @date 01 Jun 2017
 * @group TLJSONGenerator
**/
public class TLJSONGenerator {

	// =========================================================
	//  ATTRIBUTES
	// =========================================================

	private final JSONGenerator generator;

	// =========================================================
	//  CONSTRUCTORS
	// =========================================================

	public TLJSONGenerator() {
		this(false);
	}

	public TLJSONGenerator(Boolean prettyPrint) {
		this(JSON.createGenerator(prettyPrint));
	}

	private TLJSONGenerator(JSONGenerator generator) {
		this.generator = generator;
	}

	// =========================================================
	//  PUBLIC METHODS
	// =========================================================

	public void close()	{
		generator.close();
	}

	public String getAsString()	{
		return generator.getAsString();
	}

	public Boolean isClosed() {
		return generator.isClosed();
	}

	public void writeBlob(Blob b) {
		if(shouldWrite(b)) generator.writeBlob(b);
	}

	public void writeBlobField(String fieldName, Blob b) {
		if(shouldWrite(fieldName, b)) generator.writeBlobField(fieldName, b);
	}

	public void writeBoolean(Boolean b) {
		if(shouldWrite(b)) generator.writeBoolean(b);
	}

	public void writeBooleanField(String fieldName, Boolean b) {
		if(shouldWrite(fieldName, b)) generator.writeBooleanField(fieldName, b);
	}

	public void writeDate(Date d) {
		if(shouldWrite(d)) generator.writeDate(d);
	}

	public void writeDateField(String fieldName, Date d) {
		if(shouldWrite(fieldName, d)) generator.writeDateField(fieldName, d);
	}

	public void writeDateTime(Datetime dt) {
		if(shouldWrite(dt)) generator.writeDateTime(dt);
	}

	public void writeDateTimeField(String fieldName, Datetime dt) {
		if(shouldWrite(dt)) generator.writeDateTimeField(fieldName, dt);
	}

	public void writeEndArray() {
		generator.writeEndArray();
	}

	public void writeEndObject() {
		generator.writeEndObject();
	}

	public void writeFieldName(String fieldName) {
		if(shouldWrite(fieldName)) generator.writeFieldName(fieldName);
	}

	public void writeId(Id pid) {
		if(shouldWrite(pid)) generator.writeId(pid);
	}

	public void writeIdField(String fieldName, Id pid) {
		if(shouldWrite(fieldName, pid)) generator.writeIdField(fieldName, pid);
	}

	public void writeNull() {
		generator.writeNull();
	}

	public void writeNullField(String fieldName) {
		if (shouldWrite(fieldName)) generator.writeNullField(fieldName);
	}

	public void writeNumber(Decimal d) {
		if(shouldWrite(d)) generator.writeNumber(d);
	}

	public void writeNumber(Double d) {
		if(shouldWrite(d)) generator.writeNumber(d);
	}

	public void writeNumber(Integer i) {
		if(shouldWrite(i)) generator.writeNumber(i);
	}

	public void writeNumber(Long lng) {
		if(shouldWrite(lng)) generator.writeNumber(lng);
	}

	public void writeNumberField(String fieldName, Decimal d) {
		if(shouldWrite(fieldName, d)) generator.writeNumberField(fieldName, d);
	}

	public void writeNumberField(String fieldName, Double d) {
		if(shouldWrite(fieldName, d)) generator.writeNumberField(fieldName, d);
	}

	public void writeNumberField(String fieldName, Integer i) {
		if(shouldWrite(fieldName, i)) generator.writeNumberField(fieldName, i);
	}

	public void writeNumberField(String fieldName, Long lng) {
		if(shouldWrite(fieldName, lng)) generator.writeNumberField(fieldName, lng);
	}

	public void writeObject(Object o) {
		if(shouldWrite(o)) generator.writeObject(o);
	}

	public void writeObjectField(String fieldName, Object o) {
		if(shouldWrite(fieldName, o)) generator.writeObjectField(fieldName, o);
	}

	public void writeStartArray() {
		generator.writeStartArray();
	}

	public void writeStartObject() {
		generator.writeStartObject();
	}

	public void writeString(String str) {
		if(shouldWrite(str)) generator.writeString(str);
	}

	public void writeStringField(String fieldName, String str) {
		if(shouldWrite(fieldName, str)) generator.writeStringField(fieldName, str);
	}

	public void writeTime(Time t) {
		if(shouldWrite(t)) generator.writeTime(t);
	}

	public void writeTimeField(String fieldName, Time t) {
		if(shouldWrite(fieldName, t)) generator.writeTimeField(fieldName, t);
	}

    public void writeObjectListField(String fieldName, List<Object> objects) {
        if(shouldWrite(fieldName, objects)) {
            generator.writeFieldName(fieldName);
            this.writeObjectList(objects);
        }
    }

    public void writeObjectList(List<Object> objects) {
        if(shouldWrite(objects)) {
            generator.writeStartArray();
            for (Object o : objects) {
                generator.writeObject(o);
            }
            generator.writeEndArray();
        }
    }

    public void writeObjectMapField(String fieldName, Map<Id, Object> objects) {
        if(shouldWrite(fieldName, objects)) {
            generator.writeFieldName(fieldName);
            this.writeObjectMap(objects);
        }
    }

    public void writeObjectMap(Map<Id, Object> objects) {
        if(shouldWrite(objects)) {
            generator.writeStartObject();
            for (String key : objects.keySet()) {
                generator.writeObjectField(key, objects.get(key));
            }
            generator.writeEndObject();
        }
    }
	// =========================================================
	//  PRIVATE METHODS
	// =========================================================

	private Boolean shouldWrite(Object o) {
		if(o instanceof String) {
			return String.isNotBlank((String)o);
		} else {
			return o != null;
		}
	}
    private Boolean shouldWrite(List<Object> o) {
        return (o != null);
    }
    private Boolean shouldWrite(Map<Id, Object> o) {
        return (o != null);
    }
	private Boolean shouldWrite(String fieldName, Object o) {
		return String.isNotBlank(fieldName) && shouldWrite(o);
	}
    private Boolean shouldWrite(String fieldName, List<Object> o) {
        return String.isNotBlank(fieldName) && shouldWrite(o);
    }
    private Boolean shouldWrite(String fieldName, Map<Id, Object> o) {
        return String.isNotBlank(fieldName) && shouldWrite(o);
    }

}