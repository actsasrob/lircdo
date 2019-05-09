#!/bin/bash

# meta: name=tvsource
# meta: displayname=TV Source 
# meta: intent=lircdo
# meta: action=SOURCE_SELECT
# meta: component=COMPONENT_TV
# meta: default_component=true
# meta: numargs=0

status=0
if [ "$#" -eq 1 ]; then
   argument="$1"
   if [[ "$argument" =~ ^[0-9]+$ ]]; then
      if [ "${argument}" -gt 10 ]; then
         argument="10"
      fi
      for ((i=0; i<"${argument}"; i++)); do
        irsend SEND_ONCE Samsung_BN59-00516A_TV KEY_CYCLEWINDOWS --count=1
        sleepenh 0.1
        status=$?
      done
   fi
fi

exit $status 
