sudo useradd -c "hadoop" -d /home/hadoop -m -s /bin/bash hadoop
# if hadoop already exists, ensure env is as expected
sudo usermod -s /bin/bash -d /home/hadoop hadoop
echo "hadoop:hadoop" |sudo chpasswd
sudo -u hadoop rm -rf /home/hadoop/.ssh
sudo -u hadoop ssh-keygen -f /home/hadoop/.ssh/id_rsa -t rsa -N ''
chmod 666 *jar
sudo -u hadoop cp *jar ~hadoop/
cp setup.sh /tmp/
sudo -i -u hadoop bash /tmp/setup.sh
