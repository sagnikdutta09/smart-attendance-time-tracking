public with sharing class EmployeeService {
    public static void createAttendanceRecord(List<Employee__c> newRecords){
        if(newRecords.isEmpty()){
            return;
        }
        List<Attendance__c> createdAttendances = new List<Attendance__c>();
        for(Employee__c emp: newRecords){
                Attendance__c newatn = new Attendance__c(
                    Employee__c = emp.Id,
                    Weekly_Attendance__c = 0,
                    Monthly_Attendance__c = 0,
                    Yearly_Attendance__c = 0
                );
                createdAttendances.add(newatn);
        }
        if(!createdAttendances.isEmpty()){
            insert createdAttendances;
        }
    }
}