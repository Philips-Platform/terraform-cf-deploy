terraform apply -auto-approve  -var-file=variables\default.tfvars -target=module.postgres-service 
terraform apply -auto-approve  -var-file=variables\default.tfvars -target=module.metrics-service 
terraform apply -auto-approve  -var-file=variables\default.tfvars -target=module.logdrainer-service 
terraform apply -auto-approve  -var-file=variables\default.tfvars -target=module.rabbitmq-service 
terraform apply -auto-approve  -var-file=variables\default.tfvars -target=module.redis-service 
