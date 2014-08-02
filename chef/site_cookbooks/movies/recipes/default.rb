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

web_app "movies" do
  server_name "alpha.movies"
  server_aliases ["www.alpha.movies"]
  docroot "/var/www/movies/movies/html"
  directory_index "index.php"
end