def registry = 'https://abduldevops.jfrog.io'
def imageName= 'abduldevops.jfrog.io/abdul-docker-local/namtrend'
def version= '2.1.3'
def app // Declare the app variable at the top level

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

        stage("Jar Publish") {
            steps {
                script {
                    echo '<--------------- Jar Publish Started --------------->'
                    def server = Artifactory.newServer url: registry + "/artifactory", credentialsId: "jfrog-artifact-creds"
                    def properties = "buildid=${env.BUILD_ID},commitid=${GIT_COMMIT}"
                    def uploadSpec = """{
                        "files": [
                            {
                                "pattern": "jarstaging/(*)",
                                "target": "abdul-lib-snapshot-libs-release-local/{1}",
                                "flat": "false",
                                "props": "${properties}",
                                "exclusions": [ "*.sha1", "*.md5"]
                            }
                        ]
                    }"""
                    echo "Upload spec: ${uploadSpec}"

                    // Verify if files exist in the specified pattern
                    echo "Listing files in /home/ubuntu/jenkins/workspace/Nam-trend-multibranch_main/jarstaging/com/valaxy/demo-workshop/2.1.3/:"
                    sh "ls -l /home/ubuntu/jenkins/workspace/Nam-trend-multibranch_main/jarstaging/com/valaxy/demo-workshop/2.1.3/"

                    try {
                        def buildInfo = server.upload(uploadSpec)
                        buildInfo.env.collect()
                        server.publishBuildInfo(buildInfo)
                        echo '<--------------- Jar Publish Ended --------------->'
                    } catch (Exception e) {
                        echo "Error during upload: ${e.message}"
                        if (e.cause != null) {
                            echo "Cause: ${e.cause}"
                        }
                        throw e
                    }
                }
            }
        }

        stage("Docker Build") {
            steps {
                script {
                    echo '<--------------- Docker Build Started --------------->'
                    app = docker.build(imageName + ":" + version)
                    echo '<--------------- Docker Build Ends --------------->'
                }
            }
        }

        stage("Docker Publish") {
            steps {
                script {
                    echo '<--------------- Docker Publish Started --------------->'
                    docker.withRegistry(registry, 'jfrog-artifact-creds') {
                        app.push()
                    }
                    echo '<--------------- Docker Publish Ended --------------->'
                }
            }
        }

        stage ("Deploy"){
            steps {
                script {
                    echo '<------------------- Heml Deploy Started --------------->'
                    sh 'helm install namtrend namtrend-0.1.0.tgz'
                    echo '<------------------- Heml Deploy Ends --------------->'
                }
            }
        }
    }
}


