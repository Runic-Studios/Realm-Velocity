@Library('Jenkins-Shared-Lib') _

pipeline {
    agent {
        kubernetes {
            yaml jenkinsAgent("registry.runicrealms.com")
        }
    }

    environment {
        DEPLOYMENT_REPO = 'git@github.com:Runic-Studios/Realm-Deployment.git'
        IMAGE_NAME = 'realm-velocity'
    }

    stages {
        stage('Send Discord Notification (Build Start)') {
            steps {
                discordNotifyStart('Realm Velocity', env.GIT_URL, env.GIT_BRANCH, env.GIT_COMMIT)
            }
        }
        stage('Determine Environment') {
            steps {
                script {
                    def branchName = env.GIT_BRANCH.replaceAll(/^origin\//, '').replaceAll(/^refs\/heads\//, '')

                    echo "Using normalized branch name: ${branchName}"

                    if (branchName == 'dev') {
                        env.DEPLOYMENT_BRANCH = 'dev'
                        env.RUN_MAIN_DEPLOY = 'false'
                    } else if (branchName == 'main') {
                        env.DEPLOYMENT_BRANCH = 'main'
                        env.RUN_MAIN_DEPLOY = 'true'
                    } else {
                        error "Unsupported branch: ${branchName}"
                    }
                }
            }
        }
        stage('Build and Push Docker Image') {
            steps {
                container('jenkins-agent') {
                    dockerBuildPush(IMAGE_NAME, env.GIT_COMMIT, "registry.runicrealms.com")
                }
            }
        }
        stage('Update Deployment (Dev Only)') {
            when { expression { return env.RUN_MAIN_DEPLOY == 'false' } }
            steps {
                container('jenkins-agent') {
                    updateDeployment(env.DEPLOYMENT_BRANCH, IMAGE_NAME, env.GIT_COMMIT, "registry.runicrealms.com")
                }
            }
        }
//         stage('Create PR to Promote Dev to Main (Main Only)') {
//             when {
//                 expression { return env.RUN_MAIN_DEPLOY == 'true' }
//             }
//             steps {
//                 script {
//                     withCredentials([sshUserPrivateKey(credentialsId: 'github-ssh', keyFileVariable: 'SSH_KEY')]) {
//                         sh """
//                           export GIT_SSH_COMMAND='ssh -i $SSH_KEY -o StrictHostKeyChecking=no'
//                           gh auth setup-git
//                           gh pr create --base main --head dev --title 'Promote latest Realm-Velocity image to production' \
//                             --body 'This PR promotes the latest tested Realm-Velocity build from dev to production. This was triggered because of a push to Realm-Velocity main.'
//                         """
//                     }
//                 }
//             }
//         }
    }
    post {
        success {
            discordNotifySuccess('Realm Velocity', env.GIT_URL, env.GIT_BRANCH, env.GIT_COMMIT)
        }
        failure {
            discordNotifyFail('Realm Velocity', env.GIT_URL, env.GIT_BRANCH, env.GIT_COMMIT)
        }
    }
}
