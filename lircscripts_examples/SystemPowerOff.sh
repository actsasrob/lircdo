#!/bin/bash

# meta: name=systempoweroff
# meta: displayname=Power Off System
# meta: intent=lircdo
# meta: action=POWER_OFF
# meta: component=COMPONENT_SYSTEM
# meta: default_component=true
# meta: numargs=0

status=0
exitstatus=0

mydir=$(dirname "$0")

$mydir/AVPowerOff.sh
status=$?
if [ "$status" -ne 0 ]; then
   exitstatus=$status
fi
sleep 1

$mydir/SetTopBoxPowerToggle.sh
status=$?
if [ "$status" -ne 0 ]; then
   exitstatus=$status
fi
sleep 1

$mydir/TVPowerToggle.sh
status=$?
if [ "$status" -ne 0 ]; then
   exitstatus=$status
fi

exit $exitstatus
