pipeline {
    agent any

    environment {
        DEPLOYMENT_REPO = 'git@github.com:Runic-Studios/Realm-Deployment.git'
    }

    stages {
        stage('Determine Environment') {
            steps {
                script {
                    if (env.GIT_BRANCH == 'origin/dev') {
                        env.DEPLOYMENT_BRANCH = 'dev'
                        env.RUN_MAIN_DEPLOY = 'false'
                    } else if (env.GIT_BRANCH == 'origin/main') {
                        env.DEPLOYMENT_BRANCH = 'main'
                        env.RUN_MAIN_DEPLOY = 'true'
                    } else {
                        error "Unsupported branch: ${env.GIT_BRANCH}"
                    }
                }
            }
        }
        stage('Checkout Realm-Deployment') {
            steps {
                script {
                    sh "git clone --branch ${env.DEPLOYMENT_BRANCH} ${DEPLOYMENT_REPO} Realm-Deployment"
                }
            }
        }
        stage('Update Image Reference (Dev Only)') {
            when {
                expression { return env.RUN_MAIN_DEPLOY == 'false' }
            }
            steps {
                script {
                    sh "sed -i 's|newTag: .*|newTag: \"${env.GIT_COMMIT}\"|' Realm-Deployment/base/image-overlays.yaml"
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
                        sh """
                          git config --global user.email "runicrealms.mc@gmail.com"
                          git config --global user.name "Runic Realms Jenkins"
                          git add base/image-overlays.yaml
                          git commit -m "Update Realm-Velocity image to ${env.GIT_COMMIT} for dev"
                          git push origin dev
                        """
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
                    sh """
                      gh pr create --base main --head dev --title 'Promote latest Realm-Velocity image to production' \
                        --body 'This PR promotes the latest tested Realm-Velocity build from dev to production. This was triggered because of a push to Realm-Velocity main.'
                    """
                }
            }
        }
    }
}
