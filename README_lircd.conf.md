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

I'll cover two approaches to create custom remote control definition files:
* irrecord
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


### IrScrutinizer

IrScrutinizer is a powerful program for capturing, generating, analyzing, importing, and exporting of infrared (IR) signals.

IrScrutinizer is a wonderful tool created by [Dr. Bengt Mårtensson](http://www.bengt-martensson.de/).

You can download the latest version of IrScrutinizer [here](https://github.com/bengtmartensson/harctoolboxbundle/releases/latest). The [AppImage](https://appimage.org/) format can be downloaded and executed on a a Linux 64-bit system such as a Raspberry Pi running the Debian Jessie OS. This makes it a convenient tool to use on a Raspberry Pi with an attached IR receiver to capute IR signals. The captured signals can be exported in the format recognized by LIRC.

You can find IrScrutinizer documentation [here](http://www.harctoolbox.org/IrScrutinizer.html) with a tutorial [here](http://www.hifi-remote.com/wiki/index.php?title=IrScrutinizer_Guide).

## Creating lircdo Shell Scripts


