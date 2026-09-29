public with sharing class AttendanceAutoCheckoutScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        List<Attendance_Log__c> atnLog = new List<Attendance_Log__c>();
        Date today = Date.today();
        Datetime tenHoursAgo = System.now().addHours(-10);
        atnLog = [
            SELECT Id, Check_In__c, Check_Out__c
            FROM Attendance_Log__c
            WHERE Attendance_Date__c = :today
            AND Check_Out__c = NULL
            AND Check_In__c <= :tenHoursAgo
        ];
        if(atnLog.isEmpty()){return;}
        for(Attendance_Log__c logIndex: atnLog){
            logIndex.Check_Out__c = logIndex.Check_In__c.addHours(10);
        }
        update atnLog;
    }
}