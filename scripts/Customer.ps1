param(
[Parameter(Mandatory=$true)]
[string]$domainprefix,

[Parameter(Mandatory=$true)]
[string]$clientadmin,

[Parameter(Mandatory=$true)]
[string]$clientpw,

[Parameter(Mandatory=$true)]
[string]$email,

[Parameter(Mandatory=$true)]
[string]$CompanyName,

[Parameter(Mandatory=$true)]
[string]$First,

[Parameter(Mandatory=$true)]
[string]$Last,

[Parameter(Mandatory=$true)]
[string]$street,

[Parameter(Mandatory=$true)]
[string]$city,

[Parameter(Mandatory=$true)]
[string]$state,

[Parameter(Mandatory=$true)]
[string]$zipcode,

[Parameter(Mandatory=$true)]
[string]$ph
)


#Resellers tenant id, locate this in https://Partnercenter.microsoft.com, Account settings,  Organization Profile, Microsoft ID

$global:ResellerTenantId = "f7f66891-a582-418d-999e-cb1be5354253"

#As configured in AD for my Service Provider tenant (or through CSP panel)
$global:ApplicationID= "f8507bd7-ece4-45d5-86e7-71dacd8d7717"

#Application secret as defined in AD for my ApplicationID
$global:ApplicationSecret= "B6hmbGjz0EAG6jJOposheGlx1cB08uiD8VXB5dlDE0g="

#Reseller domain name
$global:ResellerDomain = "coretekservices.com"

$global:URI_AAD="https://login.windows.net/$ResellerDomain/oauth2/token?api-version=1.0"                    
$global:URI_GetCustomers="https://graph.windows.net/$ResellerDomain/contracts?api-version=1.5"
$global:URI_CSPAPI="https://api.cp.microsoft.com/"
$global:URI_GetSAToken=$URI_CSPAPI + "my-org/tokens"
$global:URI_GetReseller=$URI_CSPAPI+"customers/get-by-identity?provider=AAD&type=tenant&tid=" + $ResellerTenantId
$global:URI_CreateCustomer=$URI_CSPAPI + $ResellerTenantId + "/customers/create-reseller-customer"


# Get the Azure Active Directory application token https://msdn.microsoft.com/en-us/library/partnercenter/dn974935.aspx
# Cloud Solution Provider partners must generate their own authentication credentials— a client ID and a secret key—before they can work with the CREST APIs. They use these credentials to create an Azure Active Directory security token. 

    $headers="" 
    $grantbody="grant_type=client_credentials&resource=https://graph.windows.net&client_id=$ApplicationID&client_secret=$ApplicationSecret"
    $AADTokenResponse=Invoke-Restmethod -Uri $URI_AAD -ContentType "application/x-www-form-urlencoded" -Body $grantbody -Method "POST" -verbose -Debug
    $global:AADToken = $AADTokenResponse.access_token
    $AADToken


#GET SA token https://msdn.microsoft.com/en-us/library/partnercenter/mt146414.aspx
#To use the CREST API, you must have an authorization token for the reseller’s account, which is generated using your Azure AD security token. This reseller token is called a Sales Agent Token, shortened to SA_Token.
#After you create an SA_Token, you can use it to get your cid-for-reseller. See Get a reseller id.

$headers=@{Authorization="Bearer $AADToken"
        }
$SABody ="grant_type=client_credentials"
$SATokenResponse = Invoke-RestMethod -Uri $URI_GetSAToken -ContentType "application/x-www-form-urlencoded" -Headers $headers -Body $SABody -method "POST" -Debug -Verbose
$global:SAToken=$SATokenResponse.access_token
$SAToken

#Get a reseller id https://msdn.microsoft.com/en-us/library/partnercenter/mt427345.aspx
#You can get the Customer resource that represents you, the CSP partner. This Customer resource contains an id which is your {cid-for-reseller} value for CREST API calls.
#Before you can get a reseller ID, you must have an SA_Token. Get a reseller token. 
#

    $TrackingGUID=[guid]::NewGuid()
    $CorrelationGUID=[guid]::NewGuid()
    $headers=@{Authorization="Bearer $SAToken"
            "Accept"="application/json"
            "api-version"="2015-03-31"
            "x-ms-correlation-id"=$CorrelationGUID
            "x-ms-tracking-id"=$TrackingGUID
            }

    $GetResellerResponse=Invoke-RestMethod -Uri $URI_GetReseller -ContentType "application/x-www-form-urlencoded" -Headers $headers -Method "GET" -Debug -Verbose
    $global:ResellerIdentity=$GetResellerResponse.id  #contains {cid-for-reseller}
    $ResellerIdentity





    $customerdata= @{
	    domain_prefix = $domainprefix;
	    user_name = $clientadmin; 
	    password = $clientpw;
        profile=@{
            email = $email
		    company_name = $companyname;
		    culture = "en-US";
		    language = "en";
            type = "organization";
            default_address=@{
			    first_name = $first;
			    last_name = $last;
			    address_line1 = $street;
			    city = $city;
			    region = $state;
			    postal_code = $zipcode;
			    country = "US";
                phone_number = $ph
            }
        
        }
    }

    $customerjson=$customerdata | ConvertTo-Json

    $TrackingGUID=[guid]::NewGuid()
    $CorrelationGUID=[guid]::NewGuid()
    $headers=@{Authorization="Bearer $SAToken"
            "Accept"="application/json"
            "api-version"="2015-03-31"
            "x-ms-correlation-id"=$CorrelationGUID
            "x-ms-tracking-id"=$TrackingGUID
            }

    $customer=Invoke-RestMethod -Uri $URI_CreateCustomer -Method "POST" -Headers $headers -Body $customerjson -ContentType "application/json"
    $customer
 