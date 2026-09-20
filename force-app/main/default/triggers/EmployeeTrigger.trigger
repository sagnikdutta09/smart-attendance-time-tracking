trigger EmployeeTrigger on Employee__c (after insert) {
    EmployeeTriggerHandler handler = new EmployeeTriggerHandler();
    if(Trigger.isAfter && Trigger.isInsert){
        handler.afterInsert(Trigger.new);
    }
}