/**
 * Universal Mocking class
 * Responds to methods with the corresponding values in responseMap.
 * If no matching value can be found, or responseMap is null, falls back to response value.
 * Logs all method calls with their attributes in history
 * @author Grant Adamson, Traction on Demand
 * @date   2017-04-24
 * @group TLMocker
 */
@IsTest
public class TLMocker {
    public Object stub { get; private set; }
    public Map<String, List<List<Object>>> history { get; private set; }

    /**
     * Create a new TLMocker for the type specified
     * @param  t Type of object to be mocked
     * @return   new TLMocker instance with stub initialized to the appropriate StubProvider
     */
    public TLMocker(Type t) {
        this(t, null, null);
    }

    /**
     * Create a new TLMocker for the type specified
     * @param  t        Type of object to be mocked
     * @param  retVal   Return value for all methods 
     * @return          new TLMocker instance with stub initialized to the appropriate StubProvider
     */
    public TLMocker(Type t, Object retVal) {
        this(t, null, retVal);
    }

    /**
     * Create a new TLMocker for the type specified
     * @param  t            Type of object to be mocked
     * @param  retValMap    Map of Method Name to return value
     * @return              new TLMocker instance with stub initialized to the appropriate StubProvider
     */
    public TLMocker(Type t, Map<String, Object> retValMap) {
        this(t, retValMap, null);
    }

    /**
     * Create a new TLMocker for the type specified
     * @param  t            Type of object to be mocked
     * @param  retValMap    Map of Method Name to return value
     * @param  retVal       Fallback return value for any methods not found in retValMap
     * @return              new TLMocker instance with stub initialized to the appropriate StubProvider
     */
    public TLMocker(Type t, Map<String, Object> retValMap, Object retVal) {
        history = new Map<String, List<List<Object>>>();
        stub = Test.createStub(t, new UniversalStub(retValMap, retVal, history));
    }

    /**
     * Generic StubProvider implementation
     */
    public class UniversalStub implements System.StubProvider {
        private Map<String, Object> retValMap;
        private Object retVal;
        private Map<String, List<List<Object>>> history;

        private UniversalStub(Map<String, Object> retValMap, Object retVal, Map<String, List<List<Object>>> history) {
            this.retValMap = (retValMap != null ? retValMap : new Map<String, Object>());
            this.retVal = retVal;
            this.history = history;
        }

        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {

            logMethodCall(stubbedMethodName, listOfArgs);

            Object returnValue = getReturnValue(stubbedMethodName);

            if(returnValue instanceof Exception) {
                throw (Exception)returnValue;
            }

            return returnValue;
        }

        private Object getReturnValue(String stubbedMethodName) {
            if(retValMap.containsKey(stubbedMethodName)) {
                return retValMap.get(stubbedMethodName);
            }

            return retVal;
        }

        private void logMethodCall(String stubbedMethodName, List<Object> listOfArgs) {
            if(!history.containsKey(stubbedMethodName)) {
                history.put(stubbedMethodName, new List<List<Object>>());
            }

            history.get(stubbedMethodName).add(listOfArgs);
        }
    }
}