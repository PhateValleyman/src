#!/ffp/bin/bash

set -e
unset CXXFLAGS CFLAGS LDFLAGS CPPFLAGS
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
GNU_BUILD=arm-ffp-linux-uclibcgnueabi
GNU_HOST="$GNU_BUILD"
BUILDDIR=/mnt/HD_a2/build
PACKAGENAME=libass
VERSION="0.13.6"
SOURCEURL=https://github.com/${PACKAGENAME}/${PACKAGENAME}/releases/download/${VERSION}/${PACKAGENAME}-${VERSION}.tar.xz 
HOMEURL=https://github.com/libass/libass/
PKGDIR="/mnt/HD_a2/ffp0.7arm/packages/ffmpeg3"
PKGDIRBACKUP="/ffp/funpkg/additional/ffmpeg3"
export PATH PKGDIR
STARTTIME=$(date +"%s")
echo "Start point:$(date -d @${STARTTIME} +%F\ %T)"
# Create build and pkgs directories, if required
for DIR in ${BUILDDIR} ${PKGDIR} ${PKGDIRBACKUP}
do
	if [ ! -d ${DIR} ]
	then
		mkdir -p ${DIR}
	fi
done
cd ${BUILDDIR}
wget -nv ${SOURCEURL}
tar xf "${SOURCEURL##*/}"
cd ${PACKAGENAME}-${VERSION}
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
./configure \
	--prefix=/ffp \
	--build="$GNU_BUILD" \
	--host="$GNU_HOST" \
	--enable-static \
	--enable-shared
make
#make check
make install DESTDIR=${BUILDDIR}
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

libass is a portable subtitle renderer for the ASS/SSA (Advanced Substation Alpha/Substation Alpha)
subtitle format that allows for more advanced subtitles than the conventional SRT and similar formats.  
License: BSD
Version: ${VERSION}
Homepage: ${HOMEURL}

EOF
echo ${HOMEURL} > ${BUILDDIR}/install/HOMEPAGE
cd ${BUILDDIR}
rm -rf ${BUILDDIR}/${PACKAGENAME}-*
# Remove unused docs
if [ -d ${BUILDDIR}/ffp/share/doc ]
then
   rm -rf ${BUILDDIR}/ffp/share/doc
fi
# Correct permissions for shared libraries and libtool library files
if [ -d ${BUILDDIR}/ffp/lib ]
then
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
# Generate direct dependencies list for packages.html and slapt-get
gendeps ${BUILDDIR}/ffp
# Remove package itself from dependencies requirements
sed -i "s|\<${PACKAGENAME}\> ||" ${BUILDDIR}/install/DEPENDS
sed -i "/^${PACKAGENAME}$/d" ${BUILDDIR}/install/slack-required
makepkg ${PACKAGENAME} ${VERSION} 1
cp -a ${PKGDIR}/${PACKAGENAME}-${VERSION}-arm-1.txz ${PKGDIRBACKUP}
cd
rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Compile duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"