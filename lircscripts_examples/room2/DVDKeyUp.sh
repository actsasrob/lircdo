#!/bin/bash

# meta: name=dvdkeyup
# meta: displayname=DVD Key Up
# meta: intent=navigate_action
# meta: action=NAVIGATE_UP
# meta: component=COMPONENT_DVD
# meta: default_component=false
# meta: numargs=1

status=0
if [ "$#" -eq 1 ]; then
   argument="$1"
   if [[ "$argument" =~ ^[0-9]+$ ]]; then
      if [ "${argument}" -gt 10 ]; then
         argument="10"
      fi
      for ((i=0; i<"${argument}"; i++)); do
        irsend SEND_ONCE RMT-VB201U KEY_UP --count=1
        sleepenh 0.1
        status=$?
      done
   fi
fi

exit $status
