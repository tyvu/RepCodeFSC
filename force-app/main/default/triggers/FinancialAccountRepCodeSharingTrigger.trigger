trigger FinancialAccountRepCodeSharingTrigger on Financial_Account_RepCode__c (after insert, after update) {
    
    if(Trigger.isInsert)    {
        
        boolean result = FinancialAccountRepCodeSharing.manualFinancialAccountRepCodeChangeShare('Insert',null,Trigger.newmap);
        
    }
    else {
    //is updated   
    boolean result = FinancialAccountRepCodeSharing.manualFinancialAccountRepCodeChangeShare('Update',Trigger.Oldmap, Trigger.newmap); 
    
    }
    
}