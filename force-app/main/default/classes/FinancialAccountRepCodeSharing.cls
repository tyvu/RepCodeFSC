public with sharing class FinancialAccountRepCodeSharing {
    public static boolean manualUserRepCodeChangeShare(String sAction, Map<ID,Rep_Code_User__c> rcOldMaps, Map<ID,Rep_Code_User__c> rcNewMaps){ 
		// Update sharings for the lookup Financial Accounts
		List<FinServ__FinancialAccount__Share> facctShares = new List<FinServ__FinancialAccount__Share>();
		List<Financial_Account_RepCode__c> farcs = new List<Financial_Account_RepCode__c>();
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
			
            farcs = [Select ID, Financial_Account__c,Rep_Code__c from Financial_Account_RepCode__c where Rep_Code__c in :oldRCIDs ];
			Set<ID> facctIDs = new Set<ID>();
			
			
			for (Financial_Account_RepCode__c arc:farcs) {
				facctIDs.add(arc.Financial_Account__c);
				//oldUserIDs.add(rcOldMaps.get(arc.Rep_Code__c).User__c);
				
			}
			
			//find old sharings
			List<FinServ__FinancialAccount__Share> ashs = [SELECT ID, ParentID, UserOrGroupId from FinServ__FinancialAccount__Share where ParentID  IN: facctIDs 
										AND UserOrGroupId IN :oldUserIDs	AND RowCause = 'Manual'];
			
			 ////////1. Remove sharings for old users, old rep code master, but same accounts   
			for (FinServ__FinancialAccount__Share ash:ashs) {
				for (Financial_Account_RepCode__c arc:farcs) {
					
					system.debug ('deleting old ---' + ash.ParentID + '@' + arc.Rep_Code__c + '@@' + ash.UserOrGroupId) ;
							
							if (ash.ParentID== arc.Financial_Account__c && mOldRC_User.get(arc.Rep_Code__c).contains(String.valueOf(ash.UserOrGroupId))  )  {
								facctShares.add(ash);
							}
				
				}			
                
			}
		 
           	
			 if (facctShares.size() >0) 
             {
                 Database.DeleteResult[] srs = Database.delete(facctShares,false);
			 	system.debug('sharing deletion result - ' + srs);
				
				//call other methods to delete sharings for related objects
				//a. Financial Account
				relatedAccountChangeShare('Delete',facctShares);
				
             }
		
		} 
		
		
	   ////////////2. add new sharings
	   facctShares.clear();
	   Set<ID> newRCIDs = new Set<ID>(); 
		Set<ID> newUserIDs = new Set<ID>();
		for (Rep_Code_User__c rcu:rcNewMaps.values()) {
			//only adding sharing rules if new records are active
			if (rcu.Active__c) {
				newRCIDs.add(rcu.Rep_Code_Master__c);
				newUserIDs.add(rcu.User__c);
			}
		}
			
	   farcs = [Select ID, Rep_Code__c, Financial_Account__c from Financial_Account_RepCode__c where Rep_Code__c in :newRCIDs AND Active__c = TRUE];
	   system.debug('adding sharing - ' + newRCIDs + '!@@#' + farcs);
	   
	  for (Financial_Account_RepCode__c rec : farcs) {  
		  for (Rep_Code_User__c rcu:rcNewMaps.values()) {
			  
			if  (rec.Rep_Code__c == rcu.Rep_Code_Master__c && rcu.Active__c) {
				FinServ__FinancialAccount__Share actSh  = new FinServ__FinancialAccount__Share();
   
			  // Set the ID of record being shared.
			  actSh.ParentID = rec.Financial_Account__c;
			   // Set the ID of user or group being granted access.
			  actSh.UserOrGroupId = rcu.User__c;
				
			  // Set the access level.
			  actSh.AccessLevel = 'Edit';
				
			  // Set rowCause to 'manual' for manual sharing.
			  // This line can be omitted as 'manual' is the default value for sharing objects.
			  actSh.RowCause = 'Manual';
			  facctShares.add(actSh);

				}  
			  
		  }	
		 
	  }
   
	   system.debug('to be added - ' + facctShares);
		if (facctShares.size()>0) 
        {
            Database.SaveResult[] srs = Database.insert(facctShares,false);	 
			system.debug(srs);
			//call other methods to add sharings for related objects
			//a. Account
			relatedAccountChangeShare('Adding',facctShares);
        }
      return true;
   }
   
   
    public static boolean manualFinancialAccountRepCodeChangeShare(String sAction, Map<ID,Financial_Account_RepCode__c> arcOlds, Map<ID,Financial_Account_RepCode__c> arcNews){
 // Create new sharing object for the custom object.
 List<FinServ__FinancialAccount__Share> facctShares = new List<FinServ__FinancialAccount__Share>();
 List<Rep_Code_User__c> arcs = new List<Rep_Code_User__c>(); 
 
 if (sAction =='Update') { 
       Set<ID> oldFAcctIDs = new Set<ID>();
       Set<ID> oldRCIDs = new Set<ID>();
       Map<ID,String> mOldFAccount_RC = new Map<ID,String>();
                   
       for (Financial_Account_RepCode__c arc:arcOlds.values()) {
           oldFAcctIDs.add(arc.Financial_Account__c);
           oldRCIDs.add(arc.Rep_Code__c);
           
           //create map of Rep code and list of User
           if (mOldFAccount_RC.containsKey(arc.Rep_Code__c)==false) {
               mOldFAccount_RC.put(arc.Rep_Code__c,String.valueOf(arc.Financial_Account__c));
           }
           else { 
               String strtmp = mOldFAccount_RC.get(arc.Rep_Code__c) + '@@@' + arc.Financial_Account__c;
               mOldFAccount_RC.put(arc.Rep_Code__c,strtmp);
               
           }
           
       }
       
       arcs = [Select ID,Rep_Code_Master__c,User__c from Rep_Code_User__c where Rep_Code_Master__c in :oldRCIDs ];
       
       Set<ID> userIDs = new Set<ID>();
       for (Rep_Code_User__c arc:arcs) {
           userIDs.add(arc.User__c);
           
       }
       
       
       List<FinServ__FinancialAccount__Share> ashs = [SELECT ID, ParentID, UserOrGroupId from FinServ__FinancialAccount__Share where ParentID IN : oldFAcctIDs
           AND UserOrGroupId IN : userIDs AND RowCause = 'Manual'];	
 
        ////////1. Remove sharings for old Financial accounts, old rep code master, but same users   
       for (FinServ__FinancialAccount__Share ash:ashs)  {
           for (Rep_Code_User__c arc:arcs) {
               
               system.debug ('deleting old ---' + ash.ParentID + '@' + arc.Rep_Code_Master__c + '@@' + ash.UserOrGroupId) ;
                       
                       if (ash.UserOrGroupId== arc.User__c && mOldFAccount_RC.get(arc.Rep_Code_Master__c).contains(String.valueOf(ash.ParentID))  )  {
                           facctShares.add(ash);
                       }
           
           }			
               
           
       }
    
        if (facctShares.size()>0) 
        {
           Database.DeleteResult[] srs = Database.delete(facctShares,false); 
           //call other methods to delete sharings for related objects
           //a.  Account
           relatedAccountChangeShare('Delete',facctShares);
        }
  
 } 
 
   
  ////////////2. add new sharings
  facctShares.clear();
  Set<ID> newRCIDs = new Set<ID>(); 
   
   for (Financial_Account_RepCode__c rcu:arcNews.values()) {
       if (rcu.Active__c) newRCIDs.add(rcu.Rep_Code__c);
       
   }
       
  arcs = [Select ID, Rep_Code_Master__c, User__c from Rep_Code_User__c where Rep_Code_Master__c in :newRCIDs AND Active__c = TRUE];
  
  for (Rep_Code_User__c rec : arcs) {  
     for (Financial_Account_RepCode__c rcu:arcNews.values())  {
         
       if  (rec.Rep_Code_Master__c == rcu.Rep_Code__c && rcu.Active__c) {
           FinServ__FinancialAccount__Share actSh  = new FinServ__FinancialAccount__Share();

         // Set the ID of record being shared.
         actSh.ParentID = rcu.Financial_Account__c;
          // Set the ID of user or group being granted access.
         actSh.UserOrGroupId = rec.User__c;
           
         // Set the access level.
         actSh.AccessLevel = 'Edit';
           
         // Set rowCause to 'manual' for manual sharing.
         // This line can be omitted as 'manual' is the default value for sharing objects.
         actSh.RowCause = 'Manual';
         
          
           facctShares.add(actSh);

           }  
         
     }	
    
 }


system.debug('here to added - ' + facctShares);
   if (facctShares.size()>0) 
   {
       Database.SaveResult[] srs = Database.insert(facctShares,false);
       system.debug(srs);
       //call other methods to add sharings for related objects
       //a.  Account
       relatedAccountChangeShare('Adding',facctShares);

   }
         
return true;  
      
}

public static boolean relatedAccountChangeShare(String sAction, List<FinServ__FinancialAccount__Share> lFinancialAccountShares){ 
   list<AccountShare> lAccountShares = new list<AccountShare>();
   list<Account>  lAccounts = new list<Account>();
   list<FinServ__FinancialAccount__c>  lFAccounts = new list<FinServ__FinancialAccount__c>();
   Set<ID> facctIDs = new set<ID>();
   Set<ID> acctIDs = new set<ID>();
   Set<ID> userIDs = new set<ID>();
   for (FinServ__FinancialAccount__Share rcu:lFinancialAccountShares) {
           userIDs.add(rcu.UserOrGroupId);
           facctIDs.add(rcu.ParentID);
   }
   
   //20230419 tyvu - add field  FinServ__Household__c + FinServ__PrimaryOwner__c
   lFAccounts = [SELECT Id, FinServ__PrimaryOwner__c, FinServ__Household__c FROM FinServ__FinancialAccount__c
                       where ID IN :facctIDs];
   
   for (FinServ__FinancialAccount__c ffa:lFAccounts) {
       acctIDs.add(ffa.FinServ__PrimaryOwner__c);
       if (ffa.FinServ__Household__c != NUll) acctIDs.add(ffa.FinServ__Household__c);
   }	
   
   if (sAction =='Delete') { //remove sharing
       lAccountShares = [SELECT Id, UserOrGroupId, AccountID, RowCause FROM AccountShare where UserOrGroupId IN :userIDs
                           AND AccountID in :acctIDs and RowCause='Manual'];
                           
       if (lAccountShares.size()>0) 
       {
           Database.DeleteResult[] srs = Database.delete(lAccountShares,false); 
           system.debug(srs);

           //20230419 tyvu - remove sharings for related objects, except Financial Account
           AccountRepCodeSharing.relatedObjectsAccountChangeShare('Delete',lAccountShares,FALSE);
       }
       
   }
   
   else {  //add sharing
       
       for (FinServ__FinancialAccount__c rc : lFAccounts ) {
           for (FinServ__FinancialAccount__Share ash: lFinancialAccountShares) {
               
               if (ash.ParentID == rc.ID) {
                   AccountShare fAShares = new AccountShare();
                   //20230419 tyvu - add field FinServ__Household__c + FinServ__PrimaryOwner__c
                   fAShares.AccountID = rc.FinServ__PrimaryOwner__c;
                   fAShares.UserOrGroupId = ash.UserOrGroupId;
                   fAShares.RowCause = 'Manual';
                   fAShares.AccountAccessLevel = 'Edit';
                   fAShares.OpportunityAccessLevel = 'Edit';
                   fAShares.CaseAccessLevel = 'Edit';
                   
                   //for primary owner
                   lAccountShares.add(fAShares);
                   
                   fAShares = new AccountShare(); 
                   fAShares.AccountID = rc.FinServ__Household__c;
                   fAShares.UserOrGroupId = ash.UserOrGroupId;
                   fAShares.RowCause = 'Manual';
                   fAShares.AccountAccessLevel = 'Edit';
                   fAShares.OpportunityAccessLevel = 'Edit';
                   fAShares.CaseAccessLevel = 'Edit';
                   
                   //for household
                   lAccountShares.add(fAShares);


               }
           }
           
       }
       
       if (lAccountShares.size()>0) 
       {
           Database.SaveResult[] srs = Database.insert(lAccountShares,false);
           system.debug(srs);
           //20230419 tyvu - add sharings for related objects, except Financial Account
           AccountRepCodeSharing.relatedObjectsAccountChangeShare('Adding',lAccountShares,FALSE);

       }
       
   }
   return true;
    } 
}