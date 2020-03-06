Download official image

# Gitlab machine
# qemu-img create -f qcow2 foobar.qcow2 100M
# qemu-img convert -O qcow2 original_image.qcow2_backup original_image.qcow2

virt-builder list
virt-builder ubuntu-18.04 -o ubuntu-workstation.qcow2 --format qcow2 --root-password password:ubuntu --size 40G --update

cat <<EOF > /tmp/workstation-ubuntu.sh
runuser -l devops -c "mkdir .ssh -m 700"
echo "devops ALL=(ALL) ALL" > /etc/sudoers.d/devops
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCjDuuv85vBwqj9OdIllpwmNygqd5VjlBXmdFKJlc27FDGf0cKs7LzJls/M758pStUJGpxoGIaOeb1AmnKWoeL/Lm00wnEAR7MMsiMviKbEDaYTdrXrlVQyjzO3kwWnOjCLsnXNDb6n4BtkPNjpMn0zrYChUlWyY+F+RsEMsm6exZbViUnLmmx5VGH0mtsFSe5rS/onb1JdYDwJwnhob8MZG+h8zSh8VXIvbhkzZVw10AipKp6j8+mOeaPZ3QFYjOiURlNEM3FKVCSF4IOWW/ct1O/6845QQJ0nEZ6QrnOa8ZZhcAWWWpcx6DFfNTIAIA41+gpdEoj0LV3PikiQP7V/ devops@instructor.example.com" > ~devops/.ssh/authorized_keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAx/Xk+tLGBCatkBuxzyEXVhupSgb4Lema0PAnM8dFbSxcPz4W4jO8yQgtONzHs8KOhs4J1NG9bHeAwpJa2p9iJkyrigxmQv0LOpvENdlGbA1hwsRoOhBGqwRzSmKHS4Or94FBXvzDwHfbkxDV0XhzHKod8b9tYuaIQfhbF3NUR2ItZiYJhBds+3GOAHhdbU9DOAyX8X60vppkgoJ4nb2Mugw51LM+uVh8ds24wzU3Khr6Dcmae7KX/b/PX0J0rO23ZPq1AJ3i6r13AJUc6beLjQXPzYs/ZLKiQZWaZUePnsiaIpKXpH7vuBK3zidvcK2pf6XXAB9MW7GtoFJnr6v+bQ== root@foundation0.ilt.example.com" >> ~devops/.ssh/authorized_keys
rm -f /etc/netplan/*
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list
apt install code -y


sudo setfacl --modify user:<user name or ID>:rw /var/run/docker.sock
EOF

cat <<EOF > ubuntu-network.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp1s0:
      dhcp4: no
      addresses: [192.168.123.100/24]
      gateway4: 192.168.123.1
      nameservers:
        addresses: [192.168.123.1,8.8.8.8]
EOF

virt-customize -a ubuntu-workstation.qcow2  \
--run-command 'useradd -m -s /bin/bash devops' \
--hostname workstation --password devops:password:devops \
--firstboot /tmp/workstation-ubuntu.sh \
--copy-in ubuntu-network.yaml:/etc/netplan/ \
--copy-in motd:/etc/ --install apt-transport-https -m 2048

virt-install --name workstation --import --memory 4096 --disk ubuntu-workstation.qcow2 --os-variant ubuntu18.04 --network bridge=virbr0,model=virtio --noautoconsole
----

----foundation0
virt-install --name workstation --import --memory 4096 --disk ubuntu-workstation.qcow2 --os-variant ubuntu18.04 --network bridge=br1,model=virtio --noautoconsole

#tasksel