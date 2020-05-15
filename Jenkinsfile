node('docker') {
    /* Requires the Docker Pipeline plugin to be installed */
    stage('checkout'){
        checkout scm
    }
    stage('CF deployment') {
        docker.image('hashicorp/terraform:latest').inside('--entrypoint=""') {
            // withEnv(["DOCKER_REGISTRY_USERNAME=${DOCKER_REGISTRY_USERNAME}", 
            // "DOCKER_REGISTRY_PASSWORD=${DOCKER_REGISTRY_PASSWORD}", 
            // "CLOUD_FOUNDRY_USERNAME=${CLOUD_FOUNDRY_USERNAME}",
            // "CLOUD_FOUNDRY_PASSWORD=${CLOUD_FOUNDRY_PASSWORD}",
            // "CLOUD_FOUNDRY_ORG=${CLOUD_FOUNDRY_ORG}",
            // "CLOUD_FOUNDRY_SPACE=${CLOUD_FOUNDRY_SPACE}",
            // "DOCKER_REGISTRY_NAMESPACE=${DOCKER_REGISTRY_NAMESPACE}"
            // ]){
            //     def data = {
            //         "DOCKER_REGISTRY_USERNAME": "$DOCKER_REGISTRY_USERNAME",
            //         "DOCKER_REGISTRY_PASSWORD": "$DOCKER_REGISTRY_PASSWORD",
            //         "CLOUD_FOUNDRY_USERNAME": "$CLOUD_FOUNDRY_USERNAME",
            //         "CLOUD_FOUNDRY_PASSWORD": "$CLOUD_FOUNDRY_PASSWORD",
            //         "CLOUD_FOUNDRY_ORG": "$CLOUD_FOUNDRY_ORG",
            //         "CLOUD_FOUNDRY_SPACE": "$CLOUD_FOUNDRY_SPACE",
            //         "DOCKER_REGISTRY_NAMESPACE": "$DOCKER_REGISTRY_NAMESPACE"
            //     }
            //     writeFile file: ".tfvars.json", text: data
            // }
            //configFileProvider([configFile(fileId: 'terraform-input', variable: 'TERRAFORM_SETTINGS')]) {
            withCredentials([file(credentialsId: 'terraform.rc', variable: 'TERRAFORMRC')]) {
                dir("${env.WORKSPACE}/src"){
                    withEnv(["TF_CLI_CONFIG_FILE=${TERRAFORMRC}"]){
                        sh 'unzip ../plugins/linux_amd64/terraform-provider-aws_v2.62.zip -d ../plugins/linux_amd64/'
                        
                        //sh 'cp $TERRAFORM_SETTINGS terraform-input.json'
                        sh 'terraform init -plugin-dir=../plugins/linux_amd64 -var-file=./variables/default.auto.tfvars'
                        // terraform validation
                        sh 'terraform validate'
                        // apply the terraform configuration
                        withCredentials([file(credentialsId: 'terraform-input.json', variable: 'TERRAFORMINPUT')]) {    
                            sh 'terraform apply -var-file="./variables/default.auto.tfvars" -var-file="$TERRAFORMINPUT" -target=module.gradle-sample-app -var="global_stopped=false" -auto-approve'
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
