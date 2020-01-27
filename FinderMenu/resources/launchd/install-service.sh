#!/bin/bash

######################################################
# Install launchd given by the paramter.
# Param is the plist id.
# The plist should be already copied to
#       ~/Library/LaunchAgents
######################################################

id="$1"
plist="$id.plist"
cd ~/Library/LaunchAgents
launchctl unload "$plist"
launchctl load "$plist"
launchctl list | grep "$id"
