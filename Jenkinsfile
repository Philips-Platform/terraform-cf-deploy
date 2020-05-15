node('docker') {
    /* Requires the Docker Pipeline plugin to be installed */
    stage('checkout'){
        checkout scm
    }
    stage('Deploy sample app') {
        docker.image('ubuntu:18.04').inside("--user=root") {
            sh 'apt-get update'
            sh 'apt-get -y upgrade'
            sh 'apt-get install unzip'
            sh 'wget https://releases.hashicorp.com/terraform/0.12.25/terraform_0.12.25_linux_amd64.zip -O terraform.zip'
            sh 'unzip terraform.zip'
            sh 'mv terraform /usr/local/bin'
            sh 'rm terraform.zip'
            sh 'terraform -v'
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
                    sh 'terraform init -plugin-dir=./plugins/linux_amd64 -var-file=./src/variables/default.tfvars ./src'
                    // terraform validation
                    sh 'terraform validate'
                    // apply the terraform configuration
                    sh 'terraform apply -var-file="$TERRAFORM_SETTINGS" -var-file="./src/variables/default.tfvars" -target=module.gradle-sample-app -var="global_stopped=false" -auto-approve ./src'
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
