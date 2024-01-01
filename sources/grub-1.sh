./configure --prefix=$LFS/tools               \
            --build=$(build-aux/config.guess) \
            --host=$(build-aux/config.guess)  \
            --target=$LFS_TGT                 \
            --program-prefix=lfs-             \
            --disable-werror'
            make
            make install

            mkdir -pv $LFS/boot/grub
cat > $LFS/boot/grub/grub.cfg << "EOF"
# Begin /boot/grub/grub.cfg
set default=0
set timeout=5

menuentry "LFS Temporary System" {
        linux   /vmlinuz root=/dev/sda2 rw init=/bin/bash
        boot
}
EOF
