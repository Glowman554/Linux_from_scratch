set -e
source config.sh

export LFS_BUILD=$PWD/build_toolchain
mkdir -pv $LFS_BUILD

function build_binutils {
    in_build
    ../configure --prefix=$LFS/tools \
        --with-sysroot=$LFS \
        --target=$LFS_TARGET \
        --disable-nls \
        --enable-gprofng=no \
        --disable-werror \
        --enable-default-hash-style=gnu
    make -j8
    make install
}
build_root_tmp binutils-2.42 build_binutils

function build_gcc {
    tar -xf $LFS_SOURCES/mpfr-4.2.1.tar.xz
    mv -v mpfr-4.2.1 mpfr
    tar -xf $LFS_SOURCES/gmp-6.3.0.tar.xz
    mv -v gmp-6.3.0 gmp
    tar -xf $LFS_SOURCES/mpc-1.3.1.tar.gz
    mv -v mpc-1.3.1 mpc
    case $(uname -m) in
        x86_64)
            sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
        ;;
    esac

    in_build
    ../configure \
        --target=$LFS_TARGET \
        --prefix=$LFS/tools \
        --with-glibc-version=2.39 \
        --with-sysroot=$LFS \
        --with-newlib \
        --without-headers \
        --enable-default-pie \
        --enable-default-ssp \
        --disable-nls \
        --disable-shared \
        --disable-multilib \
        --disable-threads \
        --disable-libatomic \
        --disable-libgomp \
        --disable-libquadmath \
        --disable-libssp \
        --disable-libvtv \
        --disable-libstdcxx \
        --enable-languages=c,c++
    make -j8
    make install

    cd $1
    cat gcc/limitx.h gcc/glimits.h gcc/limity.h > $(dirname $("$LFS_TARGET"-gcc -print-libgcc-file-name))/include/limits.h
}
build_root_tmp gcc-13.2.0 build_gcc

function build_linux {
    make mrproper
    make headers
    find usr/include -type f ! -name '*.h' -delete
    cp -rv usr/include $LFS/usr
}
build_root_tmp linux-6.7.4 build_linux

function build_glibc {
    case $(uname -m) in
        i?86)   ln -sfv ld-linux.so.2 $LFS/lib/ld-lsb.so.3
        ;;
        x86_64) ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
                ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
        ;;
    esac
    patch -Np1 -i $LFS_SOURCES/glibc-2.39-fhs-1.patch

    in_build
    echo "rootsbindir=/usr/sbin" > configparms

    ../configure \
        --prefix=/usr \
        --host=$LFS_TARGET \
        --build=$(../scripts/config.guess) \
        --enable-kernel=4.19 \
        --with-headers=$LFS/usr/include \
        --disable-nscd \
        libc_cv_slibdir=/usr/lib
    make -j8
    make DESTDIR=$LFS install

    sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd
}
build_root_tmp glibc-2.39 build_glibc

function build_libstdcpp {
    in_build
    ../libstdc++-v3/configure \
        --host=$LFS_TARGET \
        --build=$(../config.guess) \
        --prefix=/usr \
        --disable-multilib \
        --disable-nls \
        --disable-libstdcxx-pch \
        --with-gxx-include-dir=/tools/$LFS_TARGET/include/c++/13.2.0
    make -j8
    make DESTDIR=$LFS install
    rm -v $LFS/usr/lib/lib{stdc++{,exp,fs},supc++}.la
}
build_root_tmp gcc-13.2.0 build_libstdcpp
