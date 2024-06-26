source config.sh


dd if=/dev/zero of=$LFS_IMAGE bs=512 count=67108864 status=progress
cfdisk $LFS_IMAGE

sudo losetup $LFS_LOOP $LFS_IMAGE -P
sudo mkfs.vfat -F32 -nBOOT "$LFS_LOOP"p1
sudo mkfs.ext4 -LROOT "$LFS_LOOP"p2
sudo losetup -d $LFS_LOOP 