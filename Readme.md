# GT Vagrant

GT Vagrant is an open source [Vagrant](https://www.vagrantup.com) configuration focused on [WordPress](https://wordpress.org) development, loosely based on [Varying Vagrant Vagrants](https://varyingvagrantvagrants.org/). This product is released under the [MIT License](LICENSE).

## Objectives

* Approachable development environment with a modern server configuration.
* Stable state of software and configuration in default provisioning.
* Modular WordPress environment managed via GIT and WP-Cli.

## Minimum System requirements

* [Vagrant](https://www.vagrantup.com) 2.1+
* [Virtualbox](https://www.virtualbox.org) 5.2+

## Software included

GT Vagrant is built on a Ubuntu 16.04 LTS (Xenial) base VM and provisions the server with a _conservative_ list of several software packages, including:

* [Apache](http://apache.org/) 2.4.x
* [MySQL](https://www.mysql.com/) 5.7.x
* [PHP](https://php.org/) 7.4 (Apache module)
* [WordPress](https://wordpress.org/)
* [Git](https://git-scm.com/) 2.7.x
* [WP-CLI](http://wp-cli.org/)
* [Composer](https://github.com/composer/composer)
* [NodeJs](https://nodejs.org/)
* [GulpJS](https://gulpjs.com/)
* [Yarn](https://yarnpkg.com/en/)
* [PhpMyAdmin](https://www.phpmyadmin.net/)
* [MailHog](https://github.com/mailhog/MailHog)

## Getting Started

Graduate Vagrant requires recent versions of both Vagrant and VirtualBox.

[Vagrant](https://www.vagrantup.com) is a "tool for building and distributing development environments". It works with [virtualization](https://en.wikipedia.org/wiki/X86_virtualization) software such as [VirtualBox](https://www.virtualbox.org/) to provide a virtual machine sandboxed from your local environment. Please note that no provider support is available for Parallels, Hyper-V, VMWare Fusion, and VMWare Workstation.

If you aren’t using a Mac, you may need to turn on virtualization in your computers BIOS, some computers have it turned off by default. On Intel machines this is called Intel VT-x, and AMD calls it AMD-V. Refer to your machines manufacturer for how to access your BIOS. [This article may be helpful for enabling Intel VT-x](https://www.howtogeek.com/213795/how-to-enable-intel-vt-x-in-your-computers-bios-or-uefi-firmware/). Please note that if you have turned Hyper-V on, VirtualBox will not work.

## Installing Vagrant and VirtualBox

1. Start with any local operating system such as Mac OS X, Linux, or Windows.
1. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads).
1. Install [Vagrant](https://www.vagrantup.com/downloads.html). If Vagrant is already installed, use `vagrant -v` to check the version. You may want to consider upgrading if a much older version is in use.
	1. `vagrant` will now be available as a command in your terminal, try it out.
	1. Provider support is included only for VirtualBox at this time.
	1. The [Vagrant Hosts Updater](https://github.com/cogitatio/vagrant-hostsupdater) plugin will be installed by the provisioning script.
1. Reboot your machine. If you don’t reboot your machine after installing/updating Vagrant and VirtualBox, there can be networking issues. A full power cycle will ensure all components are fully installed and loaded.

## Installing Graduate Vagrant

We recommend using Git as it makes updating much easier. Open a Terminal window and clone the main repo into a local directory:

`git clone -b master https://gitlab.com/gccomms/vagrant.git ~/vagrant-local`

If you are a Mac user, the easiest way to install Git is to install the Xcode Command Line Tools which comes with Git among other things. On Mavericks (10.9) or above you can do this simply by trying to run the git command from the Terminal, with `git --version`. If you don’t have git installed already, it will prompt you to install it. If you are using a different operating system, please refer to the [official documentation](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) to learn how to install git on your machine. Or you can [download the repository as a zip file](https://gitlab.com/gccomms/vagrant/-/archive/master/vagrant-master.zip) instead, and avoid installing Git on your machine altogether.

The default configuration will initialize a virtual machine `gtvagrant` with IP address 192.168.100.100. If you would like to change either the name or the static IP address assigned to the virtual machine, please copy `config.yml` to `config-custom.yml` (which is ignored in the repository) and update the values according to your needs, **before** you run the installation script. Please, do not edit `config.yml` directly.

Once the repo has been cloned (or the zip file has been unzipped), in Terminal enter the new directory with `cd ~/vagrant-local` (please type the actual directory name you used) and start the Vagrant environment with `vagrant up`. Be patient as the magic happens. This *will* take a while on the first run as your local machine downloads the required files. During the installation, you will be prompted to provide an administrator or `su` password to properly modify the hosts file on your local machine, so that you will be able to access the various web pages later. On future runs of `vagrant up`, the packaged box will be cached on your local machine and Vagrant will only need to apply the requested provisioning.

When the installation is complete, make sure no errors were reported by any of the scripts. If everything went well, you can access your newly minted virtual enviroment with `vagrant ssh`. You can also visit the default WordPress site at `https://wp.local` (username: admin, password: vagrant), PhpMyAdmin at `https://db.local` (username: root, password: vagrant), and MailHog at `http://mail.local:8025` (no password required).

**Please note**: Graduate Vagrant uses self-signed SSL certificates, which will trigger a warning on your browser about the connection not being secure. This is expected, and can be fixed by configuring your browser to accept this exception and not display a warning anymore. There are [many resources on the web](https://stackoverflow.com/questions/7580508/getting-chrome-to-accept-self-signed-localhost-certificate) that explain how to do that. Feel free to research the solution that applies to your specific browser.

## Basic Usage

This documentation assumes some very basic terminal/command line knowledge to run simple commands. However, some people prefer the convenience of a visual UI. If you fall into this category then consider the [Vagrant Manager](http://vagrantmanager.com/) project.

* Turning GTV on: `vagrant up`
* Turning GTV off: `vagrant halt`
* Restarting GTV: `vagrant reload`
* Logging into GTV: `vagrant ssh` (your user has full sudo access)

## Folder structure

Your host and guest share two folders:
* `www/` is mounted as `/var/www/` on the guest 
* `provision/` is mounted as `/provision/` and is used by the provisioning script to setup the environment.
* Utility scripts are available in `/usr/local/bin/` (which is included in the search PATH for the command line).

The default WordPress site is installed under `/var/www/wp.local` (or the custom domain name you specified in your config file). Web folders contain three main subfolders:
* `backups` where the daily file and database snapshots are saved.
* `logs`, which contains the Apache access and error logs.
* `html` configured as the web server document root for that website.
	* `.gitignore`
	* `.gitmodules`
	* `config.php` defines the database credentials and other custom settings (and is not tracked in Git).
	* `content` is a replacement for the built-in wp-content folder, and it contains plugins, themes and uploads.
		* `plugins` we recommend installing plugins and themes via Git, by cloning the corresponding repos, not via the WordPress admin or WP-CLI.
		* `themes`
		* `uploads` not tracked in Git.
	* `index.php`
	* `wp` contains WordPress as a Git submodule. Please [refer to this article](https://deliciousbrains.com/install-wordpress-subdirectory-composer-git-submodule/) for more information on why we decided to follow this approach. In short, by treating WordPress itself as a dependency, you can make the structure of your Git repo more modular and clean. You don’t have to replicate the code and updates become much easier as you don’t have to commit updates to WordPress as part of your workflow.
	* `wp-config.php` has been modified to make WordPress aware of our custom folder structure, and it does NOT contain database credentials or other custom settings.

Our basic configuration is very lean and simple, and it only includes WordPress and GradPress as a submodule, to give you an idea of how to add dependencies, as described in [this article on Delicious Brains](https://deliciousbrains.com/git-submodules-manage-wordpress-themes-and-plugins/). This will make it easier to deploy a standard enviroment that already includes all the themes and plugins your developers will need to build many new awesome WordPress-based websites, without having to go through the tedious task of installing those dependencies individually. More information on how to create your custom collection can be found on our [WSE Gitlab Page](https://gitlab.com/gccomms/wordpress#adding-dependencies).

## Editing files and committing changes: host or guest?

So, now that you have your shiny new virtual development enviroment, how should you use it? Of course, there is no single best practice that we can recommend, it all depends on what you feel comfortable with. Some teams will do everything in GV: edit files, commit changes, test their features, etc. Others prefer using tools like [Visual Studio Code](https://code.visualstudio.com/) on their host machine, since it includes a visual interface to commit changes, manage workspaces and so on. They only use GV's web and database servers to run their code in a standardized enviroment. You might decide to adopt a hybrid approach, where some developers in your team go with one workflow and others use their favorite IDE. We encourage you to experiment and see what works best for you.

## Keeping Up To Date

Your GTV install will hopefully serve you for many years, but in order to keep pace with new fixes and improvements, you’ll need to update it from time to time. A simple `git pull; vagrant reload --provision` should do just fine. You may want to make sure your vagrant and virtualbox are up to date. If necessary, download a new vagrant and install a fresh copy. 

Graduate Vagrant is intended as a developer environment, and you should be able to throw away the VM and rebuild it without losing anything. However, you should be able to destroy a machine without losing any of the files in the `www` folder (but you **will** lose the databases!). Having said that, do not keep critical information stored only in GV, always take backups.

## Adding a New Site

Adding a new site is as simple as running a command line script: `wp-setup newsite.local`

This script accepts another optional parameter to install the website as a *standard* WordPress environment (not using submodules as described here above): `wp-setup newsite.local standard`

This is what will happen when you run that command:

* A new folder `newsite.local` is added under /var/www, along with all the subfolders as described here above.
* A new database `sites_newsite_local` is added to MySQL.
* The WordPress Git repo is cloned in the appropriate location (this will take a while, so please be patient).
* The WP configuration script is generated, with random salts, credentials, etc.
* The following WordPress admin credentials are used: **username = admin, password = vagrant**
* A new virtual host is added to Apache (under `/etc/apache2/sites-available`)
* A new cronjob to run the daily backup is added to crontab

Please remember to add `newsite.local` to your local /etc/hosts file, with IP address 192.168.100.100 (or the custom IP address specified in your config file). Once you do that, point your browser to https://newsite.local and you should see your new shiny WordPress install up and running. Also, keep in mind that when using the custom folder structure, the admin panel is available at https://newsite.local/wp/wp-login.php.

Graduate Vagrant does not support custom versions of PHP for each virtual host, for the sake of simplicity; if your development workflow requires a more customizable experience, we recommend that you look into [Varying Vagrant Vagrants](https://varyingvagrantvagrants.org/).

## Updating WordPress and plugins

We recommend not using the WP admin to update your environment, since this method might delete your Git repo files. Instead, when WordPress is installed in a subfolder as its own Git repo, updates are as easy as switching to a new Git branch:

`cd /var/www/wp.local/html/wp/; git fetch --all; git checkout tags/5.2 -b 5.2`

For your plugins, we bundled a script with our Vagrant environment to make things as simple as possible:

`cd /var/www/wp.local/html/content/plugins; wp-update plugin redirection`

This script will temporarily save your `.git` folder, and then use WP-CLI to update your plugin. It will also ask you if you want to push the new version to your Git repo.

## A Note on Our Git Workflow

Our team has adopted a fairly [standard development workflow](https://nvie.com/posts/a-successful-git-branching-model/). Developers work on bugs and features in separate Git branches; once these updates are ready to be released, they are merged into the `dev` branch and deployed to the staging environment for quality assurance and testing; after testing is complete, the `dev` branch is merged into the master branch, ready to be deployed to the production environment. This commit is also tagged with a release number, when applicable. We consider origin/master to be the main branch where the source code of HEAD always reflects a production-ready state. We consider origin/dev to be the main branch where the source code of HEAD always reflects a state with the latest delivered development changes for the next release. Next to the main branches master and dev, our development model uses a variety of supporting branches to aid parallel development between team members, ease tracking of features, prepare for production releases and to assist in quickly fixing live production problems.

The Graduate Vagrant environment has been designed with this workflow in mind, even though is flexible enough to be adapted to other styles and practices.
