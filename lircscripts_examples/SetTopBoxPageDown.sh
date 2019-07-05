#!/bin/bash

# meta: name=settopboxpagedown
# meta: displayname=Set Top Box Page Down
# meta: intent=navigate_action
# meta: action=NAVIGATE_PAGE_DOWN
# meta: component=COMPONENT_STB
# meta: default_component=true
# meta: numargs=1

PAGE_SIZE=8

status=0
if [ "$#" -eq 1 ]; then
   argument="$1"
   if [[ "$argument" =~ ^[0-9]+$ ]]; then
      if [ "${argument}" -gt 10 ]; then
         argument="10"
      fi
      #for (( j=0; j<"${PAGE_SIZE}"; j++ )); do
      #   for ((i=0; i<"${argument}"; i++)); do
      #     irsend SEND_ONCE Motorola_QIP6200-2 KEY_DOWN --count=1
      #     sleepenh 0.1
      #     status=$?
      #   done
      #done

      # Turns out the KEY_CHANNELDOWN/KEY_CHANNELUP buttons act as page down/up when used in the channel guide
      for ((i=0; i<"${argument}"; i++)); do
        irsend SEND_ONCE Motorola_QIP6200-2 KEY_CHANNELDOWN --count=1
        sleepenh 0.1
        status=$?
      done
   fi
fi

exit $status 
