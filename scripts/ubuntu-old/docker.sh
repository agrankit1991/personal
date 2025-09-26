# install docker
#This command updates the list of available packages and their versions, but it does not install or upgrade any packages.
sudo apt-get update
# This command installs necessary packages for the system to be able to download over an https connection.
sudo nala install apt-transport-https ca-certificates curl software-properties-common
# This command downloads the official GPG key of Docker to ensure that the Docker packages you download and install are authentic. It adds the key to your system's list of trusted keys.
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# This command adds the Docker repository to your system's software repositories list. Here, $(lsb_release -cs) is used to substitute the codename of your Ubuntu distribution (like focal, bionic, etc.).
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
# This command updates the list of available packages and their versions, including the Docker packages you just added.
sudo apt update
# his command installs Docker Community Edition (CE) on your system.
sudo nala install docker-ce
# his command checks the status of the Docker service. It should show that Docker is active (running).
sudo systemctl status docker
# This command adds the current user to the Docker group so that you can run Docker commands without using sudo.
sudo usermod -aG docker ${USER}
# This command logs you out of the current shell session and logs you back in. This is necessary for the group changes to take effect.
su - ${USER}
# This command checks if the current user is added to the Docker group. It lists all the groups the current user is a part of, which should now include docker.
id -nG
# This command adds the user 'agrankit' to the Docker group. Replace 'username' with your actual username.
sudo usermod -aG docker agrankit
# his command checks the installed version of Docker.
docker --version
# This command runs the 'hello-world' Docker image. If it's not available locally, Docker will download it from the Docker Hub. It's a simple test to ensure Docker is installed correctly.
docker run hello-world
# This command updates the list of available packages and their versions, but it does not install or upgrade any packages.
sudo apt update
# This command installs Docker Compose, a tool for defining and running multi-container Docker applications.
sudo nala install docker-compose
# This command checks the installed version of Docker Compose.
docker-compose --version