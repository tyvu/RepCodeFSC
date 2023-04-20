list<String> lObject = new list<String> {'ActionPlan','AccountContactRelation'};
list<String> str = new list<String>();
list<Sharing_Configuration__c> lsc = [SELECT ID from Sharing_Configuration__c];
//remove the old records
if (lsc.size()>0) delete lsc;

lsc.clear();
for(ChildRelationship relationship: sObjectType.Account.getChildRelationships()) {
     string objName = String.valueOf(relationship.getChildSObject()) ;
        string objField = string.valueOf(relationship.getField());

    
    if (objField.contains('FinServ__') || lObject.contains(objName)  )
    {  
        
        Sharing_Configuration__c sc = new Sharing_Configuration__c();
        sc.Primary_Object__c = 'Account';
        sc.Related_Object__c = objName;
        sc.Lookup_Field_Name__c = objField;
        
        lsc.add(sc);
    }
    
      
}
   insert lsc;