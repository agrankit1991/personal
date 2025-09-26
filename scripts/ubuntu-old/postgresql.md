# Complete PostgreSQL Setup Guide for Ubuntu

## 1. Install PostgreSQL

First, update your package lists and install PostgreSQL:

```bash
# Update package lists
sudo nala update

# Install PostgreSQL (latest version in repositories)
sudo nala install postgresql postgresql-contrib
```

To install a specific version (e.g., PostgreSQL 16):

```bash
# Add PostgreSQL repository
sudo sh -c 'echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

# Update package lists
sudo nala update

# Install PostgreSQL 16
sudo nala install postgresql-16 postgresql-contrib-16
```

## 2. Verify Installation and Service Status

```bash
# Check if PostgreSQL service is running
sudo systemctl status postgresql

# If not running, start the service
sudo systemctl start postgresql

# Enable PostgreSQL to start on boot
sudo systemctl enable postgresql
```

## 3. Create User and Database

```bash
# Switch to postgres user
sudo -u postgres psql

# In psql, create user 'bawandar' with password 'password'
CREATE USER bawandar WITH PASSWORD 'password' SUPERUSER;

# Create a database with the same name as the user
CREATE DATABASE artha_sagar OWNER bawandar;

# Exit psql
\q
```

## 4. Configure PostgreSQL Authentication

```bash
# Find postgresql.conf location
sudo -u postgres psql -c "SHOW config_file;"

# Edit pg_hba.conf in the same directory as postgresql.conf
# Usually at /etc/postgresql/[version]/main/pg_hba.conf
sudo code /etc/postgresql/16/main/pg_hba.conf
# (or use your preferred text editor)
```

Add or modify the following line in pg_hba.conf (under IPv4 local connections):
```
host    all             bawandar        127.0.0.1/32            scram-sha-256
```

After editing, restart PostgreSQL:
```bash
sudo systemctl restart postgresql
```

## 5. Configure PostgreSQL Password Encryption (Optional)

If you want to ensure passwords are stored securely:

```bash
# Edit postgresql.conf
sudo nano /etc/postgresql/16/main/postgresql.conf
# (or use your preferred text editor)
```

Find and set:
```
password_encryption = scram-sha-256
```

Save and restart PostgreSQL:
```bash
sudo systemctl restart postgresql
```

## 6. Test Connection

```bash
# Connect to database
psql -U bawandar -h 127.0.0.1 -d artha_sagar

# Or with password
PGPASSWORD=password psql -U bawandar -h 127.0.0.1 -d bawandar
```

## 7. Useful Commands Inside psql

```sql
-- List all databases
\l

-- List all users
\du

-- List all tables in current database
\dt

-- Exit psql
\q
```

## 8. Add Bash Aliases

Add these aliases to your `~/.bashrc` or `~/.zshrc` file:

```bash
# Add PostgreSQL aliases
cat >> ~/.bashrc << 'EOL'
# PostgreSQL aliases
alias pg-start="sudo systemctl start postgresql"
alias pg-stop="sudo systemctl stop postgresql"
alias pg-restart="sudo systemctl restart postgresql"
alias pg-status="sudo systemctl status postgresql"
alias psql-bawandar="PGPASSWORD=password psql -U bawandar -h 127.0.0.1 -d bawandar"
EOL

# Apply changes to current session
source ~/.bashrc
```

## 9. Adjust PostgreSQL Configuration (if needed)

To modify performance settings, edit postgresql.conf:

```bash
sudo nano /etc/postgresql/16/main/postgresql.conf
```

Common settings to adjust:
```
# Connection settings
listen_addresses = 'localhost'    # Listen only on localhost
max_connections = 100             # Maximum number of connections

# Memory settings
shared_buffers = 128MB            # Start with 25% of your RAM
work_mem = 4MB                    # Memory for query operations

# Write-ahead Log
wal_level = replica               # Minimal, replica, or logical
```

Save and restart PostgreSQL:
```bash
sudo systemctl restart postgresql
```

## 10. Basic Security Configuration

```bash
# Set proper permissions for data directory
sudo chmod 700 /var/lib/postgresql/16/main

# Ensure PostgreSQL uses a separate user (default is 'postgres')
sudo systemctl status postgresql
```

## 11. Backup and Restore

For database backups:

```bash
# Create backup
pg_dump -U bawandar -h 127.0.0.1 -d bawandar > backup.sql

# Restore from backup
psql -U bawandar -h 127.0.0.1 -d bawandar < backup.sql
```

## Troubleshooting

```bash
# Check PostgreSQL logs
sudo tail -f /var/log/postgresql/postgresql-16-main.log

# If you need to delete and recreate:
sudo -u postgres psql -c "DROP DATABASE bawandar;"
sudo -u postgres psql -c "DROP USER bawandar;"
# Then repeat steps 3-4

# Restart PostgreSQL if needed
sudo systemctl restart postgresql
```

Remember:
- Username: bawandar
- Password: password
- Default port: 5432
- Host: localhost or 127.0.0.1