#!/bin/bash

# meta: name=settopboxchangechannel
# meta: displayname=Set Top Box Change Channel
# meta: intent=channel_action
# meta: action=CHANNEL_CHANGE
# meta: component=COMPONENT_STB
# meta: default_component=true
# meta: numargs=1

status=0

if [ "$#" -eq 1 ]; then
   argument="$1"
   if [[ "$argument" =~ ^[0-9]+$ ]] && [ ${#argument} -lt 5 ]; then
      for ((i=0; i<${#argument}; i++)); do
        irsend SEND_ONCE Motorola_QIP6200-2 "KEY_${argument:i:1}"
        status=$?
      done
   fi
fi

exit $?
