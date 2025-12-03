
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

        stage('Publish to JFrog') {
            steps {
                script {
                    echo "----------- Publishing JAR to JFrog Artifactory ----------"

                    // ✅ Dynamically find the first valid JAR (ignoring sources/tests)
                    def jarFile = sh(script: "find . -name '*.jar' | grep -v 'sources' | grep -v 'tests' | head -n 1", returnStdout: true).trim()

                    // ✅ JFrog Artifactory URL (replace with your actual repo path)
                    def jfrogUrl = 'https://<your-jfrog-domain>/artifactory/<your-repo>'

                    // ✅ Securely use Jenkins credentials
                    withCredentials([usernamePassword(credentialsId: 'JFROG_CREDENTIALS', usernameVariable: 'JFROG_USER', passwordVariable: 'JFROG_PASS')]) {
                        sh """
                            curl -u ${JFROG_USER}:${JFROG_PASS} \
                            -T ${jarFile} \
                            ${jfrogUrl}/myapp/${BUILD_NUMBER}/$(basename ${jarFile})
                        """
                    }

                    echo "----------- JAR Published Successfully ----------"
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
