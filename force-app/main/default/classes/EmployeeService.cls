public with sharing class EmployeeService {
    public static void createAttendanceRecord(List<Employee__c> newRecords){
        if(newRecords.isEmpty()){
            return;
        }
        List<Attendance__c> createdAttendances = new List<Attendance__c>();
        for(Employee__c emp: newRecords){
            Attendance__c newatn = new Attendance__c(
                Employee__c = emp.Id,
            Weekly_Attendance__c = 100,
            Monthly_Attendance__c = 100,
            Yearly_Attendance__c = 100
                );
            createdAttendances.add(newatn);
        }
        if(!createdAttendances.isEmpty()){
            insert createdAttendances;
        }
    }
    public static void updateEmployeeAssignment(List<Employee__c> newRecords, Map<Id, Employee__c> oldMap) {
        if (newRecords.isEmpty()) {
            return;
        }
        
        List<Employee_Assignment__c> newAssignments = new List<Employee_Assignment__c>();List<Employee_Assignment__c> updatedAssignments = new List<Employee_Assignment__c>();
        
        Set<Id> employeeIds = new Set<Id>();
        
        for (Employee__c emp : newRecords) {
            
            Employee__c oldEmp = oldMap.get(emp.Id);
            
            if (emp.Manager__c != oldEmp.Manager__c) {
                
                employeeIds.add(emp.Id);
                
                if (emp.Manager__c != null) {
                    Employee_Assignment__c assignment =
                        new Employee_Assignment__c(
                        Employee__c = emp.Id,
                    Manager__c = emp.Manager__c,
                    Start_Date__c = Date.today()
                        );
                    
                    newAssignments.add(assignment);
                }
            }
        }
        
        for (Employee_Assignment__c assignment : [
        SELECT Id
        FROM Employee_Assignment__c
        WHERE Employee__c IN :employeeIds
        AND End_Date__c = NULL
    ]) {
            assignment.End_Date__c = Date.today();
            updatedAssignments.add(assignment);
        }
        
        if (!newAssignments.isEmpty()) {
            insert newAssignments;
        }
        
        if (!updatedAssignments.isEmpty()) {
            update updatedAssignments;
        }
    }
}