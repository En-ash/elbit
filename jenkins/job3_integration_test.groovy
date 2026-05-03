// Job DSL - Job 3: Integration Test - Fetch, Compose, Test
job('integration-test') {
    description('Fetch both images from DockerHub, compose them, and test HTTP 200')
    parameters {
        stringParam('APP_IMAGE', 'ayashben/el-app:latest', 'App Docker image to pull')
        stringParam('NGINX_IMAGE', 'ayashben/el-nginx:latest', 'Nginx Docker image to pull')
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

# Login to DockerHub
echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin

# Pull both images
docker pull ${APP_IMAGE}
docker pull ${NGINX_IMAGE}
''')
        shell('''
#!/bin/bash
set -e

# Create docker-compose.yml for testing (Git has the compose, but I did this without git, only image pulling)

cat > docker-compose.yaml << 'EOF'
services:
  app:
    image: ${APP_IMAGE}
    container_name: el-app
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    expose:
      - "9090"
    restart: unless-stopped

  nginx:
    image: ${NGINX_IMAGE}
    container_name: el-nginx
    ports:
      - "8090:8080"
    depends_on:
      - app
    restart: unless-stopped
EOF

# Run compose
docker compose -f docker-compose.yaml up -d
sleep 20

curl --silent --fail http://localhost:80:90

echo "SUCCESS: Received HTTP 200 and body 'ok'"

# Clean up
docker compose -f docker-compose.yaml down
''')
    }
}