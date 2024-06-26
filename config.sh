set -e

export LFS=$PWD/mount/root
export LFS_SOURCES=$PWD/source
export LFS_LOOP=/dev/loop420
export LFS_IMAGE=lfs.img
export LFS_TARGET=x86_64-lfs-linux-gnu
export LFS_BUILD=$PWD/build
export LFS_ROOT=$PWD

mkdir -pv $LFS
mkdir -pv $LFS_SOURCES
mkdir -pv $LFS_BUILD

export CONFIG_SITE=$LFS/usr/share/config.site

export PATH=$LFS/tools/bin:$PATH


function build_root_tmp {
    local root_folder=$LFS_BUILD/$1

    cd $LFS_BUILD
    tar -xf $LFS_SOURCES/$1.tar.*
    
    cd $root_folder

    notify-send "Building $1"
    $2 $root_folder | tee $root_folder.log
}



function in_build {
    mkdir -pv build
    cd build
}