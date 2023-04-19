#!/ffp/bin/sh

set -e
export SHELL="/ffp/bin/sh"
export CONFIG_SHELL="/ffp/bin/sh"
export PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
export TMPDIR="/mnt/HD_a2/tmp"
GNU_BUILD=arm-ffp-linux-uclibceabi
GNU_HOST=$GNU_BUILD
###Suppress deprecated functions warnings
export CPPFLAGS="-I/ffp/include -Wno-deprecated-declarations"
### Our uClibc doesn't support epoll_1 create function, so will disable it
export CXXFLAGS="-march=armv5te -O3 -DBOOST_ASIO_DISABLE_EPOLL"
export CFLAGS="-march=armv5te -O3"
BUILDDIR=/mnt/HD_a2/build/libtorrent
PACKAGENAME=libtorrent
SOURCEURL=svn://svn.code.sf.net/p/${PACKAGENAME}/code/branches/RC_1_0
#SOURCEURL=svn://svn.code.sf.net/p/${PACKAGENAME}/code/branches/RC_0_16
HOMEURL=http://www.rasterbar.com/products/libtorrent/
### Set install directory for python bindings (module)
export PYTHON_INSTALL_PARAMS="--root=${BUILDDIR}"
STARTTIME=$(date +"%s")
echo "Start point:$(date -d @${STARTTIME} +%F\ %T)"
if [ ! -d ${TMPDIR} ]; then
   mkdir -p ${TMPDIR}
fi
if [ ! -d ${BUILDDIR} ]; then
   mkdir -p ${BUILDDIR}
fi
cd ${BUILDDIR}
#Get libtorrent source code from svn repository:
#svn checkout -q ${SOURCEURL} ${PACKAGENAME}
svn checkout -q -r 10286 ${SOURCEURL} ${PACKAGENAME}
REVISION=`svn info ${BUILDDIR}/${PACKAGENAME}/|grep 'Revision:'|awk -F ' ' '{print $2}'`
VERSION=`grep 'VERSION =' ${BUILDDIR}/${PACKAGENAME}/Jamfile|awk -F ' ' '{print $3}'`_svn${REVISION}
mv ${PACKAGENAME} ${PACKAGENAME}-${VERSION}
cd ${PACKAGENAME}-${VERSION}
# Remove whitespaces at the end of row in file or autoreconf will fail
sed -i 's/ $//' test/Makefile.am
# Adapt scripts to FFP prefix
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
#run libtool and autoreconf
./autotool.sh
# Adapt scripts to FFP prefix after autoreconf
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
#correct Run-time system search path for libraries for libtool
sed -i '/$lt_ld_extra/c\    sys_lib_dlsearch_path_spec="/ffp/lib $lt_ld_extra"' configure
### Make other corrections to compile successfully
#sed -i '/^#define TORRENT_DISK_BUFFER_POOL/a\#include <boost/noncopyable.hpp>' include/libtorrent/disk_buffer_pool.hpp
### Seems like trick above is not needed anymore
###
### uClibc doesn't has function posix_fallocate so we will disable it:
### Fixes error: 'posix_fallocate' was not declared in this scope
### http://comments.gmane.org/gmane.network.bit-torrent.libtorrent/3345
sed -i 's|TORRENT_HAS_FALLOCATE 1|TORRENT_HAS_FALLOCATE 0|g' include/libtorrent/config.hpp
### Fix error: 'INT64_MAX' was not declared in this scope
### http://code.google.com/p/libtorrent/issues/detail?id=339
sed -i '/config.hpp"/i\#define __STDC_LIMIT_MACROS 1' src/utp_stream.cpp
sed -i '/cstdint.hpp>/a\#include <stdint.h>' src/utp_stream.cpp
sed -i '/config.hpp"/i\#define __STDC_LIMIT_MACROS 1' src/lazy_bdecode.cpp
sed -i '/cstring>/a\#include <stdint.h>' src/lazy_bdecode.cpp
##### Disable utp to improve speed of downloading and maybe seeding?
sed -i 's|enable_incoming_utp(true)|enable_incoming_utp(false)|g' src/session.cpp
sed -i 's|enable_outgoing_utp(true)|enable_outgoing_utp(false)|g' src/session.cpp
#####
#Mijzelf's epoll_1 hack is not working, better use instead CXXFLAGS=-DBOOST_ASIO_DISABLE_EPOLL
#cp /mnt/HD_a2/ffp0.7arm/scripts/deluge/web_connection_base.cpp ${BUILDDIR}/${PACKAGENAME}-${VERSION}/src/
./configure \
	--build=$GNU_BUILD \
	--host=$GNU_HOST \
	--prefix=/ffp \
	--exec-prefix=/ffp \
	--enable-shared \
	--disable-static \
	--with-libgeoip \
	--with-libiconv \
	--enable-python-binding \
	--with-boost=/ffp \
	--with-openssl=/ffp
colormake
colormake install DESTDIR=${BUILDDIR}
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

Description of ${PACKAGENAME}:
Libtorrent is a feature complete C++ bittorrent implementation, focusing on efficiency and
scalability. It runs on embedded devices as well as desktops. It boasts a well documented 
library interface that is easy to use.The main goals of libtorrent are:
	#to be cpu efficient
	#to be memory efficient
	#to be very easy to use
License:BSD
Version:${VERSION}
Homepage:${HOMEURL}

Depends on these packages:
br2:geoip br2:boost br2:libiconv br2:python-2.7.* br2:gcc-solibs s:openssl s:zlib
br2:uClibc-solibs

EOF
echo ${HOMEURL} > ${BUILDDIR}/install/HOMEPAGE
cd ${BUILDDIR}
rm -rf ${BUILDDIR}/${PACKAGENAME}-*
# Remove unused docs
if [ -d ${BUILDDIR}/ffp/share/doc ]; then
   rm -rf ${BUILDDIR}/ffp/share/doc
fi
# Correct permissions for shared libraries and libtool library files
if [ -d ${BUILDDIR}/ffp/lib ]; then
   find ${BUILDDIR}/ffp/lib -type f -iname "*.la" -exec chmod 755 {} \;
   find ${BUILDDIR}/ffp/lib -type f -iname "*.so*" -exec chmod 755 {} \;
fi
# Adapt scripts to FFP prefix before making package
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
makepkg ${PACKAGENAME} ${VERSION} 1
if [ ! -d "/mnt/HD_a2/ffp0.7arm/packages/deluge" ]; then
    mkdir -p /mnt/HD_a2/ffp0.7arm/packages/deluge
fi
if [ ! -d "/ffp/funpkg/additional/deluge" ]; then
    mkdir -p /ffp/funpkg/additional/deluge
fi
cp /tmp/${PACKAGENAME}-${VERSION}-arm-1.txz /mnt/HD_a2/ffp0.7arm/packages/deluge/
mv /tmp/${PACKAGENAME}-${VERSION}-arm-1.txz /ffp/funpkg/additional/deluge/
cd
rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Compile duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"