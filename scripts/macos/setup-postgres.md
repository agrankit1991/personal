Here's a step-by-step guide to install and configure PostgreSQL on macOS:

1. **Install PostgreSQL using Homebrew**:
```bash
# Install PostgreSQL
brew install postgresql@16

# Start PostgreSQL service
brew services start postgresql@16
```

2. **Add PostgreSQL to your PATH** (add to `~/.zshrc`):
```bash
# If you need to have postgresql@16 first in your PATH, run:
echo 'export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"' >> ~/.zshrc

# For compilers to find postgresql@16 you may need to set:
echo 'export LDFLAGS="-L/opt/homebrew/opt/postgresql@16/lib"' >> ~/.zshrc
echo 'export CPPFLAGS="-I/opt/homebrew/opt/postgresql@16/include"' >> ~/.zshrc

source ~/.zshrc
```

3. **Create User and Database**:
```bash
# Create user 'bawandar' with password 'password'
createuser --interactive --pwprompt bawandar
# Enter password when prompted: password
# Answer 'y' for superuser

# Create a database with the same name as the user
createdb <database name>
```

4. **Configure PostgreSQL Authentication**:
```bash
# Find postgresql.conf location
echo "show config_file;" | psql

# Edit pg_hba.conf in the same directory as postgresql.conf
# Usually at /opt/homebrew/var/postgresql@16/pg_hba.conf
# Add this line (use sudo if needed):
echo "host    all             bawandar        127.0.0.1/32            scram-sha-256" >> /opt/homebrew/var/postgresql@16/pg_hba.conf

# Restart PostgreSQL
brew services restart postgresql@16
```

5. **Test Connection**:
```bash
# Connect to database
psql -U <user name> -d <database name>

# Or with password
PGPASSWORD=<password> psql -U <user name> -d <database name>
```

6. **Useful Commands Inside psql**:
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

7. **Add Aliases** (add to `~/.zshrc`):
```bash
# Add PostgreSQL aliases
echo '# PostgreSQL aliases
alias pg-start="brew services start postgresql@16"
alias pg-stop="brew services stop postgresql@16"
alias pg-restart="brew services restart postgresql@16"
alias pg-status="brew services list | grep postgresql"
alias psql-bawandar="PGPASSWORD=password psql -U bawandar -d bawandar"
' >> ~/.zshrc

source ~/.zshrc
```

Now you can:
- Start/stop PostgreSQL: `pg-start`, `pg-stop`
- Check status: `pg-status`
- Quick connect: `psql-bawandar`

To verify everything:
```bash
# Check PostgreSQL status
pg-status

# Connect to your database
psql-bawandar

# Inside psql, try:
SELECT current_user;
SELECT current_database();
```

Troubleshooting:
```bash
# If you need to delete and recreate:
dropdb bawandar
dropuser bawandar
# Then repeat steps 3-4

# Check logs if needed:
tail -f /opt/homebrew/var/log/postgresql@16.log
```

Remember:
- Username: bawandar
- Password: password
- Default port: 5432
- Host: localhost or 127.0.0.1

Need any clarification or having issues?