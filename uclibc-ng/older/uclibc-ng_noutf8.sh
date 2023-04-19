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
# unifdef.c  patch?
# in latest 1.0.19 build static libs are missing? Do we need them?
# libnsl.a libnsl_pic.a libresolv.a libresolv_pic.a libuargp.a libuargp_pic.a libubacktrace_pic.a libubacktrace.a
set -e
SHELL="/ffp/bin/bash"
CONFIG_SHELL="$SHELL"
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
SOURCEDIR=/mnt/HD_a2/build10
BUILDDIR=/mnt/HD_a2/build10/tmp
SCRIPTDIR="$(dirname $(readlink -f "$0"))"
PACKAGENAME=uClibc-ng
PACKAGENAME1=uClibc-ng-solibs
VERSION="1.0.20"
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
# Apply upstream patches for 1.0.19 (later will be not needed)
# Revert changes of commit 9b1077dc70e52ee85a718bce3fcfec7ae9af2967 (brakes static builds)
#wget -nv http://cgit.uclibc-ng.org/cgi/cgit/uclibc-ng.git/patch/?id=543308f6c46cf2edf8a524bc9c631e472570fe72 -O 1.patch
#wget -nv http://cgit.uclibc-ng.org/cgi/cgit/uclibc-ng.git/patch/?id=a9a2380cf01cdae519fdaf8ab021d486c8917e43 -O 2.patch
#patch -p1 < 1.patch
#patch -p1 < 2.patch
#patch -Rp1 < ${SCRIPTDIR}/patches-${VERSION}/9b1077dc70e52ee85a718bce3fcfec7ae9af2967.patch
# uClibc-ng unlike uClibc supports expand $ORIGIN in ELF files RPATH, thus no patch is required
# Remove -Wdeclaration-after-statement to suppress this warning: ISO C90 forbids mixed declarations and code
sed -i '/\t-Wdeclaration-after-statement \\$/d' Rules.mak
# Apply patches to resolve conflict with 2.6.31.8 kernel headers and avoid redefinition
# Plus adapt ldso, ldd, lddconfig, getaddrinfo config and abi version to /ffp prefix 
for patches in ${SCRIPTDIR}/patches-${VERSION}/????-*.patch
do
	patch -p1 < $patches
done
# Apply builroot upstream patches for 1.0.20 (later will be not needed)
wget -e robots=off -nv -np -nd -r --level=1 -A patch https://git.buildroot.net/buildroot/plain/package/uclibc
for patches in "$PWD"/????-*.patch
do
	patch -p1 < $patches
done
# Correct ldconfig dir path
#sed -i 's|usr/lib|lib|g' utils/ldconfig.c
# Copy build config to sourcedir
cp -a ${SCRIPTDIR}/.config $PWD/.config
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
# Confirm silently old config
make oldconfig
# Make uClibc-ng headers and libraries, then utils
make
make utils
# Install shared libs and make uClibc-ng-solibs package first
make PREFIX=${BUILDDIR} install_runtime
cp -av lib/*.so* ${BUILDDIR}/ffp/lib/
mkdir -p ${BUILDDIR}/install
cat > ${BUILDDIR}/install/DESCR << EOF

Description of ${PACKAGENAME1}:
uClibc-ng (aka µClibc-ng/pronounced yew-see-lib-see next generation) is a C library for developing embedded
Linux systems.It is much smaller than the GNU C Library, but nearly all applications supported by glibc also work
perfectly with uClibc-ng.
NOTE:This package contains the shared libraries only.
License(s): GNU LGPL
Version:${VERSION}
Homepage:${HOMEURL}

Depends on these packages:
mz:kernel_headers-2.6.31.8

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
# Add conflict with uClibc
echo 'uClibc-solibs' > ${BUILDDIR}/install/slack-conflicts
# Since commit 2016 09 26 http://cgit.uclibc-ng.org/cgi/cgit/uclibc-ng.git/commit/?id=29ff9055c80efe77a7130767a9fcb3ab8c67e8ce
# uClibc-ng is using use a single shared libc. No more separate shared libraries are available.
# Let's make symlinks for compatibility with older builds < 1.0.17. and uClibc
cd ${BUILDDIR}/ffp/lib
for lib in libcrypt libdl libm libnsl libpthread libresolv librt libuargp libubacktrace libutil
do
	ln -s libuClibc-${VERSION}.so $lib.so
	ln -s libuClibc-${VERSION}.so $lib.so.0
done
cd ${BUILDDIR}
# Create uClibc-ng-solibs package
makepkg ${PACKAGENAME1} ${VERSION} 2
cp -a ${PKGDIR}/${PACKAGENAME1}-${VERSION}-arm-2.txz ${PKGDIRBACKUP}
cd ${SOURCEDIR}/${PACKAGENAME}-${VERSION}
# Install and make uClibc-ng package
make PREFIX=${BUILDDIR} install
make PREFIX=${BUILDDIR} install_utils
cd ${BUILDDIR}
#Correct permissions for shared libraries and libtool library files
if [ -d ${BUILDDIR}/ffp/lib ]
then
   find ${BUILDDIR}/ffp/lib -type f -iname "*.la" -exec chmod 755 {} \;
   find ${BUILDDIR}/ffp/lib -type f -iname "*.so*" -exec chmod 755 {} \;
fi
# Correct description, conflicts and required dependencies for main uClibc-ng package
sed -i 's|uClibc-solibs|uClibc|' ${BUILDDIR}/install/slack-conflicts
sed -i 's|uClibc-ng-solibs|uClibc-ng|' ${BUILDDIR}/install/DESCR
sed -i '/^NOTE:/d' ${BUILDDIR}/install/DESCR
# Create main uClibc-ng package
makepkg ${PACKAGENAME} ${VERSION} 2
cp -a ${PKGDIR}/${PACKAGENAME}-${VERSION}-arm-2.txz ${PKGDIRBACKUP}
cd
rm -rf ${SOURCEDIR}
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Compile duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"