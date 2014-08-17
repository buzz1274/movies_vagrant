#set server locale
default[:locale][:lang] = "en_GB.utf8"

#configure postgresql options
default['build-essential']['compile_time'] = true
default['postgresql']['enable_pgdg_yum'] = true
default['postgresql']['version'] = "9.2"
default['postgresql']['dir'] = "/var/lib/pgsql/9.2/data"
default['postgresql']['client']['packages'] = ["postgresql92", "postgresql92-devel"]
default['postgresql']['server']['packages'] = ["postgresql92-server"]
default['postgresql']['server']['service_name'] = "postgresql-9.2"
default['postgresql']['contrib']['packages'] = ["postgresql92-contrib"]
default['postgresql']['password']['postgres'] = "xxx"
default['postgresql']['config']['port'] = "5432"

default['movies']['movies_path'] = '/mnt/movies'