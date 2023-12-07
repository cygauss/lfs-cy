export MAKEFLAGS='-j16'
export NOT_SOURCES=/sources
export NOT_DIF=".lfs"
bash /sources/notpm man-pages
bash /sources/notpm iana-etc
bash /sources/notpm glibc
bash /sources/notpm zlib
bash /sources/notpm bzip2
bash /sources/notpm xz
bash /sources/notpm zstd
bash /sources/notpm file
bash /sources/notpm readline
bash /sources/notpm m4
bash /sources/notpm bc
bash /sources/notpm flex
bash /sources/notpm tcl
bash /sources/notpm expect
bash /sources/notpm dejagnu
bash /sources/notpm binutils
bash /sources/notpm gmp
bash /sources/notpm mpfr
bash /sources/notpm mpc
bash /sources/notpm attr
bash /sources/notpm acl
bash /sources/notpm libcap
bash /sources/notpm libxcrypt
bash /sources/notpm shadow
bash /sources/notpm gcc
bash /sources/notpm pkgconf
bash /sources/notpm ncurses
bash /sources/notpm sed
bash /sources/notpm psmisc
bash /sources/notpm gettext
bash /sources/notpm bison
bash /sources/notpm grep
bash /sources/notpm bash
exec /usr/bin/bash --login << "EOF"
bash /sources/notpm libtool
bash /sources/notpm gdbm
bash /sources/notpm gperf
bash /sources/notpm expat
bash /sources/notpm inetutils
bash /sources/notpm less
bash /sources/notpm perl
bash /sources/notpm XML::Parser
bash /sources/notpm intltool
bash /sources/notpm autoconf
bash /sources/notpm automake
bash /sources/notpm openssl
bash /sources/notpm kmod
NOT_DIF=".lfs-libelf" bash /sources/notpm elfutils
bash /sources/notpm libffi
bash /sources/notpm Python
bash /sources/notpm flit_core
bash /sources/notpm wheel
bash /sources/notpm ninja
bash /sources/notpm meson
bash /sources/notpm coreutils
bash /sources/notpm check
bash /sources/notpm diffutils
bash /sources/notpm gawk
bash /sources/notpm findutils
bash /sources/notpm groff
NOT_DIF=".blfs" bash /sources/notpm mandoc
NOT_DIF=".blfs" bash /sources/notpm efivar
NOT_DIF=".blfs" bash /sources/notpm popt
NOT_DIF=".blfs" bash /sources/notpm efibootmgr
NOT_DIF=".blfs" bash /sources/notpm grub
bash /sources/notpm gzip
bash /sources/notpm iproute2
bash /sources/notpm kbd
bash /sources/notpm libpipeline
bash /sources/notpm make
bash /sources/notpm patch
bash /sources/notpm tar
bash /sources/notpm texinfo
bash /sources/notpm MarkupSafe
bash /sources/notpm Jinja2
NOT_DIF=".lfs-udev" bash /sources/notpm systemd
bash /sources/notpm man-db
bash /sources/notpm procps-ng
bash /sources/notpm util-linux
bash /sources/notpm e2fsprogs
bash /sources/notpm sysklogd
bash /sources/notpm sysvinit
bash /sources/notpm lfs-bootscripts
EOF
