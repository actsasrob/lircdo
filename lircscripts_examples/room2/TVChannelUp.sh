#!/bin/bash

# meta: name=tvchannelup
# meta: displayname=TV Channel Up 
# meta: intent=navigate_action
# meta: action=CHANNEL_UP
# meta: component=COMPONENT_TV
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
        irsend SEND_ONCE Samsung_BN59-00516A_TV KEY_CHANNELUP --count=1
        sleepenh 0.1
        status=$?
      done
   fi
fi

exit ?status
