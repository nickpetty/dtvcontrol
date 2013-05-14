dtvcontrol
==========
DirecTV title and references are copyrighted by DirecTV

A DirecTV Remote Interface.  Used to control a DirecTV STB in a off site location.  Basic functions are channel change and retrieve current tuned channel and program.

This paticular app was tailored towards the needs of the company I work for.  This may explain why some features are the way they are.  We have a DirecTV box at one of our casinos down the road that we can route to any Slot Topper TV through a web controlled video switching system.  However, we still had to go all the way to our closet at the casino to change the channel.  

After looking around online I found this wiki http://www.mythtv.org/wiki/Controlling_DirecTV_Set_Top_Box_(STB)_via_Network  I scanned through and picked out the requests being sent to the reciever and started work on this.  

I package this script with Ocra so that I can share it among the company computers without having to install the ruby framework.

Title, IP, and Password (hash) are all stored in a yml in the same directory as the app.

If no config.yml is found, you'll be forced to create one when you first launch the app.


Features
========
Change Channel

Get Current Channel

Other Information
=================
To enter setup, type 'setup'

To view info page, type 'info'


DTVControl - Help
===================

 Enter '1' to Change Channel
 Then Enter the number i.e. '206'
 'Wait...' will load, then what is currently playing on that channel
 will appear
 i.e. 'ESPN - Cowboys vs. Indians

 ----------------------------------------------
 Enter '2' to Get Current Channel and Program
 This will return the current channel and current program showing

 ----------------------------------------------
 Enter '3' to show Favorites
  To add a favorite, type 'add'.  You'll be asked to enter a Channel Number,
  then a Channel Name.
  To delete a favorite, type 'del'.  Then enter the Channel Number.

 ----------------------------------------------
 Enter 'setup' to enter setup
  Enter '1' to change the IP of the DTV box.
  Enter '2' to change the title of the DTVControl
  Enter '3' to show the currenty config.yaml settings
  Enter '4' to change the password
 ----------------------------------------------

 Any other questions should be directed toward the developer.

Known Issues
============
Deleting the config.yaml or removing the hash from the config brings user to setup then circumvents the password prompt.

