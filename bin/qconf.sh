#!/usr/bin/env bash

# QCONF

## Export encrypted QCONF values from file and export them to environment values

if [ "${QCONF_PATH}" == "" ]
then
    echo "QCONF_PATH is not defined. Aborting."
    exit 1
fi

if [ "${QCONF_FILE}" == "" ]
then
    echo "QCONF_FILE is not defined. Aborting."
    exit 1
fi

if [ ! -f "${QCONF_PATH}/${QCONF_FILE}" ]
then
    echo "QCONF_FILE ${QCONF_FILE} is not defined. Aborting."
    exit 1
fi

if [ -f /sbin/md5 ]
then
    # FreeBSD uses /sbin/md5
    QCONF_MD5SUM=`/sbin/md5 -q "${QCONF_PATH}/${QCONF_FILE}"`
elif [ -f /usr/bin/md5sum ]
then
    # CentOS uses /usr/bin/md5sum
    QCONF_MD5SUM=`/usr/bin/md5sum "${QCONF_PATH}/${QCONF_FILE}" | cut -d" " -f1`
else
    echo "Could not determine MD5 binary. Aborting."
    exit 1
fi

QCONF_INSECURE_CACHEFILE="/var/tmp/qconf-cache-${QCONF_MD5SUM}"
if [ ! -f "${QCONF_INSECURE_CACHEFILE}" ]
then
    openssl cast5-cbc -d -in "${QCONF_PATH}/${QCONF_FILE}" -out "${QCONF_INSECURE_CACHEFILE}"; chmod 400 "${QCONF_INSECURE_CACHEFILE}"
fi

if [ ! -f "${QCONF_INSECURE_CACHEFILE}" ]
then
    echo "Could not store QCONF cache. Aborting."
    exit 1
fi

if [ "`file ${QCONF_INSECURE_CACHEFILE} | cut -d':' -f2- | grep -i ascii`" == "" ]
then
    rm -f "${QCONF_INSECURE_CACHEFILE}"
    echo "Invalid QCONF. Aborting."
    exit 1
fi

eval `cat "${QCONF_INSECURE_CACHEFILE}" | ./vendor/bin/qconf-exporter.php`
