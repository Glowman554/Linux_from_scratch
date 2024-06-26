source config.sh

sudo losetup $LFS_LOOP $LFS_IMAGE -P
sudo mount "$LFS_LOOP"p2 $LFS

if [ ! -d $LFS/dev ]; then
    sudo chown -Rv janick:janick $LFS
fi

sudo mkdir -pv $LFS/{dev,proc,sys,run,boot}
sudo mount "$LFS_LOOP"p1 $LFS/boot

sudo mount -v --bind /dev $LFS/dev 
sudo mount -vt devpts devpts -o gid=5,mode=0620 $LFS/dev/pts 
sudo mount -vt proc proc $LFS/proc 
sudo mount -vt sysfs sysfs $LFS/sys 
sudo mount -vt tmpfs tmpfs $LFS/run 

if [ -h $LFS/dev/shm ]; then
    sudo install -v -d -m 1777 $LFS$(realpath /dev/shm)
else
    sudo mount -vt tmpfs -o nosuid,nodev tmpfs $LFS/dev/shm
fi
