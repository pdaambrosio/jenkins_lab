pipeline {
    // agent any
    agent {
        label "sp-terraform"
    }

    stages {

        stage('Clone Repo') {
            environment {
                ttech_token = credentials('github_token')
            }

            steps {
                git url: 'https://github.com/pdaambrosio/learn-terraform-cloud.git', branch: 'main'
            }   
        }

        stage('Validate Terraform') {
            environment {
                TF_TOKEN_app_terraform_io = credentials('terraform_cloud')
            }

            steps {
                container('terraform') {
                    sh 'export TF_TOKEN_app_terraform_io=${TF_TOKEN_app_terraform_io}'
                    sh 'env'
                    sh 'terraform init'
                    sh 'terraform validate'
                    // sh 'terraform plan'
                }
            }
        }

        stage('Validate ansible') {
            steps {
                container('ansible') {
                    sh 'ansible --version'
                }
            }
        }
    }
}
