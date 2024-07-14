# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
if Vagrant.has_plugin?("vagrant-vbguest")
 config.vbguest.auto_update = false
 config.vbguest.no_remote = true
 end 
 config.vm.box = "almalinux/9"  
 config.vm.provider "virtualbox" do |v| 
 v.memory = 1024
 v.cpus = 2
 end 
 config.vm.define "repo" do |repo| 
 repo.vm.network "private_network", ip: "192.168.56.16",  virtualbox__intnet: "net1"
 repo.vm.hostname = "repo"
 config.vm.provision :shell, :path => "repo_create.sh"
 end 
 
end 
