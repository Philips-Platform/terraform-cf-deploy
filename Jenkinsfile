node('docker') {
    /* Requires the Docker Pipeline plugin to be installed */
    stage('checkout'){
        checkout scm
    }
    properties([
            parameters([string(
                defaultValue: 'latest', 
                description: '', 
                name: 'upstreamJobBuildNumber', 
                trim: false)
            ])
        ])
    echo "buildTag: $upstreamJobBuildNumber"
    stage('CF deployment') {
        docker.image('hashicorp/terraform:latest').inside('--entrypoint=""') {
            withCredentials([file(credentialsId: 'terraform.rc', variable: 'TERRAFORMRC')]) {
                dir("${env.WORKSPACE}/src"){
                    withEnv(["TF_CLI_CONFIG_FILE=${TERRAFORMRC}"]){
                        sh 'unzip ../plugins/linux_amd64/terraform-provider-aws_v2.62.zip -d ../plugins/linux_amd64/'
                        sh 'terraform init -plugin-dir=../plugins/linux_amd64 -var-file=./variables/default.auto.tfvars'
                        // terraform validation
                        sh 'terraform validate'
                        // apply the terraform configuration
                        withCredentials([file(credentialsId: 'terraform-input.json', variable: 'TERRAFORMINPUT')]) {    
                            sh 'terraform apply -var-file="./variables/default.auto.tfvars" -var-file="$TERRAFORMINPUT" -target=module.gradle-sample-app -var="global_stopped=false" -auto-approve -var=build_tag=$upstreamJobBuildNumber'
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
