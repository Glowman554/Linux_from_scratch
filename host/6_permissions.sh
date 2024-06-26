source config.sh

sudo chown -Rv root:root $LFS/{usr,lib,var,etc,bin,sbin,tools}
    case $(uname -m) in
        x86_64) sudo chown -Rv root:root $LFS/lib64
    ;;
esac


