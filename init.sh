sudo useradd -c "hadoop" -d /home/hadoop -m -s /bin/bash hadoop
echo "hadoop:hadoop" |sudo chpasswd
sudo -u hadoop ssh-keygen -f /home/hadoop/.ssh/id_rsa -t rsa -N ''

sudo -u hadoop bash setup.sh
sudo -u hadoop echo "export JAVA_HOME=/usr/lib/jvm/java-6-openjdk-amd64/" >> /home/hadoop/.bashrc
