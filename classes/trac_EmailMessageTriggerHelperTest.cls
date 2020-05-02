/**
* @description Test Class for trac_EmailMessageTriggerHelper
* @author      Piyush Bansal, Traction on Demand
* @date        2019-12-12
*/
@isTest
public with sharing class trac_EmailMessageTriggerHelperTest {
    
    final static TLTestFactory factory = new TLTestFactory();
    @TestSetup
    static void testSetup(){ 
        List<Case> newCasesList=new List<Case>();
        Closed_Case_Email_Handler_Settings__c closedCaseEmailHandlerSettings = new Closed_Case_Email_Handler_Settings__c(
            Hours_Since_Closed_External__c = -10,
            Fields_to_clone__c = 'Description, AccountId, ContactId, ContactEmail, Subject, Case_Type__c, Category__c, Subcategory__c, RecordTypeId, OwnerId, Business_Unit__c'
        );
        insert closedCaseEmailHandlerSettings;
        Case tempCase = (Case)factory.createSObject(new Case(
            Subject = 'Subject Test',
            Description = 'testing',
            SuppliedEmail='test@abc.org',
            Status ='New',
            Priority = 'Medium',
            Business_Unit__c = 'MHF',
            RecordTypeId =TLSObj.getRecordTypeIdForName(Case.SObjectType, trac_CaseConstants.RECORD_TYPE_DEVNAME_SAKS),
            Origin = 'Web'), false);
        
        newCasesList = (List<Case>)factory.createSObjects(tempCase, 4, true);
       /* for(Case parentCase : newCasesList){
            parentCase.Case_Steward__c=parentCase.OwnerId;
            parentCase.Keep_Ownership__c=true;
            // parentCase.Status='Closed';
        }
        update newCasesList;*/
    }
    @istest
    static void insertEmailMessageTest(){
        List<Case> newCasesList = [SELECT Id,Status,OwnerId,Keep_Ownership__c,Business_Unit__c,SuppliedEmail,Subject,Description,Case_Steward__c FROM Case];
        List<EmailMessage> newEmailList=new List<EmailMessage>();
        for(Case parentCase:newCasesList){
            EmailMessage email = (EmailMessage)factory.createSObject(new EmailMessage(Incoming = true), false);
            email.FromAddress = parentCase.SuppliedEmail;
            email.ToAddress= parentCase.Id+'test@xyz.org';
            email.Subject = parentCase.Subject;
            email.HtmlBody = parentCase.Description;
            email.ParentId = parentCase.Id;
            newEmailList.add(email);
        }
        
        Test.startTest();
        insert newEmailList;
        Test.stopTest();
        System.assertEquals(8, [SELECT Id FROM EmailMessage].size());
    }
    
    /**
* Test that when a email message is sent to a closed case
* a new case is a created and email message is re-parented
*/
    @IsTest static void test_closed_case() {
        List<Case> newCasesList = [SELECT Id,Status,Business_Unit__c,SuppliedEmail,Subject,Description FROM Case];
        for(case cse : newCasesList){
            cse.status='Closed';
        }
        update newCasesList;
        EmailMessage testMsg = (EmailMessage)factory.createSObject(new EmailMessage(Incoming = true, ParentId=newCasesList[0].Id), false);
        testMsg.FromAddress = 'test@test.com';
        testMsg.toAddress = 'test@test.com';
        Test.startTest();
        insert testMsg;
        Test.stopTest();
        
        List<Case> resultCase = [SELECT Id,IsClosed FROM Case];
        List<EmailMessage> resultMsg= [SELECT Id, ParentId FROM EmailMessage WHERE Id =:testMsg.Id];
        
        System.assertEquals(newCasesList.size()+1, resultCase.size(), 'A new case should be created.');
        System.assertNotEquals(newCasesList[0].Id, resultMsg[0].ParentId, 'The Email message should be re-parented to the new case');
    }
    
    /**
*  @description Uses custom setting to specify a time that a case needs to be closed for before making a new one
*  @author      Jeremy Horan, Traction on Demand.
*  @date        4/30/2018
*/
    @IsTest static void test_closedCaseWithSetting() {  
        List<Case> newCasesList = [SELECT Id,Status,Business_Unit__c,SuppliedEmail,Subject,Description FROM Case];
        for(case cse : newCasesList){
            cse.status='Closed';
        }
        update newCasesList;
        EmailMessage testMsg = (EmailMessage)factory.createSObject(new EmailMessage(Incoming = true, HtmlBody = 'Test', ParentId = newCasesList[0].Id), false);
        testMsg.FromAddress = 'test@test.com';
        testMsg.toAddress = 'test@test.com';
        Test.startTest();
        insert testMsg;
        Test.stopTest();
        
        List<Case> resultCase = [SELECT Id,IsClosed FROM Case];
        List<EmailMessage> resultMsg= [SELECT Id, ParentId FROM EmailMessage WHERE Id =:testMsg.Id];
        
        System.assertEquals(newCasesList.size()+1, resultCase.size(), 'A new case should be created.');
        System.assertNotEquals(newCasesList[0].Id, resultMsg[0].ParentId, 'The Email message should be re-parented to the new case');
    }
    
    /**
*  @description Uses custom setting to specify a time that a case needs to be closed for before making a new one
*               Shouldn't reparent if the case hasn't been closed long enough
*  @author      Jeremy Horan, Traction on Demand.
*  @date        4/30/2018
*/
    @IsTest static void test_closedCaseWithSettingNoReparent() {
        
        List<Case> newCasesList = [SELECT Id,Status,Business_Unit__c,SuppliedEmail,Subject,Description FROM Case];
        for(case cse : newCasesList){
            cse.status='Closed';
        }
        update newCasesList;
        EmailMessage testMsg = (EmailMessage)factory.createSObject(new EmailMessage(Incoming = true, ParentId = newCasesList[0].Id), false);
        testMsg.FromAddress = 'test@test.com';
        testMsg.toAddress = 'test@test.com';
        Test.startTest();
        insert testMsg;
        Test.stopTest();
        
        List<Case> resultCase = [SELECT Id FROM Case];
        List<EmailMessage> resultMsg= [SELECT Id, ParentId FROM EmailMessage WHERE Id =:testMsg.Id];
        
        System.assertEquals(newCasesList.size()+1, resultCase.size());
    }
    
    /**
* Test that when a email message is sent to a new case
* no new case is created
*/
    @IsTest static void test_new_case() {
        
        List<Case> newCasesList = [SELECT Id,Status,Business_Unit__c,SuppliedEmail,Subject,Description FROM Case];
        EmailMessage testMsg = (EmailMessage)factory.createSObject(new EmailMessage(Incoming = true, ParentId = newCasesList[0].Id), false);
        testMsg.FromAddress = 'test@test.com';
        testMsg.HtmlBody='test';
        testMsg.toAddress = 'test@test.com';
        Test.startTest();
        insert testMsg;
        Test.stopTest();
        
        List<Case> resultCase = [SELECT Id FROM Case WHERE Status= 'New'];
        List<EmailMessage> resultMsg= [SELECT Id, ParentId FROM EmailMessage WHERE Id =:testMsg.Id];
        
        System.assertEquals(newCasesList.size(), resultCase.size(), 'A new case should not be created.');
    }
}