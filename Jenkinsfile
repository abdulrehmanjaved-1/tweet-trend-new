pipeline {
    agent { label 'maven' }
    
    environment {
        PATH = "/opt/apache-maven-3.9.4/bin:$PATH"
    }
    
    stages {
        stage("build") {
            steps {
                echo "-------- build started --------"
                sh 'mvn clean deploy -Dmaven.test.skip=true'
                echo "-------- build completed --------"
            }
        }
        
        stage("test") {
            steps {
                echo "-------- unit test started --------"
                sh 'mvn surefire-report:report'
                echo "-------- unit test completed --------"
            }
        }
        
        stage('SonarQube analysis') {
            environment {
                scannerHome = tool 'abdulrehman-sonar-scanner' // sonar scanner name should be the same as what we have defined in the tools
            }
            steps {
                // in the steps we are adding our sonar cube server that is with Sonar Cube environment.
                withSonarQubeEnv('abdulrehman-sonarqube-server') {
                    sh "${scannerHome}/bin/sonar-scanner" // This is going to communicate with our SonarQube server and send the analysis report.
                }
            }
        }
    }
}
