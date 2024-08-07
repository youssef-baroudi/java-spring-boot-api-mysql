  pipeline {
      //agent any 
      agent
      {
          label 'node1'
      }
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

        // Add tag to artifacts files
        stage('Add tag image into artifacts files') 
        {
            steps 
            {
              sh "sed -i 's,BUILD_TAG,$BUILD_NUMBER,g' docker-compose-java-mysql-api.yml"
              sh "sed -i 's,BUILD_TAG,$BUILD_NUMBER,g' kube-manifests/07-NotesApp-Deployment.yml"     
              sh "zip -r kube-manifests.zip kube-manifests"
            }
        }

        // Publish the artifacts to Nexus
        stage ('Publish files to Nexus')
        {
            steps 
            {
                script 
                {
                    def NexusRepo = Version.endsWith("SNAPSHOT") ? "java-api-mysql-SNAPSHOT" : "java-api-mysql-RELEASE"

                    nexusArtifactUploader artifacts: 
                    [
                        /* no need if we build run java inside image => see Dockerfile
                          [artifactId: "${ArtifactId}", 
                          classifier: '', 
                          file: "target/${ArtifactId}-${Version}.jar", 
                          type: 'jar'],*/

                        
                        [artifactId: "${ArtifactId}", 
                        classifier: '', 
                        file: "docker-compose-java-mysql-api.yml", 
                        type: 'yml'],

                        [artifactId: "${ArtifactId}", 
                        classifier: '', 
                        file: "kube-manifests.zip", 
                        type: 'zip']
                    ], 
                    credentialsId: 'Nexus-credential', 
                    groupId: "${GroupId}", 
                    nexusUrl: '192.168.1.211:8081', 
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

        // Deploying using docker-compose
        stage ('Deploy to production using docker-compose')
        {
            steps 
            {
                echo "ansibe: copy artifacts from nexus and deploy using docker-compose ...."
                sshPublisher(publishers: 
                [sshPublisherDesc
                (
                    configName: 'Ansible_Controller', 
                    transfers: 
                    [
                        /*sshTransfer
                        (
                            cleanRemote: false,
                            excludes: '',
                            execCommand: 'sudo cp /home/your_username/your_jar_file.jar /opt/your_service_directory/',
                            flatten: false,
                            makeEmptyDirs: false,
                            noDefaultExcludes: false,
                            patternSeparator: '[, ]+',
                            remoteDirectory: '/home/your_username/',
                            remoteDirectorySDF: false,
                            remoteFiles: '',
                            removePrefix: '',
                            sourceFiles: ''
                        ),*/
                        sshTransfer
                        (
                            cleanRemote:false,      
                            execCommand: 'ansible-playbook /opt/playbooks/ansible-docker-compose.yml -i /opt/playbooks/hosts ',                                
                            flatten: false,
                            makeEmptyDirs: false,
                            noDefaultExcludes: false,
                            remoteDirectorySDF: false,
                            remoteFiles: '',
                            removePrefix: '',
                            sourceFiles: ''
                        )
                    ], 
                    usePromotionTimestamp: false, 
                    useWorkspaceInPromotion: false, 
                    verbose: true
                )
                ])
            
            }
        }                

        // Deploying using docker-compose
        stage ('Deploy to production using kubernetes')
        {
            steps 
            {
                echo "ansibe: copy artifacts from nexus and deploy to kubernetes ...."
                sshPublisher(publishers: 
                [sshPublisherDesc
                (
                    configName: 'Ansible_Controller', 
                    transfers: 
                    [
                        sshTransfer
                        (
                            cleanRemote:false,      
                            execCommand: 'ansible-playbook /opt/playbooks/ansible-kubernetes.yml -i /opt/playbooks/hosts ',                                
                            flatten: false,
                            makeEmptyDirs: false,
                            noDefaultExcludes: false,
                            remoteDirectorySDF: false,
                            remoteFiles: '',
                            removePrefix: '',
                            sourceFiles: ''
                        )
                    ], 
                    usePromotionTimestamp: false, 
                    useWorkspaceInPromotion: false, 
                    verbose: true
                )
                ])
            
            }
        }
      }
  }