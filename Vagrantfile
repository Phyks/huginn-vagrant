# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.define "huginn-vagrant" do |huginn|
  end
  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.memory = "1024"
    vb.name = "huginn-vagrant"
  end
  config.vm.hostname = "huginn.local"
  config.vm.box_check_update = false
  config.vm.provision "shell", inline: "/vagrant/provision.sh"
  config.vm.network :forwarded_port, guest:3000, host:3000, id:"nginx", host_ip:"127.0.0.1", auto_correct: true
end
