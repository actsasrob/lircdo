# Populating /etc/lirc/lircd.conf

The LIRC service looks for the definition for remote controls in /etc/lirc/lircd.conf. If you have multiple remote controls you want to emulate then concatenate all the definitions in /etc/lirc/lircd.conf.

There are a number of sources for these definition files. Some are listed below.

Debian comes packaged with a number of commonly used config files under:  /usr/share/lirc/remotes.

Also see:
* [Source Force Remote Control Database](http://lirc-remotes.sourceforge.net/remotes-table.html)

To use a remote control config file append it to /etc/lirc/lircd.conf and restart the LIRC service 'sudo systemctl restart lirc'.

## Use irsend CLI to send IR signals

The irsend CLI is used to send IR signals using an attached IR emitter. To use irsend you need two pieces of information from the remote control definition stored in /etc/lirc/lircd.conf.

For example, my set top box is a Motorola model QIP6200. I found the remote control definition file [hete](https://sourceforge.net/p/lirc-remotes/code/ci/master/tree/remotes/motorola/QIP6200-2.lircd.conf), downloaded it and added it to /etc/lirc/lircd.conf. The config file for QIP6200 looks like:

To use irsend you need the string in the 'name' field and the button name defined within the 'begin codes ... 'end codes' section. e.g. name 'Motorola_QIP6200-2' and let's use 'KEY_POWER' as the button.

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

First, verify LIRC recognizes your remote control definition by searching for the name field using `irsend list <remote  name>...`. The example below uses the definition for Motorola_QIP6200-2 as follows:

    irsend list Motorola_QIP6200-2 '' ''

To list all remote controls recognized by the LIRC service use:

    irsend list '' ''

If you see the message 'unknown remote' then maybe you forgot to restart the lirc daemon after updating /etc/lirc/lircd.conf.

Now, to send an IR signal use `irsend SEND_ONCE <remote name> <code name>`:

For example using the remote named 'Motorola_QIP6200-2' and button code named 'KEY_POWER':

    irsend SEND_ONCE Motorola_QIP6200-2 KEY_POWER

By default the IR signal will be sent once. Sometimes sending a single pulse will not be recognized by the receiving device. You can experiment by sending multiple pulses using the `--count` switch. e.g.


    irsend SEND_ONCE Motorola_QIP6200-2 KEY_POWER --count=2

## Generating A Remote Control Definition File

If you cannot find a definition file for your specific remote control you may be able to use the definition file for another piece of hardware of the same brand. If no publicly availabe definition files can be found you can create your own using an IR receiver attached to your Raspberry Pi and the CLI programs provided by LIRC. 
