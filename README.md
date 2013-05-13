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

def help
  puts 'DTVControl - Help'.yellow
	puts "==================="
	puts ""
	puts " Enter '1' to Change Channel"
	puts "  Then Enter the number i.e. '206'"
	puts " 'Wait...' will load, then what is currently playing on that channel" 
	puts "  will appear"
	puts "  i.e. 'ESPN - Cowboys vs. Indians"
	puts ""
	puts " ----------------------------------------------".green
	puts " Enter '2' to Get Current Channel and Program"
	puts "  This will return the current channel and current program showing"
	puts ""
	puts " ----------------------------------------------".green
	puts " Enter '3' to show Favorites"
	puts "  To add a favorite, type 'add'.  You'll be asked to enter a Channel Number,"
	puts "  then a Channel Name."
	puts "  To delete a favorite, type 'del'.  Then enter the Channel Number."
	puts ""
	puts " ----------------------------------------------".green
	puts " Enter 'setup' to enter setup"
	puts "  Enter '1' to change the IP of the DTV box."
	puts "  Enter '2' to change the title of the DTVControl"
	puts "  Enter '3' to show the currenty config.yaml settings"
	puts "  Enter '4' to change the password"
	puts " ----------------------------------------------".green
	puts ""
	puts "Any other questions should be directed toward the developer."
	puts ""
end
