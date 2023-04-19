#!/ffp/bin/sh

set -e
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
GNU_BUILD=arm-ffp-linux-uclibceabi
GNU_HOST=$GNU_BUILD
BUILDDIR=/mnt/HD_a2/build/openssl
PACKAGENAME=openssl
#VERSION="1.0.2d"
VERSION="1.1.1l"
#SOURCEURL=http://openssl.org/source/${PACKAGENAME}-${VERSION}.tar.gz
SOURCEURL=http://192.168.1.20:88/MyWeb/COMPILER/finish/openssl-1.1.1l.tar.gz
HOMEURL=https://www.openssl.org/
PKGDIR="/mnt/HD_a2/ffp0.7arm/packages"
PKGDIRBACKUP="/ffp/funpkg/additional"
export PATH PKGDIR
STARTTIME=$(date +"%s")
echo "Start point:$(date -d @${STARTTIME} +%F\ %T)"
# Create build and pkgs directories, if required
for DIR in ${BUILDDIR} ${PKGDIR} ${PKGDIRBACKUP}; do
	if	[ ! -d ${DIR} ]; then
		mkdir -p ${DIR}
	fi
done
cd ${BUILDDIR}
#wget -nv ${SOURCEURL}
cp /i-data/md1/COMPILER/finish/${PACKAGENAME}-${VERSION}.tar.gz .
tar -vxf ${PACKAGENAME}-${VERSION}.tar.gz
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
# Don't use zlib-dynamic configure option, because static openssl lib will use shared zlib via dlopen (libdl)
# This will lead to segfault of static builds, which uses static openssl lib and uClibc-ng > 1.0.17
./config --prefix=/ffp \
		--openssldir=/ffp/etc/ssl \
		--libdir=lib \
		no-idea \
		no-rc5 \
		shared
colormake depend
colormake
#colormake test
colormake INSTALL_PREFIX=${BUILDDIR} MANDIR=/ffp/share/man install
mkdir -p ${BUILDDIR}/install
#|--------------------------------------Handy Ruller---------------------------------------------|
cat > ${BUILDDIR}/install/DESCR << EOF

Description of $PACKAGENAME:
The OpenSSL Project is a collaborative effort to develop a robust, commercial-grade, full-featured,
and Open Source toolkit implementing the Transport Layer Security (TLS) and Secure Sockets Layer (SSL)
protocols as well as a full-strength general purpose cryptography library. 
License: custom BSD style
Version: ${VERSION}
Homepage: ${HOMEURL}

EOF
# Direct dependencies list for packages.html and slapt-get
#cat > ${BUILDDIR}/install/DEPENDS << EOF
#openssh-7.1p1-arm-2 uClibc-solibs zlib
#EOF
#cat > ${BUILDDIR}/install/slack-required << EOF
#openssh = 7.1p1-arm-1
#uClibc-solibs
#zlib
#EOF
echo ${HOMEURL} > ${BUILDDIR}/install/HOMEPAGE
cd ${BUILDDIR}
rm -rf ${BUILDDIR}/${PACKAGENAME}-*
# Remove unused docs
if	[ -d ${BUILDDIR}/ffp/share/doc ]; then
	rm -rf ${BUILDDIR}/ffp/share/doc
fi
# No api docs
rm -rf ${BUILDDIR}/ffp/share/man/man3
# Correct permissions for shared libraries and libtool library files
if	[ -d ${BUILDDIR}/ffp/lib ]; then
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
# Get ca-bundle for new ssl module
wget -nv http://192.168.1.20:88/MyWeb/COMPILER/finish/cacert.pem -O ${BUILDDIR}/ffp/etc/ssl/cert.pem
# Create postinstall script to remove old cert.pem and openssl config file
# Also automatic install of hard dependency-openssh is included 
CHECKSUMCERT=$(md5sum ${BUILDDIR}/ffp/etc/ssl/cert.pem|awk '{print $1}')
CHECKSUMCNF=$(md5sum ${BUILDDIR}/ffp/etc/ssl/openssl.cnf|awk '{print $1}')
CHECKSUMCHASH=$(md5sum ${BUILDDIR}/ffp/etc/ssl/misc/c_hash|awk '{print $1}')
CHECKSUMCISSUER=$(md5sum ${BUILDDIR}/ffp/etc/ssl/misc/c_issuer|awk '{print $1}')
CHECKSUMCINFO=$(md5sum ${BUILDDIR}/ffp/etc/ssl/misc/c_info|awk '{print $1}')
CHECKSUMCASH=$(md5sum ${BUILDDIR}/ffp/etc/ssl/misc/CA.sh|awk '{print $1}')
CHECKSUMCNAME=$(md5sum ${BUILDDIR}/ffp/etc/ssl/misc/c_name|awk '{print $1}')
cat > ${BUILDDIR}/install/doinst.sh << EOF
#!/ffp/bin/sh

PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
export PATH

if	[ -f /ffp/etc/ssl/cert.pem.new ] && [ \$(md5sum /ffp/etc/ssl/cert.pem.new|awk '{print \$1}') = $CHECKSUMCERT ]; then
	mv /ffp/etc/ssl/cert.pem.new /ffp/etc/ssl/cert.pem
fi
if	[ -f /ffp/etc/ssl/cert.pem.new ] && [ \$(md5sum /ffp/etc/ssl/cert.pem.new|awk '{print \$1}') != $CHECKSUMCERT ]; then
	rm /ffp/etc/ssl/cert.pem.new
fi
if	[ -f /ffp/etc/ssl/openssl.cnf.new ] && [ \$(md5sum /ffp/etc/ssl/openssl.cnf.new|awk '{print \$1}') = $CHECKSUMCNF ]; then
	mv /ffp/etc/ssl/openssl.cnf.new /ffp/etc/ssl/openssl.cnf
fi
if	[ -f /ffp/etc/ssl/openssl.cnf.new ] && [ \$(md5sum /ffp/etc/ssl/openssl.cnf.new|awk '{print \$1}') != $CHECKSUMCNF ]; then
	rm /ffp/etc/ssl/openssl.cnf.new
fi
if	[ -f /ffp/etc/ssl/misc/c_hash.new ] && [ \$(md5sum /ffp/etc/ssl/misc/c_hash.new|awk '{print \$1}') = $CHECKSUMCHASH ]; then
	mv /ffp/etc/ssl/misc/c_hash.new /ffp/etc/ssl/misc/c_hash
fi
if	[ -f /ffp/etc/ssl/misc/c_hash.new ] && [ \$(md5sum /ffp/etc/ssl/misc/c_hash.new|awk '{print \$1}') != $CHECKSUMCHASH ]; then
	rm /ffp/etc/ssl/misc/c_hash.new
fi
if	[ -f /ffp/etc/ssl/misc/c_issuer.new ] && [ \$(md5sum /ffp/etc/ssl/misc/c_issuer.new|awk '{print \$1}') = $CHECKSUMCISSUER ]; then
	mv /ffp/etc/ssl/misc/c_issuer.new /ffp/etc/ssl/misc/c_issuer
fi
if	[ -f /ffp/etc/ssl/misc/c_issuer.new ] && [ \$(md5sum /ffp/etc/ssl/misc/c_issuer.new|awk '{print \$1}') != $CHECKSUMCISSUER ]; then
	rm /ffp/etc/ssl/misc/c_issuer.new
fi
if	[ -f /ffp/etc/ssl/misc/c_info.new ] && [ \$(md5sum /ffp/etc/ssl/misc/c_info.new|awk '{print \$1}') = $CHECKSUMCINFO ]; then
	mv /ffp/etc/ssl/misc/c_info.new /ffp/etc/ssl/misc/c_info
fi
if	[ -f /ffp/etc/ssl/misc/c_info.new ] && [ \$(md5sum /ffp/etc/ssl/misc/c_info.new|awk '{print \$1}') != $CHECKSUMCINFO ]; then
	rm /ffp/etc/ssl/misc/c_info.new
fi
if	[ -f /ffp/etc/ssl/misc/CA.sh.new ] && [ \$(md5sum /ffp/etc/ssl/misc/CA.sh.new|awk '{print \$1}') = $CHECKSUMCASH ]; then
	mv /ffp/etc/ssl/misc/CA.sh.new /ffp/etc/ssl/misc/CA.sh
fi
if	[ -f /ffp/etc/ssl/misc/CA.sh.new ] && [ \$(md5sum /ffp/etc/ssl/misc/CA.sh.new|awk '{print \$1}') != $CHECKSUMCASH ]; then
	rm /ffp/etc/ssl/misc/CA.sh.new
fi
if	[ -f /ffp/etc/ssl/misc/c_name.new ] && [ \$(md5sum /ffp/etc/ssl/misc/c_name.new|awk '{print \$1}') = $CHECKSUMCNAME ]; then
	mv /ffp/etc/ssl/misc/c_name.new /ffp/etc/ssl/misc/c_name
fi
if	[ -f /ffp/etc/ssl/misc/c_name.new ] && [ \$(md5sum /ffp/etc/ssl/misc/c_name.new|awk '{print \$1}') != $CHECKSUMCNAME ]; then
	rm /ffp/etc/ssl/misc/c_name.new
fi

EOF
makepkg ${PACKAGENAME} ${VERSION} 2
cp -a /i-data/md1/packages/xxx/${PACKAGENAME}-${VERSION}-arm-2.txz ${PKGDIRBACKUP}
cd
rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Compile duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"
