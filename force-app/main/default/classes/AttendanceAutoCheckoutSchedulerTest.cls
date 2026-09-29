@isTest
public with sharing class AttendanceAutoCheckoutSchedulerTest {
    @isTest
    static void executeTest(){
        Attendance_Log__c log = new Attendance_Log__c(
            Attendance_Date__c = Date.today(),
        Check_In__c = System.now().addHours(-11),
        Employee__c = 'a05ak00000iJZ0sAAG'
            );
        insert log;
        
        Test.startTest();
        System.schedule('Test Auto Checkout', '0 0 12 * * ?',  new AttendanceAutoCheckoutScheduler()); 
        Test.stopTest();
        Attendance_Log__c insertedLog = [
            SELECT Check_Out__c
            FROM Attendance_Log__c
        ];
        System.assert(insertedLog.Check_Out__c!=null);
        System.assertEquals(insertedLog.Check_In__c.addHours(10),insertedLog.Check_Out__c);
    }
}