#!/bin/bash

if [ -f $HOME/VBoxSVC.pid ];
then
  PSOUT=$(ps aux | grep $(cat $HOME/VBoxSVC.pid) | wc -l)
  if [ $PSOUT -eq 1 ];
  then
    # The vm daemon is not up, start a new one
    nohup /usr/lib/virtualbox/VBoxSVC --pidfile $HOME/VBoxSVC.pid >/dev/null 2>&1 &
  fi
else
    # The vm daemon is not up, start a new one
    nohup /usr/lib/virtualbox/VBoxSVC --pidfile $HOME/VBoxSVC.pid >/dev/null 2>&1 &
fi
