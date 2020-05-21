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
def deployServices(TERRAFORMINPUT){
    // update the services to be deployed
    sh 'cp ./templates/services.json ./main.tf.json'
    sh 'terraform init -plugin-dir=../plugins/linux_amd64 -backend-config=./backends/backend-services.hcl'
    // terraform validation
    sh 'terraform validate'
    sh 'terraform fmt -check -diff'
    sh "terraform refresh -var-file=$TERRAFORMINPUT -var=CLOUD_FOUNDRY_SPACE=$CFSpaceName"
    // apply the terraform configuration
    // dont destroy services everytime
    //sh 'terraform destroy -var-file="$TERRAFORMINPUT" -auto-approve'
    sh "terraform apply -var-file=$TERRAFORMINPUT -var=CLOUD_FOUNDRY_SPACE=$CFSpaceName -auto-approve"
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
    sh "terraform refresh -var-file=$TERRAFORMINPUT -var=CLOUD_FOUNDRY_SPACE=$CFSpaceName"       
    // apply the terraform configuration    
    sh "terraform destroy -var-file=$TERRAFORMINPUT -var=CLOUD_FOUNDRY_SPACE=$CFSpaceName -auto-approve -var=stop_apps=false"
    sh "terraform apply -var-file=$TERRAFORMINPUT -var=CLOUD_FOUNDRY_SPACE=$CFSpaceName -auto-approve -var=stop_apps=false"
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
        docker.image('hashicorp/terraform:latest').inside('--entrypoint="" --user=root') {
            withCredentials([file(credentialsId: 'terraform.rc', variable: 'TERRAFORMRC')]) {
                dir("${env.WORKSPACE}/src"){
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
                            sh 'unzip ../plugins/linux_amd64/terraform-provider-aws_v2.62.zip -d ../plugins/linux_amd64/'
                            deployServices("${TERRAFORMINPUT}")
                            deployApp("${TERRAFORMINPUT}")
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