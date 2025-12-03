
pipeline {
    agent { label 'maven' }

    environment {
        JAVA_HOME = '/usr/lib/jvm/java-17-openjdk-amd64'
        PATH = "${JAVA_HOME}/bin:${env.PATH}"
        SONAR_TOKEN = credentials('SONAR_TOKEN')
    }

    stages {
        stage('Build') {
            steps {
                sh 'mvn clean install'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Package') {
            steps {
                sh 'mvn package'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    echo "----------- SonarQube Analysis Started ----------"
                    sh 'mvn sonar:sonar -Dsonar.projectKey=mypractaxi_mypractaxi -Dsonar.organization=mypractaxi -Dsonar.host.url=https://sonarcloud.io -Dsonar.token=${SONAR_TOKEN}'
                    echo "----------- SonarQube Analysis Completed ----------"
                }
            }
        }

        stage('Publish JAR to JFrog') {
            steps {
                script {
                    echo "----------- Publishing JAR to JFrog Artifactory ----------"

                    def server = Artifactory.newServer(
                        url: 'https://mypractaxi.jfrog.io/artifactory',
                        credentialsId: 'jfrog-cred'
                    )

                    def uploadSpec = """{
                        "files": [
                            {
                                "pattern": "server/target/*.jar",
                                "target": "taxi-libs-release-local/myapp/${BUILD_NUMBER}/"
                            }
                        ]
                    }"""

                    server.upload(uploadSpec)

                    echo "----------- JAR Published Successfully ----------"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "----------- Building Docker Image ----------"
                    sh 'docker build -t taxi01.jfrog.io/taxi-docker-local/taxiapp:1.0.${BUILD_NUMBER} .'
                }
            }
        }

        stage('Push Docker Image to JFrog') {
            steps {
                script {
                    echo "----------- Pushing Docker Image to JFrog ----------"

                    withCredentials([usernamePassword(credentialsId: 'jfrog-cred', usernameVariable: 'JFROG_USER', passwordVariable: 'JFROG_PASS')]) {
                        sh '''
                            echo "${JFROG_PASS}" | docker login taxi01.jfrog.io -u "${JFROG_USER}" --password-stdin
                            docker push taxi01.jfrog.io/taxi-docker-local/taxiapp:1.0.${BUILD_NUMBER}
                        '''
                    }

                    echo "----------- Docker Image Pushed Successfully ----------"
                }
            }
        }
    }

    post {
        success {
            echo '✅ Build completed successfully!'
        }
        failure {
            echo '❌ Build failed!'
        }
    }
}
