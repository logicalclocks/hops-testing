pipeline {
  agent any
  stages {
    stage('cleanup') {
      agent {
        node {
          label 'platform_testing'
        }
      }
      steps {
        sh '${WORKSPACE}/purge.sh'
        sh '${WORKSPACE}/clean_branches.sh'
      }
    }
    stage('prepareRepos') {
      agent {
        node {
          label 'platform_testing'
        }
      }
      steps {
        sh '${WORKSPACE}/prepare_repos.sh'
      }
    }
    stage('build') {
      parallel {
        stage('BuildUbuntu') {
          agent {
            node {
              label 'platform_testing'
            }
          }
          steps {
            sh '${WORKSPACE}/run_test.sh ubuntu'
          }
          post {
            always {
              stash(name: 'ubuntu', includes: 'out/ubuntu.xml')
              sh 'rm out/ubuntu.xml'
            }
          }
        }
        stage('BuildCentos') {
          agent {
            node {
              label 'platform_testing'
            }
          }
          steps {
            sh '${WORKSPACE}/run_test.sh centos'
          }
          post {
            always {
              stash(name: 'centos', includes: 'out/centos.xml')
              sh 'rm out/centos.xml'
            }
          }
        }
      }
    }
  }
  post {
    always {
      unstash 'ubuntu'
      unstash 'centos'
      junit 'out/ubuntu.xml,out/centos.xml'
      sh 'rm out/*'
    }
  }
}
