#!/ffp/bin/sh

# For further java 9? version build, this script requires some corrections.
# It contains workarounds for currently used bootstrap archlinux JDK 7
# and needs to be cleaned when native ffp openjdk8 will be used for future openjdk9 version building.   
set -e
unset JAVA_HOME
unset CFLAGS
unset CXXFLAGS
unset LDFLAGS
LD_RUN_PATH="/ffp/lib"
PATH="/ffp/opt/java/java-7-openjdk/bin:/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
GNU_BUILD=arm-ffp-linux-uclibceabi
GNU_HOST=$GNU_BUILD
BUILDDIR=/mnt/HD_a2/build/openjdk
SCRIPTDIR="$(dirname $(readlink -f "$0"))"
PACKAGENAME=openjdk
VERSION="8.40.25"
SOURCEVERSION=jdk8u40-b25
SOURCEURL=http://hg.openjdk.java.net/jdk8u/jdk8u/archive/${SOURCEVERSION}.tar.gz
HOMEURL=openjdk.java.net
PKGDIR="/mnt/HD_a2/ffp0.7arm/packages/serviio"
PKGDIRBACKUP="/ffp/funpkg/additional/serviio"
export PATH PKGDIR LD_RUN_PATH
STARTTIME=$(date +"%s")
#### Apply patches for uclibc first to be done##########################
echo "Start point:$(date -d @${STARTTIME} +%F\ %T)"
# Create new swap space
newswapfile="/i-data/3776680e/.zyxel/nsa310swapfile"
oldswapfile="/i-data/3776680e/.zyxel/swap_ul6545p"
if	[ -f $newswapfile ]; then
	if	[ "$(cat /proc/swaps | awk 'NR == 2 {print $1}')" = "$oldswapfile" ]; then
		swapon $newswapfile
		swapoff $oldswapfile
	fi
else
	# Create 1 GB swap file
	dd if=/dev/zero of=$newswapfile bs=1M count=1024
	mkswap $newswapfile
	swapon $newswapfile
	swapoff $oldswapfile
fi
echo "Current swapfile in use is:"
swapon -s
# Create build and pkgs directories, if required
for DIR in ${BUILDDIR} ${PKGDIR} ${PKGDIRBACKUP}; do
	if [ ! -d ${DIR} ]; then
		mkdir -p ${DIR}
	fi
done
cd ${BUILDDIR}
cd ${PACKAGENAME}-${VERSION}
LD_LIBRARY_PATH="/lib:/usr/lib:/usr/local/lib:/usr/local/zy-pkgs/lib:/ffp/lib" make V=1 DEBUG_BINARIES=true images
#It is not good idea to build with DEBUG_BINARIES=true, avoid it us much as you can
#LD_LIBRARY_PATH="/lib:/usr/lib:/usr/local/lib:/usr/local/zy-pkgs/lib:/ffp/lib" make DEBUG_BINARIES=true all CONF=linux-arm-normal-zero-release
exit 0
##### TO do correct permissions and copy to required places 2 packages
#make install DESTDIR=${BUILDDIR}
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

Description of $PACKAGENAME:
OpenJDK is an open-source implementation of Oracle's Java Standard Edition platform. OpenJDK is 
useful for developing Java programs, and provides a complete runtime environment to run Java programs.
License:ASL 1.1 and ASL 2.0 and GPL+ and GPLv2 and GPLv2 with exceptions and LGPL+ and LGPLv2
and MPLv1.0 and MPLv1.1 and Public Domain and W3C
Version:${VERSION}
Homepage:${HOMEURL}

Depends on these packages:
br2:alsa-lib br2:util-macros br2:xproto-headers br2:libXau br2:libXdmcp br2:xcb-proto br2:libxcb
br2:fontconfig br2:freetype br2:expat br2:gettext br2:libiconv br2:libffi br2:gcc-solibs br2:uClibc-solibs
s:util-linux s:giflib s:bzip2 s:zlib

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
# Get ca-bundle for ssl module
mkdir -p ${BUILDDIR}/ffp/etc/ssl/certs
wget -nv http://curl.haxx.se/ca/cacert.pem -O ${BUILDDIR}/ffp/etc/ssl/certs/cacert.pem
# Create postinstall script to remove old cert.pem
CHECKSUM=$(md5sum ${BUILDDIR}/ffp/etc/ssl/certs/cacert.pem|awk '{print $1}')
cat > ${BUILDDIR}/install/doinst.sh << EOF
#!/ffp/bin/sh

if [ -f /ffp/etc/ssl/certs/cacert.pem.new ] && [ \$(md5sum /ffp/etc/ssl/certs/cacert.pem.new|awk '{print \$1}') = $CHECKSUM ]; then
   mv /ffp/etc/ssl/certs/cacert.pem.new /ffp/etc/ssl/certs/cacert.pem
fi
if [ -f /ffp/etc/ssl/certs/cacert.pem.new ] && [ \$(md5sum /ffp/etc/ssl/certs/cacert.pem.new|awk '{print \$1}') != $CHECKSUM ]; then
   rm /ffp/etc/ssl/certs/cacert.pem.new
fi
EOF
chmod 755 ${BUILDDIR}/install/doinst.sh
makepkg ${PACKAGENAME} ${VERSION} 1
cp -a ${PKGDIR}/${PACKAGENAME}-${VERSION}-arm-1.txz ${PKGDIRBACKUP}
cd
rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Compile duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"