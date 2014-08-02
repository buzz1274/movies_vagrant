include_recipe "apache2"

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

directory "/var/www/movies.zz50.co.uk" do
  owner "apache"
  group "apache"
  mode "0641"
  action :create
end

web_app "movies" do
  server_name "alpha.movies.zz50.co.uk"
  server_aliases ["www.alpha.movies.zz50.co.uk"]
  docroot "/var/www/movies.zz50.co.uk/"
end