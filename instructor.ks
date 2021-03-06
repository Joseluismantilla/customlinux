#version=DEVEL
# System authorization information
auth --enableshadow --passalgo=sha512
# Use CDROM installation media
#reboot
cdrom
# Use graphical install
graphical
# Run the Setup Agent on first boot
firstboot --disable
%pre
SRCDISK=$(blkid -t LABEL=DEVOPS | sed -e 's:^/dev/::' -e 's/[0-9].*//')
CANDIDATES=$(lsblk -ido KNAME,TYPE | grep -w disk | cut -d" " -f1 | grep -Ev '^fd' | grep -Ev '^zram')
for d in $CANDIDATES; do
    #grep -q 1 /sys/block/$d/removable && continue
    [[ "$d" == "$SRCDISK" ]] && continue
    MAINDISK=$d
    break
done
if [[ -z "${MAINDISK}" ]]; then
    # Abort, abort
    chvt 1
    echo | tee /dev/tty1
    echo -e "Could not find a disk to install to\r" | tee /dev/tty1
    echo -n "Press <enter> to reboot..." > /dev/tty1
    read text
    reboot
fi


cat >> /tmp/ksconfig <<-EOF
ignoredisk --only-use=$MAINDISK
# System bootloader configuration
bootloader --location=mbr --boot-drive=$MAINDISK 
autopart --type=lvm
# Partition clearing information
clearpart --all --drives=$MAINDISK
EOF
%end

# Keyboard layouts
keyboard --vckeymap=latam --xlayouts='latam'
# System language
lang en_US.UTF-8

# Network information
network  --bootproto=dhcp --device=eth0 --onboot=on --ipv6=auto --no-activate
network  --hostname=instructor.example.com

# Root password
rootpw --iscrypted $6$DOgftsTO3cx2cXGa$DLdKigAD6ikbm33xyRXQhXMe/JaR2rVJVp.vC3XK86oSJXTa8Zi6LOlz023OOQ2qbiGsg/wAqy4hX.2.NHHyN1
# System services
#services --disabled="chronyd"
services --enabled=NetworkManager,sshd,httpd
firewall --enabled 
# System timezone
timezone America/Bogota --isUtc --nontp
user --name=devops --password=devops --plaintext --gecos="devops" --groups libvirt

%include /tmp/ksconfig

xconfig  --startxonboot --defaultdesktop=GNOME

%post
echo "Executing post installation scripts"
echo "Installation Completed" |tee -a /var/log/messages
tar cvf /tmp/repos.tar /etc/yum.repos.d/
rm -f /etc/yum.repos.d/*.repo 

cat > /etc/yum.repos.d/centos-course.repo <<-EOF 
[devops]
name=DevOps Course
baseurl=file:///var/www/html/repo/materials
gpgcheck=0

[c7-media]
name=CentOS Installer
baseurl=file:///mnt/cdrom/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
EOF
mkdir /home/devops/.ssh -m 700
echo -e "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCjDuuv85vBwqj9OdIllpwmNygqd5VjlBXmdFKJlc27FDGf0cKs7LzJls/M758pStUJGpxoGIaOeb1AmnKWoeL/Lm00wnEAR7MMsiMviKbEDaYTdrXrlVQyjzO3kwWnOjCLsnXNDb6n4BtkPNjpMn0zrYChUlWyY+F+RsEMsm6exZbViUnLmmx5VGH0mtsFSe5rS/onb1JdYDwJwnhob8MZG+h8zSh8VXIvbhkzZVw10AipKp6j8+mOeaPZ3QFYjOiURlNEM3FKVCSF4IOWW/ct1O/6845QQJ0nEZ6QrnOa8ZZhcAWWWpcx6DFfNTIAIA41+gpdEoj0LV3PikiQP7V/ devops@instructor.example.com" > /home/devops/.ssh/id_rsa.pub
echo "-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAow7rr/ObwcKo/TnSJZacJjcoKneVY5QV5nRSiZXNuxQxn9HC
rOy8yZbPzO+fKUrVCRqcaBiGjnm9QJpylqHi/y5tNMJxAEezDLIjL4imxA2mE3a1
65VUMo8zt5MFpzowi7J1zQ2+p+AbZDzY6TJ9M62AoVJVsmPhfkbBDLJunsWW1YlJ
y5pseVRh9JrbBUnua0v6J29SXWA8CcJ4aG/DGRvofM0ofFVyL24ZM2VcNdAIqSqe
o/Ppjnmj2d0BWIzolEZTRDNxSlQkheCDllv3LdTv+vOOUECdJxGekK5zmvGWYXAF
llqXMegxXzUyACAONfoKXRKI9C1dz4pIkD+1fwIDAQABAoIBAF2pe26FY0nIVCOo
6/JVcfptom/KYxBhBrdqx+JqH1O/xMWFyupjzgmJzHFujyE77+Ub2Q3eUKRUf4Y1
cW7fLLHh7C7rJdfAV7QKOzXZq9lf8a6qeNMK4uNr6IwhMpUdUrdb2ljf9U0e6P0K
CprhOpPNrN59meYvg15yq/9sGyitcj8TvHYjHn7yE8KLH6krhqC5JhquaT/HrnTY
asJqmIM+CMtEDFfKzA3VanCOgQ/BnvaGkcm36PIE9PLenZ1fZqqyYFIZWQJuvY1z
ULuBlcSzL7VC0TKhb9tjYuYoiuT5mlekfn5zyi3z4UKgIOfHiO0Uy7zh53iaRptu
utPbgCECgYEAzTynX5FhNBHDgVxvNrDeGM38uYJkmdDXLEXfBY5Stp31NcmscJGI
4AK8ppFhREfrwlpzrD2GABp4BYA5sUtYuCcCjR+K+9grNJ6KRwQqVnfxm3kmBHhN
dzh/ZmdDH9/tY9Nnfpd+H+1JODNHkY34MH6GezDPTfZGju5lAq+wNDECgYEAy2OR
U66BhIASEOSrLLkLiSZADE2qzVfcNUd9eRNSlO5+z2pn3BphXvhlJVAV4saZ71Ro
49vk67RdnvoaO/vXp/9BPMJEBfnJyVLn8moK1GzmYXVt74pCDm5Xec8Sw/XZjpbh
t3gONNEKnW5fPKhrcYFBG8lQFmi+dArGcmGyiK8CgYBZJQlGF21zImwa2j1sMfKm
L4KgSSTNMsrjbg3q6eC/dWi2zjxaQLyFIGs0plzrPZoHtyYbIDX+AYE0Une8rI+C
nV8cUSEbNs+9cUd6hTKmkD6fW0XKFz7+k8myfxPG2orQG1kOwVqFH5n4ET362QF+
ftaG17KTmG8ZUi8JtaoBYQKBgQC0XvCazb9+yjU7Vg+X8eMRFiLmxlobETfw6B2W
KlSqT3eWaj8BK0P+/Tp2BLfkDUymuqzqpjA1+Bauzg5F8+okynIIeB/rTMJvEF8y
1GgWSx1kgMemD27VbXWWSNXTg0wU8Cnsk0PGAzzusNs06Aeg+YfMJJQpy2pbbtLe
zVWPcQKBgQCSS6F19ySAEACMCd2i8qqEdSA4ZZ1Yi0v+HyxMl9yhWaO/4jHy+FOG
SFcP0It0cCIGRBBCGFmILAOiX1OPrnLKcaU7fV0k0Hz7Wd/KWSp40YvXCHdGqod9
mz62nXqP27KfvBMGHE6+B0ZBAa7GUkHbGRPAxlvV/FVSwQEoB2sPYQ==
-----END RSA PRIVATE KEY-----" > /home/devops/.ssh/id_rsa
chown devops.devops -R /home/devops/.ssh
chmod 600 /home/devops/.ssh/id_rsa
echo post |tee -a /root/ks-post.log
gpasswd -a devops qemu

rpm --import https://packages.microsoft.com/keys/microsoft.asc
sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

echo "192.168.122.10 jenkins jenkins.example.local" >> /etc/hosts
echo "192.168.122.11 kubernetes kubernetes.example.local" >> /etc/hosts
echo "192.168.122.12 jenkins-node jenkins-node.example.local" >> /etc/hosts
echo "192.168.122.13 kubernetes-node kubernetes-node.example.local" >> /etc/hosts
echo "192.168.122.14 registry registry.example.local" >> /etc/hosts


%end

%post --nochroot --log=/mnt/sysimage/root/ks-post.log
df -h |tee -a /mnt/sysimage/root/ks-post.log
cat > /mnt/sysimage/tmp/centos-course <<-EOF 
REPO_COURSE=/var/www/html/repo/materials
REPO_ISO=/var/www/html/iso
DATE_INSTALLATION=$(date +%F)
centosiso=CentOS-7-x86_64-DVD-1908.iso
EOF

source /mnt/sysimage/tmp/centos-course
mkdir -p /mnt/sysimage${REPO_COURSE} /mnt/sysimage${REPO_ISO}  /mnt/sysimage/mnt/cdrom /mnt/sysimage/var/www/html/images/{centos,ubuntu,slides}
ls -l /mnt/sysimage/var/www/html |tee -a /mnt/sysimage/root/ks-post.log
cp -a /run/install/isodir/repositories/*  /mnt/sysimage${REPO_COURSE}

echo "Copy RHEL DVD to local drive..." | tee /dev/tty8

cp /run/install/isodir/centos/isos/* /mnt/sysimage/var/www/html/iso/
echo "/var/www/html/iso/CentOS-7-x86_64-DVD-1908.iso /mnt/cdrom iso9660 loop,ro 0 0" >> /mnt/sysimage/etc/fstab

cp /run/install/isodir/centos/images/CentOS* /mnt/sysimage/var/www/html/images/centos/
cp /run/install/isodir/ubuntu/vms/*.gz /mnt/sysimage/var/lib/libvirt/images/
chmod 755 -R /mnt/sysimage/var/lib/libvirt/images/
cp /run/install/isodir/bsupport-* /mnt/sysimage/usr/bin/
chmod a+x /mnt/sysimage/usr/bin/bsupport-*
cp /run/install/isodir/slides/d* /mnt/sysimage/var/www/html/images/slides
cp /run/install/isodir/bsupportvm* /mnt/sysimage/etc/bash_completion.d/

%end


%packages
@core
@base
@fonts
@gnome-desktop
@x11
@java-platform
@virtualization-client
@virtualization-hypervisor
@virtualization-platform
@virtualization-tools
mtools
createrepo
httpd
firefox
bind
-gnome-initial-setup
kexec-tools

%end

%addon com_redhat_kdump --disable --reserve-mb='auto'

%end

