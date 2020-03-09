

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

#----- partition
parted /dev/sdb print
parted /dev/sdb mklabel msdos
parted /dev/sdb mkpart primary ext4 1M 100%
mkfs.ext4 /dev/sdb1
-----------------
 fdisk /dev/sdb
 primary partition complete and after flag to boot (a)

dd conv=notrunc bs=440 count=1 if=/usr/share/syslinux/mbr.bin of=/dev/sdb
mkfs.ext4 /dev/sdb1
tune2fs -L DEVOPS /dev/sdb1
extlinux --install /run/media/....
STEP 4: Copy a Linux kernel image (like vmlinuz) to the root (/dev/sdX1) of your media.

STEP 5: Lastly, create a 'syslinux.cfg' file in the root of your media (/dev/sdX1) and
enter any configuration options you need/want. 

---Final version
Creating BOOT ISO in first usb partition second partition

/dev/sdb = USB Memory

fdisk 
Device     Boot   Start      End  Sectors  Size Id Type
/dev/sdb1  *       2048  2099199  2097152    1G 83 Linux
/dev/sdb2       2099200 61767679 59668480 28.5G 83 Linux

dd if=/usr/share/syslinux/mbr.bin of=/dev/sdb
isohybrid --partok file.iso
dd if=/home/kiosk/Downloads/rhel-server-7.7-x86_64-boot.iso of=/dev/sdb1 bs=64M statur=progress

mkisofs -o /tmp/devops8.iso -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -V "CentOS 8 x86_64" -R -l -v  .
