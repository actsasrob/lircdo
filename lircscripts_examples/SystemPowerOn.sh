#!/bin/bash

# meta: name=systempoweron
# meta: displayname=Power On System
# meta: intent=lircdo
# meta: action=POWER_ON
# meta: component=COMPONENT_SYSTEM
# meta: default_component=true
# meta: numargs=0

mydir=$(dirname "$0")
$mydir/AVPowerOn.sh
sleep 1
$mydir/SetTopBoxPowerToggle.sh
sleep 1
$mydir/TVPowerToggle.sh
