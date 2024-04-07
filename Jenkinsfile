  pipeline {
      agent any 
      /*agent
      {
          label 'node1'
      }*/
      environment 
      {
        ArtifactId = readMavenPom().getArtifactId()
        Version = readMavenPom().getVersion()
        Name = readMavenPom().getName()
        GroupId = readMavenPom().getGroupId()
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

        // Print some information
        stage ('Print Environment variables')
        {
            steps 
            {
                echo "Artifact ID is '${ArtifactId}'"
                echo "Version is '${Version}'"
                echo "GroupID is '${GroupId}'"
                echo "Name is '${Name}'"
            }
        } 

        // Publish the artifacts to Nexus
        stage ('Publish to Nexus')
        {
            steps 
            {
                script 
                {
                    def NexusRepo = Version.endsWith("SNAPSHOT") ? "java-api-mysql-SNAPSHOT" : "java-api-mysql-RELEASE"

                    nexusArtifactUploader artifacts: 
                    [[artifactId: "${ArtifactId}", 
                    classifier: '', 
                    file: "target/${ArtifactId}-${Version}.jar", 
                    type: 'jar']], 
                    credentialsId: 'Nexus-credential', 
                    groupId: "${GroupId}", 
                    nexusUrl: '192.168.0.211:8081', 
                    nexusVersion: 'nexus3', 
                    protocol: 'http', 
                    repository: "${NexusRepo}", 
                    version: "${Version}"
                }
            }
        }
        stage('Building the Image') 
        {
          steps 
            {
              script 
                {
                    dockerImage = docker.build "1youssefbaroudi1/notesapp-javapi:$BUILD_NUMBER"
                }
            }
        }
        stage ('Push to docker hub') 
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

        stage('Cleaning up docker image') 
        {
            steps
            {
                sh "1youssefbaroudi1/notesapp-javapi:$BUILD_NUMBER"
            }
        }

        /* Deploy using docker-compose 
        stage('push to production using docker-compose')
        {
            steps 
            {
                ansiblePlaybook playbook: '/opt/playbooks/ansible-deployment-docker.yml'
            }
        }
        /*
        stage('Push to production using k8') 
        {
            steps 
            {
              sh "echo 'youssef baroudi'"
              sh "pwd"
              sh "sed -i 's,Image_BuildNumber,$BUILD_NUMBER,g' springboot-deployment.yml"
              ansiblePlaybook playbook: 'ansible-deployment.using-k8.yml'
            }
        }*/
      }
  }