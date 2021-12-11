#!/bin/bash


# func createRpmPackages() {
# 	createFpmPackage(linuxPackageOptions{
# 		packageType:            "rpm",
# 		homeDir:                "/usr/share/snmpcollector",
# 		binPath:                "/usr/sbin/snmpcollector",
# 		configDir:              "/etc/snmpcollector",
# 		configFilePath:         "/etc/snmpcollector/config.toml",
# 		etcDefaultPath:         "/etc/sysconfig",
# 		etcDefaultFilePath:     "/etc/sysconfig/snmpcollector",
# 		initdScriptFilePath:    "/etc/init.d/snmpcollector",
# 		systemdServiceFilePath: "/usr/lib/systemd/system/snmpcollector.service",

# 		postinstSrc:    "packaging/rpm/control/postinst",
# 		initdScriptSrc: "packaging/rpm/init.d/snmpcollector",
# 		defaultFileSrc: "packaging/rpm/sysconfig/snmpcollector",
# 		systemdFileSrc: "packaging/rpm/systemd/snmpcollector.service",

# 		depends: []string{"initscripts"},
# 	})
# }

# // create directories
# runPrint("mkdir", "-p", filepath.Join(packageRoot, options.homeDir))
# runPrint("mkdir", "-p", filepath.Join(packageRoot, options.configDir))
# runPrint("mkdir", "-p", filepath.Join(packageRoot, "/etc/init.d"))
# runPrint("mkdir", "-p", filepath.Join(packageRoot, options.etcDefaultPath))
# runPrint("mkdir", "-p", filepath.Join(packageRoot, "/usr/lib/systemd/system"))
# runPrint("mkdir", "-p", filepath.Join(packageRoot, "/usr/sbin"))

set -vx

BINARY=$1
DESCRIPTION="some description"
PKGNAME=github-actions-test
VENDOR=${GITHUB_ACTOR:-toni}
URL=${GITHUB_SERVER_URL:-http://server}/${GITHUB_REPOSITORY:-repo/test}
LICENSE="Apache2.0"
MAINTAINER=toni.moreno@gmail.com

TEMPDIR=$(mktemp -d -t pkg-XXXXXXXXXX)


cat<<EOF >> $GITHUB_ENV
description=${DESCRIPTION}
pkgname=${PKGNAME}
vendor=${VENDOR}
url=${URL}
license=${LICENSE}
maintainer=${MAINTAINER}
tempdir=${TEMPDIR}
rpmbasedir=${TEMPDIR}/rpm
distdir=${TEMPDIR}/dist
EOF
mkdir -p ${TEMPDIR}/dist

#--------------------------------------------------
#               RPM
#--------------------------------------------------

mkdir -p ${TEMPDIR}/rpm/usr/share/${PKGNAME} #home
mkdir -p ${TEMPDIR}/rpm/etc/${PKGNAME} #config
mkdir -p ${TEMPDIR}/rpm/etc/init.d #init.d
mkdir -p ${TEMPDIR}/rpm/etc/sysconfig #default path
mkdir -p ${TEMPDIR}/rpm/usr/lib/systemd/system #system
mkdir -p ${TEMPDIR}/rpm/sbin #system

# copy binary
cp -p  ${BINARY}   ${TEMPDIR}/rpm/usr/sbin/${PKGNAME}
# copy init.d script
cp -p packaging/rpm/init.d/${PKGNAME} ${TEMPDIR}/rpm/etc/init.d
# copy environment var file
cp -p packaging/rpm/sysconfig/${PKGNAME} ${TEMPDIR}/rpm/etc/sysconfig
# copy systemd 
cp -p packaging/rpm/systemd/${PKGNAME}.service    ${TEMPDIR}/rpm/usr/lib/systemd/system/${PKGNAME}.service
# // copy release files
cp -a packaging ${TEMPDIR}/rpm/usr/share/${PKGNAME}/
# copy sample ini file to /etc/${PKGNAME}
cp README.md ${TEMPDIR}/rpm/usr/share/${PKGNAME}/
# runPrint("cp", "conf/sample.config.toml", filepath.Join(packageRoot, options.configFilePath))

VERSION=`git describe --abbrev=0 --tag`
VERSION=`echo $VERSION | sed 's/^v//'`

echo "version=${VERSION}" >> $GITHUB_ENV

fpm     -t rpm  \
        -s dir  \
        --description "${DESCRIPTION}" \
        -C "${TEMPDIR}/rpm" \
        --vendor "${VENDOR}" \
		--url "${URL}" \
        --license "${LICENSE}" \
        --maintainer "${MAINTAINER}" \
        --config-files /usr/share/${PKGNAME}/README.md \
		--config-files /etc/init.d/${PKGNAME} \
		--config-files /etc/sysconfig/${PKGNAME} \
		--config-files /usr/lib/systemd/system/${PKGNAME}.service \
		--after-install packaging/rpm/control/postinst \
		--name ${PKGNAME} \
		--version  ${VERSION} \
		-p ${TEMPDIR}/dist \
        --depends "initscript" .

echo $T--descriptioEMPDIR
