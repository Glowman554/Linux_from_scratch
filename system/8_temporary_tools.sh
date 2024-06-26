source config.sh

function build_gettext {
    ./configure --disable-shared
    make -j8
    cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin
}
build_root_tmp gettext-0.22.4 build_gettext

function build_bison {
    ./configure --prefix=/usr \
        --docdir=/usr/share/doc/bison-3.8.2
    make -j8
    make install
}
build_root_tmp bison-3.8.2 build_bison

function build_perl {
    sh Configure -des \
        -Dprefix=/usr \
        -Dvendorprefix=/usr \
        -Duseshrplib \
        -Dprivlib=/usr/lib/perl5/5.38/core_perl \
        -Darchlib=/usr/lib/perl5/5.38/core_perl \
        -Dsitelib=/usr/lib/perl5/5.38/site_perl \
        -Dsitearch=/usr/lib/perl5/5.38/site_perl \
        -Dvendorlib=/usr/lib/perl5/5.38/vendor_perl \
        -Dvendorarch=/usr/lib/perl5/5.38/vendor_perl
    make -j8
    make install
}
build_root_tmp perl-5.38.2 build_perl

function build_python {
    ./configure --prefix=/usr \
        --enable-shared \
        --without-ensurepip
    make -j8
    make install
}
build_root_tmp Python-3.12.2 build_python

function build_texinfo {
    ./configure --prefix=/usr
    make -j8
    make install
}
build_root_tmp texinfo-7.1 build_texinfo

function build_util_linux {
    mkdir -pv /var/lib/hwclock
    ./configure --libdir=/usr/lib \
        --runstatedir=/run \
        --disable-chfn-chsh \
        --disable-login \
        --disable-nologin \
        --disable-su \
        --disable-setpriv \
        --disable-runuser \
        --disable-pylibmount \
        --disable-static \
        --without-python \
        ADJTIME_PATH=/var/lib/hwclock/adjtime \
        --docdir=/usr/share/doc/util-linux-2.39.3
    make -j8
    make install
}
build_root_tmp util-linux-2.39.3 build_util_linux
