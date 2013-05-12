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

	File.open("config.yaml", 'w') do |f|
		f.write(config.to_yaml)
	end

	clear
	main
end

def load_config
	if File.file?("config.yaml") == false
		clear
		create_config
	end
	
	config = YAML.load_file("config.yaml")
	if config["hash"] == nil
		clear
		puts "No password is set.".red
		puts "Please choose option 4 in setup to create a password".red
		setup
	end

	if config["ip"] == nil
		clear
		puts "No IP found".red
		setup
	end
	
	@ip = config["ip"]
	@title = config["title"]
	@hash = config["hash"]
end

def clear
	system("cls")
	system("clear")
end

def setup

	config_temp = {}
	config_file = YAML.load_file("config.yaml")
	
	# Load in current config

	config_temp["ip"] = config_file["ip"]
	config_temp["title"] = config_file["title"]
	config_temp["hash"] = config_file["hash"]
	
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
				puts "IP: " + config_file["ip"].yellow
				puts "Title: " + config_file["title"].yellow
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
		File.open("config.yaml", 'w') do |f|
			f.write(config_temp.to_yaml)
			end
	end

end

def get_channel
uri = URI('http://' + @ip + ':8080/tv/getTuned')

	begin
		result = Net::HTTP.get(uri)
		response = JSON.parse(result)

		if response["episodeTitle"] == nil # Not allow programs have an 'episodetitle'.  However, from my experience, all have a 'title' at the least.
			puts response["callsign"] + ' - ' + response["title"] # Callsign is the channel 'name'
		else
			puts response["callsign"] + ' - ' + response["title"] + ': ' + response["episodeTitle"]
		end

	rescue Errno::ETIMEDOUT => e
		puts ''
		puts "Can't Connect".red
	end
end

def info
	puts "Written and Developed by Nicholas M. Petty"
	puts "ihackeverything.com - Creative Commons 2013"
	puts "Written in Ruby"
	puts "--------------------------------------------"
	puts "Current DTV Box IP: " + @ip
end

def tune
print 'Enter Channel Number: '
chan = gets
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


def motd
	puts 'Command List:'
	puts ''
	puts '1. Change Channel'
	puts '2. Get Current Channel'
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
		print 'Command Number (h - for list): '.green

		command = gets.chomp
		puts ''

		case command

			when "1"
				tune
			when "2"
				get_channel
			when "3"
				get_info
			when "q"
				q
			when "debug"
				debug
			when "h"
				motd
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
		password = gets.chop
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
