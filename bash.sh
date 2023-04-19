#!/ffp/bin/sh

set -e
PATH="/ffp/bin:/ffp/sbin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"
BASH_CFLAGS=(-DDEFAULT_PATH_VALUE=\'\"/ffp/bin:/ffp/sbin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin\"\'
			-DSTANDARD_UTILS_PATH=\'\"/ffp/bin:/ffp/sbin:/ffp/etc:/bin:/usr/bin:/sbin:/usr/sbin:/etc:/usr/etc\"\'
			-DSYS_BASHRC=\'\"/ffp/etc/bash.bashrc\"\'
			-DSYS_BASH_LOGOUT=\'\"/ffp/etc/bash.bash_logout\"\')
CFLAGS="${CFLAGS} ${BASH_CFLAGS[@]}"
GNU_BUILD=arm-ffp-linux-uclibceabi
GNU_HOST="$GNU_BUILD"
BUILDDIR=/mnt/HD_a2/hdd1/build/bash
PACKAGENAME=bash
VERSION=5.2.15
#SOURCEURL=https://ftp.gnu.org/gnu/bash/bash-5.2.tar.gz
#SOURCEURL=http://192.168.1.20:88/MyWeb/COMPILER/finish/bash-5.2.tar.gz
HOMEURL=http://www.gnu.org/software/bash
STARTTIME=$(date +"%s")
PKGDIR="/mnt/HD_a2/hdd1/ffp0.7arm/packages"
PKGDIRBACKUP="/ffp/funpkg/additional"
export PATH PKGDIR CFLAGS
echo "Start point:$(date -d @${STARTTIME} +%F\ %T)"
if [ ! -d ${BUILDDIR} ]; then
   mkdir -p ${BUILDDIR}
fi
#rm /mnt/HD_a2/hdd1/build/bash/*
cd ${BUILDDIR}
#wget -nv ${SOURCEURL}
#cp /i-data/md1/hdd2/COMPILER/finish/${PACKAGENAME}-5.2.15.tar.gz ${BUILDDIR}/
#curl -k https://ftp.gnu.org/gnu/bash/bash-5.1.8.tar.gz --output bash-5.1.8.tar.gz
#tar -vxzf ${PACKAGENAME}-5.2.tar.gz
tar -vxzf /i-data/md1/hdd2/COMPILER/finish/bash-5.2.15.tar.gz
cd ${PACKAGENAME}-5.2.15
#Get and apply patches
#wget -nv -np -nd -r --level=1 http://ftp.gnu.org/gnu/bash/${PACKAGENAME}-5.2-patches
#wget -nv ftp://ftp.gnu.org/gnu/bash/${PACKAGENAME}-5.2-patches/${PACKAGENAME}*-???
#for patches in ${PACKAGENAME}*-???; do
#    patch -p0 < $patches
#done
PATCHLEVEL=$(grep -w 'define PATCHLEVEL' ${BUILDDIR}/${PACKAGENAME}-5.2.15/patchlevel.h | awk '{print $3}')
# Correct hardcoded shell
# Adapt hardcoded paths to ffp
for file in ${BUILDDIR}/${PACKAGENAME}-5.2.15/support/*; do
	sed -i 's|/usr/local|/ffp|g' $file
	sed -i 's|/usr|/ffp|g' $file
done
sed -i 's|/usr/local|/ffp|g' configure
sed -i 's|/usr|/ffp|g' configure configure.ac
sed -i 's|/bin/sh|/ffp/bin/sh|g' configure configure.ac
#correct Run-time system search path for libraries for libtool
sed -i '/$lt_ld_extra/c\    sys_lib_dlsearch_path_spec="/ffp/lib"' configure
# /ffp/etc/profile
sed -i "s|/etc/profile|/ffp/etc/profile|" pathnames.h.in
# For Readline
# /ffp/etc/inputrc
sed -i "s|/etc/inputrc|/ffp/etc/inputrc|" lib/readline/rlconf.h
# Configure Readline to link against the libncurses (really, libncursesw) library:
sed -i 's|^SHLIB_LIBS=|SHLIB_LIBS=-lncursesw|' support/shobj-conf
#adapt scripts to FFP prefix
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
# use bash_cv_getenv_redef=0 before ./configure command for static linking

#bash_cv_getenv_redef=0 ./configure --prefix=/ffp \
#			--build=$GNU_BUILD \
#			--host=$GNU_HOST \
#			--enable-multibyte \
#			--without-bash-malloc \
#			--disable-nls \
#			--with-installed-readline
#			--enable-static-link

./configure --prefix=/ffp \
            --build=$GNU_BUILD \
            --host=$GNU_HOST \
            --enable-multibyte \
            --without-bash-malloc \
            --disable-nls \
            --with-installed-readline

#adapt scripts to FFP prefix after configuration
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
colormake
#make tests
colormake install DESTDIR=${BUILDDIR}
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

Description of $PACKAGENAME:
Bash is the GNU Project's shell. Bash is the Bourne Again SHell. Bash is an sh-compatible shell
that incorporates useful features from the Korn shell (ksh) and C shell (csh). It is intended
to conform to the IEEE POSIX P1003.2/ISO 9945.2 Shell and Tools standard. It offers functional
improvements over sh for both programming and interactive use. In addition, most sh scripts can
be run by Bash without modification.
License:GNU GPLv3, or any later version
Version: 5.2
Homepage: ${HOMEURL}

Depends on these packages:
br2:uClibc br2:uClibc-solibs br2:libiconv br2:ncurses

EOF
echo ${HOMEURL} > ${BUILDDIR}/install/HOMEPAGE
cd ${BUILDDIR}
rm -rf ${BUILDDIR}/${PACKAGENAME}-*
# Remove unnecessary stuff
if [ -d ${BUILDDIR}/ffp/share/doc ]; then
   rm -rf ${BUILDDIR}/ffp/share/doc
fi
rm -f ${BUILDDIR}/ffp/bin/bashbug
rm -f ${BUILDDIR}/ffp/share/man/*/bashbug.*
#Correct permissions for shared libraries and libtool library files
if [ -d ${BUILDDIR}/ffp/lib ]; then
   find ${BUILDDIR}/ffp/lib -type f -iname "*.la" -exec chmod 755 {} \;
   find ${BUILDDIR}/ffp/lib -type f -iname "*.so*" -exec chmod 755 {} \;
fi
# Adapt scripts to FFP prefix again, before making package
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
# Create compatability symlink to old Bourne shell
cd ${BUILDDIR}/ffp/bin
ln -s bash sh
cd ${BUILDDIR}
# Generate direct dependencies list for packages.html and slapt-get
gendeps ${BUILDDIR}/ffp
if	[ -d ${BUILDDIR}/ffp/install ]; then
   mv ${BUILDDIR}/ffp/install/* ${BUILDDIR}/install
   rm -rf ${BUILDDIR}/ffp/install
fi
# Remove duplicate gcc and uclibc and in some cases package itself dependencies requirements
for pkgname in gcc uClibc ${PACKAGENAME}; do
	sed -i "s|\<${pkgname}\> ||" ${BUILDDIR}/install/DEPENDS
	sed -i "/^${pkgname}$/d" ${BUILDDIR}/install/slack-required
done
makepkg ${PACKAGENAME} 5.2.15 1
cp -a ${PKGDIR}/${PACKAGENAME}-5.2.15-arm-1.txz ${PKGDIRBACKUP}
cd
rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Compile duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"
