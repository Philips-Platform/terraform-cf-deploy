def createInfraBackendWorkspace(workspaceJsonFile, cfSpaceName, apiToken){
    sh "sed -i 's/#spacename#/$cfSpaceName/g' $workspaceJsonFile"
    sh "sed -i 's/#subname#/infra/g' $workspaceJsonFile"
    sh "curl --header 'Authorization: Bearer $apiToken' --header 'Content-Type: application/vnd.api+json' --request PATCH --data '$workspaceJsonFile' https://app.terraform.io/api/v2/organizations/Philips-platform/workspaces"
    return "platform-$cfSpaceName-infra"
}
def createAppBackendWorkspace(workspaceJsonFile, cfSpaceName, apiToken, appName){
    sh "sed -i 's/#spacename#/$cfSpaceName/g' $workspaceJsonFile"
    sh "sed -i 's/#subname#/$appName/g' $workspaceJsonFile"
    sh "curl --header 'Authorization: Bearer $apiToken' --header 'Content-Type: application/vnd.api+json' --request PATCH --data '$workspaceJsonFile' https://app.terraform.io/api/v2/organizations/Philips-platform/workspaces"
    return "platform-$cfSpaceName-$appName" 
}
def updateInfraBackendWorkspace(cfSpaceName){
    sh "sed -i 's/#spacename#/$cfSpaceName/g' ./backends/backend-services.hcl"
}
def updateAppBackendWorkspace(cfSpaceName, appName){
    sh "sed -i 's/#spacename#/$cfSpaceName/g' ./backends/backend-app.hcl"
    sh "sed -i 's/#appname#/$appName/g' ./backends/backend-app.hcl"
}
def deployServices(TERRAFORMINPUT, cfSpaceName){
    // update the services to be deployed
    sh 'cp ./templates/services.json ./main.tf.json'
    sh 'terraform init -plugin-dir=../plugins/linux_amd64 -backend-config=./backends/backend-services.hcl'
    // terraform validation
    sh 'terraform validate'
    sh 'terraform fmt -check -diff'
    sh "terraform refresh -var-file=$TERRAFORMINPUT -var=CLOUD_FOUNDRY_SPACE=$cfSpaceName"
    // apply the terraform configuration
    // dont destroy services everytime
    //sh 'terraform destroy -var-file="$TERRAFORMINPUT" -auto-approve'
    sh "terraform apply -var-file=$TERRAFORMINPUT -var=CLOUD_FOUNDRY_SPACE=$cfSpaceName -auto-approve"
}
def deployApp(TERRAFORMINPUT){
    // update the modules to be deployed 
    sh 'cp -rf ./templates/sample-app.json ./main.tf.json'
    // update the service name in the template
    sh "sed -i 's/#APP-NAME#/$MicroserviceName/g' ./main.tf.json"
    sh "sed -i 's/#IMAGE-NAME#/$DockerImageRepoName/g' ./main.tf.json"
    sh "sed -i 's/#IMAGE-TAG#/$upstreamJobBuildNumber/g' ./main.tf.json"

    sh 'terraform init -plugin-dir=../plugins/linux_amd64 -backend-config=./backends/backend-app.hcl'
    
    // terraform validation
    sh 'terraform validate'
    sh 'terraform fmt -check -diff'                 
    sh "terraform refresh -var-file=$TERRAFORMINPUT -var=CLOUD_FOUNDRY_SPACE=$cfSpaceName"       
    // apply the terraform configuration    
    sh "terraform destroy -var-file=$TERRAFORMINPUT -var=CLOUD_FOUNDRY_SPACE=$cfSpaceName -auto-approve -var=stop_apps=false"
    sh "terraform apply -var-file=$TERRAFORMINPUT -var=CLOUD_FOUNDRY_SPACE=$cfSpaceName -auto-approve -var=stop_apps=false"
}
node('docker') {
    /* Requires the Docker Pipeline plugin to be installed */
    stage('checkout'){
        checkout scm
    }
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
                trim: true)
            ])
        ])
    stage('CF deployment') {
        docker.image('hashicorp/terraform:latest').inside('--entrypoint=""') {
            withCredentials([file(credentialsId: 'terraform.rc', variable: 'TERRAFORMRC')]) {
                dir("${env.WORKSPACE}/src"){
                    withEnv(["TF_CLI_CONFIG_FILE=${TERRAFORMRC}"]){
                        withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId:'terraform-token', usernameVariable: 'TERRAFORM-TOKEN', passwordVariable: 'TOKEN']]) {
                            withCredentials([file(credentialsId: 'workspace.json', variable: 'WORKSPACEJSON')]) {
                                createInfraBackendWorkspaceWorkspace('$WORKSPACEJSON', '$CFSpaceName', '$TOKEN')
                                createAppBackendWorkspaceWorkspace('$WORKSPACEJSON', '$CFSpaceName', '$TOKEN', '$MicroserviceName')
                                updateInfraBackendWorkspace('$CFSpaceName')
                                updateAppBackendWorkspace('$CFSpaceName','$MicroserviceName')
                            }
                        }
                        withCredentials([file(credentialsId: 'terraform-input.json', variable: 'TERRAFORMINPUT')]) {
                            sh 'unzip ../plugins/linux_amd64/terraform-provider-aws_v2.62.zip -d ../plugins/linux_amd64/'
                            deployServices('$TERRAFORMINPUT', '$CFSpaceName')
                            deployApp('$TERRAFORMINPUT', '$CFSpaceName')
                        }
                    }
                }   
            }
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