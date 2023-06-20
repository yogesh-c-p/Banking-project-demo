pipeline {
    agent any

    stages {
        stage('git checkout') {
            steps {
                git 'https://github.com/yogesh-c-p/Banking-project-demo.git'

            }
        }
        stage('build maven') {
            steps {
                sh 'mvn clean package'

            }
        }
        stage('build docker image') {
            steps {
                sh 'docker build -t yogesha/banking:1.0 .'

            }
        }
        stage('docker image push to docker hub') {
            steps {
                withCredentials([string(credentialsId: 'docker-hub-password', variable: 'dockerhubpassword')]) {
                    sh "docker login -u yogesha -p ${dockerhubpassword}"
                    sh 'docker push yogesha/banking:1.0'
                }
            }
        }
        stage('configure and deploy on test-server') {
            steps {
                ansiblePlaybook become: true, credentialsId: 'ansible-ssh-key', disableHostKeyChecking: true, installation: 'Ansible', inventory: '/etc/ansible/hosts/', playbook: 'configure-test-server.yml'

            }
        }
        stage('run the seleniumtestcase runable jar') {
            steps {
                sh 'java -jar selenium-banking.jar'

            }
        }
        stage('configure and deploy on prod server') {
            steps {
                ansiblePlaybook become: true, credentialsId: 'ansible-ssh-key', disableHostKeyChecking: true, installation: 'Ansible', inventory: '/etc/ansible/hosts/', playbook: 'configure-prod-server.yml'

            }
        }
    }
}
