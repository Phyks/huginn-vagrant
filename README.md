# Huginn with Vagrant and VirtualBox

Based on instructions here:

https://github.com/cantino/huginn/blob/master/doc/manual/installation.md

**Setup Huginn under VirtualBox, with minimal configuration required.**

A working VirtualBox installation is a prerequisite.

If you know the settings you will use for your Huginn installation (such
as SMTP host, MySQL settings, etc) you can:

- Clone this repository: `git clone https://github.com/m0nty/huginn-vagrant.git`
- Jump straight in with `./setup.sh` and follow the prompts. No attempt 
  is made to validate your input while you do this, but sensible defaults are
  suggested for usernames, passwords, etc.
- Run `vagrant up` to provision your Huginn instance.

If you prefer to edit the config files yourself:

- Clone this repository: `git clone https://github.com/m0nty/huginn-vagrant.git`
- Edit the `env` file, which will be copied to `/home/huginn/huginn/.env`
  (look for the FIXME comments in the file to see what you need to adjust).
- Edit `provision.sh` and change the MySQL passwords for the root MySQL user and
  the Huginn DB user (search for FIXME again).
- Edit the `Vagrantfile` if you want to change the virtual machine settings. I've
  gone with `vb.memory = "1024"` which you might want to increase if you think
  your Huginn is going to be busier.
- You might want to change the line `config.vm.box = "ubuntu/trusty64"` if your
  PC can't run 64-bit images.
- Edit the `huginn` file if you want to change the listening address and port for
  your Huginn instance.
- I don't think you need to change the Procfile, but you may as well check anyway.
- After that, run `vagrant up` to provision your Huginn instance.

Please let me know if I've messed up in any way. I've got my Huginn instance working
now, and I'm delighted with it. I just wanted to help out if anyone else is having
problems with the other installation methods.

# To-do

I'll probably do a Dockerfile sometime, so you can create a docker instance yourself
without pulling the Huginn docker image.

