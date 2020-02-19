/**
 *  @description Ability to create a dynamic query
 *  @author      Graham Barnard, Traction on Demand.
 *  @date        2016-02-18
 */
 public with sharing class TLQueryBuilder {
    public final static String FIELD_SEPERATOR = ', ';

    public final static String AND_OPERATOR = 'AND';
    public final static String OR_OPERATOR = 'OR';

    public final static String EQUALS_OPERATOR = '=';
    public final static String NOT_EQUALS_OPERATOR = '!=';
    public final static String LIKE_OPERATOR = 'LIKE';

    public final static String LESS_THAN_OPERATOR = '<';
    public final static String GREATER_THAN_OPERATOR = '>';
    public final static String LESS_THAN_OR_EQUAL_OPERATOR = '<=';
    public final static String GREATER_THAN_OR_EQUAL_OPERATOR = '>=';

    private final static String EXCEPTION_MISSING_OBJECT_FIELD = 'Object must be set';
    private final static String EXCEPTION_OPERATOR = 'Conditions don\'t have an OR or AND operator';

    private final static String NUMBER_TYPE = 'TypeNumber';
    private final static String BOOLEAN_TYPE = 'TypeBoolean';

    private String objectName;
    private Integer queryLimit;
    private List<String> fields;
    public BaseOperator baseOperator;

    public TLQueryBuilder() {
        baseOperator = new BaseOperator();
        fields = new List<String>();
    }

    public void setLimit(Integer queryLimit) {
        this.queryLimit = queryLimit;
    }

    public void setFields(List<String> fields) {
        this.fields = fields;
    }

    public void setObject(String objectName) {
        this.objectName = objectName;
    }

    public void setLogicalOperator(String operator) {
        this.baseOperator.setLogicalOperator(operator);
    }

    public String build() {
        if(objectName == null) throw new TLQueryBuilderException(EXCEPTION_MISSING_OBJECT_FIELD);

        String queryString = 'SELECT ' + buildFieldString() + ' FROM ' + objectName;
        if(baseOperator.conditions.size() > 0 || baseOperator.operators.size() > 0) {
            queryString += ' WHERE ' + baseOperator.build();
        }

        if(queryLimit != null) {
            queryString += ' LIMIT ' +  queryLimit;
        }

        return queryString;
    }

    public String buildFieldString() {
        if(fields.size() == 0) return 'Id';
        return String.join(fields, FIELD_SEPERATOR);
    }

    public virtual class Operator {
        private Boolean isTopLevel;
        private String logicalOperator;
        private List<Condition> conditions;
        private List<Operator> operators;

        public Operator() {
            isTopLevel = false;
            conditions = new List<Condition>();
            operators = new List<Operator>();
        }

        public void setLogicalOperator(String logicalOperator) {
            this.logicalOperator = logicalOperator;
        }

        public String build() {
            List<String> conditionStrings = new List<String>();
            for(Condition condition : conditions) {
                conditionStrings.add(condition.build());
            }

            for(Operator operator : operators) {
                conditionStrings.add(operator.build());
            }

            if(logicalOperator == null && conditionStrings.size() > 1) throw new TLQueryBuilderException(EXCEPTION_MISSING_OBJECT_FIELD);
            if(isTopLevel) {
                return String.join(conditionStrings, ' ' + logicalOperator + ' ');
            }
            else {
                return '(' + String.join(conditionStrings, ' ' + logicalOperator + ' ') + ')';
            }
        }

        public void addCondition(Condition condition) {
            this.conditions.add(condition);
        }

        public void addConditions(List<Condition> conditions) {
            this.conditions.addAll(conditions);
        }

        public void addOperator(Operator operator) {
            this.operators.add(operator);
        }

        public void addOperators(List<Operator> operators) {
            this.operators.addAll(operators);
        }
    }

    public class BaseOperator extends Operator {
        public BaseOperator() {
            super();
            isTopLevel = true;
        }
    }

    public class AndOperator extends Operator {
        public AndOperator() {
            super();
            logicalOperator = AND_OPERATOR;
        }
    }

    public class OrOperator extends Operator {
        public OrOperator() {
            super();
            logicalOperator = OR_OPERATOR;
        }
    }

    public class Condition {
        private String field;
        private String operator;
        private String value;
        private String type;

        public Condition(String field, String operator, String value) {
            this.field = field;
            this.operator = operator;
            this.value = value;
        }

        public Condition(String field, String operator, String value, String type) {
            this.field = field;
            this.operator = operator;
            this.value = value;
            this.type = type;
        }

        public String build() {
            String conditionString = '';
            if(this.operator == EQUALS_OPERATOR || this.operator == NOT_EQUALS_OPERATOR || this.operator == LIKE_OPERATOR
            || this.operator == LESS_THAN_OPERATOR || this.operator == GREATER_THAN_OPERATOR || this.operator == LESS_THAN_OR_EQUAL_OPERATOR 
            || this.operator == GREATER_THAN_OR_EQUAL_OPERATOR) {
                if (type == NUMBER_TYPE || type == BOOLEAN_TYPE) {
                    conditionString = this.field + ' ' + this.operator + ' ' + this.value;
                }
                else {
                    conditionString = this.field + ' ' + this.operator + ' \'' + this.value + '\'';
                }
            }
            return conditionString;
        }
    }
}