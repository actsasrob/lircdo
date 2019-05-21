#!/bin/bash

# meta: name=dvdreverse
# meta: displayname=DVD Reverse Play 
# meta: intent=navigate_action
# meta: action=REVERSE
# meta: component=COMPONENT_DVD
# meta: default_component=false
# meta: numargs=1

# Need to figure out what the numeric argument should be
# For instance the number could be the number of seconds to reverse play followed
# by an IR signal to return to normal play mode
# For now just simulate a single reverse button press
status=0
if [ "$#" -eq 1 ]; then
   argument="$1"
   if [[ "$argument" =~ ^[0-9]+$ ]]; then
      if [ "${argument}" -gt 10 ]; then
         argument="10"
      fi
      argument=1
      for ((i=0; i<"${argument}"; i++)); do
        irsend SEND_ONCE RMT-VB201U KEY_REVERSE --count=1
        sleepenh 0.1
        status=$?
      done
   fi
fi

exit $status
