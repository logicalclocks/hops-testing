pipeline {
  agent {
    node {
      label 'bbc7_testing'
    }
  }
  stages {
    stage('prepareRepos') {
      agent {
        node {
          label 'bbc7_testing'
        }
      }
      steps {
        sh '${WORKSPACE}/scripts/prepare_repos.sh'
      }
    }
    stage('checkLicenses') {
      agent {
        node {
          label 'bbc7_testing'
        }
      }
      steps {
        sh '${WORKSPACE}/scripts/check_licenses.sh'
      }
    }
    stage('setupVBoxSVC') {
      agent {
        node {
          label 'bbc7_testing'
        }
      }
      steps {
        script {
          withEnv(['JENKINS_NODE_COOKIE=dontkill']) {
            sh '${WORKSPACE}/scripts/setup_svc.sh'
          }
        }
      }
    }
    stage('build') {
      parallel {
        stage('BuildUbuntu') {
          agent {
            node {
              label 'bbc7_testing'
            }
          }
          steps {
            sh '${WORKSPACE}/scripts/run_test.sh ubuntu'
          }
          post {
            always {
              stash(name: 'ubuntu', includes: 'out/*.xml')
              sh 'rm out/*.xml'
            }
          }
        }
        stage('BuildCentos') {
          agent {
            node {
              label 'bbc7_testing'
            }
          }
          steps {
            sh '${WORKSPACE}/scripts/run_test.sh centos'
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
    stage('cleanup') {
      agent {
        node {
          label 'bbc7_testing'
        }
      }
      steps {
        sh '${WORKSPACE}/scripts/clean_branches.sh'
      }
    }
  }
  post {
    always {
      unstash 'ubuntu'
      unstash 'centos'
      junit 'out/*.xml,out/centos.xml'
      sh 'rm out/*'
    }
  }
}
