source config.sh

export LFS_BUILD=/tools/build_system
mkdir -pv $LFS_BUILD

cat > /etc/resolv.conf << "EOF"
Begin /etc/resolv.conf
nameserver 8.8.8.8
nameserver 1.1.1.1
End /etc/resolv.conf
EOF

function build_man_pages {
    rm -v man3/crypt*
    make prefix=/usr install
}
build_root_tmp man-pages-6.06 build_man_pages

function build_iana_etc {
    cp services protocols /etc
}
build_root_tmp iana-etc-20240125 build_iana_etc

function build_glibc {
    patch -Np1 -i $LFS_SOURCES/glibc-2.39-fhs-1.patch

    in_build
    echo "rootsbindir=/usr/sbin" > configparms

    ../configure --prefix=/usr \
        --disable-werror \
        --enable-kernel=4.19 \
        --enable-stack-protector=strong \
        --disable-nscd \
        libc_cv_slibdir=/usr/lib
    make -j8
    

    touch /etc/ld.so.conf
    sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile

    make install
    sed '/RTLDLIST=/s@/usr@@g' -i /usr/bin/ldd

    mkdir -pv /usr/lib/locale
    localedef -i C -f UTF-8 C.UTF-8
    localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8
    localedef -i de_DE -f ISO-8859-1 de_DE
    localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro
    localedef -i de_DE -f UTF-8 de_DE.UTF-8
    localedef -i el_GR -f ISO-8859-7 el_GR
    localedef -i en_GB -f ISO-8859-1 en_GB
    localedef -i en_GB -f UTF-8 en_GB.UTF-8
    localedef -i en_HK -f ISO-8859-1 en_HK
    localedef -i en_PH -f ISO-8859-1 en_PH
    localedef -i en_US -f ISO-8859-1 en_US
    localedef -i en_US -f UTF-8 en_US.UTF-8
    localedef -i es_ES -f ISO-8859-15 es_ES@euro
    localedef -i es_MX -f ISO-8859-1 es_MX
    localedef -i fa_IR -f UTF-8 fa_IR
    localedef -i fr_FR -f ISO-8859-1 fr_FR
    localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
    localedef -i fr_FR -f UTF-8 fr_FR.UTF-8
    localedef -i is_IS -f ISO-8859-1 is_IS
    localedef -i is_IS -f UTF-8 is_IS.UTF-8
    localedef -i it_IT -f ISO-8859-1 it_IT
    localedef -i it_IT -f ISO-8859-15 it_IT@euro
    localedef -i it_IT -f UTF-8 it_IT.UTF-8
    localedef -i ja_JP -f EUC-JP ja_JP
    localedef -i ja_JP -f SHIFT_JIS ja_JP.SJIS 2> /dev/null || true
    localedef -i ja_JP -f UTF-8 ja_JP.UTF-8
    localedef -i nl_NL@euro -f ISO-8859-15 nl_NL@euro
    localedef -i ru_RU -f KOI8-R ru_RU.KOI8-R
    localedef -i ru_RU -f UTF-8 ru_RU.UTF-8
    localedef -i se_NO -f UTF-8 se_NO.UTF-8
    localedef -i ta_IN -f UTF-8 ta_IN.UTF-8
    localedef -i tr_TR -f UTF-8 tr_TR.UTF-8
    localedef -i zh_CN -f GB18030 zh_CN.GB18030
    localedef -i zh_HK -f BIG5-HKSCS zh_HK.BIG5-HKSCS
    localedef -i zh_TW -f UTF-8 zh_TW.UTF-8

    make localedata/install-locales

    localedef -i C -f UTF-8 C.UTF-8
    localedef -i ja_JP -f SHIFT_JIS ja_JP.SJIS 2> /dev/null || true

    cat > /etc/nsswitch.conf << "EOF"
Begin /etc/nsswitch.conf
passwd: files
group: files
shadow: files
hosts: files dns
networks: files
protocols: files
services: files
ethers: files
rpc: files
End /etc/nsswitch.conf
EOF

    tar -xf ../../tzdata2024a.tar.gz
    ZONEINFO=/usr/share/zoneinfo
    mkdir -pv $ZONEINFO/{posix,right}
    for tz in etcetera southamerica northamerica europe africa antarctica asia australasia backward; do
        zic -L /dev/null -d $ZONEINFO ${tz}
        zic -L /dev/null -d $ZONEINFO/posix ${tz}
        zic -L leapseconds -d $ZONEINFO/right ${tz}
    done
    cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
    zic -d $ZONEINFO -p America/New_York
    unset ZONEINFO

    ln -sfv /usr/share/zoneinfo/Europe/Berlin /etc/localtime

    cat > /etc/ld.so.conf << "EOF"
Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib
EOF

cat >> /etc/ld.so.conf << "EOF"
Add an include directory
include /etc/ld.so.conf.d/*.conf
EOF
    mkdir -pv /etc/ld.so.conf.d
}
build_root_tmp glibc-2.39 build_glibc

function build_zlib {
    ./configure --prefix=/usr
    make -j8
    
    make install
    rm -fv /usr/lib/libz.a
}
build_root_tmp zlib-1.3.1 build_zlib

function build_bzip2 {
    patch -Np1 -i $LFS_SOURCES/bzip2-1.0.8-install_docs-1.patch
    sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
    sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile

    make -f Makefile-libbz2_so
    make clean

    make -j8

    make PREFIX=/usr install

    cp -av libbz2.so.* /usr/lib
    ln -sv libbz2.so.1.0.8 /usr/lib/libbz2.so

    cp -v bzip2-shared /usr/bin/bzip2
    for i in /usr/bin/{bzcat,bunzip2}; do
        ln -sfv bzip2 $i
    done

    rm -fv /usr/lib/libbz2.a
}
build_root_tmp bzip2-1.0.8 build_bzip2

function build_xz {
    ./configure --prefix=/usr \
        --disable-static \
        --docdir=/usr/share/doc/xz-5.4.6
    make -j8
    
    make install
}
build_root_tmp xz-5.4.6 build_xz

function build_zstd {
    make prefix=/usr -j8
    
    make prefix=/usr install
    rm -v /usr/lib/libzstd.a
}
build_root_tmp zstd-1.5.5 build_zstd

function build_file {
    ./configure --prefix=/usr
    make -j8
    
    make install
}
build_root_tmp file-5.45 build_file

function build_readline {
    sed -i '/MV.*old/d' Makefile.in
    sed -i '/{OLDSUFF}/c:' support/shlib-install

    patch -Np1 -i $LFS_SOURCES/readline-8.2-upstream_fixes-3.patch

    ./configure --prefix=/usr \
        --disable-static \
        --with-curses \
        --docdir=/usr/share/doc/readline-8.2

    make SHLIB_LIBS="-lncursesw" -j8
    make SHLIB_LIBS="-lncursesw" install

    install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-8.2
}
build_root_tmp readline-8.2 build_readline

function build_m4 {
    ./configure --prefix=/usr

    make -j8
    
    make install
}
build_root_tmp m4-1.4.19 build_m4

function build_bc {
    CC=gcc ./configure --prefix=/usr -G -O3 -r
    make -j8 
    
    make install
}
build_root_tmp bc-6.7.5 build_bc

function build_flex {
    ./configure --prefix=/usr \
        --docdir=/usr/share/doc/flex-2.6.4 \
        --disable-static
    make -j8
    
    make install

    ln -sv flex /usr/bin/lex
    ln -sv flex.1 /usr/share/man/man1/lex.1
}
build_root_tmp flex-2.6.4 build_flex

function build_tcl {
    SRCDIR=$(pwd)
    cd unix
    ./configure --prefix=/usr \
        --mandir=/usr/share/man

        make
    sed -e "s|$SRCDIR/unix|/usr/lib|" \
        -e "s|$SRCDIR|/usr/include|" \
        -i tclConfig.sh
    sed -e "s|$SRCDIR/unix/pkgs/tdbc1.1.5|/usr/lib/tdbc1.1.5|" \
        -e "s|$SRCDIR/pkgs/tdbc1.1.5/generic|/usr/include|" \
        -e "s|$SRCDIR/pkgs/tdbc1.1.5/library|/usr/lib/tcl8.6|" \
        -e "s|$SRCDIR/pkgs/tdbc1.1.5|/usr/include|" \
        -i pkgs/tdbc1.1.5/tdbcConfig.sh
    sed -e "s|$SRCDIR/unix/pkgs/itcl4.2.3|/usr/lib/itcl4.2.3|" \
        -e "s|$SRCDIR/pkgs/itcl4.2.3/generic|/usr/include|" \
        -e "s|$SRCDIR/pkgs/itcl4.2.3|/usr/include|" \
        -i pkgs/itcl4.2.3/itclConfig.sh
    unset SRCDIR

    
    make install

    chmod -v u+w /usr/lib/libtcl8.6.so
    make install-private-headers
    ln -sfv tclsh8.6 /usr/bin/tclsh
    mv /usr/share/man/man3/{Thread,Tcl_Thread}.3
}
build_root_tmp tcl8.6.13 build_tcl

function build_expect {
    ./configure --prefix=/usr \
        --with-tcl=/usr/lib \
        --enable-shared \
        --mandir=/usr/share/man \
        --with-tclinclude=/usr/include
    make -j8
    
    make install

    ln -svf expect5.45.4/libexpect5.45.4.so /usr/lib
}
build_root_tmp expect5.45.4 build_expect

function build_dejagnu {
    in_build
    ../configure --prefix=/usr
    makeinfo --html --no-split -o doc/dejagnu.html ../doc/dejagnu.texi
    makeinfo --plaintext -o doc/dejagnu.txt ../doc/dejagnu.texi

    
    make install
    install -v -dm755 /usr/share/doc/dejagnu-1.6.3
    install -v -m644 doc/dejagnu.{html,txt} /usr/share/doc/dejagnu-1.6.3
}
build_root_tmp dejagnu-1.6.3 build_dejagnu

function build_pkgconf {
    ./configure --prefix=/usr \
        --disable-static \
        --docdir=/usr/share/doc/pkgconf-2.1.1
    make -j8
    make install

    ln -sv pkgconf /usr/bin/pkg-config
    ln -sv pkgconf.1 /usr/share/man/man1/pkg-config.1
}
build_root_tmp pkgconf-2.1.1 build_pkgconf 

function build_binutils {
    in_build
    ../configure --prefix=/usr \
        --sysconfdir=/etc \
        --enable-gold \
        --enable-ld=default \
        --enable-plugins \
        --enable-shared \
        --disable-werror \
        --enable-64-bit-bfd \
        --with-system-zlib \
        --enable-default-hash-style=gnu
    make tooldir=/usr -j8
    make tooldir=/usr install
    rm -fv /usr/lib/lib{bfd,ctf,ctf-nobfd,gprofng,opcodes,sframe}.a
}
build_root_tmp binutils-2.42 build_binutils

function build_gmp {
    ./configure --prefix=/usr \
        --enable-cxx \
        --disable-static \
        --docdir=/usr/share/doc/gmp-6.3.0
    make -j8 
    make html
    
    make install
    make install-html
}
build_root_tmp gmp-6.3.0 build_gmp

function build_mpfr {
    ./configure --prefix=/usr \
        --disable-static \
        --enable-thread-safe \
        --docdir=/usr/share/doc/mpfr-4.2.1
    make -j8
    make html
    
    make install
    make install-html
}
build_root_tmp mpfr-4.2.1 build_mpfr

function build_mpc {
    ./configure --prefix=/usr \
        --disable-static \
        --docdir=/usr/share/doc/mpc-1.3.1
    make -j8
    make html
    
    make install
    make install-html
}
build_root_tmp mpc-1.3.1 build_mpc

function build_attr {
    ./configure --prefix=/usr \
        --disable-static \
        --sysconfdir=/etc \
        --docdir=/usr/share/doc/attr-2.5.2
    make -j8
    
    make install
}
build_root_tmp attr-2.5.2 build_attr

function build_acl {
    ./configure --prefix=/usr \
        --disable-static \
        --docdir=/usr/share/doc/acl-2.3.2
    make -j8
    make install
}
build_root_tmp acl-2.3.2 build_acl

function build_libcap {
    sed -i '/install -m.*STA/d' libcap/Makefile
    make prefix=/usr lib=lib -j8
    
    make prefix=/usr lib=lib install
}
build_root_tmp libcap-2.69 build_libcap

function build_libxcrypt {
    ./configure --prefix=/usr \
        --enable-hashes=strong,glibc \
        --enable-obsolete-api=no \
        --disable-static \
        --disable-failure-tokens
    make -j8
    
    make install
}
build_root_tmp libxcrypt-4.4.36 build_libxcrypt

function build_shadow {
    sed -i 's/groups$(EXEEXT) //' src/Makefile.in
    find man -name Makefile.in -exec sed -i 's/groups\.1 / /' {} \;
    find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
    find man -name Makefile.in -exec sed -i 's/passwd\.5 / /' {} \;

    sed -e 's:#ENCRYPT_METHOD DES:ENCRYPT_METHOD YESCRYPT:' \
        -e 's:/var/spool/mail:/var/mail:' \
        -e '/PATH=/{s@/sbin:@@;s@/bin:@@}' \
        -i etc/login.defs

    touch /usr/bin/passwd
    ./configure --sysconfdir=/etc \
        --disable-static \
        --with-{b,yes}crypt \
        --without-libbsd \
        --with-group-name-max-length=32
    make -j8

    make exec_prefix=/usr install
    make -C man install-man

    pwconv
    grpconv

    mkdir -p /etc/default
    useradd -D --gid 999
}
build_root_tmp shadow-4.14.5 build_shadow

function build_gcc {
    case $(uname -m) in
        x86_64)
            sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
        ;;
    esac

    in_build

    ../configure --prefix=/usr \
        LD=ld \
        --enable-languages=c,c++ \
        --enable-default-pie \
        --enable-default-ssp \
        --disable-multilib \
        --disable-bootstrap \
        --disable-fixincludes \
        --with-system-zlib
    make -j8
    make install

    ln -svr /usr/bin/cpp /usr/lib
    ln -sv gcc.1 /usr/share/man/man1/cc.1

    ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/13.2.0/liblto_plugin.so /usr/lib/bfd-plugins/

    echo 'int main(){}' > dummy.c
    cc dummy.c -v -Wl,--verbose &> dummy.log
    readelf -l a.out | grep ': /lib'
    grep -E -o '/usr/lib.*/S?crt[1in].*succeeded' dummy.log
    grep -B4 '^ /usr/include' dummy.log
    grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'
    grep "/lib.*/libc.so.6 " dummy.log
    grep found dummy.log
    rm -v dummy.c a.out dummy.log

    mkdir -pv /usr/share/gdb/auto-load/usr/lib
    mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib
}
build_root_tmp gcc-13.2.0 build_gcc

function build_ncurses {
    ./configure --prefix=/usr \
        --mandir=/usr/share/man \
        --with-shared \
        --without-debug \
        --without-normal \
        --with-cxx-shared \
        --enable-pc-files \
        --enable-widec \
        --with-pkg-config-libdir=/usr/lib/pkgconfig
    make -j8

    make DESTDIR=$PWD/dest install
    install -vm755 dest/usr/lib/libncursesw.so.6.4 /usr/lib
    rm -v dest/usr/lib/libncursesw.so.6.4
    sed -e 's/^#if.*XOPEN.*$/#if 1/' -i dest/usr/include/curses.h
    cp -av dest/* /

    for lib in ncurses form panel menu ; do
        ln -sfv lib${lib}w.so /usr/lib/lib${lib}.so
        ln -sfv ${lib}w.pc /usr/lib/pkgconfig/${lib}.pc
    done

    ln -sfv libncursesw.so /usr/lib/libcurses.so
    cp -v -R doc -T /usr/share/doc/ncurses-6.4-20230520
}
build_root_tmp ncurses-6.4-20230520 build_ncurses

function build_sed {
    ./configure --prefix=/usr

    make -j8
    make html

    make install
    install -d -m755 /usr/share/doc/sed-4.9
    install -m644 doc/sed.html /usr/share/doc/sed-4.9
}
build_root_tmp sed-4.9 build_sed

function build_psmisc {
    ./configure --prefix=/usr
    make -j8
    
    make install
}
build_root_tmp psmisc-23.6 build_psmisc

function build_gettext {
    ./configure --prefix=/usr \
        --disable-static \
        --docdir=/usr/share/doc/gettext-0.22.4
    make -j8
    

    make install
    chmod -v 0755 /usr/lib/preloadable_libintl.so
}
build_root_tmp gettext-0.22.4 build_gettext

function build_bison {
    ./configure --prefix=/usr \
        --docdir=/usr/share/doc/bison-3.8.2
    make -j8
    
    make install
}
build_root_tmp bison-3.8.2 build_bison

function build_grep {
    sed -i "s/echo/#echo/" src/egrep.sh
    ./configure --prefix=/usr
    make -j8
    
    make install
}
build_root_tmp grep-3.11 build_grep

function build_bash {
    patch -Np1 -i $LFS_SOURCES/bash-5.2.21-upstream_fixes-1.patch
    ./configure --prefix=/usr \
        --without-bash-malloc \
        --with-installed-readline \
        --docdir=/usr/share/doc/bash-5.2.21
    make -j8
    make install
}
build_root_tmp bash-5.2.21 build_bash

function build_libtool {
    ./configure --prefix=/usr
    make -j8
    make install
    rm -fv /usr/lib/libltdl.a
}
build_root_tmp libtool-2.4.7 build_libtool

function build_gdbm {
    ./configure --prefix=/usr \
        --disable-static \
        --enable-libgdbm-compat
    make -j8
    
    make install
}
build_root_tmp gdbm-1.23 build_gdbm

function build_gperf {
    ./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.1
    make
    
    make install
}
build_root_tmp gperf-3.1 build_gperf

function build_expat {
    ./configure --prefix=/usr \
        --disable-static \
        --docdir=/usr/share/doc/expat-2.6.2
    make -j8
    
    make install
    install -v -m644 doc/*.{html,css} /usr/share/doc/expat-2.6.2
}
build_root_tmp expat-2.6.2 build_expat

function build_inetuitls {
    ./configure --prefix=/usr \
        --bindir=/usr/bin \
        --localstatedir=/var \
        --disable-logger \
        --disable-whois \
        --disable-rcp \
        --disable-rexec \
        --disable-rlogin \
        --disable-rsh \
        --disable-servers
    make -j8
    
    make install
    mv -v /usr/{,s}bin/ifconfig
}
build_root_tmp inetutils-2.5 build_inetuitls

function build_less {
    ./configure --prefix=/usr --sysconfdir=/etc
    make -j8
    
    make install
}
build_root_tmp less-643 build_less

function build_perl {
    export BUILD_ZLIB=False
    export BUILD_BZIP2=0
    
    sh Configure -des \
        -Dprefix=/usr \
        -Dvendorprefix=/usr \
        -Dprivlib=/usr/lib/perl5/5.38/core_perl \
        -Darchlib=/usr/lib/perl5/5.38/core_perl \
        -Dsitelib=/usr/lib/perl5/5.38/site_perl \
        -Dsitearch=/usr/lib/perl5/5.38/site_perl \
        -Dvendorlib=/usr/lib/perl5/5.38/vendor_perl \
        -Dvendorarch=/usr/lib/perl5/5.38/vendor_perl \
        -Dman1dir=/usr/share/man/man1 \
        -Dman3dir=/usr/share/man/man3 \
        -Dpager="/usr/bin/less -isR" \
        -Duseshrplib \
        -Dusethreads
    make -j8
    make install
    unset BUILD_ZLIB BUILD_BZIP2
}
build_root_tmp perl-5.38.2 build_perl

function build_xml_parser {
    perl Makefile.PL
    make -j8
    
    make install
}
build_root_tmp XML-Parser-2.47 build_xml_parser

function build_intltool {
    sed -i 's:\\\${:\\\$\\{:' intltool-update.in
    ./configure --prefix=/usr
    make -j8
    
    make install
    install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO
}
build_root_tmp intltool-0.51.0 build_intltool

function build_autoconf {
    ./configure --prefix=/usr
    make -j8
    
    make install
}
build_root_tmp autoconf-2.72 build_autoconf

function build_automake {
    ./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.16.5
    make -j8
    make install
}
build_root_tmp automake-1.16.5 build_automake

function build_openssl {
    ./config --prefix=/usr \
        --openssldir=/etc/ssl \
        --libdir=lib \
        shared \
        zlib-dynamic
    make -j8

    sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
    make MANSUFFIX=ssl install
    mv -v /usr/share/doc/openssl /usr/share/doc/openssl-3.2.1
    cp -vfr doc/* /usr/share/doc/openssl-3.2.1
}
build_root_tmp openssl-3.2.1 build_openssl

function build_kmod {
    ./configure --prefix=/usr \
        --sysconfdir=/etc \
        --with-openssl \
        --with-xz \
        --with-zstd \
        --with-zlib
    make -j8

    make install
    for target in depmod insmod modinfo modprobe rmmod; do
        ln -sfv ../bin/kmod /usr/sbin/$target
    done
    ln -sfv kmod /usr/bin/lsmod
}
build_root_tmp kmod-31 build_kmod

function build_elfutils {
    ./configure --prefix=/usr \
        --disable-debuginfod \
        --enable-libdebuginfod=dummy
    
    make -j8
    make -C libelf install
    install -vm644 config/libelf.pc /usr/lib/pkgconfig
    rm /usr/lib/libelf.a
}
build_root_tmp elfutils-0.190 build_elfutils

function build_libffi {
    ./configure --prefix=/usr \
        --disable-static \
        --with-gcc-arch=native
    make -j8
    
    make install
}
build_root_tmp libffi-3.4.4 build_libffi

function build_python {
    ./configure --prefix=/usr \
        --enable-shared \
        --with-system-expat \
        --enable-optimizations
    make -j8
    make install

    cat > /etc/pip.conf << EOF
[global]
root-user-action = ignore
disable-pip-version-check = true
EOF
}
build_root_tmp Python-3.12.2 build_python

function build_flit_core {
    pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
    pip3 install --no-index --no-user --find-links dist flit_core
}
build_root_tmp flit_core-3.9.0 build_flit_core

function build_wheel {
    pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
    pip3 install --no-index --find-links=dist wheel
}
build_root_tmp wheel-0.42.0 build_wheel

function build_setuptools {
    pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
    pip3 install --no-index --find-links dist setuptools
}
build_root_tmp setuptools-69.1.0 build_setuptools

function build_ninja {
    python3 configure.py --bootstrap

    install -vm755 ninja /usr/bin/
    install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja
    install -vDm644 misc/zsh-completion /usr/share/zsh/site-functions/_ninja
}
build_root_tmp ninja-1.11.1 build_ninja

function build_meson {
    pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD

    pip3 install --no-index --find-links dist meson
    install -vDm644 data/shell-completions/bash/meson /usr/share/bash-completion/completions/meson
    install -vDm644 data/shell-completions/zsh/_meson /usr/share/zsh/site-functions/_meson
}
build_root_tmp meson-1.3.2 build_meson

function build_coreutils {
    patch -Np1 -i $LFS_SOURCES/coreutils-9.4-i18n-1.patch

    sed -e '/n_out += n_hold/,+4 s|.*bufsize.*|//&|' -i src/split.c

    autoreconf -fiv
    FORCE_UNSAFE_CONFIGURE=1 ./configure \
        --prefix=/usr \
        --enable-no-install-program=kill,uptime
    
    make -j8
    make install

    mv -v /usr/bin/chroot /usr/sbin
    mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
    sed -i 's/"1"/"8"/' /usr/share/man/man8/chroot.8
}
build_root_tmp coreutils-9.4 build_coreutils

function build_check {
    ./configure --prefix=/usr --disable-static
    make -j8
    
    make docdir=/usr/share/doc/check-0.15.2 install
}
build_root_tmp check-0.15.2 build_check

function build_diffutils {
    ./configure --prefix=/usr
    make -j8
    
    make install
}
build_root_tmp diffutils-3.10 build_diffutils


function build_gawk {
    sed -i 's/extras//' Makefile.in

    ./configure --prefix=/usr
    make -j8
    rm -f /usr/bin/gawk-5.3.0
    make install

    ln -sv gawk.1 /usr/share/man/man1/awk.1

    mkdir -pv /usr/share/doc/gawk-5.3.0
    cp -v doc/{awkforai.txt,*.{eps,pdf,jpg}} /usr/share/doc/gawk-5.3.0
}
build_root_tmp gawk-5.3.0 build_gawk

function build_findutils {
    ./configure --prefix=/usr --localstatedir=/var/lib/locate
    make -j8
    make install
}
build_root_tmp findutils-4.9.0 build_findutils

function build_groff {
    PAGE=A4 ./configure --prefix=/usr
    make -j8
    
    make install
}
build_root_tmp groff-1.23.0 build_groff

function build_grub2 {
    unset {C,CPP,CXX,LD}FLAGS

    echo depends bli part_gpt > grub-core/extra_deps.lst

    ./configure --prefix=/usr \
        --sysconfdir=/etc \
        --disable-efiemu \
        --disable-werror
    make -j8
    make install
    mv -v /etc/bash_completion.d/grub /usr/share/bash-completion/completions
}
build_root_tmp grub-2.12 build_grub2

function build_gzip {
    ./configure --prefix=/usr
    make -j8
    
    make install
}
build_root_tmp gzip-1.13 build_gzip

function build_iproute2 {
    sed -i /ARPD/d Makefile
    rm -fv man/man8/arpd.8

    make NETNS_RUN_DIR=/run/netns -j8
    make SBINDIR=/usr/sbin install

    mkdir -pv /usr/share/doc/iproute2-6.7.0
    cp -v COPYING README* /usr/share/doc/iproute2-6.7.0
}
build_root_tmp iproute2-6.7.0 build_iproute2

function build_kbd {
    patch -Np1 -i $LFS_SOURCES/kbd-2.6.4-backspace-1.patch

    sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure
    sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in

    ./configure --prefix=/usr --disable-vlock

    make -j8
    
    make install

    cp -R -v docs/doc -T /usr/share/doc/kbd-2.6.4
}
build_root_tmp kbd-2.6.4 build_kbd

function build_libpipeline {
    ./configure --prefix=/usr
    make -j8
    
    make install
}
build_root_tmp libpipeline-1.5.7 build_libpipeline

function build_make {
    ./configure --prefix=/usr
    make -j8
    make install
}
build_root_tmp make-4.4.1 build_make

function build_patch {
    ./configure --prefix=/usr
    make -j8
    
    make install
}
build_root_tmp patch-2.7.6 build_patch

function build_tar {
    FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=/usr
    make -j8
    
    make install
    make -C doc install-html docdir=/usr/share/doc/tar-1.35
}
build_root_tmp tar-1.35 build_tar

function build_texinfo {
    ./configure --prefix=/usr
    make -j8
    
    make install

    make TEXMF=/usr/share/texmf install-tex

    pushd /usr/share/info
        rm -v dir
        for f in *
            do install-info $f dir 2>/dev/null
        done
    popd
}
build_root_tmp texinfo-7.1 build_texinfo

function build_vim {
    echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h

    ./configure --prefix=/usr

    make -j8
    make install

    ln -sv vim /usr/bin/vi
    for L in /usr/share/man/{,*/}man1/vim.1; do
        ln -sv vim.1 $(dirname $L)/vi.1
    done

    ln -sv ../vim/vim91/doc /usr/share/doc/vim-9.1.0041

    cat > /etc/vimrc << "EOF"
" Begin /etc/vimrc
" Ensure defaults are set before customizing settings, not after
source $VIMRUNTIME/defaults.vim
let skip_defaults_vim=1
set nocompatible
set backspace=2
set mouse=
syntax on
if (&term == "xterm") || (&term == "putty")
set background=dark
endif
" End /etc/vimrc
EOF
}
build_root_tmp vim-9.1.0041 build_vim

function build_markupsafe {
    pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
    pip3 install --no-index --no-user --find-links dist Markupsafe
}
build_root_tmp MarkupSafe-2.1.5 build_markupsafe

function build_jinja2 {
    pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
    pip3 install --no-index --no-user --find-links dist Jinja2
}
build_root_tmp Jinja2-3.1.3 build_jinja2

function build_udev {
    sed -i -e 's/GROUP="render"/GROUP="video"/' \
           -e 's/GROUP="sgx", //' rules.d/50-udev-default.rules.in
    sed '/systemd-sysctl/s/^/#/' -i rules.d/99-systemd.rules.in
    sed '/NETWORK_DIRS/s/systemd/udev/' -i src/basic/path-lookup.h

    in_build
    meson setup \
        --prefix=/usr \
        --buildtype=release \
        -Dmode=release \
        -Ddev-kvm-mode=0660 \
        -Dlink-udev-shared=false \
        -Dlogind=false \
        -Dvconsole=false \
        ..

    export udev_helpers=$(grep "'name' :" ../src/udev/meson.build | \
        awk '{print $3}' | tr -d ",'" | grep -v 'udevadm')

    ninja udevadm systemd-hwdb \
        $(ninja -n | grep -Eo '(src/(lib)?udev|rules.d|hwdb.d)/[^ ]*') \
        $(realpath libudev.so --relative-to .) \
        $udev_helpers

    install -vm755 -d {/usr/lib,/etc}/udev/{hwdb.d,rules.d,network}
    install -vm755 -d /usr/{lib,share}/pkgconfig
    install -vm755 udevadm /usr/bin/
    install -vm755 systemd-hwdb /usr/bin/udev-hwdb
    ln -svfn ../bin/udevadm /usr/sbin/udevd
    cp -av libudev.so{,*[0-9]} /usr/lib/
    install -vm644 ../src/libudev/libudev.h /usr/include/
    install -vm644 src/libudev/*.pc /usr/lib/pkgconfig/
    install -vm644 src/udev/*.pc /usr/share/pkgconfig/
    install -vm644 ../src/udev/udev.conf /etc/udev/
    install -vm644 rules.d/* ../rules.d/README /usr/lib/udev/rules.d/
    install -vm644 $(find ../rules.d/*.rules -not -name '*power-switch*') /usr/lib/udev/rules.d/
    install -vm644 hwdb.d/* ../hwdb.d/{*.hwdb,README} /usr/lib/udev/hwdb.d/
    install -vm755 $udev_helpers /usr/lib/udev
    install -vm644 ../network/99-default.link /usr/lib/udev/network

    tar -xvf $LFS_SOURCES/udev-lfs-20230818.tar.xz
    make -f udev-lfs-20230818/Makefile.lfs install

    tar -xf $LFS_SOURCES/systemd-man-pages-255.tar.xz \
        --no-same-owner --strip-components=1 \
        -C /usr/share/man --wildcards '*/udev*' '*/libudev*' \
            '*/systemd.link.5' \
            '*/systemd-'{hwdb,udevd.service}.8

    sed 's|systemd/network|udev/network|' \
        /usr/share/man/man5/systemd.link.5 \
        > /usr/share/man/man5/udev.link.5
    sed 's/systemd\(\\\?-\)/udev\1/' /usr/share/man/man8/systemd-hwdb.8 \
        > /usr/share/man/man8/udev-hwdb.8
    sed 's|lib.*udevd|sbin/udevd|' \
        /usr/share/man/man8/systemd-udevd.service.8 \
        > /usr/share/man/man8/udevd.8
    rm /usr/share/man/man*/systemd*

    unset udev_helpers

    udev-hwdb update
}
build_root_tmp systemd-255 build_udev

function build_man_db {
    ./configure --prefix=/usr \
        --docdir=/usr/share/doc/man-db-2.12.0 \
        --sysconfdir=/etc \
        --disable-setuid \
        --enable-cache-owner=bin \
        --with-browser=/usr/bin/lynx \
        --with-vgrind=/usr/bin/vgrind \
        --with-grap=/usr/bin/grap \
        --with-systemdtmpfilesdir= \
        --with-systemdsystemunitdir=
    make -j8
    
    make install
}
build_root_tmp man-db-2.12.0 build_man_db

function build_procps_ng {
    ./configure --prefix=/usr \
        --docdir=/usr/share/doc/procps-ng-4.0.4 \
        --disable-static \
        --disable-kill
    make -j8
    make install
}
build_root_tmp procps-ng-4.0.4 build_procps_ng

function build_util_linux {
    sed -i '/test_mkfds/s/^/#/' tests/helpers/Makemodule.am

    ./configure --bindir=/usr/bin \
        --libdir=/usr/lib \
        --runstatedir=/run \
        --sbindir=/usr/sbin \
        --disable-chfn-chsh \
        --disable-login \
        --disable-nologin \
        --disable-su \
        --disable-setpriv \
        --disable-runuser \
        --disable-pylibmount \
        --disable-static \
        --without-python \
        --without-systemd \
        --without-systemdsystemunitdir \
        ADJTIME_PATH=/var/lib/hwclock/adjtime \
        --docdir=/usr/share/doc/util-linux-2.39.3
    make -j8
    make install
}
build_root_tmp util-linux-2.39.3 build_util_linux

function build_e2fsprogs {
    in_build
    ../configure --prefix=/usr \
        --sysconfdir=/etc \
        --enable-elf-shlibs \
        --disable-libblkid \
        --disable-libuuid \
        --disable-uuidd \
        --disable-fsck
    make -j8
    make install

    rm -fv /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a   

    gunzip -v /usr/share/info/libext2fs.info.gz
    install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info

    makeinfo -o doc/com_err.info ../lib/et/com_err.texinfo
    install -v -m644 doc/com_err.info /usr/share/info
    install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info

    sed 's/metadata_csum_seed,//' -i /etc/mke2fs.conf
}
build_root_tmp e2fsprogs-1.47.0 build_e2fsprogs

function build_sysklogd {
    sed -i '/Error loading kernel symbols/{n;n;d}' ksym_mod.c
    sed -i 's/union wait/int/' syslogd.c

    make -j8
    make BINDIR=/sbin install

    cat > /etc/syslog.conf << "EOF"
Begin /etc/syslog.conf
auth,authpriv.* -/var/log/auth.log
*.*;auth,authpriv.none -/var/log/sys.log
daemon.* -/var/log/daemon.log
kern.* -/var/log/kern.log
mail.* -/var/log/mail.log
user.* -/var/log/user.log
*.emerg *
End /etc/syslog.conf
EOF
}
build_root_tmp sysklogd-1.5.1 build_sysklogd

function build_sysvinit {
    patch -Np1 -i $LFS_SOURCES/sysvinit-3.08-consolidated-1.patch
    make -j8
    make install
}
build_root_tmp sysvinit-3.08 build_sysvinit

function build_cmake {
    ./bootstrap --prefix=/usr
    make -j8
    make install
}
build_root_tmp cmake-3.29.6 build_cmake

function build_libunistring {
    ./configure --prefix=/usr    \
        --disable-static \
        --docdir=/usr/share/doc/libunistring-1.1
    make -j8
    make install
}
build_root_tmp libunistring-1.1 build_libunistring

function build_libidn2 {
    ./configure --prefix=/usr \
        --disable-static
    make -j8
    make install
}
build_root_tmp libidn2-2.3.7 build_libidn2

function build_libpsl {
    in_build

    meson setup --prefix=/usr --buildtype=release
    ninja
    ninja install
}
build_root_tmp libpsl-0.21.5 build_libpsl

function build_curl {
    ./configure --prefix=/usr \
        --disable-static \
        --with-openssl \
        --enable-threaded-resolver \
        --with-ca-path=/etc/ssl/certs
    make -j8
    make install
}
build_root_tmp curl-8.6.0 build_curl

function build_pcre2 {
    ./configure --prefix=/usr \
        --enable-pcre2-8 \
        --enable-pcre2-16 \
        --enable-pcre2-32 \
        --disable-static
    make -j8
    make install
}
build_root_tmp pcre2-10.44 build_pcre2

function build_fish {
    cmake -DCMAKE_INSTALL_PREFIX=/usr .
    make -j8
    make install
}
build_root_tmp fish-3.7.1 build_fish

function build_dhcpcd {
    ./configure --prefix=/usr \
        --sysconfdir=/etc \
        --libexecdir=/usr/lib/dhcpcd \
        --dbdir=/var/lib/dhcpcd \
        --runstatedir=/run \
        --disable-privsep
    make -j8
    make install
}
build_root_tmp dhcpcd-10.0.6 build_dhcpcd

function build_tree {
    make
    make PREFIX=/usr MANDIR=/usr/share/man install
}
build_root_tmp unix-tree-2.1.1 build_tree

function build_make_ca {
    make install 
    install -vdm755 /etc/ssl/local

}
build_root_tmp make-ca-1.13 build_make_ca

function build_libasn1 {
    ./configure --prefix=/usr --disable-static
    make -j8
    make install
    make -C doc/reference install-data-local
}
build_root_tmp libtasn1-4.19.0 build_libasn1

function build_libxml2 {
    ./configure --prefix=/usr \
        --sysconfdir=/etc \
        --disable-static \
        --with-history \
        --with-icu \
        PYTHON=/usr/bin/python3 \
        --docdir=/usr/share/doc/libxml2-2.12.5
    make -j8
    make install
    rm -vf /usr/lib/libxml2.la
    sed '/libs=/s/xml2.*/xml2"/' -i /usr/bin/xml2-config
}
build_root_tmp libxml2-2.12.5 build_libxml2

function build_libxslt {
    ./configure --prefix=/usr \
        --disable-static \
        --docdir=/usr/share/doc/libxslt-1.1.39 \
        PYTHON=/usr/bin/python3
    make -j8
    make install
}
build_root_tmp libxslt-1.1.39 build_libxslt

function build_pk11_kit {
    sed '20,$ d' -i trust/trust-extract-compat &&

    cat >> trust/trust-extract-compat << "EOF"
Copy existing anchor modifications to /etc/ssl/local
/usr/libexec/make-ca/copy-trust-modifications

Update trust stores
/usr/sbin/make-ca -r
EOF

    in_build
    meson setup .. \
      --prefix=/usr \
      --buildtype=release \
      -Dtrust_paths=/etc/pki/anchors
    ninja

    ninja install
    ln -sfv /usr/libexec/p11-kit/trust-extract-compat /usr/bin/update-ca-certificates
}
build_root_tmp p11-kit-0.25.3 build_pk11_kit

function build_wget {
    ./configure --prefix=/usr \
        --sysconfdir=/etc \
        --with-ssl=openssl
    make -j8
    make install
}
build_root_tmp wget-1.21.4 build_wget

function build_pciutils {
    make PREFIX=/usr \
        SHAREDIR=/usr/share/hwdata \
        SHARED=yes -j8
    make PREFIX=/usr \
        SHAREDIR=/usr/share/hwdata \
        SHARED=yes \
        install install-lib

    chmod -v 755 /usr/lib/libpci.so
}
build_root_tmp pciutils-3.10.0 build_pciutils

function build_libusb {
    ./configure --prefix=/usr --disable-static
    make -j8
    make install
}
build_root_tmp libusb-1.0.27 build_libusb

function build_usbutils {
    ./configure --prefix=/usr --datadir=/usr/share/hwdata
    make -j8
    make install
    install -dm755 /usr/share/hwdata/
}
build_root_tmp usbutils-017 build_usbutils

function build_rsync {
    ./configure --prefix=/usr \
        --disable-lz4 \
        --disable-xxhash \
        --without-included-zlib
    make -j8
    make install
}
build_root_tmp rsync-3.2.7 build_rsync

function build_dosfstools {
    ./configure --prefix=/usr \
        --enable-compat-symlinks \
        --mandir=/usr/share/man \
        --docdir=/usr/share/doc/dosfstools-4.2
    make -j8
    make install
}
build_root_tmp dosfstools-4.2 build_dosfstools