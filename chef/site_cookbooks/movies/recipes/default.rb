include_recipe "hw-chef-locale"
include_recipe 'build-essential::default'
include_recipe "apache2"
include_recipe "php"
include_recipe "apache2::mod_php5"
include_recipe "simple-iptables"
include_recipe "git"
include_recipe "database::postgresql"
include_recipe "postgresql::server"
include_recipe "python"

#set server time to UK
link "/etc/localtime" do
  to "/usr/share/zoneinfo/GB"
  not_if "readlink /etc/localtime | grep -q 'GB$'"
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

####end generic server configuration

#delete /var/www/html
directory "/var/www/html" do
  recursive true
  action :delete
end

#delete /var/www/icons
directory "/var/www/icons" do
  recursive true
  action :delete
end

#delete /var/www/cgi-bin
directory "/var/www/cgi-bin" do
  recursive true
  action :delete
end

#delete /var/www/error
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
  allow_override "All"
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

#create database connection
db_connection = {:host => 'localhost',
                 :port => node['postgresql']['config']['port'],
                 :username => 'postgres',
                 :password => node['postgresql']['password']['postgres']}

#drop database movies before re-creating
postgresql_database 'movies' do
  connection(db_connection)
  database_name 'movies'
  action :drop
end

#create database movies
postgresql_database 'movies' do
  connection(db_connection)
  provider   Chef::Provider::Database::Postgresql
  action     :create
end

#create user movies
postgresql_database_user 'movies' do
  connection(db_connection)
  password 'movies'
  action :create
end

#grant all DB permission to movies user on movies DB
postgresql_database_user 'movies' do
  connection(db_connection)
  database_name 'movies'
  privileges    [:all]
  action        :grant
end

#create a vagrant user for the DB
postgresql_database_user 'vagrant' do
  connection(db_connection)
  password 'movies'
  action :create
end

#grant all DB permission to vagrant user on movies DB
postgresql_database 'copy_movies_permissions_to_vagrant' do
  connection(db_connection)
  database_name 'movies'
  sql {'GRANT movies TO vagrant;'}
  action :query
end

#import movies db schema
postgresql_database 'import_db_schema' do
  connection(db_connection)
  database_name 'movies'
  sql { ::File.open('/var/www/movies/_docs/sql/schema.sql').read }
  action :query
end

#import movies db static data
postgresql_database 'import_static_data' do
  connection(db_connection)
  database_name 'movies'
  sql { ::File.open('/var/www/movies/_docs/sql/static_data.sql').read }
  action :query
end

#create admin user - username-admin, password-admin
postgresql_database 'import_db_schema' do
  connection(db_connection)
  database_name 'movies'
  sql {"INSERT INTO \"user\" VALUES (1, 'admin', 'd033e22ae348aeb5660fc2140aec35850c4da997', true, NOW(), 'Admin');"}
  action :query
end

python_pip "sqlalchemy"