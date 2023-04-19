!/ffp/bin/bash

set -e
PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
GNU_BUILD=arm-ffp-linux-uclibceabi
GNU_HOST=$GNU_BUILD
BUILDDIR=/mnt/HD_a2/build/minidlna
SCRIPTDIR="$(dirname $(readlink -f "$0"))"
PACKAGENAME=minidlna
SOURCEURL="git://git.code.sf.net/p/${PACKAGENAME}/git ${PACKAGENAME}"
HOMEURL=http://sourceforge.net/projects/minidlna/
PKGDIR="/mnt/HD_a2/ffp0.7arm/packages"
PKGDIRBACKUP="/ffp/funpkg/additional"
export PATH PKGDIR
STARTTIME=$(date +"%s")
echo "Start point:$(date -d @${STARTTIME} +%F\ %T)"
# Create build and pkgs directories, if required
for DIR in ${BUILDDIR} ${PKGDIR} ${PKGDIRBACKUP}; do
	if [ ! -d ${DIR} ]; then
		mkdir -p ${DIR}
	fi
done
cd ${BUILDDIR}

#cd ${PACKAGENAME}


# Remove old minidlna settings and start script file, left by previous versions
CHECKSUMCONF=$(md5sum ${BUILDDIR}/ffp/etc/minidlna.conf|awk '{print $1}')
CHECKSUMSCRIPT=$(md5sum ${BUILDDIR}/ffp/start/minidlna.sh|awk '{print $1}')
cat > ${BUILDDIR}/install/doinst.sh << EOF
#!/ffp/bin/sh

PATH="/ffp/sbin:/ffp/bin:/usr/sbin:/sbin:/usr/bin:/bin"
export PATH

DATE=\$(date "+%Y%m%d_%H%M%S")

if	[ -f /ffp/start/${PACKAGENAME}.sh.new ] && [ \$(md5sum /ffp/start/${PACKAGENAME}.sh.new|awk '{print \$1}') = $CHECKSUMSCRIPT ]; then
	if	[ -f /ffp/start/${PACKAGENAME}.sh ]; then
		mv /ffp/start/${PACKAGENAME}.sh /ffp/start/${PACKAGENAME}.sh.old\${DATE}
		chmod 644 /ffp/start/${PACKAGENAME}.sh.old\${DATE}
		mv /ffp/start/${PACKAGENAME}.sh.new /ffp/start/${PACKAGENAME}.sh
	else
		mv /ffp/start/${PACKAGENAME}.sh.new /ffp/start/${PACKAGENAME}.sh
	fi
fi
if	[ -f /ffp/start/${PACKAGENAME}.sh.new ] && [ \$(md5sum /ffp/start/${PACKAGENAME}.sh.new|awk '{print \$1}') != $CHECKSUMSCRIPT ]; then
	rm /ffp/start/${PACKAGENAME}.sh.new
fi
if	[ -f /ffp/etc/${PACKAGENAME}.conf.new ] && [ \$(md5sum /ffp/etc/${PACKAGENAME}.conf.new|awk '{print \$1}') = $CHECKSUMCONF ]; then
	if	[ -f /ffp/etc/${PACKAGENAME}.conf ]; then
		mv /ffp/etc/${PACKAGENAME}.conf /ffp/etc/${PACKAGENAME}.conf.old\${DATE}
		mv /ffp/etc/${PACKAGENAME}.conf.new /ffp/etc/${PACKAGENAME}.conf
	else
		mv /ffp/etc/${PACKAGENAME}.conf.new /ffp/etc/${PACKAGENAME}.conf
	fi
fi

EOF
chmod 755 ${BUILDDIR}/install/doinst.sh
# Generate direct dependencies list for packages.html and slapt-get
gendeps ${BUILDDIR}/ffp
# Remove package itself from dependencies requirements
sed -i "s|\<${PACKAGENAME}\> ||" ${BUILDDIR}/install/DEPENDS
sed -i "/^${PACKAGENAME}$/d" ${BUILDDIR}/install/slack-required
# Make an FFP package
makepkg ${PACKAGENAME} ${VERSION} 1
cp ${PACKAGENAME}-${VERSION}-arm-1.txz ${PKGDIR}/
cp -a ${PKGDIR}/${PACKAGENAME}-${VERSION}-arm-1.txz ${PKGDIRBACKUP}
cd
rm -rf ${BUILDDIR}
ENDTIME=$(date +"%s")
DIFF=$(($ENDTIME-$STARTTIME))
echo "End point:$(date -d @${ENDTIME} +%F\ %T)"
echo "Compile duration: $(($DIFF / 3600 )) hours $(($DIFF / 60 % 60)) minutes and $(($DIFF % 60)) seconds"

