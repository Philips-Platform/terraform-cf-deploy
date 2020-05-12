
resource "local_file" "nginx_conf" {
  filename = "${path.module}/api-gateway-nginx/nginx.conf"
  content=<<EOF
worker_processes 1;
daemon off;

error_log stderr;
events { worker_connections 1024; }

pid /tmp/nginx.pid;

http {
  charset utf-8;
  log_format cloudfoundry 'NginxLog "$request" $status $body_bytes_sent';
  access_log /dev/stdout cloudfoundry;
  default_type application/octet-stream;
  include mime.types;
  sendfile on;

  tcp_nopush on;
  keepalive_timeout 30;
  port_in_redirect off; # Ensure that redirects don't include the internal container PORT - 8080
  resolver 169.254.0.2;


  server {
      set $system_config "http://sys-config-${var.app_hostbase}.${var.app_external_domain}";
      set $api_admin "http://sys-config-${var.app_hostbase}.${var.app_external_domain}";
      set $fhir "http://fhir-gw-${var.app_hostbase}.${var.app_external_domain}";
      set $generic "http://generic-gw-${var.app_hostbase}.${var.app_external_domain}";
      set $genericsupport "http://generic-support-gw-${var.app_hostbase}.${var.app_external_domain}";
      set $calc_trace "http://calc-trace-${var.app_hostbase}.${var.app_external_domain}";
      set $calc_config "http://calc-config-${var.app_hostbase}.${var.app_external_domain}";
      set $dispatcher "http://dispatcher-${var.app_hostbase}.${var.app_external_domain}";
      set $execution "http://execution-${var.app_hostbase}.${var.app_external_domain}";
      set $outbound_config "http://outbound_config-${var.app_hostbase}.${var.app_external_domain}";
      set $outbound "http://outbound-${var.app_hostbase}.${var.app_external_domain}";
      set $scheduler "http://scheduler-${var.app_hostbase}.${var.app_external_domain}";
      set $auth "http://authenticationsvc-${var.app_hostbase}.${var.app_external_domain}";
	    set $tenant_config "http://tenant-config-${var.app_hostbase}.${var.app_external_domain}";

      listen {{port}}; # This will be replaced by CF magic. Just leave it here.
      index index.html index.htm Default.htm;

      location /api/system-config {
        proxy_pass $system_config;
      }

      location /api/admin {
        proxy_pass $api_admin;
      }

      location ~* ^/system-config/swagger/(?<baseuri>.*) {
          rewrite /system-config/swagger/(.*) /swagger/$1 break;
          proxy_pass $system_config;
        }

      location /api/fhir {
        proxy_pass $fhir;
      }

      location ~* ^/fhir/swagger/(?<baseuri>.*) {
        rewrite /fhir/swagger/(.*) /swagger/$1 break;
        proxy_pass $fhir;
      }


      location /api/generic {
        proxy_pass $generic;
      }

      location ~* ^/generic/swagger/(?<baseuri>.*) {
        rewrite /generic/swagger/(.*) /swagger/$1 break;
        proxy_pass $generic;
      }

      location /api/genericsupport {
        proxy_pass $genericsupport;
      }

      location ~* ^/genericsupport/swagger/(?<baseuri>.*) {
        rewrite /genericsupport/swagger/(.*) /swagger/$1 break;
        proxy_pass $genericsupport;
      }

      location /api/calc-trace {
        proxy_pass $calc_trace;
      }

      location ~* ^/calc-trace/swagger/(?<baseuri>.*) {
        rewrite /calc-trace/swagger/(.*) /swagger/$1 break;
        proxy_pass $calc_trace;
      }

      location /api/calc-config {
        proxy_pass $calc_config;
      }


      location ~* ^/calc-config/swagger/(?<baseuri>.*) {
        rewrite /calc-config/swagger/(.*) /swagger/$1 break;
        proxy_pass $calc_config;
      }

      location /api/dispatcher {
        proxy_pass $dispatcher;
      }

      location ~* ^/dispatcher/swagger/(?<baseuri>.*) {
        rewrite /dispatcher/swagger/(.*) /swagger/$1 break;
        proxy_pass $dispatcher;
      }

      location /api/execution {
        proxy_pass $execution;
      }

      location ~* ^/execution/swagger/(?<baseuri>.*) {
        rewrite /execution/swagger/(.*) /swagger/$1 break;
        proxy_pass $execution;
      }

      location /api/outbound-config {
        proxy_pass $outbound_config;
      }

      location ~* ^/outbound-config/swagger/(?<baseuri>.*) {
        rewrite /outbound-config/swagger/(.*) /swagger/$1 break;
        proxy_pass $outbound_config;
      }

      location /api/outbound {
        proxy_pass $outbound;
      }

      location ~* ^/outbound/swagger/(?<baseuri>.*) {
        rewrite /outbound/swagger/(.*) /swagger/$1 break;
        proxy_pass $outbound;
      }

      location /api/scheduler {
        proxy_pass $scheduler;
      }

      location ~* ^/scheduler/swagger/(?<baseuri>.*) {
        rewrite /scheduler/swagger/(.*) /swagger/$1 break;
        proxy_pass $scheduler;
      }

      location /api/auth {
        proxy_pass $auth;
      }

      location ~* ^/auth/swagger/(?<baseuri>.*) {
        rewrite /auth/swagger/(.*) /swagger/$1 break;
        proxy_pass $auth;
      }
	  
      location /api/tenant-config {
        proxy_pass $tenant_config;
      }


      location ~* ^/tenant-config/swagger/(?<baseuri>.*) {
        rewrite /tenant-config/swagger/(.*) /swagger/$1 break;
        proxy_pass $tenant_config;
      }	  
    }
}
EOF

}

data "cloudfoundry_domain" "ngcap_internal_domain" {
	name = var.app_internal_domain
}

data "cloudfoundry_domain" "ngcap_external_domain" {
  name = var.app_external_domain
}

resource "cloudfoundry_route" "ngcap_internal_route" {

    domain = data.cloudfoundry_domain.ngcap_internal_domain.id 
    space = var.space_id
    hostname = "ngcap-api-${var.app_hostbase}"
}

resource "cloudfoundry_route" "ngcap_external_route" {

    domain = data.cloudfoundry_domain.ngcap_external_domain.id 
    space = var.space_id
    hostname = "ngcap-api-${var.app_hostbase}"
}



resource "cloudfoundry_app" "ngcap_api_instance" {
  name         = var.app_name
  space        = var.space_id
  memory       = var.app_memory
  disk_quota   = var.app_disk_quota

  buildpack = "https://github.com/cloudfoundry/nginx-buildpack.git"
  path = "${path.module}/api-gateway-nginx/"


  routes {
    route = cloudfoundry_route.ngcap_external_route.id 
  }

  routes {
     route = cloudfoundry_route.ngcap_internal_route.id 
  }
  
  timeout = 180
  stopped = true

  depends_on = [ local_file.nginx_conf]

}
