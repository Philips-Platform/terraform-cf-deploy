node('docker') {
    /* Requires the Docker Pipeline plugin to be installed */
    stage('checkout'){
        checkout scm
    }
    stage('Deploy sample app') {
        docker.image('hashicorp/terraform:latest').inside('--entrypoint=""') {
            sh 'cd ./src/'
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
            configFileProvider([configFile(fileId: 'terraform-input', variable: 'TERRAFORM_SETTINGS')]) {
                //dir("${env.WORKSPACE}/src"){
                    sh 'pwd'
                    sh 'terraform init -var-file="./variables/default.tfvars" ./src'
                    // terraform validation
                    sh 'terraform validate'
                    // apply the terraform configuration
                    sh 'terraform apply -var-file="$TERRAFORM_SETTINGS" -var-file="./variables/default.tfvars" -auto-approve -target=module.gradle-sample-app'        
                //}
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
