Download official image

# jenkins machine

virt-builder list
virt-builder ubuntu-18.04 -o jenkins-node.qcow2 --format qcow2 --root-password password:ubuntu --size 10G
cat <<EOF > /tmp/jenkinsnode-script.sh
runuser -l devops -c "mkdir .ssh -m 700"
echo "devops ALL=(ALL) ALL" > /etc/sudoers.d/devops
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCjDuuv85vBwqj9OdIllpwmNygqd5VjlBXmdFKJlc27FDGf0cKs7LzJls/M758pStUJGpxoGIaOeb1AmnKWoeL/Lm00wnEAR7MMsiMviKbEDaYTdrXrlVQyjzO3kwWnOjCLsnXNDb6n4BtkPNjpMn0zrYChUlWyY+F+RsEMsm6exZbViUnLmmx5VGH0mtsFSe5rS/onb1JdYDwJwnhob8MZG+h8zSh8VXIvbhkzZVw10AipKp6j8+mOeaPZ3QFYjOiURlNEM3FKVCSF4IOWW/ct1O/6845QQJ0nEZ6QrnOa8ZZhcAWWWpcx6DFfNTIAIA41+gpdEoj0LV3PikiQP7V/ devops@instructor.example.com" > ~devops/.ssh/authorized_keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAx/Xk+tLGBCatkBuxzyEXVhupSgb4Lema0PAnM8dFbSxcPz4W4jO8yQgtONzHs8KOhs4J1NG9bHeAwpJa2p9iJkyrigxmQv0LOpvENdlGbA1hwsRoOhBGqwRzSmKHS4Or94FBXvzDwHfbkxDV0XhzHKod8b9tYuaIQfhbF3NUR2ItZiYJhBds+3GOAHhdbU9DOAyX8X60vppkgoJ4nb2Mugw51LM+uVh8ds24wzU3Khr6Dcmae7KX/b/PX0J0rO23ZPq1AJ3i6r13AJUc6beLjQXPzYs/ZLKiQZWaZUePnsiaIpKXpH7vuBK3zidvcK2pf6XXAB9MW7GtoFJnr6v+bQ== root@foundation0.ilt.example.com" >> ~devops/.ssh/authorized_keys
rm -f /etc/netplan/*
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
apt install docker-ce -y
#apt install --reinstall openssh-server
EOF

cat <<EOF > ubuntu-network.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp1s0:
      dhcp4: no
      addresses: [192.168.123.12/24]
      gateway4: 192.168.123.1
      nameservers:
        addresses: [192.168.123.1,8.8.8.8]
EOF

virt-customize -a jenkins-node.qcow2  --run-command 'useradd -m -s /bin/bash devops' --hostname jenkins-node.example.com --password devops:password:devops \
--firstboot /tmp/jenkinsnode-script .sh --copy-in motd:/etc/ --copy-in ubuntu-network.yaml:/etc/netplan/

virt-install --name jenkins-node --import --memory 900 --disk jenkins-node.qcow2 --os-variant ubuntu18.04 --network bridge=virbr0,model=virtio --noautoconsole
----

----

virt-install --name jenkins-node --import --memory 4096 --vcpus 2 --disk jenkins-node.qcow2 --os-variant ubuntu18.04 --network bridge=br1,model=virtio --noautoconsole
