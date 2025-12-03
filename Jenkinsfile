
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

            def jarFile = './server/target/server.jar' // or use dynamic find command if needed
            def jfrogUrl = 'https://mypractaxi.jfrog.io/ui/repos/tree/General/taxi-libs-release'

            withCredentials([usernamePassword(credentialsId: 'jfrog-cred', usernameVariable: 'JFROG_USER', passwordVariable: 'JFROG_PASS')]) {
                sh '''
                    curl -u ${JFROG_USER}:${JFROG_PASS} \
                    -T ./server/target/server.jar \
                    https://mycompany.jfrog.io/artifactory/libs-release-local/myapp/${BUILD_NUMBER}/$(basename ./server/target/server.jar)
                '''
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
