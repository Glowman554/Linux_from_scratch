source config.sh

function download {
    local output=$LFS_SOURCES/$(basename $1)

    echo "Downloading "$(basename $1)" to $output..."

    curl $1 -sSL -o $output

    # Calculate MD5 checksum
    local actual_md5=$(md5sum $output | awk '{print $1}')

    if [ "$actual_md5" != "$2" ]; then
        echo "Download failed! MD5 checksum does not match."
    fi
}

download https://download.savannah.gnu.org/releases/acl/acl-2.3.2.tar.xz 590765dee95907dbc3c856f7255bd669
download https://download.savannah.gnu.org/releases/attr/attr-2.5.2.tar.gz 227043ec2f6ca03c0948df5517f9c927
download https://ftp.gnu.org/gnu/autoconf/autoconf-2.72.tar.xz 1be79f7106ab6767f18391c5e22be701
download https://ftp.gnu.org/gnu/automake/automake-1.16.5.tar.xz 4017e96f89fca45ca946f1c5db6be714
download https://ftp.gnu.org/gnu/bash/bash-5.2.21.tar.gz ad5b38410e3bf0e9bcc20e2765f5e3f9
download https://github.com/gavinhoward/bc/releases/download/6.7.5/bc-6.7.5.tar.xz e249b1f86f886d6fb71c15f72b65dd3d
download https://sourceware.org/pub/binutils/releases/binutils-2.42.tar.xz a075178a9646551379bfb64040487715
download https://ftp.gnu.org/gnu/bison/bison-3.8.2.tar.xz c28f119f405a2304ff0a7ccdcc629713
download https://www.sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz 67e051268d0c475ea773822f7500d0e5
download https://github.com/libcheck/check/releases/download/0.15.2/check-0.15.2.tar.gz 50fcafcecde5a380415b12e9c574e0b2
download https://ftp.gnu.org/gnu/coreutils/coreutils-9.4.tar.xz 459e9546074db2834eefe5421f250025
download https://ftp.gnu.org/gnu/dejagnu/dejagnu-1.6.3.tar.gz 68c5208c58236eba447d7d6d1326b821
download https://ftp.gnu.org/gnu/diffutils/diffutils-3.10.tar.xz 2745c50f6f4e395e7b7d52f902d075bf
download https://downloads.sourceforge.net/project/e2fsprogs/e2fsprogs/v1.47.0/e2fsprogs-1.47.0.tar.gz 6b4f18a33873623041857b4963641ee9
download https://sourceware.org/ftp/elfutils/0.190/elfutils-0.190.tar.bz2 79ad698e61a052bea79e77df6a08bc4b
download https://prdownloads.sourceforge.net/expat/expat-2.6.2.tar.xz 0cb75c8feb842c0794ba89666b762a2d
download https://prdownloads.sourceforge.net/expect/expect5.45.4.tar.gz 00fce8de158422f5ccd2666512329bd2
download https://astron.com/pub/file/file-5.45.tar.gz 26b2a96d4e3a8938827a1e572afd527a
download https://ftp.gnu.org/gnu/findutils/findutils-4.9.0.tar.xz 4a4a547e888a944b2f3af31d789a1137
download https://github.com/westes/flex/releases/download/v2.6.4/flex-2.6.4.tar.gz 2882e3179748cc9f9c23ec593d6adc8d
download https://pypi.org/packages/source/f/flit-core/flit_core-3.9.0.tar.gz 3bc52f1952b9a78361114147da63c35b
download https://ftp.gnu.org/gnu/gawk/gawk-5.3.0.tar.xz 97c5a7d83f91a7e1b2035ebbe6ac7abd
download https://ftp.gnu.org/gnu/gcc/gcc-13.2.0/gcc-13.2.0.tar.xz e0e48554cc6e4f261d55ddee9ab69075
download https://ftp.gnu.org/gnu/gdbm/gdbm-1.23.tar.gz 8551961e36bf8c70b7500d255d3658ec
download https://ftp.gnu.org/gnu/gettext/gettext-0.22.4.tar.xz 2d8507d003ef3ddd1c172707ffa97ed8
download https://ftp.gnu.org/gnu/glibc/glibc-2.39.tar.xz be81e87f72b5ea2c0ffe2bedfeb680c6
download https://ftp.gnu.org/gnu/gmp/gmp-6.3.0.tar.xz 956dc04e864001a9c22429f761f2c283
download https://ftp.gnu.org/gnu/gperf/gperf-3.1.tar.gz 9e251c0a618ad0824b51117d5d9db87e
download https://ftp.gnu.org/gnu/grep/grep-3.11.tar.xz 7c9bbd74492131245f7cdb291fa142c0
download https://ftp.gnu.org/gnu/groff/groff-1.23.0.tar.gz 5e4f40315a22bb8a158748e7d5094c7d
download https://ftp.gnu.org/gnu/grub/grub-2.12.tar.xz 60c564b1bdc39d8e43b3aab4bc0fb140
download https://ftp.gnu.org/gnu/gzip/gzip-1.13.tar.xz d5c9fc9441288817a4a0be2da0249e29
download https://github.com/Mic92/iana-etc/releases/download/20240125/iana-etc-20240125.tar.gz aed66d04de615d76c70890233081e584
download https://ftp.gnu.org/gnu/inetutils/inetutils-2.5.tar.xz 9e5a6dfd2d794dc056a770e8ad4a9263
download https://launchpad.net/intltool/trunk/0.51.0/+download/intltool-0.51.0.tar.gz 12e517cac2b57a0121cda351570f1e63
download https://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-6.7.0.tar.xz 35d8277d1469596b7edc07a51470a033
download https://pypi.org/packages/source/J/Jinja2/Jinja2-3.1.3.tar.gz caf5418c851eac59e70a78d9730d4cea
download https://www.kernel.org/pub/linux/utils/kbd/kbd-2.6.4.tar.xz e2fd7adccf6b1e98eb1ae8d5a1ce5762
download https://www.kernel.org/pub/linux/utils/kernel/kmod/kmod-31.tar.xz 6165867e1836d51795a11ea4762ff66a
download https://www.greenwoodsoftware.com/less/less-643.tar.gz cf05e2546a3729492b944b4874dd43dd
download https://www.linuxfromscratch.org/lfs/downloads/12.1/lfs-bootscripts-20230728.tar.xz a236eaa9a1f699bc3fb6ab2acd7e7b6c
download https://www.kernel.org/pub/linux/libs/security/linux-privs/libcap2/libcap-2.69.tar.xz 4667bacb837f9ac4adb4a1a0266f4b65
download https://github.com/libffi/libffi/releases/download/v3.4.4/libffi-3.4.4.tar.gz 0da1a5ed7786ac12dcbaf0d499d8a049
download https://download.savannah.gnu.org/releases/libpipeline/libpipeline-1.5.7.tar.gz 1a48b5771b9f6c790fb4efdb1ac71342
download https://ftp.gnu.org/gnu/libtool/libtool-2.4.7.tar.xz 2fc0b6ddcd66a89ed6e45db28fa44232
download https://github.com/besser82/libxcrypt/releases/download/v4.4.36/libxcrypt-4.4.36.tar.xz b84cd4104e08c975063ec6c4d0372446
download https://www.kernel.org/pub/linux/kernel/v6.x/linux-6.7.4.tar.xz 370e1b6155ae63133380e421146619e0
download https://ftp.gnu.org/gnu/m4/m4-1.4.19.tar.xz 0d90823e1426f1da2fd872df0311298d
download https://ftp.gnu.org/gnu/make/make-4.4.1.tar.gz c8469a3713cbbe04d955d4ae4be23eeb
download https://download.savannah.gnu.org/releases/man-db/man-db-2.12.0.tar.xz 67e0052fa200901b314fad7b68c9db27
download https://www.kernel.org/pub/linux/docs/man-pages/man-pages-6.06.tar.xz 26b39e38248144156d437e1e10cb20bf
download https://pypi.org/packages/source/M/MarkupSafe/MarkupSafe-2.1.5.tar.gz 8fe7227653f2fb9b1ffe7f9f2058998a
download https://github.com/mesonbuild/meson/releases/download/1.3.2/meson-1.3.2.tar.gz 2d0ebd3a24249617b1c4d30026380cf8
download https://ftp.gnu.org/gnu/mpc/mpc-1.3.1.tar.gz 5c9bc658c9fd0f940e8e3e0f09530c62
download https://ftp.gnu.org/gnu/mpfr/mpfr-4.2.1.tar.xz 523c50c6318dde6f9dc523bc0244690a
download https://anduin.linuxfromscratch.org/LFS/ncurses-6.4-20230520.tar.xz c5367e829b6d9f3f97b280bb3e6bfbc3
download https://github.com/ninja-build/ninja/archive/v1.11.1/ninja-1.11.1.tar.gz 32151c08211d7ca3c1d832064f6939b0
download https://www.openssl.org/source/openssl-3.2.1.tar.gz c239213887804ba00654884918b37441
download https://ftp.gnu.org/gnu/patch/patch-2.7.6.tar.xz 78ad9937e4caadcba1526ef1853730d5
download https://www.cpan.org/src/5.0/perl-5.38.2.tar.xz d3957d75042918a23ec0abac4a2b7e0a
download https://distfiles.ariadne.space/pkgconf/pkgconf-2.1.1.tar.xz bc29d74c2483197deb9f1f3b414b7918
download https://sourceforge.net/projects/procps-ng/files/Production/procps-ng-4.0.4.tar.xz 2f747fc7df8ccf402d03e375c565cf96
download https://sourceforge.net/projects/psmisc/files/psmisc/psmisc-23.6.tar.xz ed3206da1184ce9e82d607dc56c52633
download https://www.python.org/ftp/python/3.12.2/Python-3.12.2.tar.xz e7c178b97bf8f7ccd677b94d614f7b3c
download https://www.python.org/ftp/python/doc/3.12.2/python-3.12.2-docs-html.tar.bz2 8a6310f6288e7f60c3565277ec3b5279
download https://ftp.gnu.org/gnu/readline/readline-8.2.tar.gz 4aa1b31be779e6b84f9a96cb66bc50f6
download https://ftp.gnu.org/gnu/sed/sed-4.9.tar.xz 6aac9b2dbafcd5b7a67a8a9bcb8036c3
download https://pypi.org/packages/source/s/setuptools/setuptools-69.1.0.tar.gz 6f6eb780ce12c90d81ce243747ed7ab0
download https://github.com/shadow-maint/shadow/releases/download/4.14.5/shadow-4.14.5.tar.xz 452b0e59f08bf618482228ba3732d0ae
download https://www.infodrom.org/projects/sysklogd/download/sysklogd-1.5.1.tar.gz c70599ab0d037fde724f7210c2c8d7f8
download https://github.com/systemd/systemd/archive/v255/systemd-255.tar.gz 521cda27409a9edf0370c128fae3e690
download https://anduin.linuxfromscratch.org/LFS/systemd-man-pages-255.tar.xz 1ebe54d7a80f9abf8f2d14ddfeb2432d
download https://github.com/slicer69/sysvinit/releases/download/3.08/sysvinit-3.08.tar.xz 81a05f28d7b67533cfc778fcadea168c
download https://ftp.gnu.org/gnu/tar/tar-1.35.tar.xz a2d8042658cfd8ea939e6d911eaf4152
download https://downloads.sourceforge.net/tcl/tcl8.6.13-src.tar.gz 0e4358aade2f5db8a8b6f2f6d9481ec2
download https://downloads.sourceforge.net/tcl/tcl8.6.13-html.tar.gz 4452f2f6d557f5598cca17b786d6eb68
download https://ftp.gnu.org/gnu/texinfo/texinfo-7.1.tar.xz edd9928b4a3f82674bcc3551616eef3b
download https://www.iana.org/time-zones/repository/releases/tzdata2024a.tar.gz 2349edd8335245525cc082f2755d5bf4
download https://anduin.linuxfromscratch.org/LFS/udev-lfs-20230818.tar.xz acd4360d8a5c3ef320b9db88d275dae6
download https://www.kernel.org/pub/linux/utils/util-linux/v2.39/util-linux-2.39.3.tar.xz f3591e6970c017bb4bcd24ae762a98f5
download https://github.com/vim/vim/archive/v9.1.0041/vim-9.1.0041.tar.gz 79dfe62be5d347b1325cbd5ce2a1f9b3
download https://pypi.org/packages/source/w/wheel/wheel-0.42.0.tar.gz 802ad6e5f9336fcb1c76b7593f0cd22d
download https://cpan.metacpan.org/authors/id/T/TO/TODDR/XML-Parser-2.47.tar.gz 89a8e82cfd2ad948b349c0a69c494463
download https://github.com/tukaani-project/xz/releases/download/v5.4.6/xz-5.4.6.tar.xz 7ade7bd1181a731328f875bec62a9377
download https://zlib.net/fossils/zlib-1.3.1.tar.gz 9855b6d802d7fe5b7bd5b196a2271655
download https://github.com/facebook/zstd/releases/download/v1.5.5/zstd-1.5.5.tar.gz 63251602329a106220e0a5ad26ba656f
download https://www.linuxfromscratch.org/patches/lfs/12.1/bash-5.2.21-upstream_fixes-1.patch 2d1691a629c558e894dbb78ee6bf34ef
download https://www.linuxfromscratch.org/patches/lfs/12.1/bzip2-1.0.8-install_docs-1.patch 6a5ac7e89b791aae556de0f745916f7f
download https://www.linuxfromscratch.org/patches/lfs/12.1/coreutils-9.4-i18n-1.patch cca7dc8c73147444e77bc45d210229bb
download https://www.linuxfromscratch.org/patches/lfs/12.1/glibc-2.39-fhs-1.patch 9a5997c3452909b1769918c759eff8a2
download https://www.linuxfromscratch.org/patches/lfs/12.1/kbd-2.6.4-backspace-1.patch f75cca16a38da6caa7d52151f7136895
download https://www.linuxfromscratch.org/patches/lfs/12.1/readline-8.2-upstream_fixes-3.patch 9ed497b6cb8adcb8dbda9dee9ebce791
download https://www.linuxfromscratch.org/patches/lfs/12.1/sysvinit-3.08-consolidated-1.patch 17ffccbb8e18c39e8cedc32046f3a475
download https://github.com/Kitware/CMake/releases/download/v3.29.6/cmake-3.29.6.tar.gz fee55407a4750e2565e7ca1063b25ef9
download https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.44/pcre2-10.44.tar.gz 55680e6d658bf119976cac83a448c829
download https://github.com/fish-shell/fish-shell/releases/download/3.7.1/fish-3.7.1.tar.xz d32913b45d52459f40e6d434389e7bd4
download https://ftp.gnu.org/gnu/libunistring/libunistring-1.1.tar.xz 0dfba19989ae06b8e7a49a7cd18472a1
download https://ftp.gnu.org/gnu/libidn/libidn2-2.3.7.tar.gz de2818c7dea718a4f264f463f595596b
download https://github.com/rockdaboot/libpsl/releases/download/0.21.5/libpsl-0.21.5.tar.gz 870a798ee9860b6e77896548428dba7b
download https://curl.se/download/curl-8.6.0.tar.xz 8f28f7e08c91cc679a45fccf66184fbc
download https://github.com/NetworkConfiguration/dhcpcd/releases/download/v10.0.6/dhcpcd-10.0.6.tar.xz ef8356d711b17701928ead7206d15234
download https://anduin.linuxfromscratch.org/BLFS/blfs-bootscripts/blfs-bootscripts-20240209.tar.xz 843cf3bef5031dc49096c8970d06442a
download https://gitlab.com/OldManProgrammer/unix-tree/-/archive/2.1.1/unix-tree-2.1.1.tar.bz2 85f9a6d1e48f1d5262a9b2d58d47431f
download https://github.com/p11-glue/p11-kit/releases/download/0.25.3/p11-kit-0.25.3.tar.xz 2610cef2951d83d7037577eaae1acb54
download https://github.com/lfs-book/make-ca/releases/download/v1.13/make-ca-1.13.tar.xz 04bd86fe2eb299788439c3466782ce45
download https://ftp.gnu.org/gnu/wget/wget-1.21.4.tar.gz e7f7ca2f215b711f76584756ebd3c853
download https://mj.ucw.cz/download/linux/pci/pciutils-3.10.0.tar.gz ca53b87d2a94cdbbba6e09aca90924bd
download https://github.com/libusb/libusb/releases/download/v1.0.27/libusb-1.0.27.tar.bz2 1fb61afe370e94f902a67e03eb39c51f
download https://kernel.org/pub/linux/utils/usb/usbutils/usbutils-017.tar.xz 8ff21441faf2e8128e4810b3d6e49059
download https://ftp.gnu.org/gnu/libtasn1/libtasn1-4.19.0.tar.gz f701ab57eb8e7d9c105b2cd5d809b29a
download https://download.gnome.org/sources/libxslt/1.1/libxslt-1.1.39.tar.xz 22e9eb7c23825124e786611b3760a3c7
download  https://download.gnome.org/sources/libxml2/2.12/libxml2-2.12.5.tar.xz 329138464b69422815c11e62acbc10dd
download https://www.samba.org/ftp/rsync/src/rsync-3.2.7.tar.gz f216f350ef56b9ba61bc313cb6ec2ed6
download https://github.com/dosfstools/dosfstools/releases/download/v4.2/dosfstools-4.2.tar.gz 49c8e457327dc61efab5b115a27b087a

cp $LFS_SOURCES/tcl8.6.13-src.tar.gz $LFS_SOURCES/tcl8.6.13.tar.gz