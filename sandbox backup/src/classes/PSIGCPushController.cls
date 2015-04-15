public with sharing class PSIGCPushController {
    
    public String responseJSON;
    public String strLeadPickLists;

    public List<Case> Cases 										= new List<Case>();
    public List<Case> NeedtoUpdateCases								= new List<Case>();
    public Map<String, List<String>> strPropertySources 			= new Map<String, List<String>>();
    public Map<String, Map<String, String>> IntegrationsCredentialsPerAccount = new Map<String, Map<String, String>>();

    public PSIGCPushController() {
    }
    
    public List<Case> pushGuestCards() {

        for( Case cs : Cases ) {
            this.getLeadPickLists( IntegrationsCredentialsPerAccount.get( cs.AccountId ).get( 'PSIUserName' ), IntegrationsCredentialsPerAccount.get( cs.AccountId ).get( 'PSIPassword' ), '', IntegrationsCredentialsPerAccount.get( cs.AccountId ).get( 'PSIAPIUrl' ) );
        }

        return NeedtoUpdateCases;
    }

    public void getLeadPickLists( String Username, String Password, String PropertyId, String PSI_API_URL ) {
        
        JSONGenerator JSONrequest = JSON.createGenerator(true); 
        JSONrequest.writeStartObject();
            JSONrequest.writeFieldName('auth');
                JSONrequest.writeStartObject();
                JSONrequest.writeStringField( 'type', 'basic');
                JSONrequest.writeStringField( 'password', Password );
                JSONrequest.writeStringField( 'username', Username );
            JSONrequest.writeEndObject();
            JSONrequest.writeNumberField( 'requestId' , 15 );   
            JSONrequest.writeFieldName('method');
            JSONrequest.writeStartObject();
                
        		JSONrequest.writeStringField( 'name', 'getLeadPickLists');
                JSONrequest.writeFieldName( 'params' );
                JSONrequest.writeStartObject();
                    JSONrequest.writeStringField( 'propertyIds', PropertyId );
                    
               JSONrequest.writeEndObject();
            JSONrequest.writeEndObject();
        JSONrequest.writeEndObject();
        
        Http httpPro = new Http();
        HttpRequest request = new HttpRequest();
        
        request.setEndPoint( PSI_API_URL + '/leads' );
        request.setMethod( 'POST' );
        request.setHeader( 'Content-Type', 'application/json' );
        request.setBody( JSONrequest.getAsString() );
        request.setTimeout( 120000 );
        if( ! Test.isRunningTest() ) {
			HTTPResponse res = httpPro.send(request);
        	strLeadPickLists = res.getBody();            
        }

        if( null != strLeadPickLists ) {
            Map<String, Object> JSONdeserializedResponse = (Map<String, Object>) JSON.deserializeUntyped( strLeadPickLists );
            if( JSONdeserializedResponse.containsKey( 'response' ) ) {
              	JSONdeserializedResponse = ( Map<String, Object> ) JSONdeserializedResponse.get('response');
                if( JSONdeserializedResponse.containsKey( 'result' ) ) {
                   	JSONdeserializedResponse = ( Map<String, Object> ) JSONdeserializedResponse.get('result');	
                    if( JSONdeserializedResponse.containsKey( 'Property' ) ) {
                     	JSONdeserializedResponse = ( Map<String, Object> ) JSONdeserializedResponse.get('Property');
                        
                        for( String strKey : JSONdeserializedResponse.keySet() ) {
                            Map<String, Object> JSONPropertyResponse = ( Map<String, Object> ) JSONdeserializedResponse.get( strKey );
                            
                            if( JSONPropertyResponse.containsKey( 'LeadSources' ) ) {
                                JSONPropertyResponse = ( Map<String, Object> ) JSONPropertyResponse.get( 'LeadSources' );
                                
                                if( JSONPropertyResponse.containsKey( 'LeadSource' ) ) {
                                    List<Object> JSONLeadSourcesList = ( List<Object> ) JSONPropertyResponse.get( 'LeadSource' );
                                    
                                    if( !JSONLeadSourcesList.isEmpty() ) {
                                        List<String> LeadSourcesList = new List<String>();
                                        
                                        for( Object objLeadSource : JSONLeadSourcesList ) {
                                            Map<String, Object> LeadSourceElements = ( Map<String, Object> ) objLeadSource;
                                            LeadSourceElements = ( Map<String, Object> ) LeadSourceElements.get( '@attributes' );
                                            LeadSourcesList.add( ( String ) LeadSourceElements.get( 'name' ) );
                                        }
                                        
                                        strPropertySources.put( strKey, LeadSourcesList );
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}