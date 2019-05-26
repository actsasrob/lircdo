#!/bin/bash

# meta: name=stbfastforward
# meta: displayname=STB Fast Forward 
# meta: intent=navigate_action
# meta: action=FAST_FORWARD
# meta: component=COMPONENT_STB
# meta: default_component=true
# meta: numargs=1

# Need to figure out what the numeric argument should be
# For instance the number could be the number of seconds to fast forward followed
# by an IR signal to return to normal play mode
# For now just simulate a single fast forward button press
status=0
if [ "$#" -eq 1 ]; then
   argument="$1"
   if [[ "$argument" =~ ^[0-9]+$ ]]; then
      if [ "${argument}" -gt 10 ]; then
         argument="10"
      fi
      argument=1
      for ((i=0; i<"${argument}"; i++)); do
        irsend SEND_ONCE Motorola_QIP6200-2 KEY_FASTFORWARD --count=1
        sleepenh 0.1
        status=$?
      done
   fi
fi

exit $status
