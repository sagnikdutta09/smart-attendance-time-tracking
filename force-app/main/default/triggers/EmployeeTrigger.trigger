trigger EmployeeTrigger on Employee__c (after insert, after update) {
    EmployeeTriggerHandler handler = new EmployeeTriggerHandler();
    if(Trigger.isAfter){
        if(Trigger.isInsert){
        handler.afterInsert(Trigger.new);
        }
        if(Trigger.isUpdate){
            handler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}