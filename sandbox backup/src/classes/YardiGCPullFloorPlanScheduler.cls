global class YardiGCPullFloorPlanScheduler implements Schedulable {
	Integer intervalMinutes;
    
    public YardiGCPullFloorPlanScheduler() {
        this.intervalMinutes = 5;
    }
    
    public YardiGCPullFloorPlanScheduler(Integer intervalMinutes) {
  		this.intervalMinutes = intervalMinutes;
   	}
    
    global void execute(SchedulableContext sc) {
        Id SchedulerId, jobId;
        String cronString;
        DateTime now  = DateTime.now();
        try {
            // Re-schedule ourself to run again in "intervalMinutes" time
            if ([SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND Status = 'Holding' ] < 100 && [SELECT count() FROM AsyncApexJob WHERE JobType = 'BatchApex' AND  Status = 'Holding' AND ApexClass.Name = 'YardiGCPullFloorPlanBatch'] <= 5 ){ 
                DateTime nextRunTime = now.addMinutes(intervalMinutes);
                cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + nextRunTime.month() + ' ? ' + nextRunTime.year(); 
                
                SchedulerId = System.schedule( YardiGCPullFloorPlanScheduler.class.getName() + '-' + now.format(), cronString, new YardiGCPullFloorPlanScheduler(this.intervalMinutes) );
                
                YardiGCPullFloorPlanBatch objBatch = new YardiGCPullFloorPlanBatch();
                Database.executeBatch(objBatch, 50);
                
            } else {
                //schedule this same schedulable class again in 3 mins
                DateTime nextRunTime = now.addMinutes(3);
                cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + nextRunTime.month() + ' ? ' + nextRunTime.year(); 
                
                SchedulerId = System.schedule( YardiGCPullFloorPlanScheduler.class.getName() + '-' + now.format(), cronString, new YardiGCPullFloorPlanScheduler(this.intervalMinutes) );
                
            }
            
            jobId = sc.getTriggerId();
            System.abortJob(jobId);
            
            if( Test.isRunningTest() ) {
                Account a = new Account();
                insert a;
            }
        } catch ( Exception e ) {
            System.Debug( e.getMessage() );
            System.Debug( e.getStackTraceString() );
            
            String strSubject = 'YardiGCPullFloorPlanScheduler ' + DateTime.now() + ' Error';
            List<String> sendTo = new List<String>();
            sendTo.add('vivek.shah@anyonehome.com');
            
            List<String> ccTo = new List<String>();
            ccTo.add('mitch@anyonehome.com');
            ccTo.add('jaime@anyonehome.com');
            ccTo.add('mahek.joshipura@anyonehome.com');
            
            String ReplyTo = '';
            String SenderDisplayName = 'AnyoneHome Integration Team';
            String body = 'ErrorMessage: <b><I>' + e.getMessage() + '</i></b><br>';
            body += 'StackStrace: <b><I>' + e.getStackTraceString() + '</i></b><br>';
            
            try{ 
                if( null != SchedulerId ) {
                    System.abortJob(SchedulerId);
                }       
                if( null == jobId ) {
                    jobId = sc.getTriggerId();
                    System.abortJob(jobId);
                }
                
                SendIntegrationFailureEmailsController emailObject = new SendIntegrationFailureEmailsController();
                emailObject.doSendEmail( strSubject, body, sendTo, ReplyTo, ccTo, SenderDisplayName );
                
            } catch ( Exception e2 ) {
                System.Debug( e2.getMessage() );
                System.Debug( e2.getStackTraceString() );
            }
            
            DateTime nextRunTime2 = now.addMinutes(3);
            cronString = '' + nextRunTime2.second() + ' ' + nextRunTime2.minute() + ' ' + nextRunTime2.hour() + ' ' + nextRunTime2.day() + ' ' + nextRunTime2.month() + ' ? ' + nextRunTime2.year(); 
            
            System.schedule( YardiGCPullFloorPlanScheduler.class.getName() + '-' + now.format(), cronString, new YardiGCPullFloorPlanScheduler(this.intervalMinutes) );
        }
    }
}