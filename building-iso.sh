

mkdir /mnt/{dvd,iso}
mount -o loop /path/to/some.iso /mnt/iso
cp -r /tmp/iso/ /mnt/dvd
umount /mnt/iso
chmod -R u+w /mnt/iso

cp /path/to/someks.cfg /tmp/dvd/isolinux/ks.cfg
#---- This lines damage the groups
cp /path/to/*.rpm /tmp/dvd/Packages/.
cd /tmp/dvd/Packages && createrepo -dpo .. .
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