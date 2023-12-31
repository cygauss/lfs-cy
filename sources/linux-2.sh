make mrproper
make ARCH=x86 CROSS_COMPILE=$LFS_TGT- menuconfig
make ARCH=x86 CROSS_COMPILE=$LFS_TGT-
install -vm644 arch/x86/boot/bzImage $LFS/boot/vmlinuz