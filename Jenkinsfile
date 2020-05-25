def createInfraBackendWorkspace(workspaceJsonFile, apiToken){
    sh "sed 's/#spacename#/$CFSpaceName/g' $workspaceJsonFile > infra-workspace.json"
    sh "sed -i 's/#subname#/infra/g' infra-workspace.json"
    sh "curl --header 'Authorization: Bearer $apiToken' --header 'Content-Type: application/vnd.api+json' --request POST --data @'infra-workspace.json' 'https://app.terraform.io/api/v2/organizations/Philips-platform/workspaces'"
}
def createAppBackendWorkspace(workspaceJsonFile, apiToken){
    sh "sed 's/#spacename#/$CFSpaceName/g' $workspaceJsonFile > app-workspace.json"
    sh "sed -i 's/#subname#/$MicroserviceName/g' app-workspace.json"
    sh "curl --header 'Authorization: Bearer $apiToken' --header 'Content-Type: application/vnd.api+json' --request POST --data @'app-workspace.json' 'https://app.terraform.io/api/v2/organizations/Philips-platform/workspaces'"
}
def updateInfraBackendWorkspace(){
    sh "sed -i 's/#spacename#/$CFSpaceName/g' ./backends/backend-services.hcl"
}
def updateAppBackendWorkspace(){
    sh "sed -i 's/#spacename#/$CFSpaceName/g' ./backends/backend-app.hcl"
    sh "sed -i 's/#appname#/$MicroserviceName/g' ./backends/backend-app.hcl"
}
def deployServices(){
    // update the services to be deployed
    sh 'cp ./templates/services.json ./main.tf.json'
    sh 'terraform init -plugin-dir=../plugins/linux_amd64 -backend-config=./backends/backend-services.hcl'
    // terraform validation
    sh 'terraform validate'
    sh "terraform refresh"
    sh "terraform apply -auto-approve"
}
def deployApp(){
    // update the modules to be deployed 
    sh 'cp -rf ./terraform-cf-manifest.json ./main.tf.json'
    sh 'terraform init -plugin-dir=../plugins/linux_amd64 -backend-config=./backends/backend-app.hcl'
    // terraform validation
    sh 'terraform validate'   
    sh "terraform refresh"        
    // apply the terraform configuration    
    sh "terraform destroy -auto-approve"
    sh "terraform apply -auto-approve"
}
node('docker') {
    properties([
            parameters([string(
                defaultValue: 'latest', 
                description: 'Upstream Job Build Number', 
                name: 'UpstreamJobBuildNumber', 
                trim: true),
                string(
                defaultValue: '', 
                description: 'Deployment candidate microservice', 
                name: 'MicroserviceName', 
                trim: true),
                string(
                defaultValue: '', 
                description: 'Docker Repo name', 
                name: 'DockerImageRepoName', 
                trim: true),
                string(
                defaultValue: 'sandbox', 
                description: 'CF Space name', 
                name: 'CFSpaceName', 
                trim: true),
                string(
                defaultValue: 'sandbox', 
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
        try{
            docker.image('hashicorp/terraform:latest').inside('--entrypoint="" --user=root') {
                withCredentials([file(credentialsId: 'terraform.rc', variable: 'TERRAFORMRC')]) {
                    dir("${env.WORKSPACE}/src"){
                        // add curl
                        sh 'apk add --update curl'
                        withEnv(["TF_CLI_CONFIG_FILE=${TERRAFORMRC}"]){
                            withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId:'terraform-token', usernameVariable: 'TERRAFORM-TOKEN', passwordVariable: 'TOKEN']]) {
                                withCredentials([file(credentialsId: 'workspace.json', variable: 'WORKSPACEJSON')]) {
                                    createInfraBackendWorkspace("${WORKSPACEJSON}", "${TOKEN}")
                                    createAppBackendWorkspace("${WORKSPACEJSON}", "${TOKEN}")
                                    updateInfraBackendWorkspace()
                                    updateAppBackendWorkspace()
                                }
                            }
                            withCredentials([file(credentialsId: 'terraform-input.json', variable: 'TERRAFORMINPUT')]) {
                                withEnv(["TF_CLI_ARGS=-var-file=${TERRAFORMINPUT}", "TF_VAR_CLOUD_FOUNDRY_SPACE=$CFSpaceName", "TF_VAR_stop_apps=false"]) {
                                    sh 'unzip ../plugins/linux_amd64/terraform-provider-aws_v2.62.zip -d ../plugins/linux_amd64/'
                                    deployServices()
                                    deployApp()
                                }
                            }
                        }
                    }   
                }
            }
        }
        finally{
            sh 'sudo chown $USER -R ./src/.terraform'
        }
    }

    stage('Front-end') {
        docker.image('node:7-alpine').inside {
            sh 'node --version'
        }
    }
    
    stage('artifacts') {
        copyArtifacts filter: 'version.txt', fingerprintArtifacts: false, projectName: 'Philips-Platform/microservice.template/master'
        sh 'cat version.txt'
    }
}