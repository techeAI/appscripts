
## Create DNS records
# Name              Type       Value
mail                IN A       1.2.3.4 (IP)
autodiscover        IN CNAME   mail.example.org. 
autoconfig          IN CNAME   mail.example.org. 
@                   IN MX 10   mail.example.org. 

@                   IN TXT     "v=spf1 mx a -all"
_autodiscover._tcp  IN SRV     0        1      443      mail.example.org. 
_imap._tcp          IN SRV     0        1      143      mail.example.org. 
_imaps._tcp         IN SRV     0        1      993      mail.example.org. 
_pop3._tcp          IN SRV     0        1      110      mail.example.org. 
_pop3s._tcp         IN SRV     0        1      995      mail.example.org. 
_smtps._tcp         IN SRV     0        1      465      mail.example.org. 
_submission._tcp    IN SRV     0        1      587      mail.example.org. 
_submissions._tcp   IN SRV     0        1      465      mail.example.org. 

## install packages
apt install -y sudo curl git vim openssl gawk coreutils grep jq
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
sudo setfacl --modify user:$USER:rw /var/run/docker.sock 2> /dev/null
apt install docker-ce docker-ce-cli containerd.io docker-compose -y

## clone the code
umask 0022
cd /opt
git clone https://github.com/mailcow/mailcow-dockerized
cd mailcow-dockerized

## Generate config for first run 
./generate_config.sh

## then nano mailcow.conf if needed.

docker compose pull
docker compose up -d