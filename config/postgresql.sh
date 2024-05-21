sudo apt install postgresql

# switch to the postgres user
sudo -i -u postgrespsql

# access the postgrespsql command line interface
psql

# set the password for the default postgrespsql user 'postgres'
\password postgres

# create new database
create database <database_name>;

# create new user and grant privileges
CREATE USER {{username}} WITH ENCRYPTED PASSWORD '{{password}}';
GRANT ALL PRIVILEGES ON DATABASE {{database_name}} TO {{username}};

# exit the command line interface
\q

# exit the postgresql user session
exit