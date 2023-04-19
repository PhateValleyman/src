#!/ffp/bin/sh

set -e
export CXXFLAGS="-march=armv5te -O3 -DBOOST_ASIO_DISABLE_EPOLL"
#export TMPDIR="/mnt/HD_a2/tmp"
export SHELL="/ffp/bin/sh"
SOURCEDIR=/mnt/HD_a2/build/libtorrent
export PYTHON_INSTALL_PARAMS="--root=${SOURCEDIR}"
SOURCEURL=http://libtorrent.googlecode.com/files/libtorrent-rasterbar-0.16.11.tar.gz
HOMEURL=http://www.rasterbar.com/products/libtorrent/
PACKAGENAME=libtorrent
VERSION=`echo ${SOURCEURL}|awk -F'-' '{print $3}'|cut -f1,2,3 -d'.'`
if [ ! -d ${TMPDIR} ]; then
   mkdir -p ${TMPDIR}
fi
if [ ! -d ${SOURCEDIR} ]; then
   mkdir -p ${SOURCEDIR}
fi
cd ${SOURCEDIR}
wget ${SOURCEURL} -O ${PACKAGENAME}-${VERSION}.tar.gz
tar xvzf ${PACKAGENAME}-${VERSION}.tar.gz --transform=s"|${PACKAGENAME}-`echo ${SOURCEURL}|awk -F'-' '{print $2}'`-${VERSION}|${PACKAGENAME}-${VERSION}|"
cd ${PACKAGENAME}-${VERSION}
#adapt executables to FFP prefix
find . -type f -iname "config.rpath" -exec sed -i -r 's/^#! ?\/bin\/sh/#!\/ffp\/bin\/sh/' {} \;
find . -type f -executable -exec sed -i -r 's/^#! ?\/bin\/sh/#!\/ffp\/bin\/sh/' {} \;
find . -type f -executable -exec sed -i -r 's/^#! ?\/bin\/bash/#!\/ffp\/bin\/bash/' {} \;
find . -type f -executable -exec sed -i -r 's/^#! ?\/usr\/bin\/env bash/#!\/ffp\/bin\/env bash/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/usr\/bin\/python/#!\/ffp\/bin\/python/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/usr\/bin\/env/#!\/ffp\/bin\/env/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/bin\/python/#!\/ffp\/bin\/python/' {} \;
find . -type f -iname "*.py*" -exec sed -i -r 's/^#! ?\/bin\/env/#!\/ffp\/bin\/env/' {} \;
find . -type f -iname "*.pl*" -exec sed -i -r 's/^#! ?\/usr\/bin\/perl/#!\/ffp\/bin\/perl/' {} \;
find . -type f -executable -exec sed -i -r 's/^#! ?\/usr\/bin\/env perl/#!\/ffp\/bin\/env perl/' {} \;
#correct Run-time system search path for libraries for libtool
sed -i '/$lt_ld_extra/c\    sys_lib_dlsearch_path_spec="/ffp/lib $lt_ld_extra"' configure
#make other corrections to compile successfully
sed -i '/^#define TORRENT_DISK_BUFFER_POOL/a\#include <boost/noncopyable.hpp>' include/libtorrent/disk_buffer_pool.hpp
sed -i 's|TORRENT_HAS_FALLOCATE 1|TORRENT_HAS_FALLOCATE 0|g' include/libtorrent/config.hpp
sed -i '/config.hpp"/i\#define __STDC_LIMIT_MACROS 1' src/utp_stream.cpp
sed -i '/cstdint.hpp>/a\#include <stdint.h>' src/utp_stream.cpp
#Mijzelf's epool hack is not working, better use instead CXXFLAGS=-DBOOST_ASIO_DISABLE_EPOLL
#cp /mnt/HD_a2/ffp0.7arm/scripts/deluge/web_connection_base.cpp ${SOURCEDIR}/${PACKAGENAME}-${VERSION}/src/
#to build successfully  with enable-debug option, patch is needed
#cp /mnt/HD_a2/ffp0.7arm/scripts/deluge/libtorrent.patch ${SOURCEDIR}/${PACKAGENAME}-${VERSION}
#patch -Np0 -i libtorrent.patch
./configure --prefix=/ffp --exec-prefix=/ffp --with-libgeoip --enable-shared --disable-static --with-libiconv --enable-python-binding --with-boost=/ffp
colormake
colormake install DESTDIR=${SOURCEDIR}
mkdir -p ${SOURCEDIR}/install
echo "" >> ${SOURCEDIR}/install/DESCR
echo "Description of ${PACKAGENAME}:" >> ${SOURCEDIR}/install/DESCR
echo "Libtorrent is a feature complete C++ bittorrent implementation, focusing on efficiency" >> ${SOURCEDIR}/install/DESCR
echo "and scalability. It runs on embedded devices as well as desktops. It boasts a well" >> ${SOURCEDIR}/install/DESCR
echo "documented library interface that is easy to use.The main goals of libtorrent are:" >> ${SOURCEDIR}/install/DESCR
echo "   #to be cpu efficient" >> ${SOURCEDIR}/install/DESCR
echo "   #to be memory efficient" >> ${SOURCEDIR}/install/DESCR
echo "   #to be very easy to use" >> ${SOURCEDIR}/install/DESCR
echo "Version:${VERSION}" >> ${SOURCEDIR}/install/DESCR
echo "Homepage:${HOMEURL}" >> ${SOURCEDIR}/install/DESCR
echo "" >> ${SOURCEDIR}/install/DESCR
echo "Requires libraries from: gcc-solibs geoip boost-1.54.0 libiconv-1.14 openssl python-2.7.5 uClibc-solibs zlib" >> ${SOURCEDIR}/install/DESCR
echo "" >> ${SOURCEDIR}/install/DESCR
echo ${HOMEURL} > ${SOURCEDIR}/install/HOMEPAGE
cd ${SOURCEDIR}
rm -rf ${SOURCEDIR}/${PACKAGENAME}-*
if [ -d ${SOURCEDIR}/ffp/share/doc ]; then
   rm -rf ${SOURCEDIR}/ffp/share/doc
fi
#Correct permissions for shared libraries and libtool library files
if [ -d ${SOURCEDIR}/ffp/lib ]; then
   find ${SOURCEDIR}/ffp/lib -type f -iname "*.la" -exec chmod 755 {} \;
   find ${SOURCEDIR}/ffp/lib -type f -iname "*.so*" -exec chmod 755 {} \;
fi
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
rm -rf ${SOURCEDIR}