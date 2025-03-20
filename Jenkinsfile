@Library('Jenkins-Shared-Lib') _

pipeline {
    agent jenkinsAgent()

    environment {
        DEPLOYMENT_REPO = 'git@github.com:Runic-Studios/Realm-Deployment.git'
        IMAGE_NAME = 'realm-velocity'
        PROJECT = 'Realm Velocity'
    }

    stages {
        stage('Send Discord Notification (Build Start)') {
            steps {
                discordNotifyStart(PROJECT, env.GIT_URL, env.GIT_BRANCH, env.GIT_COMMIT)
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
                dockerBuildPush(IMAGE_NAME, env.GIT_COMMIT)
            }
        }
        stage('Update Deployment (Dev Only)') {
            when { expression { return env.RUN_MAIN_DEPLOY == 'false' } }
            steps {
                updateDeployment(env.DEPLOYMENT_BRANCH, IMAGE_NAME, env.GIT_COMMIT)
            }
        }
        stage('Commit and Push Changes (Dev Only)') {
            when {
                expression { return env.RUN_MAIN_DEPLOY == 'false' }
            }
            steps {
                script {
                    dir('Realm-Deployment') {
                        withCredentials([sshUserPrivateKey(credentialsId: 'github-ssh', keyFileVariable: 'SSH_KEY')]) {
                            sh """
                              export GIT_SSH_COMMAND='ssh -i $SSH_KEY -o StrictHostKeyChecking=no'
                              git config --global user.email "runicrealms.mc@gmail.com"
                              git config --global user.name "Runic Realms Jenkins"
                              git add base/kustomization.yaml
                              git commit -m "Update Realm-Velocity image to ${env.GIT_COMMIT} for dev"
                              git push origin dev
                              rm -rf Realm-Deployment
                            """
                        }
                    }
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
            discordNotifySuccess(PROJECT, env.GIT_URL, env.GIT_BRANCH, env.GIT_COMMIT)
        }
        failure {
            discordNotifyFail(PROJECT, env.GIT_URL, env.GIT_BRANCH, env.GIT_COMMIT)
        }
    }
}
