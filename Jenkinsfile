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
            sh 'cp -r out out-$BUILD_NUMBER'
          }
          post {
            always {
              stash(name: 'ubuntu-${currentBuild.number}', includes: 'out-${currentBuild.number}/*.xml')
              sh 'rm -r out-$BUILD_NUMBER'
              sh 'rm out/*.xml'
              sh '${WORKSPACE}/scripts/shutdown.sh ubuntu-$BUILD_NUMBER'
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
            sh 'cp -r out out-$BUILD_NUMBER'
          }
          post {
            always {
              stash(name: 'centos-${currentBuild.number}', includes: 'out-${currentBuild.number}/*.xml')
              sh 'rm -r out-$BUILD_NUMBER'
              sh 'rm out/centos.xml'
              sh '${WORKSPACE}/scripts/shutdown.sh centos-$BUILD_NUMBER'
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
      unstash 'ubuntu-${currentBuild.number}'
      unstash 'centos-${currentBuild.number}'
      junit 'out-${currentBuild.number}/*.xml,out-${currentBuild.number}/centos.xml'
      sh 'rm -r out-$BUILD_NUMBER'
    }
  }
}
