# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "hfm4/centos-with-docker"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  # config.vm.box_url = "http://domain.com/path/to/above.box"

  config.vm.network :forwarded_port, guest: 80, host: 8080
  config.vm.network :public_network, ip: "192.168.1.201"

  config.vm.synced_folder "../movies/", "/var/www/movies/", :nfs => true

  config.ssh.forward_agent = true

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "4096"]
  end

  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = ["chef/cookbooks", "chef/site_cookbooks"]
    chef.roles_path = "chef/roles"
    chef.data_bags_path = "chef/databags"

    chef.add_recipe "movies"
  end
end
