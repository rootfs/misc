nodes=("plana04" "plana51" "plana55" "plana85")
HADOOP_VERSION="2.4.1"

cd /home/hadoop

wget -q http://www.us.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz
tar xzf hadoop-${HADOOP_VERSION}.tar.gz 
ln -fs `pwd`/hadoop-${HADOOP_VERSION} hadoop

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


