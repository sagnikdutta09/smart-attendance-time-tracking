public with sharing class attendanceController {
    @AuraEnabled
    public static Employee__c getCurrentEmployee(Id userId) {
        List<Employee__c> employees = [
            SELECT Id, Name, 
            Employee_User__c FROM Employee__c 
            WHERE Employee_User__c = :userId LIMIT 1];
        
        if(!employees.isEmpty()){
            return employees[0];
        }else{
            return null;
        }
    }
    @AuraEnabled
    public static Attendance__c getCurrentEmployeeAttendance(Id employeeId){
        List<Attendance__c> attendanceList = [
            SELECT Id, Monthly_Attendance__c, Weekly_Attendance__c, Yearly_Attendance__c
            FROM Attendance__c
            WHERE Employee__c = :employeeId LIMIT 1];
        
        if(!attendanceList.isEmpty()){
            return attendanceList[0];
        }else{
            return null;
        }
    }
    
    @AuraEnabled
    public static void checkIn(Id userId) {
        if(userId==null){return;}
        Employee__c checkedInEmp = getCurrentEmployee(userId);
        if(checkedInEmp!=null){
            createTodaysAttendanceLog(checkedInEmp.Id);
        }
    }
    
    public static void createTodaysAttendanceLog(Id empId){
        List<Attendance_Log__c> attnlog = [
            SELECT Id, Check_In__c FROM
            Attendance_Log__c WHERE
            Employee__c = :empId AND
            Attendance_Date__c = :Date.today()
        ];
        List<Attendance_Log__c> createdLogs = new List<Attendance_Log__c>();
        if(attnlog.isEmpty()){
            Attendance_Log__c log = new Attendance_Log__c(
            Employee__c = empId,
            Attendance_Date__c = Date.today(),
            Check_In__c = System.now());
            
            createdLogs.add(log);
        }
        
        if(!createdLogs.isEmpty()){
            insert createdLogs;
        }
    }
    @AuraEnabled
    public static Attendance_Log__c getTodaysLog(Id userId){
        Date today = Date.Today();
        Employee__c emp = getCurrentEmployee(userId);
        Attendance_Log__c atnLog = [SELECT Id, Attendance_Date__c, Employee__c, Check_In__c 
        FROM Attendance_Log__c WHERE 
        Attendance_Date__c=  :today
        AND Employee__c = :emp.Id
        ORDER BY CreatedDate DESC
        LIMIT 1];
        return atnLog;
    }

    @AuraEnabled
    public static Datetime checkOut(Id userId){
        if(userId==null){return null;}
        Employee__c checkedOutEmp = getCurrentEmployee(userId);
        if(checkedOutEmp!=null){
            return updateCheckOutTime(checkedOutEmp.Id);
        }else{
            return null;
        }
    }
    
    public static Datetime updateCheckOutTime(Id empId){
        List<Attendance_Log__c> attnlog = [
            SELECT Id, Check_In__c, Check_Out__c FROM
            Attendance_Log__c WHERE
            Employee__c = :empId AND
            Attendance_Date__c = :Date.today()
            LIMIT 1
        ];
        if(!attnlog.isEmpty() && 
        attnlog[0].Check_In__c!=null && 
        attnlog[0].Check_Out__c==null){
            attnlog[0].Check_Out__c=System.now();
            update attnlog;
            return attnlog[0].Check_Out__c;
        }else{
            return null;
        }
    }

    @AuraEnabled
    public static Boolean doesLogExist(Id userId){
        Employee__c emp = getCurrentEmployee(userId);
        Date today=Date.today();
        Integer count = 
        [SELECT COUNT()
        FROM Attendance_Log__c
        WHERE Employee__c = :emp.Id
        AND Attendance_Date__c = :today];

        return count>0;
    }

    @AuraEnabled
    public static Boolean hasUserCheckedOut(Id userId){
        Employee__c emp = getCurrentEmployee(userId);
        Date today=Date.today();
        Attendance_Log__c atnLog = [SELECT Check_In__c, Check_Out__c FROM Attendance_Log__c
        WHERE Employee__c = :emp.Id
        AND Attendance_Date__c = :today
        LIMIT 1
        ];
        return atnLog.Check_Out__c!=null;
    }
}