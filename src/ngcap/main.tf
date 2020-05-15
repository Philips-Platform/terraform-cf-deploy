
module "postgres-service" {
  source                = "./modules/services-With-keys"
  service_name          = "hsdp-rds"
  service_instance_name = "postgres"
  service_instance_key = "postgreskey"
  enable_service_key = true
  service_plan          = var.postgres_service_plan
  space_id              = cloudfoundry_space_users.space.space
  service_params        = "{ \"DBName\": \"hsdp_pg\", \"EngineVersion\": \"11.1\" }"
}

module "metrics-service" {
  source                = "./modules/services"
  service_name          = "hsdp-metrics"
  service_instance_name = "metrics"
  service_plan          = "metrics"
  enable_service_key = false
  space_id              = cloudfoundry_space_users.space.space
}

module "logdrainer-service" {
  source             = "./modules/cups"
  cups_instance_name = "ngcap_log_drainer"
  syslog_drain_url    = "https://logdrainer-client-test.us-east.philips-healthsuite.com/core/log/Product/8af07a0e696d7ac48962c28f88ea94ff0dd70ef3571ef3c2ce3ecfa6e21704366b87f7bd43bde10def63020356481708"
  space_id           = cloudfoundry_space_users.space.space
}

module "rabbitmq-service" {
  source                = "./modules/services-with-keys"
  service_name          = "hsdp-rabbitmq"
  service_instance_name = "rabbitmq"
  service_instance_key = "rabbitmqkey"
  enable_service_key = true
  service_plan          = var.rabbitmq_service_plan
  space_id              = cloudfoundry_space_users.space.space
}

module "redis-service" {
  source                = "./modules/services-with-keys"
  service_name          = "hsdp-redis-sentinel"
  service_instance_name = "redis"
  service_instance_key = "rediskey"
  enable_service_key = true
  service_plan          = var.redis_service_plan
  space_id              = cloudfoundry_space_users.space.space
}

locals {
  space_name                 = lower(var.CLOUD_FOUNDRY_SPACE)
  org_name 		     = lower(var.CLOUD_FOUNDRY_ORG)
}


module "ngcap-sysconfig" {
  source = "./modules/application"
  app_name = "sys-config"
  app_docker_image                   = "${var.DOCKER_REGISTRY_NAMESPACE}/sysconfig:${var.ngcap_cs_tag}"
  docker_registry_username       = var.DOCKER_REGISTRY_USERNAME
  docker_registry_password       = var.DOCKER_REGISTRY_PASSWORD
  app_memory                         = var.memory
  app_disk_quota                     = var.disk_quota
  space_id              = cloudfoundry_space_users.space.space
  app_hostname = "sys-config-${local.org_name}-${local.space_name}" 
  app_domain = toset([var.CLOUD_FOUNDRY_INTERNAL_DOMAIN])
  app_ports = toset([5000])
  app_stopped = var.stop_apps
  app_services = [
	{ "service_instance" = module.logdrainer-service.service_instance_id } 
  ] 
  app_environment = { 
	"Calcconfig" = "http://calc-config-${local.org_name}-${local.space_name}.${var.CLOUD_FOUNDRY_INTERNAL_DOMAIN}:5000",
	"Fhir" = "http://fhir-gw-${local.org_name}-${local.space_name}.${var.CLOUD_FOUNDRY_INTERNAL_DOMAIN}:5000",
	"Generic" = "http://generic-gw-${local.org_name}-${local.space_name}.${var.CLOUD_FOUNDRY_INTERNAL_DOMAIN}:5000",
	"GenericSupport" = "http://generic-support-gw-${local.org_name}-${local.space_name}.${var.CLOUD_FOUNDRY_INTERNAL_DOMAIN}:5000",
	"OutboundConfig" = "http://outbound-config-${local.org_name}-${local.space_name}.${var.CLOUD_FOUNDRY_INTERNAL_DOMAIN}:5000",
	"TenantConfig" = "http://tenant-config-${local.org_name}-${local.space_name}.${var.CLOUD_FOUNDRY_INTERNAL_DOMAIN}:5000",
	"Authentication" = "http://authenticationsvc-${local.org_name}-${local.space_name}.${var.CLOUD_FOUNDRY_INTERNAL_DOMAIN}:5000",
     	"rabbitmq.Hostname" = module.rabbitmq-service.service_key_credentials.hostname,
     	"rabbitmq.Username" = module.rabbitmq-service.service_key_credentials.admin_username,
     	"rabbitmq.Password" = module.rabbitmq-service.service_key_credentials.admin_password,
     	"rabbitmq.VirtualHost" = "vhost",
        "rabbitmq.Port" = module.rabbitmq-service.service_key_credentials.port,
     	"postgres.DbHost" = module.postgres-service.service_key_credentials.hostname,
     	"postgres.Username" = module.postgres-service.service_key_credentials.username,
     	"postgres.Password" = module.postgres-service.service_key_credentials.password,
     	"postgres.Port" = module.postgres-service.service_key_credentials.port,
     	"supportDB.DbHost" = module.postgres-service.service_key_credentials.hostname,
     	"supportDB.Username" = module.postgres-service.service_key_credentials.username,
     	"supportDB.Password" = module.postgres-service.service_key_credentials.password,
     	"supportDB.Port" = module.postgres-service.service_key_credentials.port,
     	"supportArchiveDB.DbHost" = module.postgres-service.service_key_credentials.hostname,
     	"supportArchiveDB.Username" = module.postgres-service.service_key_credentials.username,
     	"supportArchiveDB.Password" = module.postgres-service.service_key_credentials.password,
     	"supportArchiveDB.Port" = module.postgres-service.service_key_credentials.port,
     	"archiveDB.DbHost" = module.postgres-service.service_key_credentials.hostname,
     	"archiveDB.Username" = module.postgres-service.service_key_credentials.username,
     	"archiveDB.Password" = module.postgres-service.service_key_credentials.password,
     	"archiveDB.Port" = module.postgres-service.service_key_credentials.port,
     	"redis.RedisConfigString" = "${module.redis-service.service_key_credentials.host},abortConnect=false,password=${module.redis-service.service_key_credentials.password},connectTimeout=60000,syncTimeout=60000"
  }
}


module "ngcap-fhir-gw" {
  source = "./modules/application"
  app_name = "fhir-gw"
  app_docker_image                   = "${var.DOCKER_REGISTRY_NAMESPACE}/fhirgw:${var.ngcap_cs_tag}"
  docker_registry_username       = var.DOCKER_REGISTRY_USERNAME
  docker_registry_password       = var.DOCKER_REGISTRY_PASSWORD
  app_memory                         = var.memory
  app_disk_quota                     = var.disk_quota
  space_id              = cloudfoundry_space_users.space.space
  app_hostname = "fhir-gw-${local.org_name}-${local.space_name}"
  app_domain = toset([var.CLOUD_FOUNDRY_INTERNAL_DOMAIN])
  app_ports = toset([5000])
  app_stopped = var.stop_apps
  app_services = [
        { "service_instance" = module.logdrainer-service.service_instance_id }
  ]
  app_environment = {
    "SystemConfigBaseUrl" = "http://sys-config-${local.org_name}-${local.space_name}.${var.CLOUD_FOUNDRY_INTERNAL_DOMAIN}:5000"
    "METRICS_PROMETHEUS" = "true"
    "USE_MONGO" = "false"
    "FHIR_VERSION" = var.ngcap_fhir_version

  }

}

module "ngcap-generic-gw" {
  source = "./modules/application"
  app_name = "generic-gw"
  app_docker_image                   = "${var.DOCKER_REGISTRY_NAMESPACE}/genericgw:${var.ngcap_cs_tag}"
  docker_registry_username       = var.DOCKER_REGISTRY_USERNAME
  docker_registry_password       = var.DOCKER_REGISTRY_PASSWORD
  app_memory                         = var.memory
  app_disk_quota                     = var.disk_quota
  space_id              = cloudfoundry_space_users.space.space
  app_hostname = "generic-gw-${local.org_name}-${local.space_name}"
  app_domain = toset([var.CLOUD_FOUNDRY_INTERNAL_DOMAIN])
  app_ports = toset([5000])
  app_stopped = var.stop_apps
  app_services = [
        { "service_instance" = module.logdrainer-service.service_instance_id }
  ]
  app_environment = {
    "SystemConfigBaseUrl" = "http://sys-config-${local.org_name}-${local.space_name}.${var.CLOUD_FOUNDRY_INTERNAL_DOMAIN}:5000"
    "METRICS_PROMETHEUS" = "true"
    "USE_MONGO" = "false"	
  }
}

module "ngcap-generic-support-gw" {
  source = "./modules/application"
  app_name = "generic-support-gw"
  app_docker_image                   = "${var.DOCKER_REGISTRY_NAMESPACE}/genericgw:${var.ngcap_cs_tag}"
  docker_registry_username       = var.DOCKER_REGISTRY_USERNAME
  docker_registry_password       = var.DOCKER_REGISTRY_PASSWORD
  app_memory                         = var.memory
  app_disk_quota                     = var.disk_quota
  space_id              = cloudfoundry_space_users.space.space
  app_hostname = "generic-support-gw-${local.org_name}-${local.space_name}"
  app_domain = toset([var.CLOUD_FOUNDRY_INTERNAL_DOMAIN])
  app_ports = toset([5000])
  app_stopped = var.stop_apps
  app_services = [
        { "service_instance" = module.logdrainer-service.service_instance_id }
  ]
  app_environment = {
    "SystemConfigBaseUrl" = "http://sys-config-${local.org_name}-${local.space_name}.${var.CLOUD_FOUNDRY_INTERNAL_DOMAIN}:5000"
    "METRICS_PROMETHEUS" = "true"
    "USE_MONGO" = "false"
    "DBInfo" = "supportDB"
    "DbInfoArchive" = "supportArchiveDB"
    "pathReplace" = "api/generic,api/genericsupport"
  }
}


module "ngcap-calc-trace" {
  source = "./modules/application"
  app_name = "calc-trace"
  app_docker_image                   = "${var.DOCKER_REGISTRY_NAMESPACE}/calctrace:${var.ngcap_cs_tag}"
  docker_registry_username       = var.DOCKER_REGISTRY_USERNAME
  docker_registry_password       = var.DOCKER_REGISTRY_PASSWORD
  app_memory                         = var.memory
  app_disk_quota                     = var.disk_quota
  space_id              = cloudfoundry_space_users.space.space
  app_hostname = "calc-trace-${local.org_name}-${local.space_name}"
  app_domain = toset([var.CLOUD_FOUNDRY_INTERNAL_DOMAIN])
  app_ports = toset([5000])
  app_stopped = var.stop_apps
  app_services = [
        { "service_instance" = module.logdrainer-service.service_instance_id }
  ]
  app_environment = {
    "SystemConfigBaseUrl" = "http://sys-config-${local.org_name}-${local.space_name}.${var.CLOUD_FOUNDRY_INTERNAL_DOMAIN}:5000"
    "GenericSupport" = "http://generic-support-gw-${local.org_name}-${local.space_name}.${var.CLOUD_FOUNDRY_INTERNAL_DOMAIN}:5000"
  }
}

module "ngcap-calc-config" {
  source = "./modules/application"
  app_name = "calc-config"
  app_docker_image                   = "${var.DOCKER_REGISTRY_NAMESPACE}/calcconfig:${var.ngcap_cs_tag}"
  docker_registry_username       = var.DOCKER_REGISTRY_USERNAME
  docker_registry_password       = var.DOCKER_REGISTRY_PASSWORD
  app_memory                         = var.memory
  app_disk_quota                     = var.disk_quota
  space_id              = cloudfoundry_space_users.space.space
  app_hostname = "calc-config-${local.org_name}-${local.space_name}"
  app_domain = toset([var.CLOUD_FOUNDRY_INTERNAL_DOMAIN])
  app_ports = toset([5000])
  app_stopped = var.stop_apps
  app_services = [
        { "service_instance" = module.logdrainer-service.service_instance_id }
  ]
  app_environment = {
    "SystemConfigBaseUrl" = "http://sys-config-${local.org_name}-${local.space_name}.${var.CLOUD_FOUNDRY_INTERNAL_DOMAIN}:5000"
  }
}

module "ngcap-dispatcher" {
  source = "./modules/application"
  app_name = "dispatcher"
  app_docker_image                   = "${var.DOCKER_REGISTRY_NAMESPACE}/dispatcher:${var.ngcap_cs_tag}"
  docker_registry_username       = var.DOCKER_REGISTRY_USERNAME
  docker_registry_password       = var.DOCKER_REGISTRY_PASSWORD
  app_memory                         = var.memory
  app_disk_quota                     = var.disk_quota
  space_id              = cloudfoundry_space_users.space.space
  app_hostname = "dispatcher-${local.org_name}-${local.space_name}"
  app_domain = toset([var.CLOUD_FOUNDRY_INTERNAL_DOMAIN])
  app_ports = toset([5000])
  app_stopped = var.stop_apps
  app_services = [
        { "service_instance" = module.logdrainer-service.service_instance_id }
  ]
  app_environment = {
    "SystemConfigBaseUrl" = "http://sys-config-${local.org_name}-${local.space_name}.${var.CLOUD_FOUNDRY_INTERNAL_DOMAIN}:5000"
    "LOG_PUB_MSG" = "true"
    "FHIR_VERSION" = var.ngcap_fhir_version
  }
}

module "ngcap-execution" {
  source = "./modules/application"
  app_name = "execution"
  app_docker_image                   = "${var.DOCKER_REGISTRY_NAMESPACE}/execution:${var.ngcap_cs_tag}"
  docker_registry_username       = var.DOCKER_REGISTRY_USERNAME
  docker_registry_password       = var.DOCKER_REGISTRY_PASSWORD
  app_memory                         = "1024"
  app_disk_quota                     = var.disk_quota
  space_id              = cloudfoundry_space_users.space.space
  app_hostname = "execution-${local.org_name}-${local.space_name}"
  app_domain = toset([var.CLOUD_FOUNDRY_INTERNAL_DOMAIN])
  app_ports = toset([5000])
  app_stopped = var.stop_apps
  app_services = [
        { "service_instance" = module.logdrainer-service.service_instance_id }
  ]
  app_environment = {
    "SystemConfigBaseUrl" = "http://sys-config-${local.org_name}-${local.space_name}.${var.CLOUD_FOUNDRY_INTERNAL_DOMAIN}:5000"
    "LOG_PUB_MSG" = "true"
  }
}


module "ngcap-outbound-config" {
  source = "./modules/application"
  app_name = "outbound-config"
  app_docker_image                   = "${var.DOCKER_REGISTRY_NAMESPACE}/outboundconfig:${var.ngcap_cs_tag}"
  docker_registry_username       = var.DOCKER_REGISTRY_USERNAME
  docker_registry_password       = var.DOCKER_REGISTRY_PASSWORD
  app_memory                         = var.memory
  app_disk_quota                     = var.disk_quota
  space_id              = cloudfoundry_space_users.space.space
  app_hostname = "outbound-config-${local.org_name}-${local.space_name}"
  app_stopped = var.stop_apps
  app_domain = toset([var.CLOUD_FOUNDRY_INTERNAL_DOMAIN])
  app_ports = toset([5000])
  app_services = [
        { "service_instance" = module.logdrainer-service.service_instance_id }
  ]
  app_environment = {
    "SystemConfigBaseUrl" = "http://sys-config-${local.org_name}-${local.space_name}.${var.CLOUD_FOUNDRY_INTERNAL_DOMAIN}:5000"
  }
}


module "ngcap-outbound" {
  source = "./modules/application"
  app_name = "outbound"
  app_docker_image                   = "${var.DOCKER_REGISTRY_NAMESPACE}/outbound:${var.ngcap_cs_tag}"
  docker_registry_username       = var.DOCKER_REGISTRY_USERNAME
  docker_registry_password       = var.DOCKER_REGISTRY_PASSWORD
  app_memory                         = var.memory
  app_disk_quota                     = var.disk_quota
  space_id              = cloudfoundry_space_users.space.space
  app_hostname = "outbound-${local.org_name}-${local.space_name}"
  app_domain = toset([var.CLOUD_FOUNDRY_INTERNAL_DOMAIN])
  app_ports = toset([5000])
  app_stopped = var.stop_apps
  app_services = [
        { "service_instance" = module.logdrainer-service.service_instance_id }
  ]
  app_environment = {
    "SystemConfigBaseUrl" = "http://sys-config-${local.org_name}-${local.space_name}.${var.CLOUD_FOUNDRY_INTERNAL_DOMAIN}:5000"
    "FHIR_VERSION" = var.ngcap_fhir_version
  }
}


module "ngcap-scheduler" {
  source = "./modules/application"
  app_name = "scheduler"
  app_docker_image                   = "${var.DOCKER_REGISTRY_NAMESPACE}/scheduler:${var.ngcap_cs_tag}"
  docker_registry_username       = var.DOCKER_REGISTRY_USERNAME
  docker_registry_password       = var.DOCKER_REGISTRY_PASSWORD
  app_memory                         = var.memory
  app_disk_quota                     = var.disk_quota
  space_id              = cloudfoundry_space_users.space.space
  app_hostname = "scheduler-${local.org_name}-${local.space_name}"
  app_domain = toset([var.CLOUD_FOUNDRY_INTERNAL_DOMAIN])
  app_ports = toset([5000])
  app_stopped = var.stop_apps
  app_services = [
        { "service_instance" = module.logdrainer-service.service_instance_id }
  ]
  app_environment = {
    "SystemConfigBaseUrl" = "http://sys-config-${local.org_name}-${local.space_name}.${var.CLOUD_FOUNDRY_INTERNAL_DOMAIN}:5000"
  }
}

module "ngcap-authentication" {
  source = "./modules/application"
  app_name = "authenticationsvc"
  app_docker_image                   = "${var.DOCKER_REGISTRY_NAMESPACE}/authenticationsvc:${var.ngcap_js_tag}"
  docker_registry_username       = var.DOCKER_REGISTRY_USERNAME
  docker_registry_password       = var.DOCKER_REGISTRY_PASSWORD
  app_memory                         = var.memory
  app_disk_quota                     = var.disk_quota
  space_id              = cloudfoundry_space_users.space.space
  app_hostname = "authenticationsvc-${local.org_name}-${local.space_name}"
  app_domain = toset([var.CLOUD_FOUNDRY_INTERNAL_DOMAIN])
  app_ports = toset([5000])
  app_stopped = var.stop_apps
  app_services = [
        { "service_instance" = module.logdrainer-service.service_instance_id }
  ]
  app_environment = {
    "SystemConfigBaseUrl" = "http://sys-config-${local.org_name}-${local.space_name}.${var.CLOUD_FOUNDRY_INTERNAL_DOMAIN}:5000"
    "ClientSecret" = "true"
    "LDAP" = "false"
    "Debug" = "true"
  }
}

module "ngcap-system-config-ui" {
  source = "./modules/application"
  app_name = "ngcap"
  app_docker_image                   = "${var.DOCKER_REGISTRY_NAMESPACE}/sysconfigui:0.2.42-US16222-integration"
  docker_registry_username       = var.DOCKER_REGISTRY_USERNAME
  docker_registry_password       = var.DOCKER_REGISTRY_PASSWORD
  app_memory                         = var.memory
  app_disk_quota                     = var.disk_quota
  space_id              = cloudfoundry_space_users.space.space
  app_hostname = "ngcap-${local.org_name}-${local.space_name}"
  app_domain = toset([var.CLOUD_FOUNDRY_INTERNAL_DOMAIN,var.CLOUD_FOUNDRY_EXTERNAL_DOMAIN])
  app_ports = toset([8080])
  app_stopped = var.stop_apps
  app_services = [
        { "service_instance" = module.logdrainer-service.service_instance_id }
  ]
  app_environment = {
    "SystemConfigBaseUrl" = "http://sys-config-${local.org_name}-${local.space_name}.${var.CLOUD_FOUNDRY_INTERNAL_DOMAIN}:5000"  
    "ENVJS" = "window.environment = { host: 'ngcap-api-${local.org_name}-${local.space_name}.${var.CLOUD_FOUNDRY_EXTERNAL_DOMAIN}', port: 80, protocol: 'http', support: '/api/genericsupport'}"
  }
}


module "ngcap-tenant-config" {
  source = "./modules/application"
  app_name = "tenant-config"
  app_docker_image                   = "${var.DOCKER_REGISTRY_NAMESPACE}/tenantconfig:${var.ngcap_cs_tag}"
  docker_registry_username       = var.DOCKER_REGISTRY_USERNAME
  docker_registry_password       = var.DOCKER_REGISTRY_PASSWORD
  app_memory                         = var.memory
  app_disk_quota                     = var.disk_quota
  space_id              = cloudfoundry_space_users.space.space
  app_hostname = "tenant-config-${local.org_name}-${local.space_name}"
  app_domain = toset([var.CLOUD_FOUNDRY_INTERNAL_DOMAIN])
  app_ports = toset([5000])
  app_stopped = var.stop_apps
  app_services = [
        { "service_instance" = module.logdrainer-service.service_instance_id }
  ]
  app_environment = {
    "SystemConfigBaseUrl" = "http://sys-config-${local.org_name}-${local.space_name}.${var.CLOUD_FOUNDRY_INTERNAL_DOMAIN}:5000"
  }
}

module "ngcap-api-gateway" {
  source = "./modules/ngcap-api-gateway"
  app_name="ngcap-api"
  app_hostbase = "${local.org_name}-${local.space_name}"
  app_external_domain = var.CLOUD_FOUNDRY_EXTERNAL_DOMAIN
  app_internal_domain = var.CLOUD_FOUNDRY_INTERNAL_DOMAIN
  app_memory                         = var.memory
  app_disk_quota                     = var.disk_quota
  space_id              = cloudfoundry_space_users.space.space
  app_stopped = var.stop_apps
}

module "network-policies" {
     source = "./modules/network-policies"
     app_network_policies = [
	{
          "source" = module.ngcap-sysconfig.app_instance_id,
          "destination" = module.ngcap-fhir-gw.app_instance_id,
          "portRange" = "5000"
	},
	{
          "source" = module.ngcap-sysconfig.app_instance_id,
          "destination" = module.ngcap-generic-gw.app_instance_id,
          "portRange" = "5000"
        },
	{
          "source" = module.ngcap-sysconfig.app_instance_id,
          "destination" = module.ngcap-generic-support-gw.app_instance_id,
          "portRange" = "5000"
        },
	{
          "source" = module.ngcap-sysconfig.app_instance_id,
          "destination" = module.ngcap-calc-trace.app_instance_id,
          "portRange" = "5000"
        },
	{
          "source" = module.ngcap-sysconfig.app_instance_id,
          "destination" = module.ngcap-calc-config.app_instance_id,
          "portRange" = "5000"
        },
	{
          "source" = module.ngcap-sysconfig.app_instance_id,
          "destination" = module.ngcap-dispatcher.app_instance_id,
          "portRange" = "5000"
        },
	{
          "source" = module.ngcap-sysconfig.app_instance_id,
          "destination" = module.ngcap-dispatcher.app_instance_id,
          "portRange" = "5000"
        },
	{
          "source" = module.ngcap-sysconfig.app_instance_id,
          "destination" = module.ngcap-execution.app_instance_id,
          "portRange" = "5000"
	},
	{
          "source" = module.ngcap-sysconfig.app_instance_id,
          "destination" = module.ngcap-outbound.app_instance_id,
          "portRange" = "5000"
	},
	{
          "source" = module.ngcap-sysconfig.app_instance_id,
          "destination" = module.ngcap-outbound-config.app_instance_id,
          "portRange" = "5000"
	},
	{
          "source" = module.ngcap-sysconfig.app_instance_id,
          "destination" = module.ngcap-scheduler.app_instance_id,
          "portRange" = "5000"
	},
	{
          "source" = module.ngcap-sysconfig.app_instance_id,
          "destination" = module.ngcap-authentication.app_instance_id,
          "portRange" = "5000"
	},
	{
          "source" = module.ngcap-sysconfig.app_instance_id,
          "destination" = module.ngcap-system-config-ui.app_instance_id,
          "portRange" = "5000"
	},
	{
          "source" = module.ngcap-sysconfig.app_instance_id,
          "destination" = module.ngcap-tenant-config.app_instance_id,
          "portRange" = "5000"
	},
        {
          "source" = module.ngcap-api-gateway.app_instance_id,
          "destination" = module.ngcap-sysconfig.app_instance_id,
          "portRange" = "5000"
        },
	{
          "source" = module.ngcap-api-gateway.app_instance_id,
          "destination" = module.ngcap-fhir-gw.app_instance_id,
          "portRange" = "5000"
	},
	{
          "source" = module.ngcap-api-gateway.app_instance_id,
          "destination" = module.ngcap-generic-gw.app_instance_id,
          "portRange" = "5000"
        },
	{
          "source" = module.ngcap-api-gateway.app_instance_id,
          "destination" = module.ngcap-generic-support-gw.app_instance_id,
          "portRange" = "5000"
        },
	{
          "source" = module.ngcap-api-gateway.app_instance_id,
          "destination" = module.ngcap-calc-trace.app_instance_id,
          "portRange" = "5000"
        },
	{
          "source" = module.ngcap-api-gateway.app_instance_id,
          "destination" = module.ngcap-calc-config.app_instance_id,
          "portRange" = "5000"
        },
	{
          "source" = module.ngcap-api-gateway.app_instance_id,
          "destination" = module.ngcap-dispatcher.app_instance_id,
          "portRange" = "5000"
        },
	{
          "source" = module.ngcap-api-gateway.app_instance_id,
          "destination" = module.ngcap-dispatcher.app_instance_id,
          "portRange" = "5000"
        },
	{
          "source" = module.ngcap-api-gateway.app_instance_id,
          "destination" = module.ngcap-execution.app_instance_id,
          "portRange" = "5000"
	},
	{
          "source" = module.ngcap-api-gateway.app_instance_id,
          "destination" = module.ngcap-outbound.app_instance_id,
          "portRange" = "5000"
	},
	{
          "source" = module.ngcap-api-gateway.app_instance_id,
          "destination" = module.ngcap-outbound-config.app_instance_id,
          "portRange" = "5000"
	},
	{
          "source" = module.ngcap-api-gateway.app_instance_id,
          "destination" = module.ngcap-scheduler.app_instance_id,
          "portRange" = "5000"
	},
	{
          "source" = module.ngcap-api-gateway.app_instance_id,
          "destination" = module.ngcap-authentication.app_instance_id,
          "portRange" = "5000"
	},
	{
          "source" = module.ngcap-api-gateway.app_instance_id,
          "destination" = module.ngcap-system-config-ui.app_instance_id,
          "portRange" = "5000"
	},
	{
          "source" = module.ngcap-api-gateway.app_instance_id,
          "destination" = module.ngcap-tenant-config.app_instance_id,
          "portRange" = "5000"
	},
	{
          "source" = module.ngcap-calc-config.app_instance_id,
          "destination" = module.ngcap-execution.app_instance_id,
          "portRange" = "5000"
	},
	{
          "source" = module.ngcap-calc-config.app_instance_id,
          "destination" = module.ngcap-dispatcher.app_instance_id,
          "portRange" = "5000"
	},
	{
          "source" = module.ngcap-tenant-config.app_instance_id,
          "destination" = module.ngcap-fhir-gw.app_instance_id,
          "portRange" = "5000"
	},
	{
          "source" = module.ngcap-tenant-config.app_instance_id,
          "destination" = module.ngcap-generic-gw.app_instance_id,
          "portRange" = "5000"
        },
	{
          "source" = module.ngcap-tenant-config.app_instance_id,
          "destination" = module.ngcap-generic-support-gw.app_instance_id,
          "portRange" = "5000"
        },
	{
          "source" = module.ngcap-tenant-config.app_instance_id,
          "destination" = module.ngcap-calc-trace.app_instance_id,
          "portRange" = "5000"
        },
	{
          "source" = module.ngcap-tenant-config.app_instance_id,
          "destination" = module.ngcap-calc-config.app_instance_id,
          "portRange" = "5000"
        },
	{
          "source" = module.ngcap-tenant-config.app_instance_id,
          "destination" = module.ngcap-dispatcher.app_instance_id,
          "portRange" = "5000"
        },
	{
          "source" = module.ngcap-tenant-config.app_instance_id,
          "destination" = module.ngcap-execution.app_instance_id,
          "portRange" = "5000"
	},
	{
          "source" = module.ngcap-tenant-config.app_instance_id,
          "destination" = module.ngcap-outbound.app_instance_id,
          "portRange" = "5000"
	},
	{
          "source" = module.ngcap-tenant-config.app_instance_id,
          "destination" = module.ngcap-outbound-config.app_instance_id,
          "portRange" = "5000"
	},
	{
          "source" = module.ngcap-tenant-config.app_instance_id,
          "destination" = module.ngcap-scheduler.app_instance_id,
          "portRange" = "5000"
	},
	{
          "source" = module.ngcap-tenant-config.app_instance_id,
          "destination" = module.ngcap-authentication.app_instance_id,
          "portRange" = "5000"
	},
	{
          "source" = module.ngcap-tenant-config.app_instance_id,
          "destination" = module.ngcap-system-config-ui.app_instance_id,
          "portRange" = "5000"
	}

     ]
	
}

























