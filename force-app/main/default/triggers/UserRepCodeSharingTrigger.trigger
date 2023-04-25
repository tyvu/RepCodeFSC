trigger UserRepCodeSharingTrigger on Rep_Code_User__c (after insert, after update) {

    if(Trigger.isInsert)  {
        //List<ID> newIDs = new List<ID>(Trigger.newmap.keyset());
        //for AccountShare 
       // boolean result = AccountRepCodeSharing.manualUserRepCodeChangeShare('Insert',null,Trigger.newmap);
       //for Financial account share  
       boolean result = FinancialAccountRepCodeSharing.manualUserRepCodeChangeShare('Insert',null,Trigger.newmap);

        //for Lead share
         result = LeadRepCodeSharing.manualUserRepCodeChangeShare('Insert',Trigger.oldmap, Trigger.newmap);

       
        
    }
    else {
    //is updated   
      
       // boolean result = AccountRepCodeSharing.manualUserRepCodeChangeShare('Update',Trigger.oldmap, Trigger.newmap); 
       //for Financial Account share 
       boolean result = FinancialAccountRepCodeSharing.manualUserRepCodeChangeShare('Update',Trigger.oldmap, Trigger.newmap); 

       //for Lead share
        result = LeadRepCodeSharing.manualUserRepCodeChangeShare('Update',Trigger.oldmap, Trigger.newmap);
    
    }
}