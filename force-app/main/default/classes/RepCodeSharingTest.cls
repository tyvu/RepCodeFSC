@IsTest
public class RepCodeSharingTest
{
    @IsTest
        public static void testRepCodeSharing(){
       
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
       System.runAs (thisUser) {
		   
		//create advisor 1	
        User u = new User();
        u.LastName = 'Advisor 1';
        u.Email = 'tyvu.test1@deloitte.ca';
        u.Alias = 'Adv1';
        u.username = 'tyvu.test1@deloitte.ca.testdata';
        u.ProfileId = [Select Id from Profile where name  like '%Advisor%' limit 1].Id;
        u.languagelocalekey = 'en_US';
        u.localesidkey = UserInfo.getLocale();
        u.emailEncodingKey = 'UTF-8';
        u.timeZoneSidKey = UserInfo.getTimezone().getID();
       
        insert u;
		
		//create advisor 2	
        User u2 = new User();
        u2.LastName = 'Advisor 2';
        u2.Email = 'tyvu.test2@deloitte.ca';
        u2.Alias = 'Adv2';
        u2.username = 'tyvu.test2@deloitte.ca.testdata';
        u2.ProfileId = [Select Id from Profile where name  like '%Advisor%' limit 1].Id;
        u2.languagelocalekey = 'en_US';
        u2.localesidkey = UserInfo.getLocale();
        u2.emailEncodingKey = 'UTF-8';
        u2.timeZoneSidKey = UserInfo.getTimezone().getID();
       
       
        insert u2;

		
		//create househould account	
		 Id recordTypeId = [Select Id From RecordType where sobjecttype = 'Account' and DeveloperName = 'IndustriesHousehold'].Id;
       Account acct = new Account();
       acct.Name = 'Test Household';
       acct.RecordTypeId = recordTypeId;
       insert acct;
                 
		//create another househould account	
		recordTypeId = [Select Id From RecordType where sobjecttype = 'Account' and DeveloperName = 'IndustriesHousehold'].Id;
		Account acct1 = new Account();
		acct1.Name = 'Test Household 2';
		acct1.RecordTypeId = recordTypeId;
		insert acct1;

		//create person account		 
       recordTypeId = [Select Id From RecordType where sobjecttype = 'Account' and DeveloperName = 'PersonAccount'].Id;
       Account acct2 = new Account();
       acct2.LastName = 'Test Person Account 1';
       acct2.RecordTypeId = recordTypeId;
       insert acct2;
      
	   
	    //add relationship household and person account
		Id ctid = [SELECT Id, AccountId, IsPersonAccount FROM Contact where AccountID = :acct2.ID and IsPersonAccount = TRUE Limit 1].id;
		AccountContactRelation acr = new AccountContactRelation();
		acr.AccountId = acct1.ID;
		acr.ContactId = ctid;
		acr.FinServ__Primary__c = true;
		acr.Roles = 'Client';
		acr.FinServ__Rollups__c = 'Financial Accounts';
		acr.IsActive = true;
		acr.FinServ__Primary__c = true;
		acr.FinServ__PrimaryGroup__c = true;
		
		insert acr;
		
		
		//create financial account relating to person account
		recordTypeId = [Select Id From RecordType where sobjecttype = 'FinServ__FinancialAccount__c' and DeveloperName = 'InvestmentAccount'].Id;
		FinServ__FinancialAccount__c facct1 = new FinServ__FinancialAccount__c();
		facct1.Name = 'Investment Account - test 1';
		facct1.FinServ__PrimaryOwner__c = acct2.ID;
		facct1.RecordTypeId = recordTypeId;
		insert facct1;
		
		
		//create rep code master
		Rep_Code_Master__c rcm1 = new Rep_Code_Master__c();
		rcm1.Name = 'REP CODE 1 TEST';
		insert rcm1;
		
		Rep_Code_Master__c rcm2 = new Rep_Code_Master__c();
		rcm2.Name = 'REP CODE 2 TEST';
		insert rcm2;

		//create rep code master
		Rep_Code_Master__c rcm3 = new Rep_Code_Master__c();
		rcm3.Name = 'REP CODE 3 TEST';
		insert rcm3;
		
		Rep_Code_Master__c rcm4 = new Rep_Code_Master__c();
		rcm4.Name = 'REP CODE 4 TEST';
		insert rcm4;
		
		//insert lead
		Lead ld = new Lead(LastName = 'Test Lead',FinServ__ReferredByContact__c =ctid, Company = 'Test Lead', Email = 'test@abc.com', 
		Rep_Code__c=rcm1.ID );
		insert ld;


		//insert sharing configuration
		Sharing_Configuration__c scf = new Sharing_Configuration__c(Primary_Object__c='Account',Related_Object__c='Lead',
		Lookup_Field_Name__c = 'FinServ__Household__c' ,Active__c = true);
		insert scf;

		scf = new Sharing_Configuration__c(Primary_Object__c='Account',Related_Object__c='AccountContactRelation',
		Lookup_Field_Name__c = 'AccountId' ,Active__c = true);

		insert scf ;

		//start testing
        Test.startTest();
        try{        	
       		//create rep code - account
			Account_Rep_Code__c arc = new Account_Rep_Code__c(Rep_Code__c = rcm1.ID,Account__c = acct1.id, Active__c=true);
			INSERT arc;

			//create rep code - financial account
			Financial_Account_RepCode__c facr = new Financial_Account_RepCode__c(Rep_Code__c = rcm2.ID,Financial_Account__c = facct1.ID,Active__c=true);
			insert facr;
			
			//update rep code - financial account
			facr.Rep_Code__c = rcm1.ID;
			update facr;

			//insert lead -rep code
			Lead_Rep_Code__c lr1 = new Lead_Rep_Code__c (Lead__c = ld.id, Rep_Code__c = rcm1.ID, Active__c = TRUE);
			insert lr1;

			//update lead - rep code
			lr1.Rep_Code__c = rcm2.ID;
			update lr1;

			//create rep code - user   and test for account - repcode - user
			Rep_Code_User__c rcu = new Rep_Code_User__c(Rep_Code_Master__c = rcm1.ID, User__c = u.ID, 	Active__c = true);	
			insert rcu;

			//update rep code - user
			rcu.Rep_Code_Master__c=rcm2.ID;
			update rcu;
			
			//create rep code - user   and test for financial account - repcode - user
			Rep_Code_User__c rcu2 = new Rep_Code_User__c(Rep_Code_Master__c = rcm2.ID, User__c = u2.ID, 	Active__c = true);	
			insert rcu2;

			//update rep code - account
			arc.Rep_Code__c = rcm2.ID;
			arc.Account__c = acct.ID;
			update arc;

			
			//insert lead -rep code
			Lead_Rep_Code__c lr3 = new Lead_Rep_Code__c (Lead__c = ld.id, Rep_Code__c = rcm1.ID, Active__c = TRUE);
			insert lr3;

			//update lead - rep code
			lr3.Rep_Code__c = rcm2.ID;
			update lr3;

        }
        
        catch(exception e){}   
        Test.stopTest();   
      }
}
    


}