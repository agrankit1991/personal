# Install PostgreSQL
sudo pacman -S postgresql

# Initialize the database cluster
sudo -u postgres initdb -D /var/lib/postgres/data

# Start and enable PostgreSQL service
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Switch to postgres user and create the database and user
sudo -u postgres psql << EOF
-- Create the user with password
CREATE USER assistant WITH PASSWORD 'password';

-- Create the database
CREATE DATABASE assistant;

-- Grant all privileges on the database to the user
GRANT ALL PRIVILEGES ON DATABASE assistant TO assistant;

-- Connect to the assistant database and grant schema privileges
\c assistant
GRANT ALL ON SCHEMA public TO assistant;

-- Exit
\q
EOF

# Verify the connection works
psql postgresql://assistant:password@localhost:5432/assistant -c "SELECT version();"