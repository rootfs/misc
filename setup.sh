nodes=("plana04" "plana51" "plana55" "plana85")
HADOOP_VERSION="2.4.1"

cat > /home/hadoop/.ssh/config <<EOF
Host *
   StrictHostKeyChecking no
   UserKnownHostsFile=/dev/null
EOF

cd /home/hadoop

rm -rf hadoop-${HADOOP_VERSION}*
 
if [ ! -f hadoop-${HADOOP_VERSION}.tar.gz ]
then
    wget -q http://www.us.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz
    tar xzf hadoop-${HADOOP_VERSION}.tar.gz 
    ln -fs `pwd`/hadoop-${HADOOP_VERSION} hadoop
fi

rm -f hadoop/etc/hadoop/slaves
for i in ${nodes[@]}
do 
    echo $i >> hadoop/etc/hadoop/slaves
done

# choose the last node as namenode
namenode=$i
cat > hadoop/etc/hadoop/core-site.xml << EOF
<configuration>
  <property>
    <name>fs.default.name</name>
    <value>ceph://${namenode}:6789/</value>
  </property>
  <property>
    <name>fs.defaultFS</name>
    <value>ceph://${namenode}:6789/</value>
  </property>
  <property>
    <name>ceph.conf.file</name>
    <value>/etc/ceph/ceph.conf</value>
  </property>
  <!--
     <property>
       <name>ceph.mon.address</name>
       <value>localhost:6789</value>
     </property>
     <property>
       <name>ceph.auth.id</name>
       <value>root</value>
     </property>
     -->
  <property>
    <name>ceph.data.pools</name>
    <value>data</value>
  </property>
  <property>
    <name>fs.AbstractFileSystem.ceph.impl</name>
    <value>org.apache.hadoop.fs.ceph.CephFs</value>
  </property>
  <property>
    <name>fs.ceph.impl</name>
    <value>org.apache.hadoop.fs.ceph.CephFileSystem</value>
  </property>
</configuration>
EOF

cat > hadoop/etc/hadoop/mapred-site.xml << EOF
<configuration>
     <property>
         <name>mapred.job.tracker</name>
         <value>${namenode}:9001</value>
     </property>
     <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
</configuration>
EOF

cat > hadoop/etc/hadoop/yarn-site.xml << EOF
<configuration>
<property>
 <name>yarn.resourcemanager.resourcetracker.address</name>
 <value>${namenode}:8025</value>  
</property>
<property>
 <name>yarn.resourcemanager.scheduler.address</name>
 <value>${namenode}:8030</value>  
</property>
<property>
 <name>yarn.resourcemanager.address</name>
 <value>${namenode}:8050</value>  
</property>
<property>
 <name>yarn.resourcemanager.admin.address</name>
 <value>${namenode}:8041</value>  
</property>
<property>
  <name>yarn.resourcemanager.hostname</name>
  <value>${namenode}</value>
</property>
<property>
  <name>yarn.nodemanager.aux-services</name>
  <value>mapreduce_shuffle</value>
</property>
</configuration>
EOF

# config java home
echo "export JAVA_HOME=/usr/lib/jvm/default-java" > /home/hadoop/.bashrc

# install ceph jar
ln -fs `pwd`/*.jar hadoop/share/hadoop/common/

# start hadoop
if [ `hostname` == ${namenode} ] 
then
    for i in ${nodes[@]}
    do 
        echo -n "copy ssh key to " 
        echo $i
        cat /home/hadoop/.ssh/id_rsa.pub | ssh hadoop@${i} 'cat >> /home/hadoop/.ssh/authorized_keys'
    done
    
    hadoop/sbin/stop-yarn.sh
    hadoop/sbin/start-yarn.sh
fi
