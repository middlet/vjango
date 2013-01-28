# update the packages
execute "update_package_index" do
    command "apt-get update"
    ignore_failure true
    action :nothing
end.run_action(:run)

# install the required packages
%w{python-pip postgresql postgresql-9.1-postgis}.each do |pkg|
    package pkg do
        action :install
    end
end

# create the PostGIS template
# based on geodjango instructions
# https://docs.djangoproject.com/en/dev/ref/contrib/gis/install/postgis/
bash "create_postgis_template" do
    user "postgres"
    code <<-EOH
        # ubuntu path for 12.04
        POSTGIS_SQL_PATH="/usr/share/postgresql/9.1/contrib/postgis-1.5/"
        
        # creating the template spatial database
        createdb -E UTF8 -T template0 --locale=en_GB.utf8 template_postgis
        createlang -d template_postgis plpgsql
        
        # allow non superusers to create from this template
        psql -d postgres -c "UPDATE pg_database SET datistemplate='true' WHERE datname='template_postgis';"
        # load the PostGIS SQL routines
        psql -d template_postgis -f $POSTGIS_SQL_PATH/postgis.sql
        psql -d template_postgis -f $POSTGIS_SQL_PATH/spatial_ref_sys.sql
        # enable users to alter spatial tables
        psql -d template_postgis -c "GRANT ALL ON geometry_columns TO PUBLIC;"
        psql -d template_postgis -c "GRANT ALL ON geography_columns TO PUBLIC;"
        psql -d template_postgis -c "GRANT ALL ON spatial_ref_sys TO PUBLIC;"
    EOH
end

# install django
execute "install_django" do
    command "pip install django"
end

# install python postgresql extensions
execute "install_django" do
    command "apt-get install -y python-psycopg2"
end

# set up the default db for django
bash "create_database" do
    user "postgres"
    code <<-EOH
        psql -c "create user desurbs with password 'desurbs';"
        psql -c "create database desurbsdb owner desurbs template template_postgis;"
    EOH
end

bash "postgres_config_file" do
    code <<-EOH
        cat > /etc/postgresql/9.1/main/pg_hba.conf << _EOF_
local   all             postgres                                peer
local   all             all                                     md5
host    all             all             127.0.0.1/32            md5
host    all             all             ::1/128                 md5
_EOF_
    EOH
end

# install south (database migrations)
execute "install_South" do
    command "pip install South"
end

