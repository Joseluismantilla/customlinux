

mkdir /mnt/{dvd,iso}
mount -o loop /path/to/some.iso /mnt/iso
cp -r /tmp/iso/ /mnt/dvd
umount /mnt/iso
chmod -R u+w /mnt/iso

cp /path/to/someks.cfg /tmp/dvd/isolinux/ks.cfg
#---- This lines damage the groups
cp /path/to/*.rpm /tmp/dvd/Packages/.
cd /tmp/dvd/Packages && createrepo -dpo .. .
# createrepo --update -o .. .     -> Updating repo database
# delete repodata folder if exists previously


#Modifying boot list
vim /tmp/dvd/isolinux/isolinux.cfg  #Updating the file with...
label linux
  menu label ^Install DevOps course - Instructor machine 
  menu default
  kernel vmlinuz
  append initrd=initrd.img inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 inst.ks=cdrom:/ks.cfg

label linux
  menu label ^Install CentOS 7
  kernel vmlinuz
  append initrd=initrd.img inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 quiet

label check
  menu label Test this ^media & install CentOS 7
  kernel vmlinuz
  append initrd=initrd.img inst.stage2=hd:LABEL=CentOS\x207\x20x86_64 rd.live.check quiet


cd /tmp/dvd  
mkisofs -o /tmp/boot.iso -b isolinux.bin -c boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -V "CentOS 7 x86_64" -R -J -v -T isolinux/. .

#(Optional) Use isohybrid if you want to dd the ISO file to a bootable USB key. 
isohybrid /tmp/boot.iso

#Add an MD5 checksum (to allow testing of media). 
implantisomd5 /tmp/boot.iso

# Current version
mkisofs -o /tmp/devops7.iso -b boot/isolinux/isolinux.bin -c boot/isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -V "CentOS 7 x86_64" -R -J -l -joliet-long -allow-limited-siz -iso-level 3 -v -T  .
ll /mnt/iso
drwxr-xrwx. 6 root root  120 Feb 26 22:11 boot
-rwxr-xr-x. 1 root root 5088 Feb 29 15:49 bsupport-devops-vm
-rw-r--r--. 1 root root 1069 Feb 29 13:57 bsupportvm.bash
drwxrwxrwx. 4 root root   32 Feb 27 14:41 centos
drwxr-xr-x. 4 root root   38 Feb 27 09:38 repositories
drwxr-xr-x. 2 root root   22 Feb 28 20:12 slides
drwxr-xr-x. 3 root root   17 Feb 28 20:26 ubuntu