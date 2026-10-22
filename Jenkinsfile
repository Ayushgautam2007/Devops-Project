pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    stages {
        stage('Checkout Source') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Format Check') {
            steps {
                dir('terraform') {
                    sh 'terraform fmt -check -recursive'
                }
            }
        }

        stage('Terraform Init Without Backend') {
            steps {
                dir('terraform') {
                    sh 'terraform init -backend=false -input=false -lockfile=readonly'
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir('terraform') {
                    sh 'terraform validate'
                }
            }
        }
    }

    post {
        success {
            echo 'Terraform formatting and validation passed. No infrastructure was applied.'
        }
        failure {
            echo 'Terraform validation pipeline failed. Review the stage logs.'
        }
    }
}
