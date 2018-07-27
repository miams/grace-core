
### GuardDuty Lambda
Guarddyty lambda is used to download threat IOC . It places csv file in S3 and also updates GuardDuty threat list after every download. It runs once a day. It takes [several parameter](https://github.com/GSA/grace-core/blob/master/terraform/platform/guardduty_lambda/main.tf) including private and public key to download IOC feed. 
