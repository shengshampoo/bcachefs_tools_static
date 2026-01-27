FROM chimeralinux/chimera


RUN apk update
RUN apk upgrade

RUN apk add --no-cache \
 linux-headers musl-devel musl-devel-static \
 git curl cmake gmake zlib-ng-compat-devel zlib-ng-compat-devel-static \
 openssl3-devel openssl3-devel-static clang clang-devel clang-devel-static \
 libunwind-devel libunwind-devel-static libatomic-chimera-devel libatomic-chimera-devel-static \
 libarchive-progs libgcc-chimera cargo rust rust-src rust-std \
 libaio-devel libaio-devel-static lz4-devel lz4-devel-static \
 zstd-devel zstd-devel-static udev-devel udev-devel-static \
 util-linux-blkid-devel util-linux-blkid-devel-static \
 libsodium-devel libsodium-devel-static userspace-rcu-devel userspace-rcu-devel-static \
 util-linux-uuid-devel util-linux-uuid-devel-static pkgconf \
 fuse fuse-devel fuse-devel-static jq bash xz file


RUN ln -s /usr/lib/libgcc_s.so.1 /usr/lib/libgcc_s.so
RUN ln -s /usr/sbin/cc /usr/sbin/musl-gcc

ENV RUSTFLAGS="-C target-feature=+crt-static -C linker=clang -C strip=symbols -C opt-level=s" 
ENV CARGO_TARGET_X86_64_UNKNOWN_LINUX_MUSL_LINKER=clang
ENV CARGO_TARGET_AARCH64_UNKNOWN_LINUX_MUSL_LINKER=clang
ENV XZ_OPT=-e9

COPY build-static-bcachefs-tools.sh build-static-bcachefs-tools.sh
RUN chmod +x ./build-static-bcachefs-tools.sh
RUN bash ./build-static-bcachefs-tools.sh
