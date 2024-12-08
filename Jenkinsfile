pipeline{
    
    agent any
    
    tools{
        maven 'mymaven'
    }

    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_DEFAULT_REGION    = 'us-east-1'
        ANSIBLE_HOST_KEY_CHECKING = 'False'
        DOCKER_USERNAME = credentials('docker-username')  // Jenkins stored credential for Docker username
        DOCKER_PASSWORD = credentials('docker')  // Jenkins stored credential for Docker password

    }
    
    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
        choice(name: 'action', choices: ['apply', 'destroy'], description: 'Select the action to perform')
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
                            def plan = readFile 'tfplan.txt'
                            input message: "Do you want to apply the plan?",
                            parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                        }
                        sh 'terraform ${action} -input=false tfplan'
                    } else if (params.action == 'destroy') {
                    } else {
                        sh 'terraform ${action} --auto-approve'
                    }
                        error "Invalid action selected. Please choose either 'apply' or 'destroy'."
                script {
                }
                    env.EC2_PUBLIC_IP = output.replaceAll('"', '') // Remove quotes if JSON returns them
                    def output = sh(script: 'terraform output -json instance_public_ip', returnStdout: true).trim()
                }
                }
        }
            }
            steps {
        stage('Generate Ansible Hosts File') {
                    // Write the public IP to the Ansible hosts file
                script {
                    [webserver]
                    writeFile file: 'hosts', text: """
                    """
                    ${env.EC2_PUBLIC_IP} ansible_user=ubuntu ansible_ssh_private_key_file=./terraform/web-key.pem
            }
                }
        stage('Configure Test Server with Ansible') {
        }
                // Run the Ansible playbook using the generated hosts file
            steps {
                sh 'ansible-playbook -i hosts ansible/playbook_docker.yml'
                sh 'sleep 120'
        }
            }
        stage('Deploy to Test Server') {
            steps {
                // Run the Ansible playbook using the generated hosts file
                sh 'echo ${BUILD_NUMBER}'
                sh 'ansible-playbook -i hosts ansible/playbook_deploy.yml --extra-vars "BUILD_NUMBER=${BUILD_NUMBER}" -v'
            }
        }        
    }
}
