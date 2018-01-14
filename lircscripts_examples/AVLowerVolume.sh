#!/bin/bash

# meta: name=avlowervolume
# meta: displayname=Lower AVR Volume
# meta: intent=volume_action
# meta: action=VOLUME_DECREASE
# meta: component=COMPONENT_AVR
# meta: default_component=true
# meta: numargs=1

status=0

if [ "$#" -eq 1 ]; then
   argument="$1"
   if [[ "$argument" =~ ^[0-9]+$ ]]; then
      if [ "${argument}" -gt 10 ]; then
         argument="10"
      fi
      for ((i=0; i<"${argument}"; i++)); do
        irsend SEND_ONCE Denon_RC-1070_raw KEY_VOLUMEDOWN
        status=$?
      done
   fi
fi

exit $status
~
