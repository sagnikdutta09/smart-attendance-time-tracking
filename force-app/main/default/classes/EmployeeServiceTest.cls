@isTest
public with sharing class EmployeeServiceTest {
    static User createNewUser(){
    return new User(
        FirstName = 'Test',
        LastName = 'Employee',
        Alias = 'tstemp',
        Email = 'testemployee@example.com',
        Username = 'testemployee' + System.currentTimeMillis() + '@example.com',
        TimeZoneSidKey = 'Asia/Kolkata',
        LocaleSidKey = 'en_IN',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id);
    }
    @isTest
    static void positiveAttendanceTest(){
        Employee__c emp = new Employee__c(
            Name = 'Test Employee'
            );
        Test.startTest();
        insert emp;
        Test.stopTest();
        Attendance__c attn = [
            SELECT Employee__c, 
            Weekly_Attendance__c, 
            Monthly_Attendance__c, 
            Yearly_Attendance__c
            FROM Attendance__c
            LIMIT 1];
        
        System.assertEquals(emp.Id, attn.Employee__c);
        System.assertEquals(0, attn.Weekly_Attendance__c);
        System.assertEquals(0, attn.Monthly_Attendance__c);
        System.assertEquals(0, attn.Yearly_Attendance__c);
    }
    @isTest
    static void noEmployeeNegativeAttendanceTest(){
        List<Employee__c> employees = new List<Employee__c>();
        EmployeeService.createAttendanceRecord(employees);
        System.assertEquals(0,[SELECT COUNT() FROM Attendance__c]);
    }
    @isTest
    static void bulkAttendanceCheck(){
        List<Employee__c> bulkEmployees = new List<Employee__c>();
        for(Integer i=0;i<200;i++){
            bulkEmployees.add(
                new Employee__c(Name='TestEmployee'+i)
                );
        }
        Test.startTest();
        insert bulkEmployees;
        Test.stopTest();
        System.assertEquals(200, [SELECT COUNT() FROM Attendance__c]);
    }
    
    @isTest
    static void attendanceControllerPositiveTest_checkIn(){
        User testUser = createNewUser();
        insert testUser;
        Employee__c testEmp = new Employee__c(
            Name='Test Emp',
            Employee_User__c=testUser.Id
        );
        insert testEmp;
        Test.startTest();
        attendanceController.checkIn(testUser.Id);
        Test.stopTest();
        List<Attendance_Log__c> attnLog = [
            SELECT Employee__c, Attendance_Date__c, Check_In__c
            FROM Attendance_Log__c
            WHERE Employee__c = :testEmp.Id
            LIMIT 1
        ];
        System.assertEquals(testEmp.Id, attnLog[0].Employee__c);
        System.assertEquals(Date.today(), attnLog[0].Attendance_Date__c);
        System.assertNotEquals(null, attnLog[0].Check_In__c);
    }
    @isTest
    static void attendanceControllerPositiveTest_checkOut(){
        User testUser = createNewUser();
        insert testUser;
        Employee__c testEmp = new Employee__c(
            Name='Test Emp',
            Employee_User__c=testUser.Id
        );
        insert testEmp;
        Attendance_Log__c empAtnLog = new Attendance_Log__c(
            Employee__c = testEmp.Id,
            Attendance_Date__c = Date.today(),
            Check_In__c = System.now().addHours(-3)
        );
        insert empAtnLog;
        Test.startTest();
        attendanceController.checkOut(testUser.Id);
        Test.stopTest();
        List<Attendance_Log__c> attnLog = [
            SELECT Check_Out__c,  Check_In__c
            FROM Attendance_Log__c
            WHERE Employee__c = :testEmp.Id
            LIMIT 1
        ];
        System.assertNotEquals(null, attnLog[0].Check_Out__c);
    }
    @isTest
    static void attendanceControllerNegativeTest_NullUser(){
        Test.startTest();
        attendanceController.checkIn(null);
        Test.stopTest();
        System.assertEquals(0, [SELECT COUNT() FROM Attendance_Log__c]);
    }
    @isTest
    static void attendanceControllerNegativeTest_NullEmp(){
        User testUser = createNewUser();        
        insert testUser;
        Test.startTest();
        attendanceController.checkIn(testUser.Id);
        Test.stopTest();
        System.assertEquals(0, [SELECT COUNT() FROM Attendance_Log__c]);
    }
}