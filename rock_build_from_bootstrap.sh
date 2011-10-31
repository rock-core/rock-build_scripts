#! /bin/bash

set -ex

export PATH=/home/build/rock_admin_scripts/bin:$PATH
CONFIG_DIR=/home/build/slave_conf

job_basename=`dirname $JOB_NAME`
if test -f $CONFIG_DIR/$job_basename-$FLAVOR.yml; then
  configfile=$CONFIG_DIR/$job_basename-$FLAVOR.yml
else
  configfile=$CONFIG_DIR/default-$FLAVOR.yml
fi

do_incremental=1
if test "x$INCREMENTAL" = "x1"; then
    echo "INCREMENTAL is set, doing an incremental build"
elif test -d dev && ! test -f dev/successful; then
    echo "last build was unsuccessful, doing an incremental build"
else
    echo "doing a full build"
    do_incremental=0
fi

rm -f dev/cleaned
if test "x$do_incremental" = "x1"; then
  $SHELL -ex rock-build-incremental "$@"  $configfile
else
  $SHELL -ex rock-build-server "$@"  $configfile
fi

touch dev/successful

if test "x$CLEAN_IF_SUCCESSFUL" = "x1"; then
    rm -rf dev/install
    find dev -type d -name build -delete
    touch dev/cleaned
fi
