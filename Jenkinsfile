library identifier: 'jenkins.shared@master', retriever: modernSCM(
  [$class: 'GitHubSCMSource',
    configuredByUrl: true,
    credentialsId: "3f615097-f7bf-4cc9-bc7c-7c79e11a97e1",
    repoOwner: "Philips-Platform",
    repository: "jenkins.shared",
    repositoryUrl: "https://github.com/Philips-Platform/jenkins.shared.git"])


node('docker') {
    /* Requires the Docker Pipeline plugin to be installed */

    stage('Deploy sample app') {
        withEnv(["DOCKER_REGISTRY_USERNAME=${DOCKER_REGISTRY_USERNAME}", 
        "DOCKER_REGISTRY_PASSWORD=${DOCKER_REGISTRY_PASSWORD}", 
        "CLOUD_FOUNDRY_USERNAME=${CLOUD_FOUNDRY_USERNAME}",
        "CLOUD_FOUNDRY_PASSWORD=${CLOUD_FOUNDRY_PASSWORD}",
        "CLOUD_FOUNDRY_ORG=${CLOUD_FOUNDRY_ORG}",
        "CLOUD_FOUNDRY_SPACE=${CLOUD_FOUNDRY_SPACE}",
        "DOCKER_REGISTRY_NAMESPACE=${DOCKER_REGISTRY_NAMESPACE}",
        "TARGET=module.gradle-sample-app"
        ])
        def data = {
            "DOCKER_REGISTRY_USERNAME": "$DOCKER_REGISTRY_USERNAME",
            "DOCKER_REGISTRY_PASSWORD": "$DOCKER_REGISTRY_PASSWORD",
            "CLOUD_FOUNDRY_USERNAME": "$CLOUD_FOUNDRY_USERNAME",
            "CLOUD_FOUNDRY_PASSWORD": "$CLOUD_FOUNDRY_PASSWORD",
            "CLOUD_FOUNDRY_ORG": "$CLOUD_FOUNDRY_ORG",
            "CLOUD_FOUNDRY_SPACE": "$CLOUD_FOUNDRY_SPACE",
            "DOCKER_REGISTRY_NAMESPACE": "$DOCKER_REGISTRY_NAMESPACE"
        }
        writeFile file: ".tfvars.json", text: data
        terraformExec()
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
