public class AccountRepCodeSharing {
    
	public static boolean manualUserRepCodeChangeShare(String sAction, Map<ID,Rep_Code_User__c> rcOldMaps, Map<ID,Rep_Code_User__c> rcNewMaps){ 
	   // Create new sharing object for the custom object Job.
	   List<AccountShare> acctShares = new List<AccountShare>();
	   List<Account_Rep_Code__c> arcs = new List<Account_Rep_Code__c>();
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
		   
		   arcs = [Select ID, Account__c,Rep_Code__c from Account_Rep_Code__c where Rep_Code__c in :oldRCIDs ];
		   Set<ID> acctIDs = new Set<ID>();
		   
		   
		   for (Account_Rep_Code__c arc:arcs) {
			   acctIDs.add(arc.Account__c);
			   //oldUserIDs.add(rcOldMaps.get(arc.Rep_Code__c).User__c);
			   
		   }
		   
		   //find old sharings
		   List<AccountShare> ashs = [SELECT ID, AccountId, UserOrGroupId from AccountShare where AccountId  IN: acctIDs 
									   AND UserOrGroupId IN :oldUserIDs	AND RowCause = 'Manual'];
		   
			////////1. Remove sharings for old users, old rep code master, but same accounts   
		   for (AccountShare ash:ashs) {
			   for (Account_Rep_Code__c arc:arcs) {
				   
				   system.debug ('deleting old ---' + ash.AccountId + '@' + arc.Rep_Code__c + '@@' + ash.UserOrGroupId) ;
						   
						   if (ash.AccountId== arc.Account__c && mOldRC_User.get(arc.Rep_Code__c).contains(String.valueOf(ash.UserOrGroupId))  )  {
							   acctShares.add(ash);
						   }
			   
			   }			
			   
		   }
		
			  
			if (acctShares.size() >0) 
			{
				Database.DeleteResult[] srs = Database.delete(acctShares,false);
				system.debug('sharing deletion result - ' + srs);
			   
			   //call other methods to delete sharings for related objects
			   //a. Financial Account
			   //relatedFinancialAccountChangeShare('Delete',acctShares);
			   relatedObjectsAccountChangeShare('Delete',acctShares);
			   
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
		   
	  arcs = [Select ID, Rep_Code__c, Account__c from Account_Rep_Code__c where Rep_Code__c in :newRCIDs AND Active__c = TRUE];
	  system.debug('adding sharing - ' + newRCIDs + '!@@#' + arcs);
	  
	 for (Account_Rep_Code__c rec : arcs) {  
		 for (Rep_Code_User__c rcu:rcNewMaps.values()) {
			 
		   if  (rec.Rep_Code__c == rcu.Rep_Code_Master__c && rcu.Active__c) {
			   AccountShare actSh  = new AccountShare();
  
			 // Set the ID of record being shared.
			 actSh.AccountId = rec.Account__c;
			  // Set the ID of user or group being granted access.
			 actSh.UserOrGroupId = rcu.User__c;
			   
			 // Set the access level.
			 actSh.AccountAccessLevel = 'Edit';
			   
			 // Set rowCause to 'manual' for manual sharing.
			 // This line can be omitted as 'manual' is the default value for sharing objects.
			 actSh.RowCause = 'Manual';
			 
			  //Set the portal user Id to share the accounts with
			   actSh.OpportunityAccessLevel = 'Edit';
			   actSh.CaseAccessLevel = 'Edit';
			   
			   acctShares.add(actSh);

			   }  
			 
		 }	
		
	 }
  
	  system.debug('to be added - ' + acctShares);
	   if (acctShares.size()>0) 
	   {
		   Database.SaveResult[] srs = Database.insert(acctShares,false);	 
		   system.debug(srs);
		   //call other methods to add sharings for related objects
		   //a. Financial Account
		   //relatedFinancialAccountChangeShare('Adding',acctShares);
		   relatedObjectsAccountChangeShare('Adding',acctShares);
	   }
	 return true;
  }	
  
  public static boolean manualAccountRepCodeChangeShare(String sAction, Map<ID,Account_Rep_Code__c> arcOlds, Map<ID,Account_Rep_Code__c> arcNews){
	 // Create new sharing object for the custom object Job.
	 List<AccountShare> acctShares = new List<AccountShare>();
	 List<Rep_Code_User__c> arcs = new List<Rep_Code_User__c>(); 
	 
	 if (sAction =='Update') { 
		   Set<ID> oldAcctIDs = new Set<ID>();
		   Set<ID> oldRCIDs = new Set<ID>();
		   Map<ID,String> mOldAccount_RC = new Map<ID,String>();
					   
		   for (Account_Rep_Code__c arc:arcOlds.values()) {
			   oldAcctIDs.add(arc.Account__c);
			   oldRCIDs.add(arc.Rep_Code__c);
			   
			   //create map of Rep code and list of User
			   if (mOldAccount_RC.containsKey(arc.Rep_Code__c)==false) {
				   mOldAccount_RC.put(arc.Rep_Code__c,String.valueOf(arc.Account__c));
			   }
			   else { 
				   String strtmp = mOldAccount_RC.get(arc.Rep_Code__c) + '@@@' + arc.Account__c;
				   mOldAccount_RC.put(arc.Rep_Code__c,strtmp);
				   
			   }
			   
		   }
		   
		   arcs = [Select ID,Rep_Code_Master__c,User__c from Rep_Code_User__c where Rep_Code_Master__c in :oldRCIDs ];
		   
		   Set<ID> userIDs = new Set<ID>();
		   for (Rep_Code_User__c arc:arcs) {
			   userIDs.add(arc.User__c);
			   
		   }
		   
		   
		   List<AccountShare> ashs = [SELECT ID, AccountId, UserOrGroupId from AccountShare where AccountId IN : oldAcctIDs
			   AND UserOrGroupId IN : userIDs AND RowCause = 'Manual'];	
	 
			////////1. Remove sharings for old accounts, old rep code master, but same users   
		   for (AccountShare ash:ashs)  {
			   for (Rep_Code_User__c arc:arcs) {
				   
				   system.debug ('deleting old ---' + ash.AccountId + '@' + arc.Rep_Code_Master__c + '@@' + ash.UserOrGroupId) ;
						   
						   if (ash.UserOrGroupId== arc.User__c && mOldAccount_RC.get(arc.Rep_Code_Master__c).contains(String.valueOf(ash.AccountId))  )  {
							   acctShares.add(ash);
						   }
			   
			   }			
				   
			   
		   }
		
			if (acctShares.size()>0) 
			{
			   Database.DeleteResult[] srs = Database.delete(acctShares,false); 
			   //call other methods to delete sharings for related objects
			   //a. Financial Account
			   //relatedFinancialAccountChangeShare('Delete',acctShares);
			   relatedObjectsAccountChangeShare('Delete',acctShares);
			}
	  
	 } 
	 
	   
	  ////////////2. add new sharings
	  acctShares.clear();
	  Set<ID> newRCIDs = new Set<ID>(); 
	   
	   for (Account_Rep_Code__c rcu:arcNews.values()) {
		   if (rcu.Active__c) newRCIDs.add(rcu.Rep_Code__c);
		   
	   }
		   
	  arcs = [Select ID, Rep_Code_Master__c, User__c from Rep_Code_User__c where Rep_Code_Master__c in :newRCIDs AND Active__c = TRUE];
	  
	  for (Rep_Code_User__c rec : arcs) {  
		 for (Account_Rep_Code__c rcu:arcNews.values())  {
			 
		   if  (rec.Rep_Code_Master__c == rcu.Rep_Code__c && rcu.Active__c) {
			   AccountShare actSh  = new AccountShare();
  
			 // Set the ID of record being shared.
			 actSh.AccountId = rcu.Account__c;
			  // Set the ID of user or group being granted access.
			 actSh.UserOrGroupId = rec.User__c;
			   
			 // Set the access level.
			 actSh.AccountAccessLevel = 'Edit';
			   
			 // Set rowCause to 'manual' for manual sharing.
			 // This line can be omitted as 'manual' is the default value for sharing objects.
			 actSh.RowCause = 'Manual';
			 
			  //Set the portal user Id to share the accounts with
			   actSh.OpportunityAccessLevel = 'Edit';
			   actSh.CaseAccessLevel = 'Edit';
			   
			   acctShares.add(actSh);

			   }  
			 
		 }	
		
	 }
  
  
	system.debug('here to added - ' + acctShares);
	   if (acctShares.size()>0) 
	   {
		   Database.SaveResult[] srs = Database.insert(acctShares,false);
		   system.debug(srs);
		   //call other methods to add sharings for related objects
		   //a. Financial Account
		   //relatedFinancialAccountChangeShare('Adding',acctShares);
		   relatedObjectsAccountChangeShare('Adding',acctShares);

	   }
			 
	return true;  
		  
  }
  
  /*
  public static boolean relatedFinancialAccountChangeShare(String sAction, List<AccountShare> lAccountShares){ 
	   list<FinServ__FinancialAccount__Share> lFAccountShares = new list<FinServ__FinancialAccount__Share>();
	   list<FinServ__FinancialAccount__c>  lFAccounts = new list<FinServ__FinancialAccount__c>();
	   Set<ID> acctIDs = new set<ID>();
	   Set<ID> userIDs = new set<ID>();
	   for (AccountShare rcu:lAccountShares) {
			   acctIDs.add(rcu.AccountId);
			   userIDs.add(rcu.UserOrGroupId);
	   }
	   
	   lFAccounts = [SELECT Id, FinServ__Household__c FROM FinServ__FinancialAccount__c
						   where FinServ__Household__c IN :acctIDs];
	   
	   if (sAction =='Delete') { //remove sharing
		   lFAccountShares = [SELECT Id, UserOrGroupId, ParentId, RowCause FROM FinServ__FinancialAccount__Share where UserOrGroupId IN :userIDs
							   AND ParentId in :lFAccounts and RowCause='Manual'];
							   
		   if (lFAccountShares.size()>0) 
		   {
			   Database.DeleteResult[] srs = Database.delete(lFAccountShares,false); 
			   system.debug(srs);

		   }
		   
	   }
	   
	   else {  //add sharing
		   
		   for (FinServ__FinancialAccount__c rc : lFAccounts ) {
			   for (AccountShare ash: lAccountShares) {
				   
				   if (ash.AccountId == rc.FinServ__Household__c) {
					   FinServ__FinancialAccount__Share fFAShares = new FinServ__FinancialAccount__Share();
					   fFAShares.ParentId = rc.id;
					   fFAShares.UserOrGroupId = ash.UserOrGroupId;
					   fFAShares.RowCause = 'Manual';
					   fFAShares.AccessLevel = 'Edit';
					   
					   lFAccountShares.add(fFAShares);
				   }
			   }
			   
		   }
		   
		   if (lFAccountShares.size()>0) 
		   {
			   Database.SaveResult[] srs = Database.insert(lFAccountShares,false);
			   system.debug(srs);

		   }
		   
	   }
	   return true;
  }
  */

   
public static boolean relatedObjectsAccountChangeShare(String sAction, List<AccountShare> lAccountShares) {
   list<Sharing_Configuration__c> sojSC = [select ID,Primary_Object__c, Related_Object__c, Lookup_Field_Name__c from Sharing_Configuration__c];
   List<sObject> sobjRelatedList = new List<sObject>();
   for (Sharing_Configuration__c sc:sojSC)
   {
	   List<sObject> sobjtmp = retrieveChangeShare(sAction,lAccountShares,sc.Related_Object__c,sc.Lookup_Field_Name__c) ;
	   if (sobjtmp.size()>0)  sobjRelatedList.addAll(sobjtmp);
	   
   }
   
   if (sAction =='Delete') {
	   Delete sobjRelatedList;
   }
   else {
	   
	   Insert sobjRelatedList;
   }
   
   Return true;
}


public static List<sObject> retrieveChangeShare(String sAction, List<AccountShare> lAccountShares,String strLKObject, String strLKField){ 
	list<sObject> sobjList = new list<sObject>();
	
	list<FinServ__FinancialAccount__c>  lFAccounts = new list<FinServ__FinancialAccount__c>();
	Set<ID> acctIDs = new set<ID>();
	Set<ID> userIDs = new set<ID>();
	for (AccountShare rcu:lAccountShares) {
			acctIDs.add(rcu.AccountId);
			userIDs.add(rcu.UserOrGroupId);
	}
	
	String sqlQry1 = 'SELECT Id, ' + strLKField + ' FROM ' + strLKObject + ' where ' + strLKField + ' IN :acctIDs' ;
	List<sObject> sobjRelated = Database.query(sqlQry1);	
	
	String strObjShare = strLKObject + 'Share';
	if (strLKObject.endsWith('__c')) {
		strObjShare = strLKObject.replace('__c','__Share');
	}
		
		
	if (sAction =='Delete') { //remove sharing
		String sqlQry = 'SELECT Id, UserOrGroupId, ParentId, RowCause FROM ' + strObjShare + ' where UserOrGroupId IN :userIDs AND ParentId in :sobjRelated and RowCause= \'Manual\' ' ;
		sobjList = Database.query(sqlQry);
		
		
	}
	
	else {  //add sharing
		
		for (sObject rc : sobjRelated ) {
			for (AccountShare ash: lAccountShares) {
				
				if (ash.AccountId == rc.get(strLKField)) {
					
					String objName = strObjShare;
					 
					 sObject fShares = Schema.getGlobalDescribe().get(objName).newSObject();
					 fShares.put('ParentId', rc.id) ;
					 fShares.put('UserOrGroupId', ash.UserOrGroupId) ;
					 fShares.put('RowCause', 'Manual') ;
					 fShares.put('AccessLevel', 'Edit') ;
					
					
					sobjList.add(fShares);
				}
			}
			
		}
	  
	}
	return sobjList;
}
  
}