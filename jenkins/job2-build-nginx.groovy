job('build-nginx') {
    description('Build the nginx Docker image and upload to DockerHub')
    
    parameters {
        stringParam('GIT_REPO', 'https://github.com/En-ash/elbit.git', 'Git repository URL')
        stringParam('BRANCH', 'main', 'Git branch to build')
        stringParam('DOCKER_IMAGE_NAME', 'ayashben/el-nginx', 'Docker image name')
        stringParam('DOCKER_APP_NAME', 'el-nginx', 'Docker app name')
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
    }
    steps {
        shell('''
            #!/bin/bash
            set -e
            
            docker build -t ${DOCKER_APP_NAME}:${DOCKER_TAG} -t ${DOCKER_IMAGE_NAME}:${DOCKER_TAG} -f nginx.Dockerfile .
            
            # Login to DockerHub
            echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin

            # Push image
            docker push ${DOCKER_IMAGE_NAME}:${DOCKER_TAG}
        '''.stripIndent())

    }

    publishers {
        cleanWs {
            deleteDirs(true)
        }
        postBuildScript {
            buildSteps {
                shell('docker ps -aq | xargs -r docker stop | xargs -r docker rm || true')
            }
        }
    }
}