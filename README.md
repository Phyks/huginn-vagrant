# Huginn with Vagrant and VirtualBox

Based on instructions here:

https://github.com/cantino/huginn/blob/master/doc/manual/installation.md

I created this installation for Vagrant/VirtualBox because I couldn't get email
working from the Docker image.

- Clone this repository: `git clone https://github.com/m0nty/huginn-vagrant.git`
- Either use ./setup.sh for semi-automatic configuration via a dialog interface.
  (If you do this, skip down to the line about config.vm.box below.) Or ...
- Edit the `env` file, which will be copied to `/home/huginn/huginn/.env`
  (look for the FIXME comments in the file to see what you need to adjust).
- Edit `provision.sh` and change the MySQL passwords for the root MySQL user and
  the Huginn DB user (search for FIXME again).
- Edit the `Vagrantfile` if you want to change the virtual machine settings. I've
  gone with `vb.memory = "1024"` which you might want to increase if you think
  your Huginn needs more.
- You might want to change this line `config.vm.box = "ubuntu/trusty64"` if your
  PC can't run 64-bit images.
- Edit the `huginn` file if you want to change the listening address and port for
  your Huginn instance.
- I don't think you need to change the Procfile, but you may as well check anyway.

Please let me know if I've messed up in any way. I've got my Huginn instance working
now, and I'm delighted with it. I just wanted to help out if anyone else is having
problems with the other installation methods.

# To-do

I'll probably do a Dockerfile sometime, so you can create a docker instance yourself
without pulling the Huginn docker image.

