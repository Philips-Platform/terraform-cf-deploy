def create_backend_workspace(sub_section){
    withEnv(["TERRAFORM_WORKSPACE_SUBSECTION=${sub_section}"]){
        sh './scripts/terraform-create-workspace.sh'
    }
}
def update_backend_workspace(target_file_name, sub_section){
    sh "cp ./backends/backend.hcl ${target_file_name}"
    sh "sed -i 's/#spacename#/$CFSpaceName/g' ${target_file_name}"
    sh "sed -i 's/#appname#/$sub_section/g' ${target_file_name}"
}
def deploy(manifestJson, backendFile, destroy = true){
    // update the services to be deployed
    sh "cp ${manifestJson} ./main.tf.json"
    sh "terraform init -plugin-dir=../plugins/linux_amd64 -backend-config=${backendFile}"
    // terraform validation
    sh 'terraform validate'
    sh "terraform refresh"
    if(destroy){
        sh "terraform destroy -auto-approve"
    }
    sh "terraform apply -auto-approve"
}

def secrets = [
    [path: 'cf/fb56e376-14c1-42bf-961a-3e716e863933/secret/terraform-secrets', secretValues: [
            [envVar: 'TERRAFORMRC', vaultKey: 'terraform-rc'],
            [envVar: 'TERRAFORMINPUT', vaultKey: 'terraform-input-file']]],
    [path: 'cf/fb56e376-14c1-42bf-961a-3e716e863933/secret/terraform-cloud', secretValues: [
            [envVar: 'TERRAFORM_API_TOKEN', vaultKey: 'api-token']]]
]
node('docker') {
    properties([
            parameters
            ([
                booleanParam(name: 'MONITORING', defaultValue: false, description: 'Deploy monitoring services'),
                booleanParam(name: 'PROMETHEUSINTERNAL', defaultValue: false, description: 'Deploy prometheus internal'),
                booleanParam(name: 'PROMETHEUSEXTERNAL', defaultValue: false, description: 'Deploy prometheus external'),
                booleanParam(name: 'APPS', defaultValue: false, description: 'Deploy Apps'),
                string(defaultValue: 'latest',description: 'Upstream Job Build Number',name: 'UpstreamJobBuildNumber', trim: true),
                string(defaultValue: 'patient-registration', description: 'Deployment candidate microservice', name: 'MicroserviceName', trim: true),
                string(defaultValue: 'patient-registration', description: 'Docker Repo name', name: 'DockerImageRepoName', trim: true),
                string(defaultValue: 'sandbox5', description: 'CF Space name', name: 'CFSpaceName', trim: true),
                string(defaultValue: 'pca-acs-cicd-svc', description: 'Comma separated CF Space user list', name: 'CFSpaceUsers', trim: true),
                string(defaultValue: 'master', description: 'Upstream job branch', name: 'MicroserviceBranchName', trim: true),
                choice(name: 'DeployTarget', choices: ['dev', 'intg', 'ver'], description: 'Pick deploy target')
            ]),
            disableConcurrentBuilds()
        ])
    /* Requires the Docker Pipeline plugin to be installed */
    stage('checkout'){
        checkout scm
    }
    stage('App Deployment'){
        if ("${APPS}" == "true") {
            stage('test'){
                echo "${APPS}"
                echo "${UpstreamJobBuildNumber}"
            }
            stage('download artifacts'){
                copyArtifacts filter: 'cf-manifests.zip', fingerprintArtifacts: true, projectName: "philips-internal-cci-platform/${MicroserviceName}/${MicroserviceBranchName}", selector: specific("${UpstreamJobBuildNumber}")
                unzip zipFile: './cf-manifests.zip', dir: 'src'
            }
            stage('Apps deployment') {
                withVault([vaultSecrets: secrets]) {
                    try{
                        def terraform = docker.build("terraform", "--file=./Docker/Dockerfile .")
                        terraform.inside('--entrypoint=""') {
                            dir("${env.WORKSPACE}/src"){
                                sh "./scripts/store-file.sh terraform-secret.rc terraform-input-secret.json"
                                def pwds = readJSON file: "terraform-input-secret.json"
                                withEnv(["TF_CLI_CONFIG_FILE=./terraform-secret.rc",
                                    "TF_CLI_ARGS=-var-file=./terraform-input-secret.json", 
                                    "TF_VAR_CLOUD_FOUNDRY_SPACE=$CFSpaceName", 
                                    "TF_VAR_stop_apps=false","CLOUD_FOUNDRY_API=${pwds['CLOUD_FOUNDRY_API']}", 
                                    "CLOUD_FOUNDRY_USERNAME=${pwds['CLOUD_FOUNDRY_USERNAME']}",
                                    "CLOUD_FOUNDRY_PASSWORD=${pwds['CLOUD_FOUNDRY_PASSWORD']}"]){

                                    // create terraform backend workspaces in terraform cloud
                                    create_backend_workspace('infra')
                                    create_backend_workspace("${MicroserviceName}")
                                    update_backend_workspace('backend-services.hcl', 'infra')
                                    update_backend_workspace('backend-app.hcl', "$MicroserviceName")

                                    sh './scripts/cf-login.sh'
                                    sh './scripts/get-cf-users.sh'
                                    
                                    // trigger the deployment of terraform scripts 
                                    unzip zipFile: '../plugins/linux_amd64/terraform-provider-aws_v2.62.zip', dir: '../plugins/linux_amd64/'
                                    withEnv(["TF_VAR_CLOUD_FOUNDRY_SPACE_USERS=${sh(returnStdout: true, script: "bash ${env.WORKSPACE}/src/scripts/get-cf-user-guids.sh")}"]){
                                        echo "${TF_VAR_CLOUD_FOUNDRY_SPACE_USERS}"
                                        deploy("./templates/services.json", "./backend-services.hcl", false)
                                        deploy("./${DeployTarget}-cf-manifest.json", "./backend-app.hcl")
                                    }
                                }
                                sh './scripts/clean-up.sh'
                            }
                        }
                    }
                    finally{
                        //sh 'sudo chown $USER -R ./src/.terraform'
                    }
                }
            }
        }
    }
    
    stage('Monitoring Apps deployment'){
        if ("${MONITORING}" == "true") {
            withVault([vaultSecrets: secrets]) {
                try{
                    def terraform = docker.build("terraform", "--file=./Docker/Dockerfile .")
                    terraform.inside('--entrypoint=""') {
                        dir("${env.WORKSPACE}/src"){
                            // add curl, jq and bash
                            sh 'apk add --update curl jq bash'
                            sh "./scripts/store-file.sh terraform-secret.rc terraform-input-secret.json"
                            def pwds = readJSON file: "terraform-input-secret.json"
                            withEnv(["TF_CLI_CONFIG_FILE=./terraform-secret.rc",
                                "TF_CLI_ARGS=-var-file=./terraform-input-secret.json", 
                                "TF_VAR_CLOUD_FOUNDRY_SPACE=$CFSpaceName", 
                                "TF_VAR_stop_apps=false","CLOUD_FOUNDRY_API=${pwds['CLOUD_FOUNDRY_API']}", 
                                "CLOUD_FOUNDRY_USERNAME=${pwds['CLOUD_FOUNDRY_USERNAME']}",
                                "CLOUD_FOUNDRY_PASSWORD=${pwds['CLOUD_FOUNDRY_PASSWORD']}"]){

                                // create terraform backend workspaces in terraform cloud
                                create_backend_workspace("monitoring")
                                create_backend_workspace("monitoring-network_policies")
                                update_backend_workspace("backend-monitoring.hcl", "monitoring")
                                update_backend_workspace("backend-monitoring-network_policies.hcl", "monitoring-network_policies")
                                // trigger the deployment of terraform scripts
                                if ("${PROMETHEUSINTERNAL}" == "true") {
                                    sh "./scripts/merge-modules.sh 'prometheus_internal' 'grafana'"
                                }
                                else if ("${PROMETHEUSEXTERNAL}" == "true") {
                                    sh "./scripts/merge-modules.sh 'prometheus_external' 'promregator' 'grafana'"
                                }
                                deploy("./all_modules.json", "./backend-monitoring.hcl")
                                if ("${PROMETHEUSINTERNAL}" == "true") {
                                    deploy("./monitoring-templates/network_policies_internal.json", "./backend-monitoring-network_policies.hcl", false)
                                }
                                else if ("${PROMETHEUSEXTERNAL}" == "true") {
                                    deploy("./monitoring-templates/network_policies_external.json", "./backend-monitoring-network_policies.hcl", false)
                                }
                                
                            }
                            sh './scripts/clean-up.sh'
                        }
                    }
                }
                finally{
                    //sh 'sudo chown $USER -R ./src/.terraform'
                }
            }
        }
    }
}