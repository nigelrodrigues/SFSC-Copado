/**
 *  @description Logging utilities
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        11/28/2018
 */
public with sharing class TLLog {
    public static Boolean loggingEnabled = true;

    private static final String TAG_SEPARATOR = '\t:\t';
    private static final String TAG = 'Log';
    private static final Integer LOG_LEVEL_CHATTER = 1;
    private static final Integer LOG_LEVEL_EMAIL = 2;
    private static Map<Integer, List<String>> messagesByLogLevel = getNewMessagesByLogLevel();

    // set to true to remove sensitive data form debug logs in production
    private static final Boolean hideRecordData = false;

    // used for testing purposes
    @TestVisible
    private static Boolean hideRecordDataForTest = false;
    private static final SafeSerializeVisitor serializeVisitor = new SafeSerializeVisitor();

    /**
     * Stage your message for outputting in the debug console.
     * Example: Log.debug('this will stage your message for console output');
     * @param  tag         A short string indicating the system component from which the message originates (for example, "View" for the view system).
     * @param  msg         The log message
     */
    public static void d(String tag, String msg) {
        if (loggingEnabled) {
            logToSystemDebug(LoggingLevel.DEBUG, tag, msg);
        }
    }

    public static void d(String tag, String msg, Object toSerialize) {
        if (loggingEnabled) {
            d(tag, String.format(msg, new List<String>{
                    safeSerialize(toSerialize)
            }));
        }
    }

    public static void d(String tag, String msg, Object toSerialize1, Object toSerialize2) {
        if (loggingEnabled) {
            d(tag, String.format(msg, new List<String>{
                    safeSerialize(toSerialize1), safeSerialize(toSerialize2)
            }));
        }
    }

    public static void d(String tag, String msg, Object toSerialize1, Object toSerialize2, Object toSerialize3) {
        if (loggingEnabled) {
            d(tag, String.format(msg, new List<String>{
                    safeSerialize(toSerialize1),
                    safeSerialize(toSerialize2),
                    safeSerialize(toSerialize3)
            })
            );
        }
    }

    public static void d(String tag, String msg, Object toSerialize1, Object toSerialize2, Object toSerialize3,
            Object toSerialize4) {
        if (loggingEnabled) {
            d(tag, String.format(msg, new List<String>{
                    safeSerialize(toSerialize1),
                    safeSerialize(toSerialize2),
                    safeSerialize(toSerialize3),
                    safeSerialize(toSerialize4)
            })
            );
        }
    }

    public static void d(String tag, String msg, Object toSerialize1, Object toSerialize2, Object toSerialize3,
            Object toSerialize4, Object toSerialize5) {
        if (loggingEnabled) {
            d(tag, String.format(msg, new List<String>{
                    safeSerialize(toSerialize1),
                    safeSerialize(toSerialize2),
                    safeSerialize(toSerialize3),
                    safeSerialize(toSerialize4),
                    safeSerialize(toSerialize5)
            })
            );
        }
    }

    /**
     * Stage your message for outputting in the debug console.
     * Example: Log.debug('this will stage your message for console output');
     * @param  tag         A short string indicating the system component from which the message originates (for example, "View" for the view system).
     * @param  msg         The log message
     */
    public static void i(String tag, String msg) {
        if (loggingEnabled) {
            logToSystemDebug(LoggingLevel.INFO, tag, msg);
        }
    }

    public static void i(String tag, String msg, Object toSerialize) {
        if (loggingEnabled) {
            i(tag, String.format(msg, new List<String>{
                    safeSerialize(toSerialize)
            }));
        }
    }

    public static void i(String tag, String msg, Object toSerialize1, Object toSerialize2) {
        if (loggingEnabled) {
            i(tag, String.format(msg, new List<String>{
                    safeSerialize(toSerialize1), safeSerialize(toSerialize2)
            }));
        }
    }

    public static void i(String tag, String msg, Object toSerialize1, Object toSerialize2, Object toSerialize3) {
        if (loggingEnabled) {
            i(tag, String.format(msg, new List<String>{
                    safeSerialize(toSerialize1),
                    safeSerialize(toSerialize2),
                    safeSerialize(toSerialize3)
            })
            );
        }
    }

    public static void i(String tag, String msg, Object toSerialize1, Object toSerialize2, Object toSerialize3,
            Object toSerialize4) {
        if (loggingEnabled) {
            i(tag, String.format(msg, new List<String>{
                    safeSerialize(toSerialize1),
                    safeSerialize(toSerialize2),
                    safeSerialize(toSerialize3),
                    safeSerialize(toSerialize4)
            })
            );
        }
    }

    public static void i(String tag, String msg, Object toSerialize1, Object toSerialize2, Object toSerialize3,
            Object toSerialize4, Object toSerialize5) {
        if (loggingEnabled) {
            i(tag, String.format(msg, new List<String>{
                    safeSerialize(toSerialize1),
                    safeSerialize(toSerialize2),
                    safeSerialize(toSerialize3),
                    safeSerialize(toSerialize4),
                    safeSerialize(toSerialize5)
            })
            );
        }
    }

    public static void w(String tag, String msg) {
        if (loggingEnabled) {
            logToSystemDebug(LoggingLevel.WARN, tag, msg);
        }
    }

    public static void w(String tag, String msg, Object toSerialize) {
        if (loggingEnabled) {
            logToSystemDebug(LoggingLevel.WARN, tag, String.format(msg, new List<String>{
                    safeSerialize(toSerialize)
            }));
        }
    }

    public static void w(String tag, String msg, Object toSerialize1, Object toSerialize2) {
        if (loggingEnabled) {
            logToSystemDebug(LoggingLevel.WARN, tag, String.format(msg, new List<String>{
                    safeSerialize(toSerialize1),
                    safeSerialize(toSerialize2)
            }));
        }
    }

    public static void e(String tag, String msg) {
        if (loggingEnabled) {
            logToSystemDebug(LoggingLevel.ERROR, tag, msg);
        }
    }

    public static void e(String tag, String msg, Object toSerialize) {
        if (loggingEnabled) {
            logToSystemDebug(LoggingLevel.ERROR, tag, String.format(msg, new List<String>{safeSerialize(toSerialize)}));
        }
    }

    public static void e(String tag, String msg, Object toSerialize1, Object toSerialize2) {
        if (loggingEnabled) {
            logToSystemDebug(LoggingLevel.ERROR, tag, String.format(msg, new List<String>{safeSerialize(toSerialize1), safeSerialize(toSerialize2)}));
        }
    }

    public static void e(String tag, String msg, Exception e) {
        if (loggingEnabled) {
            e(tag, msg + ' ' + exceptionToString(e));
        }
    }

    public static void e(String tag, String msg, Object toSerialize, Exception e) {
        if (loggingEnabled) {
            e(tag, String.format(msg, new List<String>{safeSerialize(toSerialize)}) + ' ' + exceptionToString(e));
        }
    }

    /**
     * If logging is enabled serializes given arguments
     * @param message The log message
     */
    public static void post(String tag, String message) {
        logToChatter(tag, message);
    }

    /**
     * If logging is enabled serializes given arguments
     * @param message The log message
     */
    public static void postAndEmail(String tag, String message) {
        logToChatterAndEmail(tag, message);
    }

    /**
     * If logging is enabled serializes given arguments
     * @param tag Tag indicating source of message
     * @param message The log message with {0} placeholders
     * @param toSerialize The object to serialize and include in the message in {0} position
     */
    public static void postAndEmail(String tag, String message, Object toSerialize) {
        logToChatterAndEmail(tag, String.format(message, new List<String>{
                safeSerialize(toSerialize)
        }));
    }

    /**
     * If logging is enabled serializes given arguments
     * @param tag Tag indicating source of message
     * @param message The log message with {0} placeholders
     * @param toSerialize The object to serialize and include in the message in {0} position
     * @param toSerialize2 The object to serialize and include in the message in {1} position
     */
    public static void postAndEmail(String tag, String message, Object toSerialize, Object toSerialize2) {
        logToChatterAndEmail(tag, String.format(message, new List<String>{
                safeSerialize(toSerialize),
                safeSerialize(toSerialize2)
        }));
    }

    private static String addTag(String tag, String message) {
        return tag + TAG_SEPARATOR + message;
    }

    private static void logToSystemDebug(LoggingLevel level, String tag, String message) {
        String taggedMessage = addTag(tag, message);
        System.debug(level, taggedMessage);
    }

    private static void logToChatter(String tag, String message) {
        logToSystemDebug(LoggingLevel.ERROR, tag, 'LOGGING TO CHATTER: ' + message);
        messagesByLogLevel.get(LOG_LEVEL_CHATTER).add(addTag(tag, message));
        //TODO: agnostic implementation
    }

    private static void logToEmail(String tag, String message) {
        logToSystemDebug(LoggingLevel.ERROR, tag, 'LOGGING TO EMAIL: ' + message);
        messagesByLogLevel.get(LOG_LEVEL_EMAIL).add(addTag(tag, message));
        //TODO: agnostic implementation
    }

    /**
     * Stage your message for outputting in the debug console and Chatter (group id is stored in a custom setting)
     * and for sending an email (user ids are stored in a custom setting). Use this in managed packages.
     * Example: Log.postAndEmail('this will stage your message for console and chatter and for sending an email');
     * @param message      A message that needs to be in the debug console, Chatter an be sent in an email
     */
    private static void logToChatterAndEmail(String tag, String message) {
        logToChatter(tag, message);
        logToEmail(tag, message);
    }

    private static String exceptionToString(Exception e) {
        return 'Exception message: ' + e.getMessage() + '; Exception stacktrace: ' + e.getStackTraceString();
    }

    private static Map<Integer, List<String>> getNewMessagesByLogLevel() {
        return new Map<Integer, List<String>> {
                LOG_LEVEL_CHATTER => new List<String>(),
                LOG_LEVEL_EMAIL => new List<String>()
        };
    }

    @TestVisible
    private static String safeSerialize(Object objToSerialize) {
        if (hideRecordData || (hideRecordDataForTest && Test.isRunningTest())) {
            if (objToSerialize instanceof List<Object>) {
                String ret = '(';
                for (Object obj : (List<Object>) objToSerialize) {
                    ret += safeSerialize(obj) + ', ';
                }
                ret = ret.removeEnd(', ');
                ret += ')';
                return ret;
            } else if (objToSerialize instanceof Set<String> || objToSerialize instanceof Set<Id>) {
                // debug common sets that do not contain sensitive info
                return String.valueOf(objToSerialize);
            } else if (objToSerialize instanceof Map<Id, Object>) {
                // debug common map
                String ret = '{';
                Map<Id, Object> temp = (Map<Id, Object>) objToSerialize;
                for (Id key : temp.keySet()) {
                    ret += key + '=' + safeSerialize(temp.get(key)) + ', ';
                }
                ret = ret.removeEnd(', ');
                ret += '}';
                return ret;
            } else if (objToSerialize instanceof Map<String, Object>) {
                // debug common map
                String ret = '{';
                Map<String, Object> temp = (Map<String, Object>) objToSerialize;
                for (String key : temp.keySet()) {
                    ret += key + '=' + safeSerialize(temp.get(key)) + ', ';
                }
                ret = ret.removeEnd(', ');
                ret += '}';
                return ret;
            } else if (isMapOrSet(objToSerialize)) {
                // instanceof Map<Object, Object>/Set<Object> returns false for comparisons that should be true
                // and casting any map to a generic map breaks during runtime. Can't iterate on a generic map or a set
                // unless we build a custom string parser for this specific use case
                return '{ a map/set of something }';
            } else if (objToSerialize instanceof SObject) {
                return serializeVisitor.accept((SObject) objToSerialize);
            }
        }
        // default objects (dates, strings etc) won't be caught by more specific logic
        // so we can just serialize them
        return String.valueOf(objToSerialize);
    }

    private class SafeSerializeVisitor {
        public String accept(SObject record) {
            return serializeIdAndType(record);
        }

        private String serializeIdAndType(SObject objToSerialize) {
            return '{Type=' + objToSerialize.getSObjectType() + ', Id=' + objToSerialize.Id + '}';
        }
    }


    /**
     * Hacky implementation needed because of buggy behaviour of instanceof
     * i.e.
     * Map<String, String> instanceof Map<Object, Object> is false, which is wrong.
     * We'll have to use this until salesforce figures out their generics
     *
     * @param obj any object
     *
     * @return true if object is a map or a set of something
     */
    private static Boolean isMapOrSet(Object obj) {
        if (obj == null || obj == '')
            return false;

        String str = String.valueOf(obj);
        String firstCharacter = str.substring(0, 1);
        String lastCharacter = str.substring(str.length() - 1, str.length());
        return !(obj instanceof String) && '{'.equals(firstCharacter) && '}'.equals(lastCharacter);
    }
}