pipeline {
    // agent any
    agent {
        label "mapfre-sp-terraform"
    }

    stages {

        stage('Clone Repo') {
            environment {
                ttech_token = credentials('github_token')
            }

            steps {
                git url: 'https://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@github.com/TTech-CCoE/tf-mapfre-vsphere.git', branch: 'main'
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
