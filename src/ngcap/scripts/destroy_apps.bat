terraform destroy -auto-approve  -var-file=variables\default.tfvars ^
-target=module.ngcap-sysconfig ^
-target=module.ngcap-fhir-gw ^
-target=module.ngcap-generic-gw ^
-target=module.ngcap-generic-support-gw ^
-target=module.ngcap-calc-trace ^
-target=module.ngcap-calc-config ^
-target=module.ngcap-dispatcher ^
-target=module.ngcap-execution ^
-target=module.ngcap-outbound-config ^
-target=module.ngcap-outbound ^
-target=module.ngcap-scheduler ^
-target=module.ngcap-authentication ^
-target=module.ngcap-system-config-ui ^
-target=module.ngcap-tenant-config ^
-target=module.ngcap-api-gateway
terraform destroy -auto-approve -target=module.network-policies -var-file=variables\default.tfvars
