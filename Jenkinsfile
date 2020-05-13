node('docker') {
    /* Requires the Docker Pipeline plugin to be installed */

    stage('Back-end') {
        docker.image('maven:3-alpine').inside {
            sh 'mvn --version'
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
