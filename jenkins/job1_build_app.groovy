// Job DSL - Job 1: Build App and Upload to DockerHub
job('build-app') {
    description('Build the application Docker image and upload to DockerHub')
    parameters {
        stringParam('GIT_REPO', 'https://github.com/En-ash/elbit.git', 'Git repository URL')
        stringParam('BRANCH', 'main', 'Git branch to build')
        stringParam('DOCKER_IMAGE_NAME', 'ayashben/el-app', 'Docker image name')
        stringParam('DOCKER_APP_NAME', 'el-app', 'Docker app name')
        stringParam('DOCKER_TAG', 'latest', 'Docker image tag')
    }

    scm {
        git {
            remote {
                url('$GIT_REPO')
                credentials('self-imp-token')
            }
            branch('*/' + '$BRANCH')
        }
    }
    wrappers {
        credentialsBinding {
            usernamePassword('DOCKER_USER', 'DOCKER_PASS', 'dockerhub-credentials')
        }
        preBuildCleanup()
    }

    steps {
        shell('''
            #!/bin/bash
            set -e
            cd app
            docker build -t ${DOCKER_APP_NAME}:${DOCKER_TAG} -t ${DOCKER_IMAGE_NAME}:${DOCKER_TAG} -f app.Dockerfile .

            docker run -d --name ${DOCKER_APP_NAME}-test -p 9090:9090 ${DOCKER_APP_NAME}:${DOCKER_TAG}
            sleep 10
            curl --silent --fail http://localhost:9090
            
            # Login to DockerHub
            echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin

            # Push image
            docker push ${DOCKER_IMAGE_NAME}:${DOCKER_TAG}
        ''')

    }

    publishers {
        postBuildTask {
            task('.*', '''
                docker stop $(docker ps -aq) || true
                docker rm $(docker ps -aq) || true
            ''')
        }
    }

}