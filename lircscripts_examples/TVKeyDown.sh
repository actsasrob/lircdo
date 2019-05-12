#!/bin/bash

# meta: name=tvkeydown
# meta: displayname=TV Key Down
# meta: intent=navigate_action
# meta: action=NAVIGATE_DOWN
# meta: component=COMPONENT_TV
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
        irsend SEND_ONCE Samsung_BN59-00516A_TV KEY_DOWN --count=1
        sleepenh 0.4
        status=$?
      done
   fi
fi

exit $status
