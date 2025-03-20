pipeline {
    agent any

    environment {
        DEPLOYMENT_REPO = 'git@github.com:Runic-Studios/Realm-Deployment.git'
        DISCORD_WEBHOOK = credentials('discord-webhook')
    }

    stages {
        stage('Send Discord Notification (Build Start)') {
            steps {
                discordSend webhookURL: env.DISCORD_WEBHOOK,
                            description: "Build started for ${env.GIT_BRANCH} at commit ${env.GIT_COMMIT}",
                            footer: "Realm-Velocity CI",
                            title: "Jenkins Build Started 🚀",
                            result: "SUCCESS"
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
        stage('Checkout Realm-Deployment') {
            steps {
                script {
                    withCredentials([sshUserPrivateKey(credentialsId: 'github-ssh', keyFileVariable: 'SSH_KEY')]) {
                        sh """
                          rm -rf Realm-Deployment
                          export GIT_SSH_COMMAND='ssh -i $SSH_KEY -o StrictHostKeyChecking=no'
                          git clone --branch ${env.DEPLOYMENT_BRANCH} ${DEPLOYMENT_REPO} Realm-Deployment
                        """
                    }
                }
            }
        }
        stage('Update Image Reference (Dev Only)') {
            when {
                expression { return env.RUN_MAIN_DEPLOY == 'false' }
            }
            steps {
                script {
                    sh "sed -i 's|newTag: .*|newTag: \"${env.GIT_COMMIT}\"|' Realm-Deployment/base/images.yaml"
                }
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
                              git add base/images.yaml
                              git commit -m "Update Realm-Velocity image to ${env.GIT_COMMIT} for dev"
                              git push origin dev
                              rm -rf Realm-Deployment
                            """
                        }
                    }
                }
            }
        }
        stage('Create PR to Promote Dev to Main (Main Only)') {
            when {
                expression { return env.RUN_MAIN_DEPLOY == 'true' }
            }
            steps {
                script {
                    withCredentials([sshUserPrivateKey(credentialsId: 'github-ssh', keyFileVariable: 'SSH_KEY')]) {
                        sh """
                          export GIT_SSH_COMMAND='ssh -i $SSH_KEY -o StrictHostKeyChecking=no'
                          gh auth setup-git
                          gh pr create --base main --head dev --title 'Promote latest Realm-Velocity image to production' \
                            --body 'This PR promotes the latest tested Realm-Velocity build from dev to production. This was triggered because of a push to Realm-Velocity main.'
                        """
                    }
                }
            }
        }
    }
    post {
        success {
            discordSend webhookURL: env.DISCORD_WEBHOOK,
                        description: "Build **SUCCESSFUL** for ${env.GIT_BRANCH} at commit ${env.GIT_COMMIT}",
                        footer: "Realm-Velocity CI",
                        title: "Jenkins Build Passed ✅",
                        result: "SUCCESS"
        }
        failure {
            discordSend webhookURL: env.DISCORD_WEBHOOK,
                        description: "Build **FAILED** for ${env.GIT_BRANCH} at commit ${env.GIT_COMMIT}",
                        footer: "Realm-Velocity CI",
                        title: "Jenkins Build Failed ❌",
                        result: "FAILURE"
        }
    }
}
