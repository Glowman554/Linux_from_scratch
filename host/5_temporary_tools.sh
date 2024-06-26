source config.sh

function build_m4 {
    ./configure --prefix=/usr \
        --host=$LFS_TARGET \
        --build=$(build-aux/config.guess)
    make -j8
    make DESTDIR=$LFS install
}
build_root_tmp m4-1.4.19 build_m4

function build_ncurses {
    sed -i s/mawk// configure

    in_build
    ../configure
    make -C include
    make -C progs tic

    cd $1
    ./configure --prefix=/usr \
        --host=$LFS_TARGET \
        --build=$(./config.guess) \
        --mandir=/usr/share/man \
        --with-manpage-format=normal \
        --with-shared \
        --without-normal \
        --with-cxx-shared \
        --without-debug \
        --without-ada \
        --disable-stripping \
        --enable-widec
    make -j8
    make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install
    ln -sv libncursesw.so $LFS/usr/lib/libncurses.so
    sed -e 's/^#if.*XOPEN.*$/#if 1/' -i $LFS/usr/include/curses.h
}
build_root_tmp ncurses-6.4-20230520 build_ncurses

function build_bash {
    ./configure --prefix=/usr \
        --build=$(sh support/config.guess) \
        --host=$LFS_TARGET \
        --without-bash-malloc
    make -j8
    make DESTDIR=$LFS install
    ln -sv bash $LFS/bin/sh
}
build_root_tmp bash-5.2.21 build_bash

function build_coreutils {
    ./configure --prefix=/usr \
        --host=$LFS_TARGET \
        --build=$(build-aux/config.guess) \
        --enable-install-program=hostname \
        --enable-no-install-program=kill,uptime
    make -j8
    make DESTDIR=$LFS install

    mv -v $LFS/usr/bin/chroot $LFS/usr/sbin
    mkdir -pv $LFS/usr/share/man/man8
    mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8
    sed -i 's/"1"/"8"/' $LFS/usr/share/man/man8/chroot.8
}
build_root_tmp coreutils-9.4 build_coreutils

function build_diffutils {
    ./configure --prefix=/usr \
        --host=$LFS_TARGET \
        --build=$(./build-aux/config.guess)
    
    make -j8
    make DESTDIR=$LFS install
}
build_root_tmp diffutils-3.10 build_diffutils

function build_file {
    in_build
    ../configure --disable-bzlib \
        --disable-libseccomp \
        --disable-xzlib \
        --disable-zlib
    make -j8

    cd $1
    ./configure --prefix=/usr --host=$LFS_TARGET --build=$(./config.guess)
    make FILE_COMPILE=$(pwd)/build/src/file -j8
    make DESTDIR=$LFS install
    rm -v $LFS/usr/lib/libmagic.la
}
build_root_tmp file-5.45 build_file

function build_findutils {
    ./configure --prefix=/usr \
        --localstatedir=/var/lib/locate \
        --host=$LFS_TARGET \
        --build=$(build-aux/config.guess)
    make -j8
    make DESTDIR=$LFS install
}
build_root_tmp findutils-4.9.0 build_findutils

function build_gawk {
    sed -i 's/extras//' Makefile.in

    ./configure --prefix=/usr \
        --host=$LFS_TARGET \
        --build=$(build-aux/config.guess)
    make -j8
    make DESTDIR=$LFS install
}
build_root_tmp gawk-5.3.0 build_gawk

function build_grep {
    ./configure --prefix=/usr \
        --host=$LFS_TARGET \
        --build=$(./build-aux/config.guess)
    make -j8
    make DESTDIR=$LFS install
}
build_root_tmp grep-3.11 build_grep

function build_gzip {
    ./configure --prefix=/usr --host=$LFS_TARGET
    make -j8
    make DESTDIR=$LFS install
}
build_root_tmp gzip-1.13 build_gzip

function build_make {
    ./configure --prefix=/usr \
        --without-guile \
        --host=$LFS_TARGET \
        --build=$(build-aux/config.guess)
    make -j8
    make DESTDIR=$LFS install
}
build_root_tmp make-4.4.1 build_make

function build_patch {
    ./configure --prefix=/usr \
        --host=$LFS_TARGET \
        --build=$(build-aux/config.guess)
    make -j8
    make DESTDIR=$LFS install
}
build_root_tmp patch-2.7.6 build_patch

function build_sed {
    ./configure --prefix=/usr \
        --host=$LFS_TARGET \
        --build=$(./build-aux/config.guess)
    make -j8
    make DESTDIR=$LFS install
}
build_root_tmp sed-4.9 build_sed

function build_tar {
    ./configure --prefix=/usr \
        --host=$LFS_TARGET \
        --build=$(build-aux/config.guess)
    make -j8
    make DESTDIR=$LFS install
}
build_root_tmp tar-1.35 build_tar

function build_xz {
    ./configure --prefix=/usr \
        --host=$LFS_TARGET \
        --build=$(build-aux/config.guess) \
        --disable-static \
        --docdir=/usr/share/doc/xz-5.4.6
    make -j8
    make DESTDIR=$LFS install
    rm -v $LFS/usr/lib/liblzma.la
}
build_root_tmp xz-5.4.6 build_xz

function build_binutils {
    sed '6009s/$add_dir//' -i ltmain.sh

    in_build
    ../configure \
        --prefix=/usr \
        --build=$(../config.guess) \
        --host=$LFS_TARGET \
        --disable-nls \
        --enable-shared \
        --enable-gprofng=no \
        --disable-werror \
        --enable-64-bit-bfd \
        --enable-default-hash-style=gnu
    make -j8
    make DESTDIR=$LFS install
    rm -v $LFS/usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes,sframe}.{a,la}
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


    sed '/thread_header =/s/@.*@/gthr-posix.h/' -i libgcc/Makefile.in libstdc++-v3/include/Makefile.in

    in_build
    ../configure \
        --build=$(../config.guess) \
        --host=$LFS_TARGET \
        --target=$LFS_TARGET \
        LDFLAGS_FOR_TARGET=-L$PWD/$LFS_TARGET/libgcc \
        --prefix=/usr \
        --with-build-sysroot=$LFS \
        --enable-default-pie \
        --enable-default-ssp \
        --disable-nls \
        --disable-multilib \
        --disable-libatomic \
        --disable-libgomp \
        --disable-libquadmath \
        --disable-libsanitizer \
        --disable-libssp \
        --disable-libvtv \
        --enable-languages=c,c++
    make -j8
    make DESTDIR=$LFS install
    ln -sv gcc $LFS/usr/bin/cc
}
build_root_tmp gcc-13.2.0 build_gcc
