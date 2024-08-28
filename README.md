# FortiGate Autoscale With FortiFlex
This Repository contains addtions to the original FortiGate Autoscale architecture which support the use of FortiFlex.  The original only supports PayGo licensing.  When this terraform is applied, the below resources are created:

1. GCP Storage Bucket which contains:
    - The baseconfig file which is used to generate device configurations for FortiGate.  
    - The GCP credentials file (account.json)
    - The FortiGate Autoscale zip file (gcp.zip) containing the original nodejs autoscale code base which creates the Autoscale Cloud Function
    - The FortiFlex zip file (flex_gcp.zip) which contians the new python code base, which creates the FortiFlex function
1. GCP FortiGate Autoscale Cloud Function
    - This function creates a Firestore database, which contains variables which can be merged with the baseconfig to generate FortiGate configurations, which it then pushes to the FortiGate.
1. GCP FortiFlex Austoscale Cloud Function
    - This function is subscribed to a pub/sub topic which ingests insert and delete logs
    - Upon Insert, the function parses ingested log data and uses it to:
        - pull device information from FortiGate 
        - activate a pending or stopped FortiFlex entitlement. Pull the serial number and Token.
        - create a firestore collection to hold the Flex Serial Number and Device ID of FortiGate
        - push Fortiflex token to FortiGate
    - Upon Delete, the function:
        - queries the Firestore collection to collect Serial number associated with device id of deleted FortiGate
        - uses this Serial number to stop the Flex entitlement
        - deletes the firestore
1. GCP VPCs:
    - Public: contains External Load Balancer
    - Protected: contains internal Load Balancer
    - sync: used to syncronize device configurations from primary fortigate to secondary fortigates
1. GCP Device Template:
    - Contains basic FortiGate VM configuration:
        - nic0: in Public VPC.  Contains public IP address for management purposes.
        - nic1: in Protectec VPC.
        - nic2: in Sync VPC.
        - configurl: calls the FortiGate Autoscale Cloud Function in order to get merged baseconfig
1. GCP Autoscaler and Health Checks
1. GCP Managed Instance Group:
    - dictates instance counts (minimum and maximum)
    - calls Device Template
    - applies Autoscaler

## Pre-requisites
1. GCP Service Account (.json key) with the below privileges:
    - Cloud Functions Admin
    - Cloud Functions Invoker
    - Cloud Run Admin
    - Compute Admin
    - Compute Storage Admin
    - Logging Admin
    - Logs Configuration Writer
    - Logs Writer
    - Project IAM Admin
    - Pub/Sub Admin
1. GCP Firestore "default" database already created
1. FortiFlex Account:
    - with API (read/write) User Credentials  
        - [Create IAM User](https://docs.fortinet.com/document/forticloud/21.2.0/identity-access-management-iam/282341/adding-an-api-user)
    - **Dedicated** Fortigate-VM Configuration which will only be used for Autoscale.
    - N x **Pre-configured (Pending or Stopped state)** Flex Entitlements for the decidated configuration.  N = The maximium number of FortiGates in the Managed Instance Group

## FortiGate Autoscale Function
A collection of **Node.js** modules and cloud-specific templates that support autoscale functionality for groups of FortiGate-VM instances on various cloud platforms.

This project contains the code and templates for the **FortiGate Autoscale for GCP** deployment.


## Supported Platforms

This project supports autoscale for the cloud platform listed below.

-  Google Cloud Platform (GCP)

## Deployment Packages

To generate local deployment packages:

1. Clone this project.
1. Run ```npm install``` ```npm run setup``` at the project root directory
1. The variable "auth_key" is set up to default to account.json.  In my setup, I downloaded the .json key file for my service account to the autoscale root directory and renamed the file as account.json.
1. Modify variables.tf and add the appropriate values for
    - project
    - service_account
    - flex_conf_name
    - flex_prog_serial
    - flexpass
    - flexuser
1. Copy **account.json** and **flex_gcp.zip** into the **dist** folder.
1. Issue ```terraform init``` command
1. Issue ```terraform plan -out tf.plan``` command
1. Issue ```terraform apply tf.plan --auto-approve`` command
1. Step away and grab some coffee.  It takes about 10 minutes for this to run completely.

[Original Install Documentation](https://docs.fortinet.com/document/fortigate-public-cloud/7.2.0/gcp-administration-guide/971604/deployment)    |

# Support

Fortinet-provided scripts in this and other GitHub projects do not fall under the regular Fortinet technical support scope and are not supported by FortiCare Support Services.


### FortiFlex Function Code Base
The FortiFlex Function Code base is zipped and included in this repository.  If you would like to modify that code base, it can be found at [this link](https://github.com/fortidg/gcp-flex-autoscale)

## License

[License](https://github.com/fortinet/fortigate-autoscale-gcp/blob/main/LICENSE) © Fortinet Technologies. All rights reserved.
