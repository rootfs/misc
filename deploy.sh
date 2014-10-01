nodes=("plana04" "plana51" "plana55" "plana85")
for i in ${nodes[@]}
do
echo $i
ssh ubuntu@${i}.front.sepia.ceph.com "mkdir -p ~/bd"
scp init.sh ubuntu@${i}.front.sepia.ceph.com:~/bd
scp setup.sh ubuntu@${i}.front.sepia.ceph.com:~/bd
ssh ubuntu@${i}.front.sepia.ceph.com "cd ~/bd; sh init.sh"
done