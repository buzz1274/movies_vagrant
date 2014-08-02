include_recipe "apache2"
include_recipe "php"
include_recipe "simple-iptables"
include_recipe "git"

directory "/var/www/html" do
  recursive true
  action :delete
end

directory "/var/www/icons" do
  recursive true
  action :delete
end

directory "/var/www/cgi-bin" do
  recursive true
  action :delete
end

directory "/var/www/error" do
  recursive true
  action :delete
end

#create apache vhost
web_app "movies" do
  server_name "alpha.movies"
  server_aliases ["www.alpha.movies"]
  docroot "/var/www/movies/movies/html"
  directory_index "index.php"
end

#create folder for cakephp library
directory "/usr/local/cakephp/" do
  owner "root"
  group "root"
  mode "755"
  action :create
end

#checkout cakephp from github
git "/usr/local/cakephp/" do
  repository "https://github.com/cakephp/cakephp"
  reference "master"
  action :sync
end

#create config.ini for movies
template "/var/www/movies/movies/app/Config/config.ini" do
  source "config_ini.erb"
  variables(:db_user => 'movies',
            :db_name => 'movies',
            :db_password => 'movies')
end

#sets location of /etc/php.ini for pear
execute "set location of php.ini for PEAR" do
  command "pear config-set php_ini /etc/php.ini"
end

#install php pdo
yum_package "php-pdo" do
  action :install
end

#install php postgresql
yum_package "php-pgsql" do
  action :install
end

#iptables Allow SSH
simple_iptables_rule "ssh" do
  rule "--proto tcp --dport 22"
  jump "ACCEPT"
end

#iptables Allow HTTP, HTTPS
simple_iptables_rule "http" do
  rule ["--proto tcp --dport 80",
        "--proto tcp --dport 443"]
  jump "ACCEPT"
end