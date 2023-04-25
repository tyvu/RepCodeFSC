public with sharing class LeadRepCodeSharing {

    
	public static boolean manualUserRepCodeChangeShare(String sAction, Map<ID,Rep_Code_User__c> rcOldMaps, Map<ID,Rep_Code_User__c> rcNewMaps){ 
        // Create/update new sharing object for Lead and related objects
        List<LeadShare> acctShares = new List<LeadShare>();
        List<Lead_Rep_Code__c> arcs = new List<Lead_Rep_Code__c>();
        if (sAction =='Update') { 
             // List<ID> oldRCIDs = new List<ID>(rcOldMaps.keyset());
            Set<ID> oldRCIDs = new Set<ID>(); 
            Set<ID> oldUserIDs = new Set<ID>();
            Map<ID,String> mOldRC_User = new Map<ID,String>();
            
            for (Rep_Code_User__c rcu:rcOldMaps.values()) {
                oldRCIDs.add(rcu.Rep_Code_Master__c);
                oldUserIDs.add(rcu.User__c);
                
                //create map of Rep code and list of User
                if (mOldRC_User.containsKey(rcu.Rep_Code_Master__c)==false) {
                    mOldRC_User.put(rcu.Rep_Code_Master__c,String.valueOf(rcu.User__c));
                }
                else { 
                    String strtmp = mOldRC_User.get(rcu.Rep_Code_Master__c) + '@@@' + rcu.User__c;
                    mOldRC_User.put(rcu.Rep_Code_Master__c,strtmp);
                    
                }
            }
            
            arcs = [Select ID, Lead__c,Rep_Code__c from Lead_Rep_Code__c where Rep_Code__c in :oldRCIDs ];
            Set<ID> acctIDs = new Set<ID>();
            
            
            for (Lead_Rep_Code__c arc:arcs) {
                acctIDs.add(arc.Lead__c);
                //oldUserIDs.add(rcOldMaps.get(arc.Rep_Code__c).User__c);
                
            }
            
            //find old sharings
            List<LeadShare> ashs = [SELECT ID, LeadId, UserOrGroupId from LeadShare where LeadId  IN: acctIDs 
                                        AND UserOrGroupId IN :oldUserIDs	AND RowCause = 'Manual'];
            
             ////////1. Remove sharings for old users, old rep code master, but same Leads   
            for (LeadShare ash:ashs) {
                for (Lead_Rep_Code__c arc:arcs) {
                    
                    system.debug ('deleting old ---' + ash.LeadId + '@' + arc.Rep_Code__c + '@@' + ash.UserOrGroupId) ;
                            
                            if (ash.LeadId== arc.Lead__c && mOldRC_User.get(arc.Rep_Code__c).contains(String.valueOf(ash.UserOrGroupId))  )  {
                                acctShares.add(ash);
                            }
                
                }			
                
            }
         
               
             if (acctShares.size() >0) 
             {
                 Database.DeleteResult[] srs = Database.delete(acctShares,false);
                 system.debug('sharing deletion result - ' + srs);
                
             }
        
        } 
        
        
       ////////////2. add new sharings
       acctShares.clear();
       Set<ID> newRCIDs = new Set<ID>(); 
        Set<ID> newUserIDs = new Set<ID>();
        for (Rep_Code_User__c rcu:rcNewMaps.values()) {
            //only adding sharing rules if new records are active
            if (rcu.Active__c) {
                newRCIDs.add(rcu.Rep_Code_Master__c);
                newUserIDs.add(rcu.User__c);
            }
        }
            
       arcs = [Select ID, Rep_Code__c, Lead__c from Lead_Rep_Code__c where Rep_Code__c in :newRCIDs AND Active__c = TRUE];
       system.debug('lead adding sharing - ' + newRCIDs + '!@@#' + arcs);
       
      for (Lead_Rep_Code__c rec : arcs) {  
          for (Rep_Code_User__c rcu:rcNewMaps.values()) {
              
            if  (rec.Rep_Code__c == rcu.Rep_Code_Master__c && rcu.Active__c) {
                LeadShare actSh  = new LeadShare();
   
              // Set the ID of record being shared.
              actSh.LeadId = rec.Lead__c;
               // Set the ID of user or group being granted access.
              actSh.UserOrGroupId = rcu.User__c;
                
              // Set the access level.
              actSh.LeadAccessLevel = 'Edit';
                
              // Set rowCause to 'manual' for manual sharing.
              // This line can be omitted as 'manual' is the default value for sharing objects.
              actSh.RowCause = 'Manual';
              
                acctShares.add(actSh);
 
                }  
              
          }	
         
      }
   
       system.debug('to be added - ' + acctShares);
        if (acctShares.size()>0) 
        {
            Database.SaveResult[] srs = Database.insert(acctShares,false);	 
            system.debug(srs);
        }
      return true;
   }	
   

    public static boolean manualLeadRepCodeChangeShare(String sAction, Map<ID,Lead_Rep_Code__c> arcOlds, Map<ID,Lead_Rep_Code__c> arcNews){
        // Create new sharing object for the custom object Job.
        List<LeadShare> acctShares = new List<LeadShare>();
        List<Rep_Code_User__c> arcs = new List<Rep_Code_User__c>(); 
        
        if (sAction =='Update') { 
              Set<ID> oldAcctIDs = new Set<ID>();
              Set<ID> oldRCIDs = new Set<ID>();
              Map<ID,String> mOldLead_RC = new Map<ID,String>();
                          
              for (Lead_Rep_Code__c arc:arcOlds.values()) {
                  oldAcctIDs.add(arc.Lead__c);
                  oldRCIDs.add(arc.Rep_Code__c);
                  
                  //create map of Rep code and list of User
                  if (mOldLead_RC.containsKey(arc.Rep_Code__c)==false) {
                      mOldLead_RC.put(arc.Rep_Code__c,String.valueOf(arc.Lead__c));
                  }
                  else { 
                      String strtmp = mOldLead_RC.get(arc.Rep_Code__c) + '@@@' + arc.Lead__c;
                      mOldLead_RC.put(arc.Rep_Code__c,strtmp);
                      
                  }
                  
              }
              
              arcs = [Select ID,Rep_Code_Master__c,User__c from Rep_Code_User__c where Rep_Code_Master__c in :oldRCIDs ];
              
              Set<ID> userIDs = new Set<ID>();
              for (Rep_Code_User__c arc:arcs) {
                  userIDs.add(arc.User__c);
                  
              }
              
              
              List<LeadShare> ashs = [SELECT ID, LeadId, UserOrGroupId from LeadShare where LeadId IN : oldAcctIDs
                  AND UserOrGroupId IN : userIDs AND RowCause = 'Manual'];	
        
               ////////1. Remove sharings for old Leads, old rep code master, but same users   
              for (LeadShare ash:ashs)  {
                  for (Rep_Code_User__c arc:arcs) {
                      
                      system.debug ('deleting old ---' + ash.LeadId + '@' + arc.Rep_Code_Master__c + '@@' + ash.UserOrGroupId) ;
                              
                              if (ash.UserOrGroupId== arc.User__c && mOldLead_RC.get(arc.Rep_Code_Master__c).contains(String.valueOf(ash.LeadId))  )  {
                                  acctShares.add(ash);
                              }
                  
                  }			
                      
                  
              }
           
               if (acctShares.size()>0) 
               {
                  Database.DeleteResult[] srs = Database.delete(acctShares,false); 
               }
         
        } 
        
          
         ////////////2. add new sharings
         acctShares.clear();
         Set<ID> newRCIDs = new Set<ID>(); 
          
          for (Lead_Rep_Code__c rcu:arcNews.values()) {
              if (rcu.Active__c) newRCIDs.add(rcu.Rep_Code__c);
              
          }
              
         arcs = [Select ID, Rep_Code_Master__c, User__c from Rep_Code_User__c where Rep_Code_Master__c in :newRCIDs AND Active__c = TRUE];
         
         for (Rep_Code_User__c rec : arcs) {  
            for (Lead_Rep_Code__c rcu:arcNews.values())  {
                
              if  (rec.Rep_Code_Master__c == rcu.Rep_Code__c && rcu.Active__c) {
                  LeadShare actSh  = new LeadShare();
     
                // Set the ID of record being shared.
                actSh.LeadId = rcu.Lead__c;
                 // Set the ID of user or group being granted access.
                actSh.UserOrGroupId = rec.User__c;
                  
                // Set the access level.
                actSh.LeadAccessLevel = 'Edit';
                  
                // Set rowCause to 'manual' for manual sharing.
                // This line can be omitted as 'manual' is the default value for sharing objects.
                actSh.RowCause = 'Manual';
                
                  acctShares.add(actSh);
   
                  }  
                
            }	
           
        }
     
     
       system.debug('here to added - ' + acctShares);
          if (acctShares.size()>0) 
          {
              Database.SaveResult[] srs = Database.insert(acctShares,false);
              system.debug(srs);
              
          }
                
       return true;  
             
     }
}