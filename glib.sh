#!/ffp/bin/sh

set -e
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
GNU_BUILD=arm-ffp-linux-uclibceabi
GNU_HOST=$GNU_BUILD
BUILDDIR=/mnt/HD_a2/build/glibc
SCRIPTDIR="$(dirname $(readlink -f "$0"))"
PACKAGENAME=glib
VERSION="2.52.3"
#SOURCEURL=http://ftp.gnome.org/pub/gnome/sources/glibc/${VERSION%.*}/${PACKAGENAME}-${VERSION}.tar.gz
SOURCEURL=http://ftp.gnome.org/pub/gnome/sources/glib/2.52/glib-2.52.3.tar.xz
HOMEURL=https://developer.gnome.org/glib
PKGDIR="/mnt/HD_a2/ffp0.7arm/packages"
PKGDIRBACKUP="/ffp/funpkg/additional"
export PATH PKGDIR
STARTTIME=$(date +"%s")
echo "Start point:$(date -d @${STARTTIME} +%F\ %T)"
# Create build and pkgs directories, if required
for DIR in pkg ${PKGDIR} ${PKGDIRBACKUP}; do
	if [ ! -d ${DIR} ]; then
		mkdir -p ${DIR}
	fi
done
cd pkg
#wget -nv ${SOURCEURL}
#tar vxf ${PACKAGENAME}-${VERSION}.tar.xz
cd ${PACKAGENAME}-${VERSION}
# Apply buildroot patches to disable building of tests as compilation of them hangs for a long time
#wget -e robots=off -nv -np -nd -r --level=1 -A patch https://git.buildroot.net/buildroot/plain/package/libglib2
#for patches in ????-*.patch; do
#    patch -p1 < $patches
#done
# Apply patch to silence automake regarding disabled sub-dirs
patch -p1 < ${SCRIPTDIR}/${PACKAGENAME}-2.50.2.patch
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
autoreconf -vfi
# 	--disable-always-build-tests not working
touch -t 201411061400 gtk-doc.make
./configure \
	--build=arm-ffp-linux-uclibceabi \
	--host=arm-ffp-linux-uclibceabi \
	--prefix=/ffp \
	--enable-shared \
	--enable-static \
	--with-pcre=system \
	--disable-gtk-doc \
	--disable-gtk-doc-html \
	--disable-gtk-doc-pdf
colormake
#make -k check
colormake install DESTDIR=pkg
# Correct gdb plugins location (incorrect place since 2.50.2 version)
mv pkg/ffp/share/gdb/auto-load/ffp/lib/* pkg/ffp/share/gdb/auto-load/
rm -rf pkg/ffp/share/gdb/auto-load/ffp
mkdir -p pkg/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > pkg/install/DESCR << EOF

Description of $PACKAGENAME:
The GLib package contains a low-level libraries useful for providing data structure handling for C,
portability wrappers and interfaces for such runtime functionality as an event loop, threads,
dynamic loading and an object system.
License:LGPL
Version:${VERSION}
Homepage:${HOMEURL}

Depends on these packages:
br2:gettext br2:libffi br2:libiconv br2:pcre s:perl br2:python-2.7.* br2:uClibc-solibs br2:util-linux
br2:zlib

EOF
echo ${HOMEURL} > pkg/install/HOMEPAGE
cd pkg
rm -rf pkg/${PACKAGENAME}-*
# Remove unused docs
if [ -d pkg/ffp/share/gtk-doc ]; then
   rm -rf pkg/ffp/share/gtk-doc
fi
if [ -d pkg/ffp/share/doc ]; then
   rm -rf pkg/ffp/share/doc
fi
# Correct permissions for shared libraries and libtool library files
if [ -d pkg/ffp/lib ]; then
   find pkg/ffp/lib -type f -iname "*.la" -exec chmod 755 {} \;
   find pkg/ffp/lib -type f -iname "*.so*" -exec chmod 755 {} \;
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
gendeps pkg/ffp
if	[ -d pkg/ffp/install ]; then
   mv pkg/ffp/install/* pkg/install
   rm -rf pkg/ffp/install
fi
# # Remove package itself from dependencies requirements
for pkgname in ${PACKAGENAME} glib2
do
	sed -i "s|\<${pkgname}\> ||" pkg/install/DEPENDS
	sed -i "/^${pkgname}$/d" pkg/install/slack-required
done
# Add additional dependencies including
sed -i '1 s|$| perl python-2.7.*|' pkg/install/DEPENDS
cat >> pkg/install/slack-required <<- EOF
perl
python >= 2.7.13-arm-1
python < 2.8.0
EOF
# Create file to inform about conflic
cat > pkg/install/slack-conflicts << EOF
glib2
EOF
makepkg ${PACKAGENAME} ${VERSION} 2
cp -a ${PKGDIR}/${PACKAGENAME}-${VERSION}-arm-2.txz ${PKGDIRBACKUP}
cd
rm -rf pkg
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Compile duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"
