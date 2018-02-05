#!/bin/bash

if [ -f /home/jenkins/VBoxSVC.pid ];
then
  PSOUT=$(ps aux | grep $(cat /home/jenkins/VBoxSVC.pid) | wc -l)
  if [ $PSOUT -eq 1 ];
  then
    # The vm daemon is not up, start a new one
    nohup /usr/lib/virtualbox/VBoxSVC --pidfile /home/jenkins/VBoxSVC.pid >/dev/null 2>&1 &
    sleep 5
  fi
else
    nohup /usr/lib/virtualbox/VBoxSVC --pidfile /home/jenkins/VBoxSVC.pid >/dev/null 2>&1 &
    sleep 5
fi
