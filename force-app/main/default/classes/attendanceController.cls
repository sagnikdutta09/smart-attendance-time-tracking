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
    public static void checkIn() {
        Id userId = UserInfo.getUserId();
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
            Database.insert(createdLogs, AccessLevel.SYSTEM_MODE);
        }
    }
    @AuraEnabled
    public static Attendance_Log__c getTodaysLog(Id userId){
        Date today = Date.Today();
        Employee__c emp = getCurrentEmployee(userId);
        Attendance_Log__c atnLog = [SELECT Id, Attendance_Date__c, Employee__c, Check_In__c, Check_Out__c
        FROM Attendance_Log__c WHERE 
        Attendance_Date__c=  :today
        AND Employee__c = :emp.Id
        ORDER BY CreatedDate DESC
        LIMIT 1];
        return atnLog;
    }
    
    @AuraEnabled
    public static Datetime checkOut(){
        Id userId = UserInfo.getUserId();
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
            Database.update(attnlog, AccessLevel.SYSTEM_MODE) ;
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
    
    @AuraEnabled
    public static List<Attendance_Log__c> getCurrentEmployeeAttendanceLog(){
        Id userId = UserInfo.getUserId();
        Employee__c emp = getCurrentEmployee(userId);
        return [
            SELECT Id, Attendance_Date__c, Check_In__c, Check_Out__c, Work_Hours__c, Attendance_Status__c
            FROM Attendance_Log__c
            WHERE Employee__c  = :emp.Id
        ];
    }
    
    private static Decimal calculateAttendance(Date startDate, Date endDate, Id userId){
        AggregateResult presentResult = [
        SELECT COUNT(Id) present
        FROM Attendance_Log__c
        WHERE Attendance_Date__c >= :startDate
        AND Attendance_Date__c <= :endDate
        AND Employee__r.Employee_User__c = :userId
        AND Attendance_Status__c = 'Present'
        ];
        Integer present = (Integer) presentResult.get('present');
        Integer total=0;
        
        for (Date currentDate = startDate; currentDate <= endDate; currentDate = currentDate.addDays(1)) {
            
            Date weekStart = currentDate.toStartOfWeek();
            Integer dayOffset = weekStart.daysBetween(currentDate);
            
            if (dayOffset >= 1 && dayOffset <= 5) {
                total++;
            }
        }
        
        if (total == 0) {
            return 100;
        }
        
        return (((Decimal) present / total) * 100).setScale(2);
    }
    
    @AuraEnabled(cacheable=true)
    public static Decimal getWeeklyAttendance(){
        Date today = Date.today();
        return calculateAttendance(today.toStartOfWeek(),today,UserInfo.getUserId());
    }
    
    @AuraEnabled(cacheable=true)
    public static Decimal getMonthlyAttendance(){
        Date today = Date.today();
        return calculateAttendance(today.toStartOfMonth(),today,UserInfo.getUserId());
    }
    
    @AuraEnabled(cacheable=true)
    public static Decimal getYearlyAttendance(){
        Date today = Date.today();
        Date yearStart = Date.newInstance(today.year(), 1, 1);
        return calculateAttendance(yearStart, today, UserInfo.getUserId());
    }
}