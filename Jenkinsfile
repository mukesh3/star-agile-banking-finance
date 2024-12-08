pipeline{
    
    agent any
    
    tools{
        maven 'mymaven'
    }

    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
    }
    
    stages{
        stage('Clone Repo')
        {
            steps{
                git 'https://github.com/mukesh3/star-agile-banking-finance.git'
            }
        }
        stage('Test Code')
        {
            steps{
                sh 'mvn test'
            }
        }
        stage('Build Code')
        {
            steps{
                sh 'mvn package'
            }
        }
        stage('Build Image')
        {
            steps{
                sh 'docker build -t capstone_project1:$BUILD_NUMBER .'
            }
        }

        stage('Push the Image to dockerhub')
        {
            steps{
                
        withCredentials([string(credentialsId: 'docker', variable: 'docker')]) 
                {
               sh 'docker login -u  nikitaks997797 -p ${docker} '
               }
                sh 'docker tag capstone_project1:$BUILD_NUMBER nikitaks997797/capstone_project1:$BUILD_NUMBER '
                sh 'docker push nikitaks997797/capstone_project1:$BUILD_NUMBER'
            }
        }
        stage('Terraform Init'){
            steps{
                dir('terraform'){
                  sh ' ls -lrt'
                  sh 'terraform  init'
                }
            }
        }
        stage('Terraform Plan'){
            steps{
                dir('terraform'){
                  sh 'terraform plan -out tfplan'
                  sh 'terraform show -no-color tfplan > tfplan.txt'
                }
            }
        }
        stage('Apply / Destroy') {
            steps {
                dir('terraform'){
                script {
                    if (params.action == 'apply') {
                        if (!params.autoApprove) {
                            def plan = readFile 'terraform/tfplan.txt'
                            input message: "Do you want to apply the plan?",
                            parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                        }

                        sh 'cd terraform'
                        sh 'terraform ${action} -input=false tfplan'
                    } else if (params.action == 'destroy') {
                        sh 'cd terraform'
                        sh 'terraform ${action} --auto-approve'
                    } else {
                        error "Invalid action selected. Please choose either 'apply' or 'destroy'."
                    }
                }
                }
            }
        }
    }
}
