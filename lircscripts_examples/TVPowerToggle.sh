
# meta: name=tvpowertoggle
# meta: displayname=Toggle TV Power
# meta: intent=lircdo
# meta: action=POWER_ON,POWER_OFF
# meta: component=COMPONENT_TV
# meta: default_component=false
# meta: numargs=0

#!/bin/bash
irsend SEND_ONCE Samsung_BN59-00516A_TV KEY_POWER
#irsend SEND_ONCE Samsungtv_raw KEY_POWER
exit $?
