pipeline {
    agent any 
    tools {
        maven "maven-3.x"
        nodejs "nodejs-8.x"
    }
    stages {
        stage('Deploy And Test'){
            steps {
                script {
                    // Get all the environments available in the origanization
                    def response = httpRequest authentication:'apigee-credentials', url: 'https://api.enterprise.apigee.com/v1/organizations/' + env.APIGEE_ORGANIZATION + '/environments'
                    def environments = (new groovy.json.JsonSlurper()).parseText(response.content)
                    // Get all the remote branches in the repository
                    def branches = sh(returnStdout: true, script: "git branch -r | sed 's@origin/@@'").split()
                    // Get all the environments for which there is no branch. There should only be one, the environment that we are using as development environment.
                    def result = environments.findAll { !(it in branches) }
                    if(result.size() > 1) {
                        echo "You have forgotten to create the branch for one of your environments"
                        currentBuild.result = 'FAILURE'
                        sh 'exit 1'
                    }
                    // feature branches are deployed to environment used for development
                    if(env.BRANCH_NAME.startsWith('feature')) {
                        environment = result[0]
                        deploymentSuffix = '-jenkins'
                        entitySuffix = deploymentSuffix
                    // master branch is deployed to environment used for development
                    } else if(env.BRANCH_NAME == 'master') {
                        environment = result[0]
                        deploymentSuffix = ''
                        entitySuffix = deploymentSuffix
                    // the branches named after an environment are deployed to that environment
                    } else if(env.BRANCH_NAME in branches) {
                        environment = env.BRANCH_NAME 
                        deploymentSuffix = ''
                        entitySuffix = '-' + environment
                    // Any other branch is not deployed
                    } else {
                        echo 'Skipping deployment'
                        currentBuild.result = 'SUCCESS'
                        sh 'exit 0'
                    }
                }
                withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'apigee-credentials',
                            usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {     
                    sh "mvn install -Dorg=${APIGEE_ORGANIZATION} -Denv=${environment} -Ddescription.suffix=\" branch: ${BRANCH_NAME} commit: ${GIT_COMMIT}\" -Ddeployment.suffix=${deploymentSuffix} -Dentity.suffix=${entitySuffix} -Dusername=${USERNAME} -Dpassword=${PASSWORD}"
                }
            }
        }
    }
    post {
        always {
            junit 'test/unit/test-report.xml'
            cucumber 'test/integration/report.json'
        }
    }
}
