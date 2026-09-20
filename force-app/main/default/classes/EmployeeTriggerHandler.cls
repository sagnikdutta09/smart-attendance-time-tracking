public with sharing class EmployeeTriggerHandler {
    public void afterInsert(List<Employee__c> newRecords) {
        EmployeeService.createAttendanceRecord(newRecords);
    }
}