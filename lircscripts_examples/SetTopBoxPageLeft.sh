#!/bin/bash

# meta: name=settopboxpageleft
# meta: displayname=Set Top Box Page Left
# meta: intent=navigate_action
# meta: action=NAVIGATE_PAGE_LEFT
# meta: component=COMPONENT_STB
# meta: default_component=true
# meta: numargs=1

PAGE_SIZE=6

status=0
if [ "$#" -eq 1 ]; then
   argument="$1"
   if [[ "$argument" =~ ^[0-9]+$ ]]; then
      if [ "${argument}" -gt 10 ]; then
         argument="10"
      fi
      for (( j=0; j<"${PAGE_SIZE}"; j++ )); do
         for ((i=0; i<"${argument}"; i++)); do
           irsend SEND_ONCE Motorola_QIP6200-2 KEY_LEFT --count=1
           sleepenh 0.1
           status=$?
         done
      done
   fi
fi

exit $status 
