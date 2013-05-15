############################################################
# DirecTV boxes when whole-home is enabled will allow web 
# request to be sent and return JSON.  Default port is 8080,
# not sure if you can change it.  Current Program has to be
# allowed to allow 'getTuned' to work.
############################################################

require 'net/http'
require 'rubygems'
require 'json'
require 'colorize'
require 'yaml'
@ver = 'RC1'
def clear
	system("cls")
	system("clear")
end
# Keep screen clean!
clear

def crypt_pass(pass)
	@hash_return = pass.crypt("f3c2780d20b90e20352c260384030431")
end

def create_config
	config = {}

	puts "No config file found"
	puts "Would you like to create one? y or n"
	answer = gets.chop

	if answer == "y"
		print "Enter IP: "
		ip = gets.chop
		puts ''
		print "Enter Title: "
		title = gets.chop
		puts ''
		print "Enter Password: "
		password = gets.chop
	else
		exit
	end

	config["ip"] = ip
	config["title"] = title
	crypt_pass(password)
	config["hash"] = @hash_return

	n = {"config" => {"ip" => ip, "title" => title, "hash" => @hash_return}}
	
	File.open("config.yaml", 'w') do |f|
		f.write(n.to_yaml)
	end

	clear
	get_pass
end

def load_config
	if File.file?("config.yaml") == false
		clear
		create_config
	end
	
	config = YAML.load_file("config.yaml")
	if config["config"]["hash"] == nil
		clear
		puts "Configuration file is corrupt.  Please manually delete config.yaml"
		puts "Press Enter to exit..."
		a = gets
		exit
	end

	if config["config"]["ip"] == nil
		clear
		puts "No IP found".red
		setup
	end
	
	@ip = config["config"]["ip"]
	@title = config["config"]["title"]
	@hash = config["config"]["hash"]
end

def clear
	system("cls")
	system("clear")
end

def setup

	config_temp = {}
	config_file = YAML.load_file("config.yaml")
	
	# Load in current config
	favs = config_file["Favorites"]
	config_temp["ip"] = config_file["config"]["ip"]
	config_temp["title"] = config_file["config"]["title"]
	config_temp["hash"] = config_file["config"]["hash"]
	
	command = ''
	puts "DTVControl - Setup"
	puts "-------------------"
	puts "1 - Change IP"
	puts "2 - Change Title"
	puts "3 - Show Current Config"
	puts "4 - Change Password"
	puts "q - Quit"
	puts ""
	while command != 'q'
		print "#: "
		command = gets.chop

		case command
			when "1"
				print "Enter IP: "
				ip = gets.chop
				config_temp["ip"] =  ip
				puts 'OK'
				puts ''
			
			when "2"
				print "Enter Title: "
				title = gets.chop
				config_temp["title"] = title
				puts 'OK'
				puts ''

			when "3"
				puts "IP: " + config_temp["ip"].yellow
				puts "Title: " + config_temp["title"].yellow
				puts ''

			when "4"
				puts "Enter Password: "
				password = gets.chop
				crypt_pass(password)
				config_temp["hash"] = @hash_return

			when "q"
				clear
				main

			else
				puts "Invalid"
		end
		n = {"config" => config_temp, "Favorites" => favs}
		File.open("config.yaml", 'w') do |f|
			f.write(n.to_yaml)
		end
	end
end



def favs(arg) # Hash key is callsign and value is channel number
	
	favs = {}
	favs_old = {}
	
	
	load = YAML.load_file("config.yaml")
	config = load["config"]
	favs_old = load["Favorites"]

	passed = arg
		case passed
		
			when "list"
				if favs_old == nil or favs_old.empty? == true
					puts "No Favorites.  Use 'add' to add."
				else
					favs_old.keys.each do |f|
						print f
						print " - "
						print favs_old[f]
						puts ''
					end
				end

			when "add"
				print "Enter Channel Number: "
				number = gets.chop
				puts ''
				print "Enter Channel Name: "
				name = gets.chop
				
				if number == '' or name == ''
					puts "You did not enter a name/channel"
				else
				
					if favs_old.nil? == true
						new_fav = {number => name}

						n = {"config" => config, "Favorites" => new_fav}

						File.open("config.yaml", 'w') do |f|
							f.write(n.to_yaml)
						end
					else
						favs_old[number] = name

						n = {"config" => config, "Favorites" => favs_old}

						File.open("config.yaml", 'w') do |f|
							f.write(n.to_yaml)
						end
					end

					
					
					puts favs_old
				end
					
			when "del"
				print "Enter Channel #: "
				input = gets.chop
				favs_old.delete(input)
				n = {"config" => config, "Favorites" => favs_old}
				File.open("config.yaml", 'a') do |f|
					f.write(n.to_yaml)
				end
		end
end

def favs_control
	input = ''
	while input != 'q'
		print '#: '
		input = gets.chop
		case input
			when "add"
				favs("add")
			when "list"
				favs("list")
			when "del"
				favs("del")
			when "q"
				main
		end
	end
end

def get_channel
uri = URI('http://' + @ip + ':8080/tv/getTuned')

	begin
		result = Net::HTTP.get(uri)
		response = JSON.parse(result)

		if response["episodeTitle"] == nil # Not allow programs have an 'episodetitle'.  However, from my experience, all have a 'title' at the least.
			puts response["major"].to_s + ': ' + response["callsign"] + ' - ' + response["title"] # Callsign is the channel 'name'
		else
			puts response["major"].to_s + ': ' + response["callsign"] + ' - ' + response["title"] + ': ' + response["episodeTitle"]
		end

	rescue Errno::ETIMEDOUT => e
		puts ''
		puts "Can't Connect".red
	end
end

def info
	puts "Written and Developed by Nicholas M. Petty"
	puts "ihackeverything.com - GNU GPL 2013"
	puts "Written in Ruby" 
	puts "Source available at https://github.com/nickpetty/dtvcontrol"
	puts "--------------------------------------------"
	puts "Current DTV Box IP: " + @ip
	puts "version " + @ver
end

def tune
print 'Enter Channel Number: '
chan = gets
	if chan == ''
		puts 'You did not enter a valid channel'	
	else
		uri = URI('http://' + @ip + ':8080/tv/tune?major=' + chan)

		begin
			result = Net::HTTP.get(uri)
			response = JSON.parse(result)
			parse = response["status"]
			message = parse["msg"]
		
			if message == 'OK.'
				print "Wait"  #Waits for 3 seconds while box turns channel.  If get_channel is called while the box is turning channels, program crashes.
				sleep 1
				print "."
				sleep 1
				print "."
				sleep 0.5
				print "."
				sleep 0.5
				puts ''
				get_channel
			else
				puts "Something went wrong..."
				puts "Response Message: ", message
				puts "See full JSON Response? y or n"
				answer = gets
			
				if answer == "y"
					puts result
				end
			end

		rescue Errno::ETIMEDOUT => e # Only resucing on timeout as the computers at my workplace are on Active Directory.  If a computer is not connected to the network, you can't log in.
			puts ''
			puts "Can't Connect".red
		end
	end
end

def q # Clears screen then quits
	clear
	exit
end

def debug
	

end

def print_ribbon # This will print '=' as the ribbon surrounding the title the number of characters in the title plus two for centering.
	n = @title
	ribbon_count = 0
	while ribbon_count != n.length
		print "="
		ribbon_count += 1
	end
	print "=="
	puts ' '
end

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

def motd
	puts 'Command List:'
	puts ''
	puts '1. Change Channel'
	puts '2. Get Current Channel'
	puts '3. Favorites'
	puts ''
	puts "Enter 'q' to quit or 'c' to clear"
end

def main
	load_config
	print_ribbon
	puts ' ' + @title.yellow
	print_ribbon

	motd #print command list

	command = ''

	while command != "q"

		puts ''
		print 'Command Number (h - help): '.green

		command = gets.chomp
		puts ''

		case command

			when "1"
				tune
			when "2"
				get_channel
			when "3"
				favs("list")
			when "add"
				favs("add")
			when "del"
				favs("del")
			when "q"
				q
			when "debug"
				debug
			when "h"
				help
			when "c"
				clear

				print_ribbon
				puts ' ' + @title.yellow
				print_ribbon

				motd
			when "info"
				info
			when "setup"
				clear
				setup
			else
				puts "Invalid"
		end
	end

end

def get_pass
load_config

count = 0
	puts "========================="
	puts "AUTHORIZED PERSONEL ONLY".red
	puts "========================="
	while count != 4
		
		print "Password: "
		password = gets
		crypt_pass(password)

		if @hash_return == @hash
			system("clear")
			system("cls")
			main
		else
			count += 1
			if count == 3
				puts "Please See Developer"
				exit
			end
		puts "Try Again"
		end
	end
end

get_pass
