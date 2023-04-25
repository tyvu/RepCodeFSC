trigger LeadRepCodeSharingTrigger on Lead_Rep_Code__c (after insert, after update) {
    
    if(Trigger.isInsert)    {
        
        boolean result = LeadRepCodeSharing.manualLeadRepCodeChangeShare('Insert',null,Trigger.newmap);
        
    }
    else {
    //is updated   
    boolean result = LeadRepCodeSharing.manualLeadRepCodeChangeShare('Update',Trigger.Oldmap, Trigger.newmap); 
    
    }
    
}