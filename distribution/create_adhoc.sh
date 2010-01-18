#!/bin/bash

set -e

TOPDIR=`pwd`

DIST=${TOPDIR}/distribution
PAYLOAD=${DIST}/Payload
APP=${TOPDIR}/build/AdHoc-iphoneos/mvpmc.app

if [ -d ${PAYLOAD} ] ; then
    rm -rf ${PAYLOAD}
fi
mkdir ${PAYLOAD}

mv ${APP} ${PAYLOAD}

cd ${DIST}
rm -f mvpmc-adhoc.ipa
zip -r mvpmc-adhoc.ipa ${PAYLOAD}
