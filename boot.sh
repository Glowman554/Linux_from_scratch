dd if=/dev/zero of=lfs2.img bs=512 count=8388608 status=progress
qemu-system-x86_64 -hda lfs.img -hdb lfs2.img -netdev user,id=u1 -device e1000,netdev=u1 --enable-kvm -m 4G
qemu-system-x86_64 -hda lfs2.img -netdev user,id=u1 -device e1000,netdev=u1 --enable-kvm -m 4G
