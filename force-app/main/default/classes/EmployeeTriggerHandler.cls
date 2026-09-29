public with sharing class EmployeeTriggerHandler {
    public void afterInsert(List<Employee__c> newRecords) {
        EmployeeService.createAttendanceRecord(newRecords);
    }

    public void afterUpdate(List<Employee__c> newRecords, Map<Id, Employee__c> oldMap){
        EmployeeService.updateEmployeeAssignment(newRecords, oldMap);
    }
}