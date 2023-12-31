make mrproper
cp ../linux.config .config
make ARCH=x86 CROSS_COMPILE=$LFS_TGT- oldconfig
make ARCH=x86 CROSS_COMPILE=$LFS_TGT-
install -vm644 arch/x86/boot/bzImage $LFS/boot/vmlinuz
