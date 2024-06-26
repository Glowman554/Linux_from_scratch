source config.sh

function build_bootscripts {
    make install
}
build_root_tmp lfs-bootscripts-20230728 build_bootscripts

cat > /etc/sysconfig/ifconfig.enp0s3 << "EOF"
ONBOOT=yes
IFACE=enp0s3
SERVICE="dhcpcd"
DHCP_START="-b -q -h $HOSTNAME"
DHCP_STOP="-k"
EOF

function build_bootscripts {
    make install-service-dhcpcd
    make install-random
}
build_root_tmp blfs-bootscripts-20240209 build_bootscripts

cat > /etc/resolv.conf << "EOF"

nameserver 8.8.8.8
nameserver 1.1.1.1

EOF

echo "lfs" > /etc/hostname

cat > /etc/hosts << "EOF"

127.0.0.1 localhost.localdomain localhost
::1 localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

EOF

make-ca -g

cat > /etc/inittab << "EOF"

id:3:initdefault:
si::sysinit:/etc/rc.d/init.d/rc S
l0:0:wait:/etc/rc.d/init.d/rc 0
l1:S1:wait:/etc/rc.d/init.d/rc 1
l2:2:wait:/etc/rc.d/init.d/rc 2
l3:3:wait:/etc/rc.d/init.d/rc 3
l4:4:wait:/etc/rc.d/init.d/rc 4
l5:5:wait:/etc/rc.d/init.d/rc 5
l6:6:wait:/etc/rc.d/init.d/rc 6
ca:12345:ctrlaltdel:/sbin/shutdown -t1 -a -r now
su:S06:once:/sbin/sulogin
s1:1:respawn:/sbin/sulogin
1:2345:respawn:/sbin/agetty --noclear tty1 9600
2:2345:respawn:/sbin/agetty tty2 9600
3:2345:respawn:/sbin/agetty tty3 9600
4:2345:respawn:/sbin/agetty tty4 9600
5:2345:respawn:/sbin/agetty tty5 9600
6:2345:respawn:/sbin/agetty tty6 9600

EOF

cat > /etc/sysconfig/clock << "EOF"

UTC=1
# Set this to any options you might need to give to hwclock,
# such as machine hardware clock type for Alphas.
CLOCKPARAMS=

EOF

cat > /etc/sysconfig/console << "EOF"

KEYMAP="de-latin1"
KEYMAP_CORRECTIONS="euro2"
FONT="lat0-16 -m 8859-15"
UNICODE="1"

EOF

cat > /etc/sysconfig/rc.site << "EOF"
# Warning: when switching from a 8bit to a 9bit font,
# the linux console will reinterpret the bold (1;) to
# the top 256 glyphs of the 9bit font. This does
# not affect framebuffer consoles
# These values, if specified here, override the defaults
#BRACKET="\\033[1;34m" # Blue
#FAILURE="\\033[1;31m" # Red
#INFO="\\033[1;36m" # Cyan
#NORMAL="\\033[0;39m" # Grey
#SUCCESS="\\033[1;32m" # Green
#WARNING="\\033[1;33m" # Yellow
# Use a colored prefix
# These values, if specified here, override the defaults
#BMPREFIX=" "
#SUCCESS_PREFIX="${SUCCESS} * ${NORMAL} "
#FAILURE_PREFIX="${FAILURE}*****${NORMAL} "
#WARNING_PREFIX="${WARNING} *** ${NORMAL} "
# Manually set the right edge of message output (characters)
# Useful when resetting console font during boot to override
# automatic screen width detection
#COLUMNS=120
# Interactive startup
#IPROMPT="yes" # Whether to display the interactive boot prompt
#itime="3" # The amount of time (in seconds) to display the prompt
# The total length of the distro welcome string, without escape codes
#wlen=$(echo "Welcome to ${DISTRO}" | wc -c )
#welcome_message="Welcome to ${INFO}${DISTRO}${NORMAL}"
# The total length of the interactive string, without escape codes
#ilen=$(echo "Press 'I' to enter interactive startup" | wc -c )
#i_message="Press '${FAILURE}I${NORMAL}' to enter interactive startup"
# Set scripts to skip the file system check on reboot
#FASTBOOT=yes
# Skip reading from the console
#HEADLESS=yes
# Write out fsck progress if yes
#VERBOSE_FSCK=no
# Speed up boot without waiting for settle in udev
#OMIT_UDEV_SETTLE=y
# Speed up boot without waiting for settle in udev_retry
#OMIT_UDEV_RETRY_SETTLE=yes
# Skip cleaning /tmp if yes
#SKIPTMPCLEAN=no
# For setclock
#UTC=1
#CLOCKPARAMS=
# For consolelog (Note that the default, 7=debug, is noisy)
#LOGLEVEL=7
# For network
#HOSTNAME=mylfs
# Delay between TERM and KILL signals at shutdown
#KILLDELAY=3
# Optional sysklogd parameters
#SYSKLOGD_PARMS="-m 0"
# Console parameters
#UNICODE=1
#KEYMAP="de-latin1"
#KEYMAP_CORRECTIONS="euro2"
#FONT="lat0-16 -m 8859-15"
#LEGACY_CHARSET=
EOF

cat > /etc/profile << "EOF"

for i in $(locale); do
    unset ${i%=*}
done
if [[ "$TERM" = linux ]]; then
    export LANG=C.UTF-8
else
    export LANG=de_DE.ISO-8859-1
fi

EOF

cat > /root/.bashrc << "EOF"
export PS1='\u:\w\$ '
EOF

cat > /etc/inputrc << "EOF"

# Modified by Chris Lynn <roryo@roryo.dynup.net>
# Allow the command prompt to wrap to the next line
set horizontal-scroll-mode Off
# Enable 8-bit input
set meta-flag On
set input-meta On
# Turns off 8th bit stripping
set convert-meta Off
# Keep the 8th bit for display
set output-meta On
# none, visible or audible
set bell-style none
# All of the following map the escape sequence of the value
# contained in the 1st argument to the readline specific functions
"\eOd": backward-word
"\eOc": forward-word
# for linux console
"\e[1~": beginning-of-line
"\e[4~": end-of-line
"\e[5~": beginning-of-history
"\e[6~": end-of-history
"\e[3~": delete-char
"\e[2~": quoted-insert
# for xterm
"\eOH": beginning-of-line
"\eOF": end-of-line
# for Konsole
"\e[H": beginning-of-line
"\e[F": end-of-line

EOF

cat > /etc/shells << "EOF"

/bin/sh
/bin/bash
/bin/fish

EOF

export BOOT_UUID=$(blkid /dev/loop420p1 -s UUID -o value)
export ROOT_UUID=$(blkid /dev/loop420p2 -s UUID -o value)

echo "UUID=${BOOT_UUID} /boot vfat defaults 1 1" > /etc/fstab
echo "UUID=${ROOT_UUID} / ext4 defaults 1 1" >> /etc/fstab

cat >> /etc/fstab << "EOF"

proc /proc proc nosuid,noexec,nodev 0 0
sysfs /sys sysfs nosuid,noexec,nodev 0 0
devpts /dev/pts devpts gid=5,mode=620 0 0
tmpfs /run tmpfs defaults 0 0
devtmpfs /dev devtmpfs mode=0755,nosuid 0 0
tmpfs /dev/shm tmpfs nosuid,nodev 0 0
cgroup2 /sys/fs/cgroup cgroup2 nosuid,noexec,nodev 0 0
EOF

function build_linux {
    make mrproper
    make menuconfig
    make -j8
    make modules_install
    cp -iv arch/x86/boot/bzImage /boot/vmlinuz-6.7.4-lfs-12.1
    cp -iv System.map /boot/System.map-6.7.4
    cp -iv .config /boot/config-6.7.4
    cp -r Documentation -T /usr/share/doc/linux-6.7.4
}
build_root_tmp linux-6.7.4 build_linux

install -v -m755 -d /etc/modprobe.d
cat > /etc/modprobe.d/usb.conf << "EOF"

install ohci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i ohci_hcd ; true
install uhci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i uhci_hcd ; true

EOF

grub-install /dev/loop420 --target i386-pc

cat > /boot/grub/grub.cfg << "EOF"
set default=0
set timeout=5
insmod part_gpt
insmod ext2
set root=(hd0,1)
menuentry "GNU/Linux, Linux 6.7.4-lfs-12.1" {
    linux /vmlinuz-6.7.4-lfs-12.1 root=/dev/sda2 ro
}

EOF

echo 12.1 > /etc/lfs-release

cat > /etc/lsb-release << "EOF"
DISTRIB_ID="Linux From Scratch"
DISTRIB_RELEASE="12.1"
DISTRIB_CODENAME="Glowman554"
DISTRIB_DESCRIPTION="Linux From Scratch"
EOF

cat > /etc/os-release << "EOF"
NAME="Linux From Scratch"
VERSION="12.1"
ID=lfs
PRETTY_NAME="Linux From Scratch 12.1"
VERSION_CODENAME="Glowman554F"
HOME_URL="https://www.linuxfromscratch.org/lfs/"
EOF