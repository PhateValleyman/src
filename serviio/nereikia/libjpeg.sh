#!/ffp/bin/sh

set -e
export TMPDIR=/mnt/HD_a2/tmp
SOURCEDIR=/mnt/HD_a2/build/libjpeg
SOURCEURL=http://www.ijg.org/files/jpegsrc.v9e.tar.gz
HOMEURL=http://www.ijg.org/
PACKAGENAME=jpeg
LIBNAME=libjpeg
SOURCEFILE=`echo ${SOURCEURL}|awk -F'/' '{print $5}'`
VERSION=9

if [ ! -d ${TMPDIR} ]; then
   mkdir -p ${TMPDIR}
fi
if [ ! -d ${SOURCEDIR} ]; then
   mkdir -p ${SOURCEDIR}
fi
cd ${SOURCEDIR}
wget ${SOURCEURL}
tar xvzf ${SOURCEFILE}
cd ${PACKAGENAME}-${VERSION}e
sed -i 's/^#!.*$/#!\/ffp\/bin\/sh/g' config.guess config.sub configure depcomp install-sh missing
# correct Run-time system search path for libraries for libtool
sed -i '/$lt_ld_extra/c\    sys_lib_dlsearch_path_spec="/ffp/lib $lt_ld_extra"' configure
# correct jmorecfg.h bug
#wget http://scottlab.ucsc.edu/fink_intel_10.6_64bit_sw/10.6/stable/main/finkinfo/graphics/libjpeg9.patch
#patch -p1 < libjpeg9.patch
./configure --prefix=/ffp --enable-shared --disable-static
colormake
colormake install DESTDIR=${SOURCEDIR}
mkdir -p ${SOURCEDIR}/install
touch ${SOURCEDIR}/install/DESCR
touch ${SOURCEDIR}/install/HOMEPAGE
echo "The libjpeg package contains libraries that allow compression of image files based on" > ${SOURCEDIR}/install/DESCR
echo "the Joint Photographic Experts Group standard. It is a "lossy" compression algorithm." >> ${SOURCEDIR}/install/DESCR
echo ${HOMEURL} >> ${SOURCEDIR}/install/DESCR
echo ${HOMEURL} > ${SOURCEDIR}/install/HOMEPAGE
cd ${SOURCEDIR}
rm -rf ${SOURCEDIR}/${PACKAGENAME}*
if [ -d ${SOURCEDIR}/ffp/share/doc ]; then
   rm -rf ${SOURCEDIR}/ffp/share/doc
fi
makepkg ${LIBNAME} ${VERSION} 0
if [ ! -d "/mnt/HD_a2/ffp0.7arm/packages/serviio" ]; then
    mkdir -p /mnt/HD_a2/ffp0.7arm/packages/serviio
fi
if [ ! -d "/ffp/funpkg/additional/serviio" ]; then
    mkdir -p /ffp/funpkg/additional/serviio
fi
cp /tmp/${LIBNAME}-${VERSION}-arm-0.txz /mnt/HD_a2/ffp0.7arm/packages/serviio/
mv /tmp/${LIBNAME}-${VERSION}-arm-0.txz /ffp/funpkg/additional/serviio/
cd
rm -rf ${SOURCEDIR}
