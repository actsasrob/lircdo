#!/bin/bash

# meta: name=settopboxkeyright
# meta: displayname=Set Top Box Key Right
# meta: intent=lircdo
# meta: action=KEY_RIGHT
# meta: component=COMPONENT_STB
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
        irsend SEND_ONCE Motorola_QIP6200-2 KEY_RIGHT --count=2
        sleepenh 0.1
        status=$?
      done
   fi
fi

exit $status 
