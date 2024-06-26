source config.sh

mkdir -pv $LFS/tools/scripts
mkdir -pv $LFS/tools/sources
cp -rv system/* $LFS/tools/scripts
cp -rv $LFS_SOURCES/* $LFS/tools/sources/


cat > $LFS/tools/scripts/config.sh << EOF
set -e

export LFS_SOURCES=/tools/sources
export LFS_BUILD=/tools/build

mkdir -pv \$LFS_BUILD

function build_root_tmp {
    local root_folder=\$LFS_BUILD/\$1

    cd \$LFS_BUILD
    tar -xf \$LFS_SOURCES/\$1.tar.*
    
    cd \$root_folder

    \$2 \$root_folder | tee \$root_folder.log
}



function in_build {
    mkdir -pv build
    cd build
}
EOF