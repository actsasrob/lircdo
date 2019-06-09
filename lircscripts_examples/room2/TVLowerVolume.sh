#!/bin/bash

# meta: name=tvlowervolume
# meta: displayname=Lowe TV Volume
# meta: intent=volume_action
# meta: action=VOLUME_DECREASE
# meta: component=COMPONENT_TV
# meta: default_component=true
# meta: numargs=1

status=0

if [ "$#" -eq 1 ]; then
   argument="$1"
   if [[ "$argument" =~ ^[0-9]+$ ]]; then
      if [ "${argument}" -gt 5 ]; then
         argument="5"
      fi
      for ((i=0; i<"${argument}"; i++)); do
        irsend SEND_ONCE Samsung_BN59-00516A_TV KEY_VOLUMEDOWN 
        status=$?
	sleepenh 0.3
      done
   fi
fi

exit $status
