pipeline {
    agent {
        docker {
            image 'backflow/docker-maven-alpine' 
            args '-v /root/.m2:/root/.m2 \
            	  -v /root/.ssh/:/root/.ssh \
                  -v /var/run/docker.sock:/var/run/docker.sock'
        }
    }
    options {
        skipStagesAfterUnstable()
    }
    stages {
        stage('Build') {
            steps {
                sh 'mvn -B -DskipTests clean package'
            }
        }
        stage('Test') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }
        stage('Deliver') {
            steps {
                sh './jenkins/deliver.sh'
            }
        }
    }
}