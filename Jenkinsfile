pipeline {
    agent any

    environment {
        IMAGE_NAME = "data-demo-api"
        CONTAINER_NAME = "data-demo-staging"
        STAGING_PORT = "8080"
        HARBOR_REGISTRY = "harbor.mycompany.com"
        HARBOR_PROJECT = "microservices"
    }

    stages {
    /* ====================== CI ZONE ====================== */
    
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/HamzaAITMOUHAOUALLA/data-demo-api.git'
            }
        }
        stage('Fix Line Endings') {
    steps {
        sh '''
        sed -i 's/\r$//' e2e-test.sh
        sed -i 's/\r$//' calculate-version.sh
        sed -i 's/\r$//' update-gitops.sh
        sed -i 's/\r$//' persist-version.sh
        '''
    }
}

        stage('Build') {
            steps {
                sh '''
                if [ -f mvnw ]; then
                  chmod +x mvnw
                  ./mvnw clean package -DskipTests
                else
                  mvn clean package -DskipTests
                fi
                '''
            }
        }

       stage('Unit Tests') {
            steps {
                sh 'mvn test'
            }
        } 
        
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQubeServer') {
                    withCredentials([string(credentialsId: 'jenkinstoken', variable: 'SONAR_TOKEN')]) {
                        sh '''
                        if [ -f mvnw ]; then
                          chmod +x mvnw
                          ./mvnw sonar:sonar -Dsonar.login=$SONAR_TOKEN
                        else
                          mvn sonar:sonar -Dsonar.login=$SONAR_TOKEN
                        fi
                        '''
                    }
                }
            }
        }   
    /* ================== SECURITY ZONE ==================== */
        stage('Docker Build (Local)') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:staging ."
            }
        }
       /* 
    stage('Trivy Security Scan') {
    steps {
        sh '''
        docker run --rm \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v trivy-cache:/root/.cache/ \
        aquasec/trivy:latest image \
        --timeout 10m \
        --scanners vuln \
        --severity HIGH,CRITICAL \
        --exit-code 1 \
        ${IMAGE_NAME}:staging
        '''
    }
}*/
   
    /* ================== STAGING ZONE ===================== */

        stage('Clean Previous Container') {
            steps {
                sh '''
                docker stop ${CONTAINER_NAME} || true
                docker rm ${CONTAINER_NAME} || true
                '''
            }
        }

        stage('Deploy to Staging') {
            steps {
                sh '''
                docker run -d \
                  --name ${CONTAINER_NAME} \
                  --network ci-network \
                  -p ${STAGING_PORT}:8080 \
                  ${IMAGE_NAME}:staging
                '''
            }
        }
        
stage('DATA E2E - Binary Integrity Test') {
    steps {
        sh 'chmod +x e2e-test.sh'
        sh './e2e-test.sh'
    }
}
    /* =================== PROD ZONE ======================= */
    stage('Calculate Version') {
        steps {
            sh 'chmod +x calculate-version.sh'
            sh './calculate-version.sh'
            script {
            env.IMAGE_TAG = readFile('VERSION').trim()
            env.FULL_IMAGE = "${env.IMAGE_NAME}:${env.IMAGE_TAG}"
            }
        }
    }
        stage('Build Production Image') {
            steps {
                sh '''
                echo "Building image with tag ${IMAGE_TAG}"
        
                docker build \
                  -t ${IMAGE_NAME}:${IMAGE_TAG} \
                  .
                '''
            }
        }
        /* stage('Push to Harbor') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'harbor-credentials',
                    usernameVariable: 'HARBOR_USER',
                    passwordVariable: 'HARBOR_PASS'
                )]) {
                    sh '''
                    echo "Tagging image for Harbor..."
        
                    docker tag ${IMAGE_NAME}:${IMAGE_TAG} \
                      ${HARBOR_REGISTRY}/${HARBOR_PROJECT}/${IMAGE_NAME}:${IMAGE_TAG}
        
                    docker tag ${IMAGE_NAME}:${IMAGE_TAG} \
                      ${HARBOR_REGISTRY}/${HARBOR_PROJECT}/${IMAGE_NAME}:latest
        
                    echo "Logging into Harbor..."
                    docker login ${HARBOR_REGISTRY} \
                      -u $HARBOR_USER \
                      -p $HARBOR_PASS
        
                    echo "Pushing version..."
                    docker push ${HARBOR_REGISTRY}/${HARBOR_PROJECT}/${IMAGE_NAME}:${IMAGE_TAG}
        
                    echo "Pushing latest..."
                    docker push ${HARBOR_REGISTRY}/${HARBOR_PROJECT}/${IMAGE_NAME}:latest
        
                    docker logout ${HARBOR_REGISTRY}
                    '''
                }
            }
        }*/

            stage('Update GitOps Repo') {
                steps {
                    withCredentials([usernamePassword(
                        credentialsId: 'git-credentials',
                        usernameVariable: 'GIT_USER',
                        passwordVariable: 'GIT_PASS'
                    )]) {
                        sh '''
                        export FULL_IMAGE=${FULL_IMAGE}
                        chmod +x update-gitops.sh
                        ./update-gitops.sh
                        '''
                    }
                }
            }

        stage('Persist Version') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'git-credentials',
                    usernameVariable: 'GIT_USER',
                    passwordVariable: 'GIT_PASS'
                )]){
                    sh '''
                    chmod +x persist-version.sh
                    git remote set-url origin https://${GIT_USER}:${GIT_PASS}@github.com/HamzaAITMOUHAOUALLA/data-demo-api.git
                    ./persist-version.sh
                    '''
                    }
                }
                }
            }

    post {
        always {
            sh 'docker logout || true'
        }
    }
}
