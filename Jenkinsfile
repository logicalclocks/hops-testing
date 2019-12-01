pipeline {
  agent {
    node {
      label 'fabio_setup'
    }
  }
  stages {
    stage('cleanup') {
      agent {
        node {
          label 'fabio_setup'
        }
      }
      steps {
        sh '${WORKSPACE}/scripts/purge.sh'
        sh '${WORKSPACE}/scripts/clean_branches.sh'
      }
    }
    stage('prepareRepos') {
      agent {
        node {
          label 'fabio_setup'
        }
      }
      steps {
        sh '${WORKSPACE}/scripts/prepare_repos.sh'
      }
    }
    stage('checkLicenses') {
      agent {
        node {
          label 'fabio_setup'
        }
      }
      steps {
        sh '${WORKSPACE}/scripts/check_licenses.sh'
      }
    }
    stage('setupVBoxSVC') {
      agent {
        node {
          label 'fabio_setup'
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
              label 'fabio_setup'
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
              label 'fabio_setup'
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
