def registry = 'https://abduldevops.jfrog.io'
pipeline {
    agent { label 'maven' }

    environment {
        PATH = "/opt/apache-maven-3.9.4/bin:$PATH"
    }

    stages {
        stage("build") {
            steps {
                echo "------- build started -------"
                sh "mvn clean deploy -Dmaven.test.skip=true"
                echo "------- build completed -------"
            }
        }

        stage("test") {
            steps {
                echo "------- unit test started -------"
                sh "mvn surefire-report:report"
                echo "------- unit test completed -------"
            }
        }

        stage('SonarQube analysis') {
            environment {
                scannerHome = tool 'abdul-sonar-scanner' // sonar scanner name should be same as what we have defined in the tools
            }
            steps {
                withSonarQubeEnv('abdul-sonarqube-server') { // in the steps we are adding our sonar cube server that is with Sonar Cube environment.
                    sh "${scannerHome}/bin/sonar-scanner" // This is going to communicate with our sonar cube server and send the analysis report.
                }
            }
        }

        stage('Quality Gate') {
            steps {
                script {
                    timeout(time: 1, unit: 'HOURS') {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "Pipeline aborted due to quality gate failure: ${qg.status}"
                        }
                    }
                }
            }
        }
        //add another stage here
        stage("Jar Publish") {
        steps {
            script {
                    echo '<--------------- Jar Publish Started --------------->'
                     def server = Artifactory.newServer url:registry+"/artifactory" ,  credentialsId:"jfrog-artifactory"
                     def properties = "buildid=${env.BUILD_ID},commitid=${GIT_COMMIT}";
                     def uploadSpec = """{
                          "files": [
                            {
                              "pattern": "jarstaging/(*)",
                              "target": "abdul-lib-snapshot-libs-release-local/{1}",
                              "flat": "false",
                              "props" : "${properties}",
                              "exclusions": [ "*.sha1", "*.md5"]
                            }
                         ]
                     }"""
                     def buildInfo = server.upload(uploadSpec)
                     buildInfo.env.collect()
                     server.publishBuildInfo(buildInfo)
                     echo '<--------------- Jar Publish Ended --------------->'  
            
            }
        }
        }
    }
}

