terraform apply -auto-approve  -var-file=variables\default.tfvars -target=module.ngcap-sysconfig 
terraform apply -auto-approve  -var-file=variables\default.tfvars -target=module.ngcap-fhir-gw 
terraform apply -auto-approve  -var-file=variables\default.tfvars -target=module.ngcap-generic-gw 
terraform apply -auto-approve  -var-file=variables\default.tfvars -target=module.ngcap-generic-support-gw 
terraform apply -auto-approve  -var-file=variables\default.tfvars -target=module.ngcap-calc-trace 
terraform apply -auto-approve  -var-file=variables\default.tfvars -target=module.ngcap-calc-config 
terraform apply -auto-approve  -var-file=variables\default.tfvars -target=module.ngcap-dispatcher 
terraform apply -auto-approve  -var-file=variables\default.tfvars -target=module.ngcap-execution 
terraform apply -auto-approve  -var-file=variables\default.tfvars -target=module.ngcap-outbound-config 
terraform apply -auto-approve  -var-file=variables\default.tfvars -target=module.ngcap-outbound 
terraform apply -auto-approve  -var-file=variables\default.tfvars -target=module.ngcap-scheduler 
terraform apply -auto-approve  -var-file=variables\default.tfvars -target=module.ngcap-authentication 
terraform apply -auto-approve  -var-file=variables\default.tfvars -target=module.ngcap-system-config-ui 
terraform apply -auto-approve  -var-file=variables\default.tfvars -target=module.ngcap-tenant-config 
terraform apply -auto-approve  -var-file=variables\default.tfvars -target=module.ngcap-api-gateway 
terraform apply -auto-approve -target=module.network-policies -var-file=variables\default.tfvars
terraform apply -auto-approve  -var-file=variables\default.tfvars -var "stop_apps=false" -target=module.ngcap-sysconfig
terraform apply -auto-approve  -var-file=variables\default.tfvars -var "stop_apps=false" -target=module.ngcap-fhir-gw
terraform apply -auto-approve  -var-file=variables\default.tfvars -var "stop_apps=false" -target=module.ngcap-generic-gw
terraform apply -auto-approve  -var-file=variables\default.tfvars -var "stop_apps=false" -target=module.ngcap-generic-support-gw
terraform apply -auto-approve  -var-file=variables\default.tfvars -var "stop_apps=false" -target=module.ngcap-calc-trace
terraform apply -auto-approve  -var-file=variables\default.tfvars -var "stop_apps=false" -target=module.ngcap-calc-config
terraform apply -auto-approve  -var-file=variables\default.tfvars -var "stop_apps=false" -target=module.ngcap-dispatcher
terraform apply -auto-approve  -var-file=variables\default.tfvars -var "stop_apps=false" -target=module.ngcap-execution
terraform apply -auto-approve  -var-file=variables\default.tfvars -var "stop_apps=false" -target=module.ngcap-outbound-config
terraform apply -auto-approve  -var-file=variables\default.tfvars -var "stop_apps=false" -target=module.ngcap-outbound
terraform apply -auto-approve  -var-file=variables\default.tfvars -var "stop_apps=false" -target=module.ngcap-scheduler
terraform apply -auto-approve  -var-file=variables\default.tfvars -var "stop_apps=false" -target=module.ngcap-authentication 
terraform apply -auto-approve  -var-file=variables\default.tfvars -var "stop_apps=false" -target=module.ngcap-system-config-ui 
terraform apply -auto-approve  -var-file=variables\default.tfvars -var "stop_apps=false" -target=module.ngcap-tenant-config 
terraform apply -auto-approve  -var-file=variables\default.tfvars -var "stop_apps=false" -target=module.ngcap-api-gateway 
