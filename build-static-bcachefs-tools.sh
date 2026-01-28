#! /bin/bash

set -e

WORKSPACE=/tmp/workspace
mkdir -p $WORKSPACE
mkdir -p /work/artifact

HOST_OS=$(uname -s)
HOST_ARCH=$(uname -m)

# keyutils
cd $WORKSPACE
curl https://git.kernel.org/pub/scm/linux/kernel/git/dhowells/keyutils.git/snapshot/keyutils-1.6.3.tar.gz | tar x --gzip
cd keyutils-1.6.3
sed -i '' '/keyctl_restrict/d' ./version.lds
sed -i '' '/keyctl_dh_compute_kdf_alloc;/d' ./version.lds
sed -i "" -e 's@-Werror@-Wno-error@g' ./Makefile
LDFLAGS="${LDFLAGS} -Wl,--undefined-version" make
make LIBDIR=/usr/lib BINDIR=/usr/bin SBINDIR=/usr/sbin install

#fuse
cd $WORKSPACE
curl -sL https://github.com/libfuse/libfuse/releases/download/fuse-3.18.0/fuse-3.18.0.tar.gz | tar x --gzip
cd fuse-3.18.0
curl -sL https://gitlab.alpinelinux.org/alpine/aports/-/raw/master/main/fuse3/dont-mknod-dev-fuse.patch | patch -p1
curl -sL https://gitlab.alpinelinux.org/alpine/aports/-/raw/master/main/fuse3/mount_util.c-check-if-utab-exists-before-update.patch | patch -p1
curl -sL https://gitlab.alpinelinux.org/alpine/aports/-/raw/master/main/fuse3/workaround-the-lack-of-support-for-rename2-in-musl.patch | patch -p1
mkdir build
cd build
meson setup --buildtype=release -Ddefault_library=static -Dprefix=/usr ..
ninja
ninja install

# bcachefs-tools
cd $WORKSPACE
git clone https://github.com/koverstreet/bcachefs-tools.git
cd bcachefs-tools
sed -i "" -e '3s@PREFIX?=/usr/local$@PREFIX?=/usr/local/bcachefsmm@' ./Makefile
sed -i "" -e '37s@std=gnu11@std=gnu23 -Wno-incompatible-function-pointer-types@' ./Makefile
LDFLAGS="-static --static -no-pie -s" BCACHEFS_FUSE=1 make libbcachefs.a
cd libbcachefs
RUSTFLAGS="-C target-feature=+crt-static -C linker=clang -C strip=symbols -C opt-level=s" cargo build --target ${HOST_ARCH}-chimera-linux-musl --release
cd ../target/${HOST_ARCH}-chimera-linux-musl/release/
tar vcJf ./bcachefs.tar.xz bcachefs
mv ./bcachefs.tar.xz /work/artifact/
