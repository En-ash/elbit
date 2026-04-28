pipeline {
    agent any
    

    stages {    
       
        stage('Checkout') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/En-ash/elbit.git',
                        credentialsId: 'self-imp-token'
                    ]],
                    extensions: [
                        [$class: 'SparseCheckoutPaths', sparseCheckoutPaths: [
                            [$class: 'SparseCheckoutPath', path: 'app/']
                        ]]
                    ]
                ])
                
                script {
                    env.BRANCH_NAME = 'main'
                }
            }
        }

        stage('Unpack App and Test Reachable'){
            steps{
                sh '''
                sudo docker build -t ayashben/el-app:latest -t el-app:latest -f app.Dockerfile .
                sudo docker build -t ayashben/el-nginx:latest  -t el-nginx:latest -f nginx.Dockerfile .
                sudo docker compose up -d
                '''
                sleep(20)

                sh '''
                    curl --silent --fail http://localhost:8080
                '''

                sh '''sudo docker compose down'''
            }
        }
        
        stage('Upload Working Image to DockerHub'){
            steps {
                withCredentials([usernamePassword(
                credentialsId: 'dockerhub-credentials',
                usernameVariable: 'DOCKER_USER',
                passwordVariable: 'DOCKER_PASS'
                )])
                {
                    sh '''echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'''
                    sh '''docker info | grep Username'''
                    sh '''docker push el-nginx:latest ayashben/el-nginx:latest'''
                }
            }
        }
    }
    post {
        always {
            cleanWs()
            sh '''
                docker ps -aq | xargs -r docker stop
                docker ps -aq | xargs -r docker rm
                '''
        }
        success {
        }
        failure {
        }
    }
}