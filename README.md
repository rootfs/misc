HOWTO
====
#### Configure
Write down host names in `nodes.cfg`. The last node must be used as HDFS's namenode or Ceph's MDS. 

Provide a password for hadoop in format of `password=xxxx` in pass.cfg. If no password is provided, a random one is generated.

In `nodes.cfg`, set `USE_HDFS=1` if using HDFS, `USE_HDFS=0` if using Ceph.

#### Run
On the deploy machine, run deploy.sh


