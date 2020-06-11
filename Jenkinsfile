def createInfraBackendWorkspace(){
    withEnv(["TERRAFORM_WORKSPACE_SUBSECTION=infra"]){
        sh './scripts/terraform-create-workspace.sh'
    }
}
def createAppBackendWorkspace(){
    withEnv(["TERRAFORM_WORKSPACE_SUBSECTION=${MicroserviceName}"]){
        sh './scripts/terraform-create-workspace.sh'
    }
}
def updateInfraBackendWorkspace(){
    sh "sed -i 's/#spacename#/$CFSpaceName/g' ./backends/backend-services.hcl"
}
def updateAppBackendWorkspace(){
    sh "sed -i 's/#spacename#/$CFSpaceName/g' ./backends/backend-app.hcl"
    sh "sed -i 's/#appname#/$MicroserviceName/g' ./backends/backend-app.hcl"
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
            parameters([string(
                defaultValue: 'latest', 
                description: 'Upstream Job Build Number', 
                name: 'UpstreamJobBuildNumber', 
                trim: true),
                string(
                defaultValue: 'patient-registration', 
                description: 'Deployment candidate microservice', 
                name: 'MicroserviceName', 
                trim: true),
                string(
                defaultValue: 'patient-registration', 
                description: 'Docker Repo name', 
                name: 'DockerImageRepoName', 
                trim: true),
                string(
                defaultValue: 'sandbox5', 
                description: 'CF Space name', 
                name: 'CFSpaceName', 
                trim: true),
                string(
                defaultValue: 'ngupta', 
                description: 'Comma separated CF Space user list', 
                name: 'CFSpaceUsers', 
                trim: true)
            ])
        ])
    /* Requires the Docker Pipeline plugin to be installed */
    stage('checkout'){
        checkout scm
    }
    stage('download artifacts'){
        copyArtifacts filter: 'terraform-cf-manifest.zip', fingerprintArtifacts: true, projectName: "Philips-Platform/${MicroserviceName}/master", selector: specific("${UpstreamJobBuildNumber}")
        unzip zipFile: './terraform-cf-manifest.zip', dir: 'src'
    }
    stage('CF deployment') {
        withVault([vaultSecrets: secrets]) {
            try{
                docker.image('hashicorp/terraform:latest').inside('--entrypoint="" --user=root') {
                    dir("${env.WORKSPACE}/src"){
                        // add curl, jq and bash
                        sh 'apk add --update curl jq bash'
                        sh "./scripts/store-file.sh '${TERRAFORMRC}' terraform-secret.rc"
                        sh "./scripts/store-file.sh '${TERRAFORMINPUT}' terraform-input-secret.json"
                        withEnv(["TF_CLI_CONFIG_FILE=./terraform.rc"]){
                            createInfraBackendWorkspace()
                            createAppBackendWorkspace()
                            updateInfraBackendWorkspace()
                            updateAppBackendWorkspace()
                            
                            def pwds = readJSON file: "terraform-input-secret.json"
                            withEnv(["CLOUD_FOUNDRY_API=${pwds['CLOUD_FOUNDRY_API']}", "CLOUD_FOUNDRY_USERNAME=${pwds['CLOUD_FOUNDRY_USERNAME']}",
                            "CLOUD_FOUNDRY_PASSWORD=${pwds['CLOUD_FOUNDRY_PASSWORD']}"]) {
                                sh './scripts/install-cf-cli.sh'
                                sh './scripts/cf-login.sh'
                                sh './scripts/get-cf-users.sh'
                            }
                            withEnv(["TF_CLI_ARGS=-var-file=./terraform-input-secret.json", "TF_VAR_CLOUD_FOUNDRY_SPACE=$CFSpaceName", "TF_VAR_stop_apps=false",
                            "TF_VAR_CLOUD_FOUNDRY_SPACE_USERS=${sh(returnStdout: true, script: "bash ${env.WORKSPACE}/src/scripts/get-cf-user-guids.sh")}"]) {
                                sh 'unzip ../plugins/linux_amd64/terraform-provider-aws_v2.62.zip -d ../plugins/linux_amd64/'
                                echo "$TF_VAR_CLOUD_FOUNDRY_SPACE_USERS"
                                deploy("./templates/services.json", "./backends/backend-services.hcl", false)
                                deploy("./terraform-cf-manifest.json", "./backends/backend-app.hcl")
                                
                            }
                        }
                        sh './scripts/clean-up.sh'
                    }   
                }
            }
            finally{
                sh 'sudo chown $USER -R ./src/.terraform'
            }
        }
    }
}