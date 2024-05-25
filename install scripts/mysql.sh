#MySql Server and Workbench: https://phoenixnap.com/kb/install-mysql-ubuntu-20-04
sudo nala install mysql-server
sudo mysql_secure_installation
sudo snap install mysql-workbench-community
# Store password for application downloaded from snap
sudo snap connect mysql-workbench-community:password-manager-service :password-manager-service
# Allow mysql workbench to connect to root user with password
sudo mysql
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '<password>';