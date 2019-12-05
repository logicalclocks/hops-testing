pipeline {
  agent {
    node {
      label 'fabio_setup'
    }
  }
  stages {
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
            sh 'cp -r out out-${currentBuild.number}'
          }
          post {
            always {
              stash(name: 'ubuntu-${currentBuild.number}', includes: 'out-${currentBuild.number}/*.xml')
              sh 'rm -r out-${currentBuild.number}'
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
            sh 'cp -r out out-${currentBuild.number}'
          }
          post {
            always {
              stash(name: 'centos-${currentBuild.number}', includes: 'out-${currentBuild.number}/*.xml')
              sh 'rm -r out-${currentBuild.number}'
              sh 'rm out/centos.xml'
            }
          }
        }
      }
    }
    stage('cleanup') {
      agent {
        node {
          label 'fabio_setup'
        }
      }
      steps {
        sh '${WORKSPACE}/scripts/clean_branches.sh'
      }
    }
  }
  post {
    always {
      unstash 'ubuntu-${currentBuild.number}'
      unstash 'centos-${currentBuild.number}'
      junit 'out-${currentBuild.number}/*.xml,out-${currentBuild.number}/centos.xml'
      sh 'rm -r out-${currentBuild.number}'
    }
  }
}
