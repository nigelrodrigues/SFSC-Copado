/**
 * Tests for TLMocker
 * @author Grant Adamson, Traction on Demand
 * @date 2017-05-01
 * @group TLMocker
 */
@IsTest
private class TLMockerTest {

    @IsTest
    private static void initWithNoValues() {
        Test.startTest();

        final TLMocker mock = new TLMocker(TLMockerTestClassToMock.class);
        final TLMockerTestClassToMock mocked = (TLMockerTestClassToMock)mock.stub;

        Test.stopTest();


        System.assertEquals(null, mocked.returnABoolean(false),
                'I can call a method and it returns a default null value');
        System.assertEquals(null, mocked.returnAnInteger(0, 'test'),
                'I can call a method and it returns a default null value');
        System.assertEquals(null, mocked.returnAnotherInteger(0),
                'I can call a method and it returns a default null value');
    }

    @IsTest
    private static void initWithSingleValue() {
        Test.startTest();

        final TLMocker mock = new TLMocker(TLMockerTestClassToMock.class, 5);
        final TLMockerTestClassToMock mocked = (TLMockerTestClassToMock)mock.stub;

        Test.stopTest();


        System.assertEquals(5, mocked.returnAnInteger(0, 'test'),
                'I can call a method and it returns the provided value');
        System.assertEquals(5, mocked.returnAnotherInteger(0),
                'I can call a method and it returns the provided value');
    }

    @IsTest
    private static void initWithSingleValueException() {
        Boolean caughtException = false;


        Test.startTest();

        final TLMocker mock = new TLMocker(TLMockerTestClassToMock.class,
                new TLMockerTestClassToMock.TestException('It broke!'));
        final TLMockerTestClassToMock mocked = (TLMockerTestClassToMock)mock.stub;

        Test.stopTest();


        try {
            mocked.returnABoolean(true);
        } catch (Exception e) {
            caughtException = true;
            System.assert(e instanceof TLMockerTestClassToMock.TestException,
                    'The correct type of exception was thrown');
        }

        System.assert(caughtException, 'An exception was thrown');
    }

    @IsTest
    private static void initWithMap() {
        Test.startTest();

        final TLMocker mock = new TLMocker(TLMockerTestClassToMock.class, new Map<String, Object>{
                'returnAnInteger' => 20,
                'returnAnotherInteger' => new TLMockerTestClassToMock.TestException('It broke!')
        });
        final TLMockerTestClassToMock mocked = (TLMockerTestClassToMock)mock.stub;

        Test.stopTest();


        System.assertEquals(20, mocked.returnAnInteger(0, 'test'),
                'I can call a method and it returns the provided value');
        System.assertEquals(null, mocked.returnABoolean(true),
                'I can call a method and it returns null if no map value was provided');

        Boolean caughtException = false;
        try {
            mocked.returnAnotherInteger(0);
        } catch (Exception e) {
            caughtException = true;
        }
        System.assert(caughtException, 'I can call a method and it returns the provided value');
    }

    @IsTest
    private static void initWithMapAndFallbackValue() {
        Test.startTest();

        final TLMocker mock = new TLMocker(TLMockerTestClassToMock.class,
                new Map<String, Object>{ 'returnAnInteger' => 20, 'returnABoolean' => true }, -1);
        final TLMockerTestClassToMock mocked = (TLMockerTestClassToMock)mock.stub;

        Test.stopTest();


        System.assertEquals(20, mocked.returnAnInteger(0, 'test'),
                'I can call a method and it returns the provided value');
        System.assertEquals(true, mocked.returnABoolean(true),
                'I can call a method and it returns the provided value');
        System.assertEquals(-1, mocked.returnAnotherInteger(0),
                'I can call a method and it returns the fallback value if the map did not provide one');
    }

    @IsTest
    private static void history() {
        Test.startTest();

        final TLMocker mock = new TLMocker(TLMockerTestClassToMock.class);
        final TLMockerTestClassToMock mocked = (TLMockerTestClassToMock)mock.stub;

        mocked.returnABoolean(false);
        mocked.returnABoolean(true);
        mocked.returnAnInteger(-1, 'test');

        final Map<String, List<List<Object>>> history = mock.history;

        Test.stopTest();


        System.assertEquals(2, history.size(), 'The history map contains an entry for each method that was called');

        final List<List<Object>> returnABooleanHistory = history.get('returnABoolean');
        System.assertEquals(2, returnABooleanHistory.size(), 'There are two entries in the history for returnABoolean');

        final List<Object> returnABooleanHistoryEntry1 = returnABooleanHistory[0];
        System.assertEquals(1, returnABooleanHistoryEntry1.size(),
                'The first entry contains the expected number of parameters');
        System.assertEquals(false, (Boolean)returnABooleanHistoryEntry1[0],
                'The first entry contains the expected parameter value');

        final List<Object> returnABooleanHistoryEntry2 = returnABooleanHistory[1];
        System.assertEquals(1, returnABooleanHistoryEntry2.size(),
                'The second entry contains the expected number of parameters');
        System.assertEquals(true, (Boolean)returnABooleanHistoryEntry2[0],
                'The second entry contains the expected parameter value');

        final List<List<Object>> returnAnIntegerHistory = history.get('returnAnInteger');
        System.assertEquals(1, returnAnIntegerHistory.size(), 'There is one entry in the history for returnAnInteger');

        final List<Object> returnAnIntegerHistoryEntry1 =  returnAnIntegerHistory[0];
        System.assertEquals(2, returnAnIntegerHistoryEntry1.size(),
                'The entry contains the expected number of parameters');
        System.assertEquals(-1, (Integer)returnAnIntegerHistoryEntry1[0],
                'The entry contains the expected parameter value');
        System.assertEquals('test', (String)returnAnIntegerHistoryEntry1[1],
                'The entry contains the expected parameter value');
    }
}