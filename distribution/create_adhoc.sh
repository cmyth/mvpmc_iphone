#!/bin/bash

set -e

TOPDIR=`pwd`

DIST=${TOPDIR}/distribution
PAYLOAD=${DIST}/payload
APP=${TOPDIR}/build/AdHoc-iphoneos/mvpmc.app

if [ -d ${PAYLOAD} ] ; then
    rm -rf ${PAYLOAD}
fi
mkdir ${PAYLOAD}

mv ${APP} ${PAYLOAD}

cd ${DIST}
zip mvpmc-adhoc.ipa ${PAYLOAD}
