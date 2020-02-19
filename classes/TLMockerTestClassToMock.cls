/**
 * Class used by TLMockerTest tests, as only top-level classes can be mocked
 * @author Grant Adamson, Traction on Demand
 * @date 2017-05-01
 * @Group TLMocker
 */
@IsTest
public class TLMockerTestClassToMock {

    public Boolean returnABoolean(Boolean value) {
        return null;
    }

    public Integer returnAnInteger(Integer value, String value2) {
        return null;
    }

    public Integer returnAnotherInteger(Integer value) {
        return null;
    }

    public class TestException extends Exception {}
}