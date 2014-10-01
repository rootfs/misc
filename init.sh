sudo useradd -c "hadoop" -d /home/hadoop -m -s /bin/bash hadoop
echo "hadoop:hadoop" |sudo chpasswd
sudo -u hadoop rm -rf /home/hadoop/.ssh
sudo -u hadoop ssh-keygen -f /home/hadoop/.ssh/id_rsa -t rsa -N ''
chmod 666 *jar
sudo -u hadoop cp *jar ~hadoop/
sudo -u hadoop bash setup.sh
