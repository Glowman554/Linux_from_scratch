source config.sh

mountpoint -q $LFS/dev/shm && sudo umount $LFS/dev/shm
sudo umount $LFS/dev/pts
sudo umount $LFS/{sys,proc,run,dev,boot}
sudo umount $LFS
sudo losetup -d $LFS_LOOP