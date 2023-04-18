trigger AccountRepCodeSharingTrigger on Account_Rep_Code__c (after insert, after update) {
    
    if(Trigger.isInsert)    {
        
        boolean result = AccountRepCodeSharing.manualAccountRepCodeChangeShare('Insert',null,Trigger.newmap);
        
    }
    else {
    //is updated   
    boolean result = AccountRepCodeSharing.manualAccountRepCodeChangeShare('Update',Trigger.Oldmap, Trigger.newmap); 
    
    }
    
}