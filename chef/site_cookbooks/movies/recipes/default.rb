include_recipe "apache2"
include_recipe "simple-iptables"

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

web_app "movies" do
  server_name "alpha.movies"
  server_aliases ["www.alpha.movies"]
  docroot "/var/www/movies/movies/html"
  directory_index "index.php"
end

#BEGIN CONFIGURE IPTABLES
#Allow SSH
simple_iptables_rule "ssh" do
  rule "--proto tcp --dport 22"
  jump "ACCEPT"
end

#Allow HTTP, HTTPS
simple_iptables_rule "http" do
  rule [ "--proto tcp --dport 80",
         "--proto tcp --dport 443" ]
  jump "ACCEPT"
end
#END CONFIGURE IPTABLES