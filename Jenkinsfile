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
                trim: true)
            ])
        ])
    stage('CF deployment') {
        docker.image('hashicorp/terraform:latest').inside('--entrypoint=""') {
            withCredentials([file(credentialsId: 'terraform.rc', variable: 'TERRAFORMRC')]) {
                dir("${env.WORKSPACE}/src"){
                    withEnv(["TF_CLI_CONFIG_FILE=${TERRAFORMRC}"]){
                        sh 'unzip ../plugins/linux_amd64/terraform-provider-aws_v2.62.zip -d ../plugins/linux_amd64/'

                        // Deploy - Services

                        sh 'cp ./templates/services.json ./main.tf.json'
                        sh 'terraform init -plugin-dir=../plugins/linux_amd64 -backend-config=./backends/backend-services.hcl'
                        // terraform validation
                        sh 'terraform validate'
                        
                        // apply the terraform configuration
                        withCredentials([file(credentialsId: 'terraform-input.json', variable: 'TERRAFORMINPUT')]) {
                            // dont destroy services everytime
                            //sh 'terraform destroy -var-file="$TERRAFORMINPUT" -auto-approve'
                            sh 'terraform apply -var-file="$TERRAFORMINPUT" -auto-approve'
                        }

                        // Deploy - App
                        sh 'cp -rf ./templates/sample-app.json ./main.tf.json'
                        sh "sed -i 's/#APP-NAME#/$MicroserviceName/g' ./main.tf.json"
                        sh "sed -i 's/#IMAGE-NAME#/$DockerImageRepoName/g' ./main.tf.json"
                        sh "sed -i 's/#IMAGE-TAG#/$upstreamJobBuildNumber/g' ./main.tf.json"

                        sh 'terraform init -plugin-dir=../plugins/linux_amd64 -backend-config=./backends/backend-app.hcl'
                        // terraform validation
                        sh 'terraform validate'
                                                
                        // apply the terraform configuration
                        withCredentials([file(credentialsId: 'terraform-input.json', variable: 'TERRAFORMINPUT')]) {
                            sh 'terraform destroy -var-file="$TERRAFORMINPUT" -auto-approve -var=stop_apps=false'
                            sh 'terraform apply -var-file="$TERRAFORMINPUT" -auto-approve -var=stop_apps=false'
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