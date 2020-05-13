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
}
