source config.sh

cd $LFS_BUILD
echo 'int main(){}' | $LFS_TARGET-gcc -xc -
readelf -l a.out | grep ld-linux
rm -v a.out
