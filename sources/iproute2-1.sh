sed '/SUBDIRS/s/=.*/=lib ip/' -i Makefile
PKG_CONFIG=false make
cp ip/ip /usr/bin
ip link set lo up
ip addr
