  pipeline {
      //agent any 
      agent
      {
          label 'node1'
      }
      environment 
      {
          registry = 'https://hub.docker.com/repositories/1youssefbaroudi1'
          registryCredential = 'jenkins-dockerhub-login-credentials'
          dockerimage = ''
      }
      stages
      {
          stage("Checkout the project") 
          {
            steps{
                git branch: 'main', url: 'https://github.com/youssef-baroudi/java-spring-boot-api-mysql.git'
            } 
          }
          stage("Build the package")
          {
              steps 
              {
                  sh 'mvn clean package'
              }
          }
          stage("Sonar Quality Check")
          {
          steps
              {
                  script
                      {
                          withSonarQubeEnv(installationName: '10.4.0-community', credentialsId: 'sonarqube-jenkins-token') 
                          {
                              sh 'mvn sonar:sonar'
                          }
                          timeout(time: 1, unit: 'HOURS') 
                          {
                                  def qg = waitForQualityGate()
                                  if (qg.status != 'OK') 
                                      {
                                          error "Pipeline aborted due to quality gate failure: ${qg.status}"
                                      }
                          }
                      }
                  }
          }
          stage('Building the Image') 
        {
              steps 
          {
                  script 
            {
              //dockerImage = docker.build registry + ":$BUILD_NUMBER"
              dockerImage = docker.build "1youssefbaroudi1/pringboot-maven:$BUILD_NUMBER"
            }
          }
          }
          stage ('Deploy the Image to yb docker hub') 
          {
              steps 
              {
                  script 
                  {
                      docker.withRegistry( '', registryCredential )
                      {
                          dockerImage.push()
                      }
                  }
              }
          }
          stage('Cleaning up') 
          {
              steps
              {
                  sh "docker rmi 1youssefbaroudi1/pringboot-maven:$BUILD_NUMBER"
              }
          }
          /*stage('Deploy to cd-server and run the container') => do not work
          {
              steps
              {
                  ansiblePlaybook credentialsId: 'private-key-to-cd-server', installation: 'ansible', inventory: '/etc/ansible/hosts', playbook: '/etc/ansible/ansible-deployment.yml', vaultTmpPath: ''
              }    
          }
          stage('Deploy to cd-server and run the container using ssh') => do not work
          {
              steps 
              {
                  script
                  {
                      sh "sudo ansible-playbook /etc/ansible/ansible-deployment.yml"
                  }
              }
          }
          stage('Execute Ansible playbook in production using only docker') => work fine
          {
              steps 
              {
                  ansiblePlaybook playbook: '/opt/playbooks/ansible-deployment-docker.yml'
              }
          }*/
          stage('Execute Ansible playbook in production using k8') 
          {
              steps 
              {
                sh "echo 'youssef baroudi'"
                sh "pwd"
                sh "sed -i 's,Image_BuildNumber,$BUILD_NUMBER,g' springboot-deployment.yml"
                ansiblePlaybook playbook: 'ansible-deployment.using-k8.yml'
              }
          }
      }
  }