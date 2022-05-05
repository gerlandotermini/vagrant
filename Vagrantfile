# -*- mode: ruby -*-
# vi: set ft=ruby ts=2 sw=2 et:
Vagrant.require_version ">= 2.1.0"

# Graduate Vagrant: an open source environment for developing with WordPress
version="1.0"

# Load default configuration file
require 'yaml'
conf = YAML.load( File.open( "config.yml", File::RDONLY ).read )

# Load local overrides from config-custom.yml
if File.exists? ( "config-custom.yml" )
	conf.merge! ( YAML.load( File.open( "config-custom.yml", File::RDONLY ).read ) )
end

green="\033[1;38;5;2m"#22m"
blue="\033[38;5;4m"#33m"
docs="\033[0m"
yellow="\033[38;5;3m"#136m"
creset="\033[0m"

splash = <<-HEREDOC
#{yellow}GT Vagrant: an open source environment for developing with WordPress
#{docs}
Version: #{version}
#{creset}
Quick Links
#{green}WordPress: #{docs}https://#{conf[ 'hostnames' ][ 'web' ]}
#{green}Database:  #{docs}https://#{conf[ 'hostnames' ][ 'db' ]}
#{green}Web Mail:  #{docs}http://#{conf[ 'hostnames' ][ 'mail' ]}:8025
#{creset}
HEREDOC

Vagrant.configure("2") do |config|
	# Welcome message
	if ARGV[0] == 'up' || ARGV[0] == 'ssh'
		puts splash
	end

	# Define the box image
	config.vm.box = "ubuntu/jammy64"
	config.vm.box_check_update = false

	# Create a private network, which allows host-only access to the machine using a specific IP.
	config.vm.network "private_network", ip: conf[ 'vm' ][ 'ip_address' ]

	# Deactivate secure keys, needed for repackaging our box
	# https://github.com/hashicorp/vagrant/issues/5186#issuecomment-77681605
	config.ssh.insert_key = false

	# Disable the default synced folder to avoid overlapping mounts
	config.vm.synced_folder '.', '/vagrant', disabled: true

	# Map the provision folder so that utilities and provisioners can access helper scripts
	config.vm.synced_folder "provision/", "/provision"

	# Share the main document root folder between host and guest
	config.vm.synced_folder "www/", "/var/www", create: true, owner: "vagrant", group: "vagrant", mount_options: [ "dmode=775", "fmode=775" ]

	# Virtualbox configuration (memory, CPUs, etc)
	config.vm.provider :virtualbox do |vb|
		vb.name = conf[ 'vm' ][ 'hostname' ]
		vb.customize [ "modifyvm", :id, "--memory", 2048 ]
		vb.customize [ "modifyvm", :id, "--cpus", 1 ]
		vb.customize [ "modifyvm", :id, "--natdnshostresolver1", "on" ]
		vb.customize [ "modifyvm", :id, "--natdnsproxy1", "on" ]
		
		# see https://github.com/hashicorp/vagrant/issues/7648
		vb.customize [ "modifyvm", :id, "--cableconnected1", "on"]

		vb.customize [ "modifyvm", :id, "--rtcuseutc", "on" ]
		vb.customize [ "modifyvm", :id, "--audio", "none" ]
		vb.customize [ "modifyvm", :id, "--paravirtprovider", "kvm" ]
		vb.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 1000 ]
	end

	# Load Vagrant plugins
	#
	# Check if the first argument to the vagrant command is plugin/destroy
	if ARGV[0] != 'plugin' && ARGV[0] != 'destroy'
		# Define the plugins in an array format
		required_plugins = [ 'vagrant-vbguest', 'vagrant-disksize', 'vagrant-hostsupdater' ]
		plugins_to_install = required_plugins.select { |plugin| not Vagrant.has_plugin? plugin }
		if not plugins_to_install.empty?
			puts "Installing plugins: #{plugins_to_install.join(' ')}"
			if system "vagrant plugin install #{plugins_to_install.join(' ')}"
			exec "vagrant #{ARGV.join(' ')}"
			else
			abort "Installation of one or more plugins has failed. Aborting."
			end
		end
	end

	if Vagrant.has_plugin?("vagrant-vbguest")
		config.vbguest.auto_update = false  
	end

	# Define host name and add it to the machine's hosts file
	config.vm.define conf[ 'vm' ][ 'name' ]
	config.vm.hostname = conf[ 'vm' ][ 'hostname' ]
	if defined?( VagrantPlugins::HostsUpdater )
		# Pass the host names to the hostsupdater plugin so it can perform magic.
		config.hostsupdater.aliases = [ conf[ 'hostnames' ][ 'web' ], conf[ 'hostnames' ][ 'db' ], conf[ 'hostnames' ][ 'mail' ] ]
		config.hostsupdater.remove_on_suspend = false
	end

	# Enable provisioning with a shell script.
	config.vm.provision :shell, :privileged => false, :path => "provision/provision.sh", 
		:args => [
			conf[ 'hostnames' ][ 'web' ],
			conf[ 'hostnames' ][ 'db' ],
			conf[ 'hostnames' ][ 'mail' ]
		]

	# Make sure to start apache on boot
	config.vm.provision :shell, :inline => "sudo apachectl -k restart", run: "always"
end
