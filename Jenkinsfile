pipeline {
    agent any
    environment {
        DOCKER_IMAGE_NAME = "nikhilagarkar/train-schedule"
    }

    stages {
        stage('Build') {
            steps {
                echo 'Running build automation'
                script {
                    try {
                        sh 'node --version'
                        sh './gradlew build --no-daemon'
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        throw e
                    }
                }
            }
        }

        stage('Build Docker Image') {
            when {
                branch 'master'
            }
            steps {
                script {
                    app = docker.build("${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}")
                    app.inside {
                        sh 'npm install'
                        sh 'npm run build'
                    }
                }
            }
        }

        stage('Push Docker Image') {
            when {
                branch 'master'
            }
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'docker_hub_login') {
                        app.push("${DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}")
                        app.push("${DOCKER_IMAGE_NAME}:latest")
                    }
                }
            }
        }

        stage('CanaryDeploy') {
            when {
                branch 'master'
            }
            environment { 
                CANARY_REPLICAS = 1
            }
            steps {
                kubernetesDeploy(
                    kubeconfigId: 'kubeconfig',
                    configs: 'train-schedule-kube-canary.yml',
                    enableConfigSubstitution: true
                )
            }
        }

        stage('DeployToProduction') {
            when {
                branch 'master'
            }
            environment { 
                CANARY_REPLICAS = 0
            }
            steps {
                input 'Deploy to Production?'
                milestone(1)
                kubernetesDeploy(
                    kubeconfigId: 'kubeconfig',
                    configs: 'train-schedule-kube.yml',
                    enableConfigSubstitution: true
                )
            }
        }
    }

    post {
        success {
            archiveArtifacts artifacts: 'dist/trainSchedule.zip'
        }
    }
}
