set -e

sudo apt-get update

sudo apt-get install -y docker.io

sudo systemctl enable docker
sudo systemctl start docker