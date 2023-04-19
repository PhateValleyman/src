#!/ffp/bin/sh

#http://lists.uclibc.org/pipermail/uclibc/2011-February/044822.html
#http://ftp.osuosl.org/pub/manulix/scripts/build-scripts/PATCHCMDS/
#http://lists.uclibc.org/pipermail/uclibc-cvs/2011-September/029861.html
#http://stackoverflow.com/questions/602912/how-do-you-echo-a-4-digit-unicode-character-in-bash
#http://repo.or.cz/w/glibc.git/blob_plain/1b188a651ec0af5dad0f368afdc6fdfbfd8dfce2:/localedata/charmaps/KOI8-RU
#http://www.tldp.org/HOWTO/Danish-HOWTO-5.html

# Some info and patches
#http://gentoo.cs.nctu.edu.tw/gentoo-portage/sys-libs/uclibc-ng/
#https://git.buildroot.net/buildroot/tree/package/uclibc
#https://github.com/Optware/Optware-ng/tree/master/sources/buildroot-armv5eabi-ng-legacy
#https://github.com/Entware-ng/Entware-ng/tree/master/toolchain/uClibc


# TODO
# in latest 1.0.22 build some of static libs are missing? Do we need them?
# libuargp.a libuargp_pic.a libubacktrace_pic.a libubacktrace.a

set -e
unset CPPFLAGS CFLAGS CXXFLAGS LDFLAGS
SHELL="/ffp/bin/sh"
CONFIG_SHELL="$SHELL"
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
SOURCEDIR=/mnt/HD_a2/build
BUILDDIR=/mnt/HD_a2/build/tmp
SCRIPTDIR="$(dirname $(readlink -f "$0"))"
PACKAGENAME=uClibc-ng
PACKAGENAME1=uClibc-ng-solibs
VERSION="1.0.17"
SOURCEURL="http://downloads.uclibc-ng.org/releases/${VERSION}/${PACKAGENAME}-${VERSION}.tar.xz"
HOMEURL=http://www.uclibc-ng.org/
PKGDIR="/mnt/HD_a2/ffp0.7arm/packages/${PACKAGENAME}"
PKGDIRBACKUP="/ffp/funpkg/additional/${PACKAGENAME}"
export PATH CONFIG_SHELL SHELL PKGDIR
STARTTIME=$(date +"%s")
echo "Start point:$(date -d @${STARTTIME} +%F\ %T)"
for dir in ${BUILDDIR} ${PKGDIR} ${PKGDIRBACKUP}
do
	if [ ! -d "$dir" ]
	then
	   mkdir -p "$dir"
	fi
done
cd ${SOURCEDIR}
wget -nvc ${SOURCEURL}
tar xf ${PACKAGENAME}-${VERSION}.tar.xz
cd ${PACKAGENAME}-${VERSION}
# uClibc-ng unlike uClibc supports expand $ORIGIN in ELF files RPATH, thus no patch is required
# Remove -Wdeclaration-after-statement to suppress this warning: ISO C90 forbids mixed declarations and code
sed -i '/\t-Wdeclaration-after-statement \\$/d' Rules.mak
# Apply patches to resolve conflict with 2.6.31.8 kernel headers and avoid redefinition
# Plus adapt ldso, ldd, lddconfig, getaddrinfo config and abi version to /ffp prefix 
for patches in ${SCRIPTDIR}/patches-${VERSION}/????-*.patch
do
	patch -p1 < $patches
done
# Apply builroot upstream patches for 1.0.22 (later will be not needed)
#wget -e robots=off -nv -np -nd -r --level=1 -A patch https://git.buildroot.net/buildroot/plain/package/uclibc
#for patches in "$PWD"/????-*.patch
#do
#	patch -p1 < $patches
#done
# Revert back removal of obstack support in 1.0.21 (we need it until the packages using it will be rebuilt)
#wget -nv 'http://repo.or.cz/uclibc-ng.git/patch/6d4d6e2cfc6b7ea247adca2d3ae137a68c4e5148' -O revert_obstack_removal1.patch
#wget -nv 'http://repo.or.cz/uclibc-ng.git/patch/0bd6bfb2b643ea2b4b1440dfd917ba752f0c0d15' -O revert_obstack_removal2.patch
#patch -Rp1 < revert_obstack_removal1.patch
#patch -Rp1 < revert_obstack_removal2.patch
# Correct ldconfig dir path (unneeded, because of 0003-ldso.patch)
#sed -i 's|usr/lib|lib|g' utils/ldconfig.c
# Adapt executables to FFP prefix
find . -type f -iname "config.*" -exec sed -i -r 's/^#! ?\/bin\/sh/#!\/ffp\/bin\/sh/' {} \;
find . -type f -iname "config.*" -exec sed -i -r 's/^#! ?\/bin\/bash/#!\/ffp\/bin\/bash/' {} \;
find . -type f -iname "config.*" -exec sed -i -r 's/^#! ?\/usr\/bin\/env/#!\/ffp\/bin\/env/' {} \;
find . -type f -iname "configure" -exec sed -i -r 's/^#! ?\/bin\/sh/#!\/ffp\/bin\/sh/' {} \;
find . -type f -iname "configure" -exec sed -i -r 's/^#! ?\/bin\/bash/#!\/ffp\/bin\/bash/' {} \;
find . -type f -iname "configure" -exec sed -i -r 's/^#! ?\/usr\/bin\/env/#!\/ffp\/bin\/env/' {} \;
find . -type f -executable -exec sed -i -r 's/^#! ?\/bin\/sh/#!\/ffp\/bin\/sh/' {} \;
find . -type f -executable -exec sed -i -r 's/^#! ?\/bin\/bash/#!\/ffp\/bin\/bash/' {} \;
find . -type f -executable -exec sed -i -r 's/^#! ?\/usr\/bin\/env/#!\/ffp\/bin\/env/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/usr\/bin\/python/#!\/ffp\/bin\/python/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/usr\/bin\/env/#!\/ffp\/bin\/env/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/bin\/python/#!\/ffp\/bin\/python/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/bin\/env/#!\/ffp\/bin\/env/' {} \;
find . -type f -iname "*.pl*" -exec sed -i -r 's/^#! ?\/usr\/bin\/perl/#!\/ffp\/bin\/perl/' {} \;
find . -type f -iname "*.pl*" -exec sed -i -r 's/^#! ?\/usr\/bin\/env/#!\/ffp\/bin\/env/' {} \;
find . -type f -iname "*.pl*" -exec sed -i -r 's/^#! ?\/bin\/perl/#!\/ffp\/bin\/perl/' {} \;
find . -type f -iname "*.pl*" -exec sed -i -r 's/^#! ?\/bin\/env/#!\/ffp\/bin\/env/' {} \;
# Adapt hardcoded paths
sed -i 's|":/bin:/usr/bin";|":/ffp/bin:/bin:/usr/bin";|' librt/spawn.c libc/unistd/exec.c
sed -i 's|"/bin:/usr/bin"|"/ffp/bin:/bin:/usr/bin"|' libc/unistd/confstr.c
sed -i 's|/usr/include/asm/unistd.h|/ffp/include/asm/unistd.h|' libc/sysdeps/linux/sh/sysdep.h
sed -i 's|/usr/include/asm/unistd.h|/ffp/include/asm/unistd.h|' libc/sysdeps/linux/arm/sysdep.h
sed -i 's|"/usr/bin:/bin"|"/ffp/bin:/usr/bin:/bin"|' include/paths.h
sed -i 's|"/usr/bin:/bin:/usr/sbin:/sbin"|"/ffp/bin:/ffp/sbin:/usr/bin:/bin:/usr/sbin:/sbin"|' include/paths.h
sed -i 's|"/usr/share/man"|"/ffp/share/man"|' include/paths.h
sed -i 's|"/usr/bin/vi"|"/ffp/bin/vi"|' include/paths.h
sed -i 's|"/usr/sbin/sendmail"|"/ffp/sbin/sendmail"|' include/paths.h
sed -i 's|/usr/include/iconv.h|/ffp/include/iconv.h|' extra/locale/Makefile.in
sed -i 's|/usr/|/ffp/|g' extra/config/Makefile.kconfig extra/scripts/relinfo.pl
sed -i 's|/usr/|/ffp/|g' extra/config/lxdialog/check-lxdialog.sh
sed -i 's|/usr/|/ffp/|g' extra/scripts/MAKEALL
sed -i 's|"/usr/share/locale"|"/ffp/share/locale"|' extra/config/lkc.h
sed -i 's|PATH="/bin:/usr/bin"|PATH="/ffp/bin:/bin:/usr/bin"|' extra/scripts/getent
sed -i 's|PATH="${PATH}:/bin:/usr/bin"|PATH="${PATH}":/ffp/bin:/bin:/usr/bin"|' extra/scripts/getent
# Copy build config to sourcedir
cp -a ${SCRIPTDIR}/.config_1.0.17 $PWD/.config
# Confirm silently old config
make oldconfig
# Make uClibc-ng headers and libraries, then utils
make
make utils
# Install shared libs and make uClibc-ng-solibs package first
make PREFIX=${BUILDDIR} install_runtime
##The following copy command installs some of symlinks and libc.so solib additionally:
# ld-uClibc.so -> ld-uClibc-1.0.22.so
# libc.so
# libthread_db.so -> libthread_db-1.0.22.so
##Do we really need them for runtime solibs package?
cp -av lib/*.so* ${BUILDDIR}/ffp/lib/
mkdir -p ${BUILDDIR}/install
cat > ${BUILDDIR}/install/DESCR << EOF

Description of ${PACKAGENAME1}:
uClibc-ng (aka µClibc-ng/pronounced yew-see-lib-see next generation) is a C library for developing embedded
Linux systems.It is much smaller than the GNU C Library, but nearly all applications supported by glibc also work
perfectly with uClibc-ng.
NOTE: This package contains the shared runtime libraries only.
License(s): GNU LGPL
Version: ${VERSION}
Homepage: ${HOMEURL}

Depends on these packages:
br2:kernel-headers-2.6.31.8

IMPORTANT NOTICE: Fully compatible with Zyxel NSA 3** series NAS'es.
Other devices with kernel different from 2.6.31.8 are only partly compatible.
This release doesn't has UTF-8 locales support.

EOF
echo ${HOMEURL} >> ${BUILDDIR}/install/HOMEPAGE
cat > ${BUILDDIR}/install/doinst.sh << 'EOF'
#!/ffp/bin/sh
echo -e "\e[1;34;42mIMPORTANT NOTICE: Fully compatible with Zyxel NSA 3** series NAS'es.\e[0m"
echo -e "\e[1;31;21mOther devices with kernel different from 2.6.31.8 are only partly compatible.\e[0m"
echo -e "\e[1;31;21mThis release doesn't has UTF-8 locales support.\e[0m"
EOF
chmod 755 ${BUILDDIR}/install/doinst.sh
cd ${BUILDDIR}
#Correct permissions for shared libraries and libtool library files
if [ -d ${BUILDDIR}/ffp/lib ]
then
   find ${BUILDDIR}/ffp/lib -type f -iname "*.la" -exec chmod 755 {} \;
   find ${BUILDDIR}/ffp/lib -type f -iname "*.so*" -exec chmod 755 {} \;
fi
# Add conflict with uClibc and uClibc-solibs
cat > ${BUILDDIR}/install/slack-conflicts << 'EOF'
uClibc
uClibc-solibs
EOF
cd ${BUILDDIR}
# Create uClibc-ng-solibs package first
makepkg uClibc-solibs ${VERSION} 1
cp -a ${PKGDIR}/uClibc-solibs-${VERSION}-arm-1.txz ${PKGDIRBACKUP}
cd ${SOURCEDIR}/${PACKAGENAME}-${VERSION}
# Install and make uClibc-ng package
make PREFIX=${BUILDDIR} install
make PREFIX=${BUILDDIR} install_utils
# Install getent utility
cp -av extra/scripts/getent ${BUILDDIR}/ffp/bin/
cd ${BUILDDIR}
#Correct permissions for shared libraries and libtool library files
if [ -d ${BUILDDIR}/ffp/lib ]
then
   find ${BUILDDIR}/ffp/lib -type f -iname "*.la" -exec chmod 755 {} \;
   find ${BUILDDIR}/ffp/lib -type f -iname "*.so*" -exec chmod 755 {} \;
fi
# Correct description and required dependencies for main uClibc-ng package
echo 'uClibc-ng-solibs' > ${BUILDDIR}/install/slack-required
sed -i 's|uClibc-ng-solibs|uClibc-ng|' ${BUILDDIR}/install/DESCR
sed -i '/^NOTE:/d' ${BUILDDIR}/install/DESCR
# Rebuild ld.so.cache right after installing package 
cat > ${BUILDDIR}/install/doinst.sh << 'EOF'
#!/ffp/bin/sh
# Rebuild ld.so.cache after installing
if	[ -f /ffp/etc/ld.so.cache ]
then
	if	[ -x /ffp/sbin/ldconfig ]
	then
		/ffp/sbin/ldconfig
	fi
fi
echo -e "\e[1;34;42mIMPORTANT NOTICE: Fully compatible with Zyxel NSA 3** series NAS'es.\e[0m"
echo -e "\e[1;31;21mOther devices with kernel different from 2.6.31.8 are only partly compatible.\e[0m"
echo -e "\e[1;31;21mThis release doesn't has UTF-8 locales support.\e[0m"
EOF
chmod 755 ${BUILDDIR}/install/doinst.sh
# Create main uClibc-ng package
makepkg uClibc ${VERSION} 1
cp -a ${PKGDIR}/uClibc-${VERSION}-arm-1.txz ${PKGDIRBACKUP}
cd
rm -rf ${SOURCEDIR}
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Compile duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"