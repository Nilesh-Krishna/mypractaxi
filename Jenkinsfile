def imageName = 'taxi01.jfrog.io/taxi-docker-local/taxiapp'
def version   = '1.0.1'
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

                    // ✅ Create Artifactory server connection
                    def server = Artifactory.newServer(
                        url: 'https://mypractaxi.jfrog.io/artifactory',
                        credentialsId: 'jfrog-cred' // Jenkins credentials ID
                    )

                    // ✅ Define upload spec (pattern and target repo)
                    def uploadSpec = """{
                        "files": [
                            {
                                "pattern": "server/target/*.jar",
                                "target": "taxi-libs-release-local/myapp/${BUILD_NUMBER}/"
                            }
                        ]
                    }"""

                    // ✅ Upload artifact
                    server.upload(uploadSpec)

                    echo "----------- JAR Published Successfully ----------"
                }
            }
        }
        stage(" Docker Build ") {
      steps {
        script {
           echo '<--------------- Docker Build Started --------------->'
           app = docker.build(imageName+":"+version)
           echo '<--------------- Docker Build Ends --------------->'
        }
      }
    }
     stage (" Docker Publish "){
        steps {
            script {
               echo '<--------------- Docker Publish Started --------------->'  
                docker.withRegistry(registry, 'jfrog-cred'){
                    app.push()
                }    
               echo '<--------------- Docker Publish Ended --------------->'  
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
