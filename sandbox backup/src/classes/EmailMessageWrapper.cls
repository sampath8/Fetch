public class EmailMessageWrapper { 
	
    public EmailMessageWrapper(String fromAddr, Id toAddrId, String sub, Map<String, String> mapSubjectParams, Map<String, String> mapBodyParams) {

		this(fromAddr, null, toAddrId, null, sub, mapSubjectParams, null, mapBodyParams );

	}
    
	public EmailMessageWrapper(String fromAddr, String toAddr, Id toAddrId, String bccAddr, String sub, Map<String, String>  mapSubjectParams, String body, Map<String, String> mapBodyParams) {

		this.FromAddress = fromAddr; 
		this.ToAddress = toAddr; 
		this.ToAddressId = toAddrId; 
		this.BccAddress = bccAddr; 
		this.Subject = sub; 
		this.ParameterSubjectMap = mapSubjectParams; 
		this.Body = body;
		this.ParameterBodyMap = mapBodyParams;

	}
    
    public String FromAddress { get; set; } 
	public String ToAddress { get; set; } 
	public Id ToAddressId { get; set; } 
	public String BccAddress { get; set; } 
	public String Subject { get; set; } 
	public Map<String, String> ParameterSubjectMap { get; set; } 
	public String Body { get; set; } 
	public Map<String, String> ParameterBodyMap { get; set; }   
    
}