

package "postgresql-9.1-postgis" do
    action :install
end

# from https://docs.djangoproject.com/en/dev/ref/contrib/gis/install/postgis/
bash "create_postgis_template" do
    user "postgres"
    code <<-EOH
        # ubuntu path for 12.04
        POSTGIS_SQL_PATH="/usr/share/postgresql/9.1/contrib/postgis-1.5/"
        
        # creating the template spatial database
        createdb template_postgis
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
