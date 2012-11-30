# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|

  # builf off ubuntu 12.04 LTS
  config.vm.box = "precise64"
  # fetch from here if it isnt already cached
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"
  # the hostname of the machine
  config.vm.host_name = "django-vagrant"

  # host only networking
  config.vm.network :hostonly, "10.13.3.7"
  
  # provisioning
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = "cookbooks"
    chef.add_recipe "django"
  end
  
end
