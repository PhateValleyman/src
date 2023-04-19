#!/ffp/bin/sh

set -e
export SHELL="/ffp/bin/sh"
SOURCEDIR=/mnt/HD_a2/build
BUILDDIR=/mnt/HD_a2/build/tmp
GITBRANCH=0.9.33
GITURL=git://uclibc.org/uClibc.git
HOMEURL=http://www.uclibc.org/
PACKAGENAME=uClibc
PACKAGENAME1=uClibc-solibs
SCRIPTDIR="$(dirname $(readlink -f "$0"))"
VERSION=0.9.33.3_git
if [ ! -d ${BUILDDIR} ]; then
   mkdir -p ${BUILDDIR}
fi
cd ${SOURCEDIR}
echo "$(date)"
git clone -q -b ${GITBRANCH} ${GITURL} ${PACKAGENAME}
cd ${PACKAGENAME}
#Remove -Wdeclaration-after-statement warning to avoid this: ISO C90 forbids mixed declarations and code  
sed -i 's| -Wdeclaration-after-statement||' Rules.mak
cp -a ${SCRIPTDIR}/locale /ffp/bin
cp -a ${SCRIPTDIR}/.config.onelocale $PWD/.config
cp -a ${SCRIPTDIR}/locales.txt ${SCRIPTDIR}/uClibc-locale-20081111-32-el.tgz $PWD/extra/locale
find $PWD/extra/locale/charmaps -name "*.pairs" > $PWD/extra/locale/codesets.txt
#mv $PWD/extra/locale/LOCALES $PWD/extra/locale/locales.txt
# Apply patches to build UTF-8 locales on system without current UTF support (unnecessary for glibc, only for uClibc without UTF)
# ATTENTION!!! /ffp/bin/locale script is prerequisite !!!
#cp -a ${SCRIPTDIR}/1_locale.patch ${SCRIPTDIR}/2_locale.patch $PWD
#patch -p1 < 1_locale.patch
#patch -p1 < 2_locale.patch
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
make silentoldconfig
make pregen
cd $PWD/extra/locale
make
cd $PWD/../../
make
make utils
echo "$(date)"
# Install shared libs and make uClibc-solibs package
make PREFIX=${BUILDDIR} install_runtime
cp -av lib/*.so* ${BUILDDIR}/ffp/lib/
mkdir -p ${BUILDDIR}/install
echo "" >> ${BUILDDIR}/install/DESCR
echo "Description of uClibc:" >> ${BUILDDIR}/install/DESCR
echo "uClibc (aka µClibc/pronounced yew-see-lib-see) is a C library for developing embedded Linux systems." >> ${BUILDDIR}/install/DESCR
echo "It is much smaller than the GNU C Library, but nearly all applications supported by glibc also work" >> ${BUILDDIR}/install/DESCR
echo "perfectly with uClibc. uClibc is maintained by Erik Andersen and is licensed under the GNU LGPL." >> ${BUILDDIR}/install/DESCR
echo "Version:${VERSION}" >> ${BUILDDIR}/install/DESCR
echo "Homepage:${HOMEURL}" >> ${BUILDDIR}/install/DESCR
echo "" >> ${BUILDDIR}/install/DESCR
echo "Requires libraries from: br2:uClibc mz:kernel_headers-2.6.31.8" >> ${BUILDDIR}/install/DESCR
echo "" >> ${BUILDDIR}/install/DESCR
echo "IMPORTANT NOTICE: Fully compatable only with Zyxel NSA 3** series NAS'es." >> ${BUILDDIR}/install/DESCR
echo "Other devices with kernel different from 2.6.31.8 are only partly compatable." >> ${BUILDDIR}/install/DESCR
echo ${HOMEURL} >> ${BUILDDIR}/install/HOMEPAGE
cat > ${BUILDDIR}/install/doinst.sh << 'EOF'
#!/ffp/bin/sh
echo -e "\e[1;34;42mIMPORTANT NOTICE: Fully compatible only with Zyxel NSA 3** series NAS'es.\e[0m"
echo -e "\e[1;31;21mOther devices with kernel different from 2.6.31.8 are only partly compatible.\e[0m"
EOF
chmod 755 ${BUILDDIR}/install/doinst.sh
cd ${BUILDDIR}
#Correct permissions for shared libraries and libtool library files
if [ -d ${BUILDDIR}/ffp/lib ]; then
   find ${BUILDDIR}/ffp/lib -type f -iname "*.la" -exec chmod 755 {} \;
   find ${BUILDDIR}/ffp/lib -type f -iname "*.so*" -exec chmod 755 {} \;
fi
#adapt executables to FFP prefix again
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
# Create uClibc-solibs package
makepkg ${PACKAGENAME1} ${VERSION} 1
if [ ! -d "/mnt/HD_a2/ffp0.7arm/packages/${PACKAGENAME}/" ]; then
    mkdir -p /mnt/HD_a2/ffp0.7arm/packages/${PACKAGENAME}/
fi
if [ ! -d "/ffp/funpkg/additional/${PACKAGENAME}/" ]; then
    mkdir -p /ffp/funpkg/additional/${PACKAGENAME}/
fi
cp /tmp/${PACKAGENAME1}-${VERSION}-arm-1.txz /mnt/HD_a2/ffp0.7arm/packages/${PACKAGENAME}/
mv /tmp/${PACKAGENAME1}-${VERSION}-arm-1.txz /ffp/funpkg/additional/${PACKAGENAME}/
cd ${SOURCEDIR}/${PACKAGENAME}
# Install and make uClibc package
make PREFIX=${BUILDDIR} install
make PREFIX=${BUILDDIR} install_utils
cd ${BUILDDIR}
#Correct permissions for shared libraries and libtool library files
if [ -d ${BUILDDIR}/ffp/lib ]; then
   find ${BUILDDIR}/ffp/lib -type f -iname "*.la" -exec chmod 755 {} \;
   find ${BUILDDIR}/ffp/lib -type f -iname "*.so*" -exec chmod 755 {} \;
fi
#adapt executables to FFP prefix again
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
# Correct dependencies for main uClibc package 
sed -i 's|br2:uClibc|br2:uClibc-solibs|' ${BUILDDIR}/install/DESCR
# Include locale script in uClibc package
cp -av ${SCRIPTDIR}/locale ${BUILDDIR}/ffp/bin
# Create main uClibc package
makepkg ${PACKAGENAME} ${VERSION} 1
if [ ! -d "/mnt/HD_a2/ffp0.7arm/packages/${PACKAGENAME}/" ]; then
    mkdir -p /mnt/HD_a2/ffp0.7arm/packages/${PACKAGENAME}/
fi
if [ ! -d "/ffp/funpkg/additional/${PACKAGENAME}/" ]; then
    mkdir -p /ffp/funpkg/additional/${PACKAGENAME}/
fi
cp /tmp/${PACKAGENAME}-${VERSION}-arm-1.txz /mnt/HD_a2/ffp0.7arm/packages/${PACKAGENAME}/
mv /tmp/${PACKAGENAME}-${VERSION}-arm-1.txz /ffp/funpkg/additional/${PACKAGENAME}/
cd
echo "$(date)"
#rm -rf ${SOURCEDIR}