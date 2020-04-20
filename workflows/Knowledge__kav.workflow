<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Validation_Status_Validated_Public</fullName>
        <field>ValidationStatus</field>
        <literalValue>Validated - Public</literalValue>
        <name>Set Validation Status Validated Public</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>KnowledgeArticle - Update Validation Status To Validated Public</fullName>
        <actions>
            <name>Set_Validation_Status_Validated_Public</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Knowledge__kav.IsVisibleInPkb</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Marks the article as Validated - Public if the article is set to public visible</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
