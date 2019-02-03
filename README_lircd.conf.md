# Populating /etc/lirc/lircd.conf and Creating lircdo Shell Scripts

The LIRC service looks for the definition for remote controls in /etc/lirc/lircd.conf. If you have multiple remote controls you want to emulate then concatenate all the definitions in /etc/lirc/lircd.conf.

There are a number of sources for these definition files. Some are listed below.

Debian comes packaged with a number of commonly used config files under:  /usr/share/lirc/remotes.

Also see:
* [Source Forge Remote Control Database](http://lirc-remotes.sourceforge.net/remotes-table.html)

To use a remote control config file append it to /etc/lirc/lircd.conf and restart the LIRC service 'sudo systemctl restart lirc'.

## Use irsend CLI to send IR signals

The irsend command line interface (CLI) is used to send IR signals using an attached IR emitter. To use irsend you need two pieces of information 1. the remote control name and 2. the button name from the remote control definition stored in /etc/lirc/lircd.conf.

For example, my set top box is a Motorola model QIP6200. I found the remote control definition file [here](https://sourceforge.net/p/lirc-remotes/code/ci/master/tree/remotes/motorola/QIP6200-2.lircd.conf), downloaded it and added it to /etc/lirc/lircd.conf. The config file for QIP6200 looks like:


    begin remote
    
      name  Motorola_QIP6200-2
      bits           16
      flags SPACE_ENC|CONST_LENGTH
      eps            30
      aeps          100
    
      header       9028  4450
      one           555  4433
      zero          555  2181
      ptrail        556
      gap          99876
      toggle_bit_mask 0x0
          begin codes
              KEY_POWER                0x5006                    #  Was: power
              KEY_MENU                 0x9806                    #  Was: menu
              KEY_EPG                  0x0C0B                    #  Was: guide
              KEY_INFO                 0xCC05                    #  Was: info
              KEY_UP                   0x2C09                    #  Was: up
              <snip>
              TOP_MENU        0x0000000000058B92
              KEY_MENU        0x00000000000D8B92
              KEY_ENTER       0x0000000000070B92
          end codes
    end remote

To use irsend you need the string in the 'name' field and the button name defined within the `begin codes` ... `end codes` section (NOTE: The begin/end section may be delimeted by `begin raw_codes` ... `end raw_codes`.) e.g. name 'Motorola_QIP6200-2' and let's use 'KEY_POWER' as the button.

First, verify LIRC recognizes your remote control definition by searching for the name field using `irsend list <remote  name>...`. The example below uses the definition for Motorola_QIP6200-2 as follows:

    irsend list Motorola_QIP6200-2 '' ''

To list all remote controls recognized by the LIRC service use:

    irsend list '' ''

If you see the message 'unknown remote' then maybe you forgot to restart the lirc daemon after updating /etc/lirc/lircd.conf.

Now, to send an IR signal use `irsend SEND_ONCE <remote name> <code name>`:

The example in this section sues the remote named 'Motorola_QIP6200-2' and button code named 'KEY_POWER':

    irsend SEND_ONCE Motorola_QIP6200-2 KEY_POWER

By default the IR signal will be sent once. Sometimes sending a single pulse will not be recognized by the receiving device. You can experiment by sending multiple pulses using the `--count` switch. e.g.


    irsend SEND_ONCE Motorola_QIP6200-2 KEY_POWER --count=2

## Generating A Remote Control Definition File

If you cannot find a definition file for your specific remote control you may be able to use the definition file for another piece of hardware of the same brand. If no publicly available definition files can be found you can create your own using an IR receiver attached to your Raspberry Pi and the CLI programs provided by LIRC. 

I'll cover two approaches to create custom remote control definition files:
* [irrecord](http://www.lirc.org/html/irrecord.html)
* [IrScrutinizer](http://www.harctoolbox.org/IrScrutinizer.html)

### irrecord

irrecord is one of the CLI executables which is part of the LIRC package.

irrecord can be used to capture IR signals from an attached IR receiver and storing the results in a configuration file in the format recognized by the LIRC service.

I have had mixed results using irrecord. Not trying to blame irrecord. Possibly the issue is with my IR receiver hardware. I recommend trying irrecord before trying IrScrutinizer. Not that irrecord is better but there is a bit of a learning curve to learn how to use IrScrutinizer. irrecord is much more straightforward to use when it works.

Start by reading the irrecord manual page `man irrecord`.

You will need a working IR receiver and the remote control you want to emulate.

Start the irrecord program as follows. This example assumes the default driver is used, the LIRC device is /dev/lirc0, and you want to store the captured remote control definition in ./test.conf:

    irrecord --driver=default --device=/dev/lirc0 test.conf

Read the splash page and then follow the instructions to continue. 

I believe in the first step irrecord is trying to recognize aspects of the remote control such as protocol, frequency, gap, etc. It uses this to populate the section of the config file between the `begin remote` and `begin codes` lines. 

Next irrecord will prompt to start capturing IR signals for individual remote control button presses. Keep going until you've captured all the buttons you care to record. Once complete append the contents of ./test.conf to /etc/lirc/lircd.conf. Restart the LIRC service using `sudo systemctl restart lirc`.

One thing to note about capturing individual button presses is that the button names you select must match one of the namespaces recognized by irrecord. You can see the list of acceptable names using `irrecord --list-namespace`. If you don't want to be constrained by the default namespace then invoke irrecord with the `--disable-namespace` switch.

Use irsend as described above to test that the captured remote control definition works to control your home A/V equipment.

If you read the irrecord man page be sure to note the section that states:

    If file already exists and contains a valid config irrecord will use the protocol  descrip‐
    tion  found  there and will only try to record the buttons. This is very useful if you want
    to learn a remote where config files of the same brand are  already  available.  

If the generated remote control definition file doesn't work you could try starting with a publicly available definition file for a similar brand of hardware. Strip out the content between the `begin codes` and `end codes` sections before starting the capture using irrecord. NOTE: the section delimeters may be `begin raw_codes` and `end raw_codes` depending on the type of capture used by irrecord.

It is worth reading through the [irrecord documentation](http://www.lirc.org/html/irrecord.html) to glean additional things you can try to get a working remote control definition file.

### IrScrutinizer

IrScrutinizer is a powerful program for capturing, generating, analyzing, importing, and exporting of infrared (IR) signals.

IrScrutinizer is a wonderful tool created by [Dr. Bengt Mårtensson](http://www.bengt-martensson.de/).

You can download the latest version of IrScrutinizer [here](https://github.com/bengtmartensson/harctoolboxbundle/releases/latest). The [AppImage](https://appimage.org/) format can be downloaded and executed on a a Linux 64-bit system such as a Raspberry Pi running the Debian Jessie OS. This makes it a convenient tool to use on a Raspberry Pi with an attached IR receiver to capute IR signals. The captured signals can be exported in the format recognized by LIRC.

You can find IrScrutinizer documentation [here](http://www.harctoolbox.org/IrScrutinizer.html) with a tutorial [here](http://www.hifi-remote.com/wiki/index.php?title=IrScrutinizer_Guide).

## Creating lircdo Shell Scripts

From the information above you should be able to get scripts working to send IR signals using the irsend command. The next step is to add metadata that can be used by the lircdo server to find and execute scripts which implement desired intents.

Look at the sample scripts in the lircscripts_examples directory to get started.

You need to embed metadata in each script. This metadata is read by the generate_json_catalog.py script to produce the catalog_internal.json file read by the lircdo server. catalog_internal.json contains the mapping between the lircdo intents and the shell scripts that you provide that implement intents. You do not need to provide a script for every possible combination of intents and slot values. Only implement the scripts for the actions that make sense for your A/V equipment.

metadata lines start with "# meta:" and end with /<key>=/<value> pairs.

The following table briefly describes the purpose of each meta key:

| meta key | Description | Required (must appear in script ) | meta key=value pair |
|-----|-----|-----|-----|
| name | id/name for the script | yes |  A string unique across all scripts |
| displayname | A human readable name. Not currently used. Might be used in future by graphical user interface (GUI). | yes | A string |
| intent | The lircdo Alexa Skill intent implemented by the script | yes | Select an appropriate 'intent=<value>' pair from 'lircdo server Key & Value' column in [this table](https://github.com/actsasrob/lircdo_ask/blob/master/README_using_skill.md#lircdo_intents) |
| action | The action to perform for the selected intent | yes | Select an appropriate 'action=<value> pair from the 'lircdo server meta Key & Value' column in the [LircAction table](https://github.com/actsasrob/lircdo_ask/blob/master/README_using_skill.md#LircAction), [LircChannelAction table](https://github.com/actsasrob/lircdo_ask/blob/master/README_using_skill.md#LircChannelAction), [LircVolumeAction table](https://github.com/actsasrob/lircdo_ask/blob/master/README_using_skill.md#LircVolumeAction), or [LircAVRAction table](https://github.com/actsasrob/lircdo_ask/blob/master/README_using_skill.md#LircAVRActon) |
| component | The A/V component or device targeted by the action | yes | Select an appropriate 'component=<value>' pair from 'lircdo server Key & Value' column in the [LircComponent table](https://github.com/actsasrob/lircdo_ask/blob/master/README_using_skill.md#LircComponent) or the [LircAVDevice table](https://github.com/actsasrob/lircdo_ask/blob/master/README_using_skill.md#LircAVDevice) |
| default_component | If no component/device is specified when invoking the lircdo Alexa skill will this script implement a default component/device? |  no | You only need to add this key for true values. List of true values: true, 1, t, y, yes List of false values: false, 0, f, n, no |
| numargs | The number of optional arguments. Currently only used by volume_action and channel_action intents to specify the numeric argument for the amount to raise/lower the volume and the channel to set, respectively | no | You only need to add this key for volume_action and channel_action intents | 1 for volume_action and channel_action intents otherwise 0 |


### Intent meta key and value

You should be able to determine the intent to implement by process of elimination.

Use the [channel_action](https://github.com/actsasrob/lircdo_ask/blob/master/README_using_skill.md#channel_action_intent) to change channels of A/V components/devices.

Use the [volume_action](https://github.com/actsasrob/lircdo_ask/blob/master/README_using_skill.md#volume_action) intent to raise or lower volumes ov A/V components/devices. NOTE: Muting components falls under the generic [lircdo](https://github.com/actsasrob/lircdo_ask/blob/master/README_using_skill.md#lircdo_intent).

Use the [avr_action](https://github.com/actsasrob/lircdo_ask/blob/master/README_using_skill.md#avr_action) intent to change the currently selected component/device for Audio Video Receivers (AVRs).

If the one of the above intents isn't appropriate then check out the generic [lircdo](https://github.com/actsasrob/lircdo_ask/blob/master/README_using_skill.md#lircdo_intent) intent.

Once you select the intent, use the links above to browse to the table for that intent. 

To populate the '# meta: intent=<value>' line in your script select the appropriate 'intent=<value>' pair from 'lircdo server Key & Value' column in [this table](https://github.com/actsasrob/lircdo_ask/blob/master/README_using_skill.md#lircdo_intents).

From the table above you can click the link for each intent to navigate to the table specific link to get more information for each intent.

In each intent specific table you will see the "slots" accepted by the intent. In general each intent accepts an action slot and a component/device slot. The action slot and the component slot both have links to the accepted actions and components, respectively, for that intent.

### Action meta key and value

To populate the '# meta: action=<value>' line in the script first navigate to the table for the intent from one of the links above. Click on the link for the action slot. You will be taken to the table which shows all the possible utterances (i.e. what you can say) for that action. Find the appropriate action and then use the key=value pair from the 'lircdo server Key & Value' column.

NOTE: A script can handle multiple actions for the same intent. A good example might be a script that toggles opening/closing the DVD Player tray. The remote control for my DVD Player has an open/close tray button which acts as a toggle as opposed to separate button to open the tran and a button to close the tray. In my case it makes sense for the script to handle both TRAY_OPEN actions and TRAY_CLOSE actions. To do this I would add a line to the script like:

    # meta: action=TRAY_OPEN,TRAY_CLOSE

For multi-valued actions add each of the supported actions seperated by commas.

### Components/Devices  meta key and value

To populate the '# meta: component=<value>' line in the script first navigate to the table for the intent from one of the links above. Click on the link for the component slot. You will be taken to the table which shows all the possible utterances (i.e. what you can say) for that component. Find the appropriate component and then use the key=value pair from the 'lircdo server Key & Value' column.

NOTE: If the intent takes a [LircComponent table](https://github.com/actsasrob/lircdo_ask/blob/master/README_using_skill.md#LircComponent) slot then there is one special component with key=value pair 'component=COMPONENT_SYSTEM'. The 'system' component is handy if you want to implement an intent where multiple components/devices are affected. Let's say you want to be able to power on multiple components at one time. For me when I say 'Alexa, tell lircdo, turn on system' I want the Set Top Box, Audio Video Receiver (AVR) and TV to be powered on. You can use the 'system' component to implement a script to do this. For example, see [this script](https://github.com/actsasrob/lircdo/blob/master/lircscripts_examples/SystemPowerOn.sh).

### Default Component meta key and value

For some intents it is handy to not have to speak the component when interacting with the lircdo Alexa skill. This especially makes sense when you only have one component/device in your home that would be an appropriate target for the intent. In my house a good example is opening/closing the tray on the DVD Player. I have more than one device with a tray but only the DVD player has a non-proprietary remote control that can be invoked via LIRC. So for me, if I invoke the lircdo skill as 'Alexa, tell lircdo, open dvd player tray' having to explicitly specify the component is wasted effort because the only valid component in my house is the dvd player. I want to be able to say 'Alexa, tell lircdo, open tray' and have the lircdo server figure out the default target is the dvd player. The default_component key allows you to do just that. If your script handles the default component for an intent/action combination add the line '# meta: default_component=true' otherwise leave that line out.

### Num args meta key and value

Only the [channel_action](https://github.com/actsasrob/lircdo_ask/blob/master/README_using_skill.md#channel_action_intent) and [volume_action](https://github.com/actsasrob/lircdo_ask/blob/master/README_using_skill.md#volume_action_intent) intents have a slot which accepts a numeric argument.

Currently only one argument is accepted. More than one argument may be accepted in the future.

If your script implements an action for the channel_action or volume_action intents then add the line '# meta: numargs=1' otherwise add the line '# meta: numargs=0' or leave the line out entirely.

### Name meta key

The 'name' meta key is required for every script. Add a line like '# meta: name=<value>' where <value> is a unique string across all of your scripts. This value acts as a unique id.

### Display Name meta key

The 'displayname' meta key is required for every script but is unused at this time. In the future the value may be used via a graphical user interface (GUI). Ad line line like '# meta: displayname=<value>' where <value> is an appropriate human readable label that succintly describes what the script does.

### Examples

Hopefully a couple of examples will help pull all this together.

#### Example 1 Open/Close DVD Tray

Let's say you want to implement a script that toggles the open/close state of the DVD Player.

Looking in [this table](https://github.com/actsasrob/lircdo_ask/blob/master/README_using_skill.md#lircdo_intents) you would quickly surmise this is a generic [lircdo](https://github.com/actsasrob/lircdo_ask/blob/master/README_using_skill.md#lircdo_intent) intent.

Add this line to the script:

    # meta: intent=lircdo

From the [lircdo](https://github.com/actsasrob/lircdo_ask/blob/master/README_using_skill.md#lircdo_intent) table click the link for the [LircAction table](https://github.com/actsasrob/lircdo_ask/blob/master/README_using_skill.md#LircAction) slot.

From the 'lircdo server meta Key & Value' column you see the action value to close the tray is "TRAY_CLOSE" and to open the tray is "TRAY_OPEN". Add the following action meta key line to the script:

    # meta: action=TRAY_OPEN,TRAY_CLOSE

From the [lircdo](https://github.com/actsasrob/lircdo_ask/blob/master/README_using_skill.md#lircdo_intent) table click the link for the [LircComponent table](https://github.com/actsasrob/lircdo_ask/blob/master/README_using_skill.md#LircComponent) slot.

From the 'lircdo server meta Key & Value' column you see the component value for DVD Player is "COMPONENT_DVD". Add the following component meta key line to the script:

    # meta: component=COMPONENT_DVD

If the script will handle the default component for the intent/action combination then add the following line to the script:

    # meta: default_component=true

Since the script is not implementing an action for the channel_action or volume_action intents you can add the following line or leave it out:

    # meta: numargs=0

Now add lines for the 'name' and 'displayname' meta keys. For example:

    # meta: name=dvdopentraytoggle
    # meta: displayname=Open/Close DVD Tray


For this example the meta key section of the script would look something like:

    # meta: name=dvdopentraytoggle
    # meta: displayname=Open/Close DVD Tray
    # meta: intent=lircdo
    # meta: action=TRAY_OPEN,TRAY_CLOSE
    # meta: component=COMPONENT_DVD
    # meta: default_component=true
    # meta: numargs=0

Example 2 Change Set Top Box Channel 

Let's say you want to implement a script that sets the channel for the Set Top Box component. 

Looking in [this table](https://github.com/actsasrob/lircdo_ask/blob/master/README_using_skill.md#lircdo_intents) you would quickly surmise this is a [channel_action](https://github.com/actsasrob/lircdo_ask/blob/master/README_using_skill.md#channel_action_intent) intent.

Add this line to the script:

    # meta: intent=channel_action

From the [channel_action](https://github.com/actsasrob/lircdo_ask/blob/master/README_using_skill.md#channel_action_intent) table click the link for the [LircChannelAction table](https://github.com/actsasrob/lircdo_ask/blob/master/README_using_skill.md#LircChannelAction) slot.

From the 'lircdo server meta Key & Value' column you see the action value change the channel is "CHANNEL_CHANGE". Add the following action meta key line to the script:

    # meta: action=CHANNEL_CHANGE

From the [channel_action](https://github.com/actsasrob/lircdo_ask/blob/master/README_using_skill.md#changle_channel_intent) table click the link for the [LircComponent table](https://github.com/actsasrob/lircdo_ask/blob/master/README_using_skill.md#LircComponent) slot.

From the 'lircdo server meta Key & Value' column you see the component value for Set Top Box is "COMPONENT_STB". Add the following component meta key line to the script:

    # meta: component=COMPONENT_STB

If the script will handle the default component for the intent/action combination then add the following line to the script:

    # meta: default_component=true

Since this script implements an action for the channel_action intent add the following line to the script:

    # meta: numargs=1

Now add lines for the 'name' and 'displayname' meta keys. For example:

    # meta: name=settopboxchangechannel
    # meta: displayname=Set Top Box Change Channel

For this example the meta key section of the script would look something like:

    # meta: name=settopboxchangechannel
    # meta: displayname=Set Top Box Change Channel
    # meta: intent=channel_action
    # meta: action=CHANNEL_CHANGE
    # meta: component=COMPONENT_STB
    # meta: default_component=true
    # meta: numargs=1

